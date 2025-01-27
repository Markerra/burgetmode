LinkLuaModifier("modifier_tower_soul_drain", "abilities/unit/tower/tower_soul_drain", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tower_soul_drain_debuff", "abilities/unit/tower/tower_soul_drain", LUA_MODIFIER_MOTION_NONE)

tower_soul_drain = class({})

function tower_soul_drain:GetIntrinsicModifierName()
    return "modifier_tower_soul_drain"
end

modifier_tower_soul_drain = class({})

function modifier_tower_soul_drain:IsPurgable() return false end

function modifier_tower_soul_drain:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_tower_soul_drain:OnAttackLanded(data)
    if self:GetCaster():PassivesDisabled() then return end
    if not IsServer() then return end
    if self:GetParent() == data.attacker then
        local target = data.target
        local duration = self:GetAbility():GetSpecialValueFor("duration")
        target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_tower_soul_drain_debuff", {duration = duration})
    end
end

modifier_tower_soul_drain_debuff = class({})

function modifier_tower_soul_drain_debuff:IsPurgable() return false end

function modifier_tower_soul_drain_debuff:OnCreated()
    self.heal_reduction = self:GetAbility():GetSpecialValueFor("hp_regen_pct")
    self.slow_percent   = self:GetAbility():GetSpecialValueFor("slow_pct")

    if not IsServer() then return end

    local parent = self:GetParent()
    self.particle = ParticleManager:CreateParticle("particles/econ/events/ti8/shivas_guard_ti8_slow.vpcf", 1, parent)
end

function modifier_tower_soul_drain_debuff:OnDestroy()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.particle, false)
end

function modifier_tower_soul_drain_debuff:DeclareFunctions()
    return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
    }
end

function modifier_tower_soul_drain_debuff:GetModifierMoveSpeedBonus_Percentage()
    return ( self.slow_percent * (-1) )
end

function modifier_tower_soul_drain_debuff:GetModifierHPRegenAmplify_Percentage()
    return ( self.heal_reduction * (-1) )
end
