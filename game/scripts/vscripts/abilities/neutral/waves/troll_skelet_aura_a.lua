LinkLuaModifier("modifier_troll_skelet_aura_a", "abilities/neutral/waves/troll_skelet_aura_a", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_troll_skelet_aura_a_aura", "abilities/neutral/waves/troll_skelet_aura_a", LUA_MODIFIER_MOTION_NONE)

troll_skelet_aura_a = class({})

function troll_skelet_aura_a:GetIntrinsicModifierName()
    return "modifier_troll_skelet_aura_a"
end

modifier_troll_skelet_aura_a = class({})

function modifier_troll_skelet_aura_a:IsAura()
    return true
end

function modifier_troll_skelet_aura_a:GetModifierAura()
    return "modifier_troll_skelet_aura_a_aura"
end

function modifier_troll_skelet_aura_a:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_troll_skelet_aura_a:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_troll_skelet_aura_a:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC
end

function modifier_troll_skelet_aura_a:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_troll_skelet_aura_a:IsHidden()
    return true
end

modifier_troll_skelet_aura_a_aura = class({})

function modifier_troll_skelet_aura_a_aura:IsHidden() return false end

function modifier_troll_skelet_aura_a_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_troll_skelet_aura_a_aura:GetModifierPreAttack_BonusDamage()

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
    if bonus then return (self:GetAbility():GetSpecialValueFor("bonus_damage") * #units) - (2 * #units)
    else
    	return self:GetAbility():GetSpecialValueFor("bonus_damage")
    end
end