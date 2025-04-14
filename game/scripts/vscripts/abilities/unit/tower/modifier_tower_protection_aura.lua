LinkLuaModifier("modifier_tower_protection", "abilities/unit/tower/modifier_tower_protection_aura", LUA_MODIFIER_MOTION_NONE)

modifier_tower_protection_aura = class({})

function modifier_tower_protection_aura:IsHidden()
    return true
end

function modifier_tower_protection_aura:IsAura()
    return true
end

function modifier_tower_protection_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_tower_protection_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_tower_protection_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_tower_protection_aura:GetModifierAura()
    return "modifier_tower_protection"
end

modifier_tower_protection = class({})

function modifier_tower_protection:OnCreated()
    local caster = self:GetCaster()
    if caster:PassivesDisabled() then 
        caster:RemoveModifierByName("modifier_tower_protection")
        return
    end
end

function modifier_tower_protection:IsHidden()
    return false
end

function modifier_tower_protection:IsDebuff()
    return true
end

function modifier_tower_protection:IsPurgable()
    return false
end

function modifier_tower_protection:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,   -- Замедление
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,   -- Снижение урона
    }
end

function modifier_tower_protection:GetModifierMoveSpeedBonus_Percentage()
    local slow = self:GetAbility():GetSpecialValueFor("slow_percent")
    return -slow 
end

function modifier_tower_protection:GetModifierDamageOutgoing_Percentage()
    local damage = self:GetAbility():GetSpecialValueFor("incoming_damage_percent")
    return -damage  -- Уменьшение урона на 50%
end

    