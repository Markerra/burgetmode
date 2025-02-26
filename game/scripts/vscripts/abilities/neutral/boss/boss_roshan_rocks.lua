require("utils/timers")

LinkLuaModifier("modifier_boss_roshan_rocks", "abilities/neutral/boss/boss_roshan_rocks", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_roshan_rocks_debuff", "abilities/neutral/boss/boss_roshan_rocks", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_roshan_rocks_stun", "abilities/neutral/boss/boss_roshan_rocks", LUA_MODIFIER_MOTION_NONE)

boss_roshan_rocks = class({})

function boss_roshan_rocks:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	FadeGesture(ACT_DOTA_CAST_ABILITY_1)
	StopSoundOn("Roshan.RevengeRoar.Local", caster)
end

function boss_roshan_rocks:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_boss_roshan_rocks", {})
end

modifier_boss_roshan_rocks = class({})

function modifier_boss_roshan_rocks:IsHidden() return true end
function modifier_boss_roshan_rocks:IsDebuff() return false end
function modifier_boss_roshan_rocks:IsPurgable() return false end

function modifier_boss_roshan_rocks:OnCreated()
    if not IsServer() then return end

    self.ability  = self:GetAbility()
    self.caster   = self:GetCaster()
    self.radius   = self.ability:GetSpecialValueFor("radius")
    self.interval = self.ability:GetSpecialValueFor("repeat")
    self.damage   = self.ability:GetSpecialValueFor("damage")

	self.slow_duration = self.ability:GetSpecialValueFor("slow_duration")
    self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")

    self.amout = self.ability:GetSpecialValueFor("amout")

    local times_repeat = 0
    local times_repeat_max = RandomInt(2, 3)
    Timers:CreateTimer(0, function() 
    	local rtype = times_repeat + 1
    	local rnd =  RandomInt(0, 8)
    	if rtype >= 2 then rnd = 10 end
    	for i=1, self.amout + rnd do
    		if self.caster:GetHealthPercent() <= 40 or self.caster:IsChanneling() then
    			self:CreateRock(RandomInt(10, 1500), RandomFloat(0, 360), rtype)
    		else
    			self:CreateRock(RandomInt(250, 2700), RandomFloat(0, 360), rtype)
    		end
		end
		times_repeat = times_repeat + 1
		if times_repeat >= times_repeat_max then 
			self:GetParent():RemoveModifierByName("modifier_boss_roshan_rocks")
			return end
		return self.interval
	end)
    Timers:CreateTimer(0.3, function()
    	ScreenShake(self.caster:GetAbsOrigin(), 250, 1.3, self.ability:GetCastPoint(), 4100, 0, true)
		EmitSoundOn("Roshan.RevengeRoar.Local", self.caster)
	end)
end

function modifier_boss_roshan_rocks:CreateRock(radius_offset, angle_offset, rtype)
	if not IsServer() then return end

	local caster  = self:GetCaster()
	local ability = self:GetAbility()
	local damage  = self.damage
	local stun_duration = self.stun_duration
	local delay   = self.ability:GetSpecialValueFor("delay")

	local angle    = angle_offset or 0
	local position = caster:GetAbsOrigin() + Vector(math.cos(angle), math.sin(angle), 0) * (self.radius + (radius_offset or 0))

	self.ground_particle = ParticleManager:CreateParticle("particles/custom/neutral/boss/boss_roshan_rocks_precast.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.ground_particle, 0, position)
	ParticleManager:SetParticleControl(self.ground_particle, 2, Vector(self.radius, 0, 0))
	ParticleManager:SetParticleControl(self.ground_particle, 3, Vector(delay, 0, 0))

	if rtype >= 2 then
		ParticleManager:SetParticleControl(self.ground_particle, 1, Vector(170, 0, 0))
		damage = self.damage + self.damage / 4
		stun_duration = self.stun_duration + self.stun_duration / 2
	end

	Timers:CreateTimer(delay, function()
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_primal_beast/primal_beast_rock_throw_impact.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(particle, 3, position)
		ParticleManager:ReleaseParticleIndex(particle)

		if IsServer() then
		ParticleManager:DestroyParticle(self.ground_particle, true)
		ParticleManager:ReleaseParticleIndex(self.ground_particle)
		end

		EmitSoundOn("Hero_PrimalBeast.RockThrow.Impact", caster)

		local enemies = FindUnitsInRadius(
		    caster:GetTeamNumber(),
		    position,
		    nil,
		    self.radius - 5,
		    DOTA_UNIT_TARGET_TEAM_ENEMY,
		    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		    DOTA_UNIT_TARGET_FLAG_NONE,
		    FIND_ANY_ORDER,
		    false
		)

		for _, enemy in pairs(enemies) do
			ApplyDamage({
		        victim = enemy,
		        attacker = caster,
		        damage = damage,
		        damage_type = DAMAGE_TYPE_MAGICAL,
		        ability = ability
		    })
			if not enemy:IsDebuffImmune() then
				if rtype > 1 then
				enemy:AddNewModifier(caster, ability, "modifier_boss_roshan_rocks_stun", {duration = self.stun_duration})
				end
				enemy:AddNewModifier(caster, ability, "modifier_boss_roshan_rocks_debuff", {duration = self.slow_duration})
			end

			EmitSoundOn("Hero_PrimalBeast.RockThrow.Stun", enemy)

			if IsServer() then
			local hp = (damage * enemy:GetBaseMagicalResistanceValue() / 100) * (self.ability:GetSpecialValueFor("heal_pct") / 100)
			caster:Heal(hp, self.ability)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, hp, nil)

		    local rock_hit = "particles/units/heroes/hero_primal_beast/primal_beast_rock_throw_impact.vpcf"
		    local particle = ParticleManager:CreateParticle(rock_hit, PATTACH_ABSORIGIN_FOLLOW, caster)
		    ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
		    ParticleManager:ReleaseParticleIndex(particle)
			end
		end

		ScreenShake(position, 500, 0.4, 0.7, self.radius, 0, true)
	end)
end

modifier_boss_roshan_rocks_debuff = class({})

function modifier_boss_roshan_rocks_debuff:IsDebuff() return true end
function modifier_boss_roshan_rocks_debuff:IsPurgable() return true end

function modifier_boss_roshan_rocks_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_boss_roshan_rocks_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow") * (-1)
end

modifier_boss_roshan_rocks_stun = class({})

function modifier_boss_roshan_rocks_stun:IsDebuff() return true end
function modifier_boss_roshan_rocks_stun:IsPurgable() return true end

function modifier_boss_roshan_rocks_stun:OnCreated()
	if not IsServer() then return end
	local fx = "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_stunned_symbol.vpcf"
	self.particle = ParticleManager:CreateParticle(fx, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
end

function modifier_boss_roshan_rocks_stun:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.particle, false)
	ParticleManager:ReleaseParticleIndex(self.particle)
end

function modifier_boss_roshan_rocks_stun:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end