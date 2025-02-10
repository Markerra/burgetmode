LinkLuaModifier("modifier_troll_skelet_aura_c", "abilities/neutral/waves/troll_skelet_aura_c", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_troll_skelet_aura_c_aura", "abilities/neutral/waves/troll_skelet_aura_c", LUA_MODIFIER_MOTION_NONE)

troll_skelet_aura_c = class({})

function troll_skelet_aura_c:GetIntrinsicModifierName()
    return "modifier_troll_skelet_aura_c"
end


modifier_troll_skelet_aura_c = class({})

function modifier_troll_skelet_aura_c:IsAura()
    return true
end

function modifier_troll_skelet_aura_c:GetModifierAura()
    return "modifier_troll_skelet_aura_c_aura"
end

function modifier_troll_skelet_aura_c:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_troll_skelet_aura_c:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_troll_skelet_aura_c:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC
end

function modifier_troll_skelet_aura_c:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_troll_skelet_aura_c:IsHidden()
    return true
end

function modifier_troll_skelet_aura_c:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT
    }
end

function modifier_troll_skelet_aura_c:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("self_bonus_evasion")
end


modifier_troll_skelet_aura_c_aura = class({})

function modifier_troll_skelet_aura_c_aura:IsHidden() return false end

function modifier_troll_skelet_aura_c_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EVASION_CONSTANT
    }
end

function modifier_troll_skelet_aura_c_aura:GetModifierEvasion_Constant()

    if self:GetCaster():PassivesDisabled() then return end

    local units = {}
    local parent = self:GetParent()
    local radius = self:GetAbility():GetSpecialValueFor("radius")
    local bonus = false

    if IsServer() then
        units = FindUnitsInRadius(
            parent:GetTeam(),
            parent:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            true)
    end
    for k, v in pairs(units) do
        if v:GetUnitName() == parent:GetUnitName() then
            bonus = true
        end
    end
    if bonus then return (self:GetAbility():GetSpecialValueFor("bonus_evasion") * #units) - (2 * #units)
    else
        return self:GetAbility():GetSpecialValueFor("bonus_evasion")
    end
end