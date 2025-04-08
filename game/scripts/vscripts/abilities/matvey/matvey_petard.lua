LinkLuaModifier("modifier_matvey_petard_debuff", "abilities/matvey/matvey_petard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_matvey_petard_buff", "abilities/matvey/matvey_petard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_unselect", "modifiers/modifier_unselect", LUA_MODIFIER_MOTION_NONE )

local tracking_interval = 0.01
_G.ActiveHomingMissiles = {}

matvey_petard = class({})

function matvey_petard:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES 
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end

end

function matvey_petard:OnSpellStart()

	self.waitAmount = 1.01

    local caster = self:GetCaster()
	if caster:HasScepter() then
		
		local enemies = FindUnitsInRadius(caster:GetTeam(), self:GetCursorPosition(), nil, 200,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		if #enemies > 0 then
			self.target = enemies[1]
		else
			self.target = CreateUnitByName("npc_dota_companion", self:GetCursorPosition(), false, nil, nil, 0)
			self.target:AddNewModifier(self.target, nil, "modifier_phased", {})
			self.target:AddNewModifier(self.target, nil, "modifier_invulnerable", {})
			self.target:AddNewModifier(self.target, nil, "modifier_unselect", {})
		end

	else self.target = self:GetCursorTarget() end

    local velocity = self:GetSpecialValueFor("projectile_speed") / 10
    local damage = self:GetSpecialValueFor("damage")
    local health = self:GetSpecialValueFor("petard_health")

    if #_G.ActiveHomingMissiles ~= nil then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == nil and _G.ActiveHomingMissiles[i].Enemy == self.target then 
				_G.ActiveHomingMissiles[i].Rocket = self
			end
		end
	end

	--InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage, health)
    self:InitialiseRocket(velocity, 0.01, 50, 900, damage, health)
	self:SetActivated(false)
    self:EndCooldown()

	Timers:CreateTimer(self.waitAmount + 2.9, function()
		local blink = caster:FindAbilityByName("matvey_petard_blink")
		blink:SetActivated(true)
	end)

end

function matvey_petard:InitialiseRocket(velocity, acceleration, detonationRadius, aoeRadius, damage, health)
    local vec_distance = self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    local distance = (vec_distance):Length2D()
    local direction = (vec_distance):Normalized()

	targetLocationCopy = shallowcopy(self.target:GetAbsOrigin())	
    local rocket = {
    	velocity = velocity,
    	location = self:GetCaster():GetAbsOrigin(),
    	target = self.target,
    	target_lastKnownLocation = targetLocationCopy,
    	direction = direction,
    }
    
    local missile = CreateUnitByName("npc_matvey_petard_missile", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	
	if self:GetCaster():HasScepter() then
		self.missile = missile
	end

	if IsServer() then
    	missile:SetMaxHealth(health)
		missile:SetHealth(health)
	end
  
    if self:GetLevel() == 1 then
		missile:SetModelScale(1.0)
	end
	if self:GetLevel() == 2 then
		missile:SetModelScale(1.10)
	end
	if self:GetLevel() == 3 then
		missile:SetModelScale(1.20)
	end
	if self:GetLevel() == 4 then
		missile:SetModelScale(1.30)
	end

    EmitSoundOn("Hero_Gyrocopter.HomingMissile", missile)

	if #_G.ActiveHomingMissiles ~= nil then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == self then
				_G.ActiveHomingMissiles[i].MissileUnit = missile
			end
		end
	end

    local tickCount = 0
    Timers:CreateTimer(function()
			if not missile then return end
            if missile:GetHealth() <= 0 then -- ROCKET DESTROY
				local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), rocket.location, nil, aoeRadius,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
				for _, enemy in pairs(enemies) do 
					ApplyDamage({
						victim = enemy,
						attacker = self:GetCaster(),
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = self,
					})
					local duration = self:GetSpecialValueFor("stun_duration")
					enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = duration})
                end
				
				local blink = self:GetCaster():FindAbilityByName("matvey_petard_blink")
				blink:SetActivated(false)

				self:SetActivated(true)
				self:StartCooldown(self:GetCooldown(self:GetLevel()))

                local exp = ParticleManager:CreateParticle( "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_POINT, rocket.target )
                ParticleManager:SetParticleControl(exp, 3, missile:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(exp)
                EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Explode", missile)
                StopSoundOn("Hero_Gyrocopter.HomingMissile", missile)
                missile:Destroy()
            end

            if GameRules:IsGamePaused() then return 0.1 end

    		tickCount = tickCount + 1
		
			if tickCount < self.waitAmount / tracking_interval then
				return tracking_interval;  --do nothing until the missile animation is ready to be moved.
			end				
			
            vec_distance = self.target:GetAbsOrigin() - rocket.location
            rocket.distance = (vec_distance):Length2D()
            rocket.direction = (vec_distance):Normalized()
            rocket.target_lastKnownLocation = shallowcopy(self.target:GetAbsOrigin())	

			rocket.velocity = rocket.velocity + acceleration
			rocket.location = rocket.location + rocket.direction * rocket.velocity
			missile:SetForwardVector(rocket.direction)
			missile:SetAbsOrigin(rocket.location)		
			distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()

			if distance < detonationRadius * 1.5 then
			end
    		if ( distance < detonationRadius ) then -- ROCKET HITS TARGET
    			
				local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), rocket.location, nil, 50,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
				for _,enemy in pairs(enemies) do 
                    local duration = self:GetSpecialValueFor("duration")
					if enemy:GetMaxMana() > 0 and not enemy:IsCreep() then
                    	enemy:AddNewModifier(self:GetCaster(), self, "modifier_matvey_petard_debuff", {duration = duration})
						local p = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_POINT, enemy )
						ParticleManager:ReleaseParticleIndex(p)
					end

                end
				
				StopSoundOn("Hero_Gyrocopter.HomingMissile", missile)

                local missile_hp = missile:GetHealth()
                local missile_maxhp = missile:GetMaxHealth()

				if self:GetCaster():HasScepter() and self.target:GetUnitName() == "npc_dota_companion" then
					self.target:Destroy()
					local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), rocket.location, nil, 30,
					DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
					for _, enemy in pairs(enemies) do 
						ApplyDamage({
							victim = enemy,
							attacker = self:GetCaster(),
							damage = damage,
							damage_type = DAMAGE_TYPE_MAGICAL,
							ability = self,
						})
						local duration = self:GetSpecialValueFor("stun_duration")
						enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = duration})
					end
	
					local exp = ParticleManager:CreateParticle( "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
					ParticleManager:SetParticleControl(exp, 3, rocket.location)
					ParticleManager:ReleaseParticleIndex(exp)
					EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Explode", missile)
					StopSoundOn("Hero_Gyrocopter.HomingMissile", missile)
				else
					local new_caster = self.target
					self.target = self:GetCaster()
					--InitialiseRocket2(caster, velocity, acceleration, detonationRadius, aoeRadius, mana, health, max_health)
					self:InitialiseRocket2(new_caster, velocity, acceleration, detonationRadius, aoeRadius, mana, missile_hp, missile_maxhp)
				end

				missile:Destroy()

				local blink = self:GetCaster():FindAbilityByName("matvey_petard_blink")
				blink:SetActivated(false)

				self:SetActivated(true)
				self:StartCooldown(self:GetCooldown(self:GetLevel()))

				for i = 1, #_G.ActiveHomingMissiles, 1 do
					if _G.ActiveHomingMissiles[i].Rocket == self then
						_G.ActiveHomingMissiles[i] = nil 
					end
				end
    			return 
    		end			

			if #_G.ActiveHomingMissiles > 0 then
				for i = 1, #_G.ActiveHomingMissiles, 1 do
					if _G.ActiveHomingMissiles[i].Enemy == rocket.target then
						if _G.ActiveHomingMissiles[i].Location == rocket.target_lastKnownLocation then --do nothing if the location is the same as last time
						else 
							rocket.target_lastKnownLocation = shallowcopy(_G.ActiveHomingMissiles[i].Location)
							vec_distance = rocket.target_lastKnownLocation - rocket.location
				    		distance = (vec_distance):Length2D()
				    		rocket.direction = (vec_distance):Normalized()
						end
					end
				end
				else
			end
    		return tracking_interval;
	end)
end

function matvey_petard:InitialiseRocket2(caster, velocity, acceleration, detonationRadius, aoeRadius, mana, health, max_health)
    local vec_distance = self.target:GetAbsOrigin() - caster:GetAbsOrigin()
    local distance = (vec_distance):Length2D()
    local direction = (vec_distance):Normalized()

	targetLocationCopy = shallowcopy(self.target:GetAbsOrigin())	
    local rocket = {
    	velocity = velocity,
    	location = caster:GetAbsOrigin(),
    	target = self.target,
    	target_lastKnownLocation = targetLocationCopy,
    	direction = direction,
    }
    
    local missile = CreateUnitByName("npc_matvey_petard_missile", self.target:GetAbsOrigin(), true, self.target, self.target, self.target:GetTeamNumber())
	
	if IsServer() then
		missile:SetHealth(health)
    	missile:SetMaxHealth(max_health)
	end
  
    if self:GetLevel() == 1 then
		missile:SetModelScale(1.0)
	end
	if self:GetLevel() == 2 then
		missile:SetModelScale(1.10)
	end
	if self:GetLevel() == 3 then
		missile:SetModelScale(1.20)
	end
	if self:GetLevel() == 4 then
		missile:SetModelScale(1.30)
	end

    local p = ParticleManager:CreateParticle( "particles/custom/matvey/matvey_petard/rubick_spell_steal_default.vpcf", PATTACH_POINT, missile )
    ParticleManager:SetParticleControl(p, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(p, 1, missile:GetAbsOrigin())
    EmitSoundOn("Hero_Rubick.SpellSteal.Target", self.target)

	if #_G.ActiveHomingMissiles ~= nil then
		for i = 1, #_G.ActiveHomingMissiles, 1 do
			if _G.ActiveHomingMissiles[i].Rocket == self then
				_G.ActiveHomingMissiles[i].MissileUnit = missile
			end
		end
	end

    local tickCount = 0
    Timers:CreateTimer(function()

            if GameRules:IsGamePaused() then return 0.1 end

            if missile:GetHealth() <= 0 then
				local enemies = FindUnitsInRadius(self.target:GetTeam(), rocket.location, nil, aoeRadius,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
				for _, enemy in pairs(enemies) do 
					ApplyDamage({
						victim = enemy,
						attacker = self.target,
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = self,
					})
					local duration = self:GetSpecialValueFor("stun_duration")
					enemy:AddNewModifier(self.target, self, "modifier_stunned", {duration = duration})

				end

				self:SetActivated(true)
				self:StartCooldown(self:GetCooldown(self:GetLevel()))
		
				local exp = ParticleManager:CreateParticle( "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_POINT, rocket.target )
				ParticleManager:SetParticleControl(exp, 3, missile:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(exp)
				EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Explode", missile)
				StopSoundOn("Hero_Gyrocopter.HomingMissile", missile)
                local modif = caster:HasModifier("modifier_matvey_petard_debuff")
                if modif then caster:RemoveModifierByName("modifier_matvey_petard_debuff") end
                missile:Destroy()
            end

    		tickCount = tickCount +1

            missile:StartGesture(ACT_DOTA_IDLE)

            vec_distance = self.target:GetAbsOrigin() - rocket.location
            rocket.distance = (vec_distance):Length2D()
            rocket.direction = (vec_distance):Normalized()
            rocket.target_lastKnownLocation = shallowcopy(self.target:GetAbsOrigin())	

			rocket.velocity = rocket.velocity + acceleration
			rocket.location = rocket.location + rocket.direction * rocket.velocity
			missile:SetForwardVector(rocket.direction)
			missile:SetAbsOrigin(rocket.location)		
			distance = (rocket.target_lastKnownLocation - rocket.location):Length2D()

    		if ( distance < detonationRadius ) then -- ROCKET 2 HITS TARGET
    			
				local enemies = FindUnitsInRadius(self.target:GetTeam(), rocket.location, nil, aoeRadius,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
				for _,enemy in pairs(enemies) do 
					local enemyDistance = (enemy:GetAbsOrigin() - rocket.location):Length2D()
                    local modif = caster:FindModifierByName("modifier_matvey_petard_debuff")
                    if modif then
                        local duration = modif:GetRemainingTime()
                        local mana = modif.mana
                        enemy:AddNewModifier(self.target, self, "modifier_matvey_petard_buff", {duration = duration, mana = mana})
                        EmitSoundOn("Hero_Rubick.SpellSteal.Complete", self.target)
                        local p2 = ParticleManager:CreateParticle( "particles/custom/matvey/matvey_petard/rubick_spell_steal_default.vpcf", PATTACH_POINT, missile )
                        ParticleManager:SetParticleControl(p2, 0, self.target:GetAbsOrigin())
                        ParticleManager:SetParticleControl(p2, 1, missile:GetAbsOrigin())
                    end
                end

				self:SetActivated(true)
				self:StartCooldown(self:GetCooldown(self:GetLevel()))
                
				missile:Destroy()

				for i = 1, #_G.ActiveHomingMissiles, 1 do
					if _G.ActiveHomingMissiles[i].Rocket == self then
						_G.ActiveHomingMissiles[i] = nil 
					end
				end
    			return 
    		end			

			if #_G.ActiveHomingMissiles > 0 then
				for i = 1, #_G.ActiveHomingMissiles, 1 do
					if _G.ActiveHomingMissiles[i].Enemy == rocket.target then
						if _G.ActiveHomingMissiles[i].Location == rocket.target_lastKnownLocation then --do nothing if the location is the same as last time
						else 
							rocket.target_lastKnownLocation = shallowcopy(_G.ActiveHomingMissiles[i].Location)
							vec_distance = rocket.target_lastKnownLocation - rocket.location
				    		distance = (vec_distance):Length2D()
				    		rocket.direction = (vec_distance):Normalized()
						end
					end
				end
				else
			end
    		return tracking_interval;
	end)
end

function matvey_petard:FindNearestEnemy()
	--something like:
		local enemies = FindUnitsInRadius(
		DOTA_TEAM_BADGUYS,
		thisEntity:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false )
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else
        copy = orig
    end
    return copy
end

modifier_matvey_petard_debuff = class({})

function modifier_matvey_petard_debuff:IsPurgable() return false end
function modifier_matvey_petard_debuff:IsDebuff() return true end

function modifier_matvey_petard_debuff:OnCreated()
    self:SetHasCustomTransmitterData(true)

	local mana_pct = self:GetAbility():GetSpecialValueFor("mana_steal_pct")
    local max_mana = self:GetParent():GetMaxMana()
	self.mana = math.floor(max_mana * (mana_pct / 100))

	
	if IsServer() then
	    self:SendBuffRefreshToClients()
		self:SetStackCount(self.mana)
    end
end

function modifier_matvey_petard_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end

function modifier_matvey_petard_debuff:AddCustomTransmitterData()
	return {
		mana = self.mana
	}
end

function modifier_matvey_petard_debuff:HandleCustomTransmitterData(data)
	self.mana = data.mana
end

function modifier_matvey_petard_debuff:GetModifierManaBonus()
	return -self.mana
end

modifier_matvey_petard_buff = class({})

function modifier_matvey_petard_buff:IsPurgable() return false end
function modifier_matvey_petard_buff:IsDebuff() return false end

function modifier_matvey_petard_buff:OnCreated(kv)
    self:SetHasCustomTransmitterData(true)

	self.mana = kv.mana
	
	if IsServer() then
	    self:SendBuffRefreshToClients()
		self:SetStackCount(self.mana)
    end
end

function modifier_matvey_petard_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end

function modifier_matvey_petard_buff:AddCustomTransmitterData()
	return {
		mana = self.mana
	}
end

function modifier_matvey_petard_buff:HandleCustomTransmitterData(data)
	self.mana = data.mana
end

function modifier_matvey_petard_buff:GetModifierManaBonus()
	return self.mana
end