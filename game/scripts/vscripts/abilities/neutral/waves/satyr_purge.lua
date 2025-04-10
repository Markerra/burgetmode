LinkLuaModifier("modifier_satyr_purge_debuff", "abilities/neutral/waves/satyr_purge", LUA_MODIFIER_MOTION_NONE)

satyr_purge = class({})

function satyr_purge:OnAbilityPhaseStart()
	self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
end

function satyr_purge:OnAbilityPhaseInterrupted()
	self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
end

function satyr_purge:OnSpellStart()
    if not IsServer() then return end
    
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local damage = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")

    target:Purge(true, false, false, false, false)

    ApplyDamage({
		victim=target,
		attacker=caster,
		damage=damage,
		damage_type=self:GetAbilityDamageType(),
		ability=self,
	})

    local particle = "particles/generic_gameplay/generic_purge.vpcf"
	self.effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(self.effect)
	target:EmitSound("n_creep_SatyrTrickster.Cast")

    target:AddNewModifier(caster, self, "modifier_satyr_purge_debuff", {duration = duration})
end

modifier_satyr_purge_debuff = class({})

function modifier_satyr_purge_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_satyr_purge_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_satyr_purge_debuff:IsDebuff()
    return true
end

function modifier_satyr_purge_debuff:IsPurgable()
    return true
end

function modifier_satyr_purge_debuff:IsHidden()
    return false
end
