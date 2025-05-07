LinkLuaModifier( "modifier_boss_roshan_amp", "abilities/neutral/boss/boss_roshan_amp", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_roshan_amp_fear", "abilities/neutral/boss/boss_roshan_amp", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_roshan_amp_heal", "abilities/neutral/boss/boss_roshan_amp", LUA_MODIFIER_MOTION_NONE )

boss_roshan_amp = class({})

function boss_roshan_amp:GetChannelTime()
	return self:GetSpecialValueFor("delay")
end

function boss_roshan_amp:OnAbilityPhaseStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    return true 
end

function boss_roshan_amp:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    local caster = self:GetCaster()
end

function boss_roshan_amp:GetChannelAnimation() return ACT_DOTA_GENERIC_CHANNEL_1 end

function boss_roshan_amp:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("delay")
	caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast")
	caster:EmitSound("Hero_Juggernaut.HealingWard.Cast")
	caster:EmitSound("Hero_Juggernaut.HealingWard.Loop")
	self.fx = ParticleManager:CreateParticle("particles/items_fx/healing_flask.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	caster:AddNewModifier(caster, self, "modifier_boss_roshan_amp_heal", {duration = duration})
end


function boss_roshan_amp:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
    local caster = self:GetCaster()
    caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
    caster:StopSound("Hero_Juggernaut.HealingWard.Loop")
    caster:EmitSound("Hero_Juggernaut.HealingWard.Stop")
   ParticleManager:DestroyParticle(self.fx, false)
    if caster:HasModifier("modifier_boss_roshan_amp_heal") then
        caster:RemoveModifierByName("modifier_boss_roshan_amp_heal")
    end

    if not bInterrupted then
    	local duration = self:GetSpecialValueFor("duration")
    	caster:AddNewModifier(caster, self, "modifier_boss_roshan_amp", {duration = duration})
    else
    	local fear_duration = self:GetSpecialValueFor("fear_duration")
    	local units = FindUnitsInRadius(
			caster:GetTeam(),
			caster:GetAbsOrigin(), 
			nil,
			1200,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			true)
	
		for k, unit in pairs(units) do
    		unit:AddNewModifier(caster, self, "modifier_boss_roshan_amp_fear", {duration = fear_duration})
			caster:EmitSound("Hero_DarkWillow.Fear.Location")
		end

    	for i = 0, caster:GetAbilityCount() - 1 do
		    local ability = caster:GetAbilityByIndex(i)
		    if ability and ability:GetCooldown(-1) > 0 then
		    	if ability:GetAbilityName() ~= self:GetAbilityName() then 
		        	ability:EndCooldown()
		    	end
		    end
		end
		-- партикл рефрешера
		local particle = ParticleManager:CreateParticle("particles/custom/neutral/boss/boss_refresh.vpcf", 13, caster)
		ParticleManager:ReleaseParticleIndex(particle)
		caster:EmitSoundParams("Hero_Rattletrap.Overclock.Cast", 0, 0.5, 0)
    end
end

modifier_boss_roshan_amp = class({})

function modifier_boss_roshan_amp:IsPurgable() return true end

function modifier_boss_roshan_amp:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_boss_roshan_amp:OnCreated()
	self:GetParent():EmitSound("Hero_OgreMagi.Bloodlust.Target")
	self:GetParent():EmitSound("Hero_OgreMagi.Bloodlust.Target.FP")
end

function modifier_boss_roshan_amp:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
end

function modifier_boss_roshan_amp:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_boss_roshan_amp:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end

function modifier_boss_roshan_amp:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_boss_roshan_amp:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_magic_res")
end

function modifier_boss_roshan_amp:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
end

function modifier_boss_roshan_amp:OnDestroy()
	if not self:GetCaster() then return end
	self:GetCaster():Purge(false, true, false, true, true)
end

modifier_boss_roshan_amp_fear = {}

function modifier_boss_roshan_amp_fear:OnCreated()
	if not IsServer() then return end

	local hero = self:GetParent()

	local alltowers = {}

	local towerCount = 8 -- текущее кол-во таверов на карте

	for i=1, towerCount do
		local name = "dota_custom"..tostring(i).."_tower_main"
    	local towers = Entities:FindAllByName(name)
    	table.insert(alltowers, towers)
	end

	local targetTower = alltowers[hero:GetTeamNumber()-5]

	if not targetTower then return end
	self:GetParent():MoveToPosition( targetTower[1]:GetOrigin() )

	self:GetParent():EmitSound("Hero_DarkWillow.Fear.Target")
end

function modifier_boss_roshan_amp_fear:OnDestroy()
	if not IsServer() then return end
	self:GetParent():Stop()
end

function modifier_boss_roshan_amp_fear:IsHidden() return true end
function modifier_boss_roshan_amp_fear:IsDebuff() return true end
function modifier_boss_roshan_amp_fear:IsPurgable() return true end

function modifier_boss_roshan_amp_fear:GetEffectName()
    return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_smoke.vpcf"
end

function modifier_boss_roshan_amp_fear:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_boss_roshan_amp_fear:CheckState()
    return {
        [MODIFIER_STATE_FEARED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

function modifier_boss_roshan_amp_fear:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end

function modifier_boss_roshan_amp_fear:GetModifierMoveSpeed_Absolute()
    return 500
end

modifier_boss_roshan_amp_heal = class({})

function modifier_boss_roshan_amp_heal:IsPurgable() return true end

function modifier_boss_roshan_amp_heal:GetEffectName()
	return "particles/items_fx/healing_flask.vpcf"
end

function modifier_boss_roshan_amp_heal:OnCreated(kv)
    self.duration = kv.duration
    self.heal_pct = self:GetAbility():GetSpecialValueFor("heal_pct")
    self.interval = 0.25
    self.heal_amount = self:GetAbility():GetCaster():GetMaxHealth() * (self.heal_pct / 100)
    self.heal_per_interval = self.heal_amount / (self.duration / self.interval)
    self:StartIntervalThink(self.interval)
end

function modifier_boss_roshan_amp_heal:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetAbility():GetCaster()
    caster:Heal(self.heal_per_interval, self:GetAbility())
    SendOverheadEventMessage(nil, 10, caster, self.heal_per_interval, nil)
end