LinkLuaModifier("modifier_ghoul_infest", "abilities/neutral/waves/ghoul_infest", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ghoul_infest_ally", "abilities/neutral/waves/ghoul_infest", LUA_MODIFIER_MOTION_NONE)

ghoul_infest = class({})

function ghoul_infest:GetCastPoint()
    if self:GetCaster():HasModifier("modifier_ghoul_infest") then
        return 0
    else
        return 0.2
    end
end

function ghoul_infest:GetManaCost(iLvl)
    if self:GetCaster():HasModifier("modifier_ghoul_infest") then
        return 0
    else
        return self.BaseClass.GetManaCost( self, iLvl )
    end
end

function ghoul_infest:GetCooldown(iLvl)
    if self:GetCaster():HasModifier("modifier_ghoul_infest") or IsClient() then
        return self.BaseClass.GetCooldown( self, iLvl )
    else
        return 0
    end
end

function ghoul_infest:GetCastAnimation()
    if self:GetCaster():HasModifier("modifier_ghoul_infest") then
        return ACT_DOTA_LIFESTEALER_INFEST
    else
        return ACT_DOTA_LIFESTEALER_INFEST_END
    end
end

function ghoul_infest:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_ghoul_infest") then
        return "life_stealer_consume"
    else
        return "life_stealer_infest"
    end
end

function ghoul_infest:GetBehavior()
    if self:GetCaster():HasModifier("modifier_ghoul_infest") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function ghoul_infest:OnOwnerDied()
    if self.target then
        self.target:RemoveModifierByName("modifier_ghoul_infest_ally")
    end
end

function ghoul_infest:CastFilterResultTarget(hTarget)
	if hTarget == self:GetCaster() then
		return UF_FAIL_CUSTOM
	--elseif hTarget:HasAbility(self:GetAbilityName()) then
	--	return UF_FAIL_CUSTOM
	--elseif hTarget:HasModifier("modifier_ghoul_infest_ally") then
	--	return UF_FAIL_CUSTOM
	else
		return UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, self:GetCaster():GetTeamNumber() )
	end
end

function ghoul_infest:GetCustomCastErrorTarget(hTarget)
	if hTarget == self:GetCaster() then
		--print("Способность не может быть использована на себя")
		return "Способность не может быть использована на себя"
	--elseif hTarget:HasAbility(self:GetAbilityName()) then
	--	print("Способность не может быть использована на это существо")
	--	return "Способность не может быть использована на это существо"
	--elseif hTarget:HasModifier("modifier_ghoul_infest_ally") then
	--	print("Способность не может быть использована повторно")
	--	return "Способность не может быть использована повторно"
	end
end

function ghoul_infest:OnSpellStart()
    local caster = self:GetCaster()

    self.target = self:GetCursorTarget()
    if self:GetCursorTarget():HasModifier("modifier_ghoul_infest_ally") then
		self.mod2 = self.target:FindModifierByName("modifier_ghoul_infest_ally")
		self.mod2:SetStackCount(self.mod2:GetStackCount()+1)
	else
		if self.target:GetTeamNumber() == caster:GetTeamNumber() then
			self.mod2 = self.target:AddNewModifier(caster, self, "modifier_ghoul_infest_ally", {})
			self.targetEmitSound("Hero_LifeStealer.Infest")
			self.mod2:SetStackCount(1)
		end
	end

    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf", PATTACH_POINT, self.target)
    ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, self.target:GetAbsOrigin())

	if IsServer() then self.mod1 = caster:AddNewModifier(caster, self, "modifier_ghoul_infest", {}) end
end

modifier_ghoul_infest = class({})

function modifier_ghoul_infest:OnCreated()	
	if IsServer() then
		self.target = self:GetAbility():GetCursorTarget()
        self:GetParent():AddNoDraw()
        self:StartIntervalThink(FrameTime())
        self:GetAbility():SetActivated(false)
    end
end

function modifier_ghoul_infest:OnRemoved()
    if IsServer() then
    	self:GetAbility():SetActivated(true)
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = 450
        parent:RemoveNoDraw()
        local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, ability.target)
        ParticleManager:SetParticleControl(fx, 0, ability.target:GetAbsOrigin())
        FindClearSpaceForUnit(parent, parentPos, false)
        local enemies = FindUnitsInRadius(
			parent:GetTeam(),
			parent:GetAbsOrigin(), 
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			true)
        for _,enemy in pairs(enemies) do
        	local dmg = self:GetAbility():GetSpecialValueFor("aoe_damage")
        	if not enemy or not parent or not dmg then print("ZZZ") end
        	local mod2 = ability.target:FindModifierByName("modifier_ghoul_infest_ally")
        	if mod2:GetStackCount() > 0 then dmg = dmg * mod2:GetStackCount() end
        	ApplyDamage({
        		victim=enemy,
        		attacker=parent,
        		damage=dmg,
        		damage_type=self:GetAbility():GetAbilityDamageType(),
        		ability=self:GetAbility(),
        	})
        end
        ability.target:RemoveModifierByName("modifier_ghoul_infest_ally")
        self:GetCaster():ForceKill( false )
    end
	self:GetCaster():EmitSound("Hero_LifeStealer.Consume")
	ScreenShake(parentPos, 300, 1.1, 0.7, 1200, 0, true)
end

function modifier_ghoul_infest:OnIntervalThink()
	if self:GetParent() == nil or self:GetCaster() == nil then return end 
	if self:GetAbility().target and self:GetAbility().target:IsAlive() and self:GetRemainingTime() > 0.1 then
		self:GetCaster():SetAbsOrigin(self:GetAbility().target:GetAbsOrigin())
	end
end

function modifier_ghoul_infest:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_ROOTED] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true}
    return state
end

function modifier_ghoul_infest:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE }
end

function modifier_ghoul_infest:IsHidden()
    return true
end

function modifier_ghoul_infest:IsDebuff()
    return false
end

function modifier_ghoul_infest:IsPurgable()
    return false
end


modifier_ghoul_infest_ally = class({})

function modifier_ghoul_infest_ally:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local hp = caster:GetHealth() * (self:GetAbility():GetSpecialValueFor("heal_amt") / 100)
		parent:Heal( hp, self:GetAbility() )
		SendOverheadEventMessage(nil, 10, parent, hp, nil)
	end
end

function modifier_ghoul_infest_ally:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ghoul_infest_ally:OnDeath( params )
	if params.unit == self:GetParent() then
		self:GetAbility():GetCaster():RemoveModifierByName("modifier_ghoul_infest")
	end
end

function modifier_ghoul_infest_ally:GetModifierHealthBonus()
	return self:GetAbility():GetCaster():GetHealth() * (self:GetAbility():GetSpecialValueFor("bonus_health") / 100)
end

function modifier_ghoul_infest_ally:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg") * self:GetStackCount()
end

function modifier_ghoul_infest_ally:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_ms") * self:GetStackCount()
end

function modifier_ghoul_infest_ally:IsDebuff()
    return false
end

function modifier_ghoul_infest_ally:IsPurgable()
    return false
end

function modifier_ghoul_infest_ally:GetEffectName()
    return "particles/units/heroes/hero_life_stealer/life_stealer_infested_unit.vpcf"
end

function modifier_ghoul_infest_ally:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end