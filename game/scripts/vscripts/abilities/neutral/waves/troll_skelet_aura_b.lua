LinkLuaModifier("modifier_troll_skelet_aura_b", "abilities/neutral/waves/troll_skelet_aura_b", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_troll_skelet_aura_b_aura", "abilities/neutral/waves/troll_skelet_aura_b", LUA_MODIFIER_MOTION_NONE)

troll_skelet_aura_b = class({})

function troll_skelet_aura_b:GetIntrinsicModifierName()
    return "modifier_troll_skelet_aura_b"
end

modifier_troll_skelet_aura_b = class({})

function modifier_troll_skelet_aura_b:IsAura()
    return true
end

function modifier_troll_skelet_aura_b:GetModifierAura()
    return "modifier_troll_skelet_aura_b_aura"
end

function modifier_troll_skelet_aura_b:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_troll_skelet_aura_b:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_troll_skelet_aura_b:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC
end

function modifier_troll_skelet_aura_b:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_troll_skelet_aura_b:IsHidden()
    return true
end

modifier_troll_skelet_aura_b_aura = class({})

function modifier_troll_skelet_aura_b_aura:IsHidden() return false end

function modifier_troll_skelet_aura_b_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_troll_skelet_aura_b_aura:GetModifierPhysicalArmorBonus()

    if self:GetCaster():PassivesDisabled() then return end
    
    local units = {}
    local parent = self:GetParent()
    if not parent then return end
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
    if bonus then return (self:GetAbility():GetSpecialValueFor("bonus_armor") * #units) - (2 * #units)
    else
        return self:GetAbility():GetSpecialValueFor("bonus_armor")
    end
end