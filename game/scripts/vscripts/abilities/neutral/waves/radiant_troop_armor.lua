LinkLuaModifier("modifier_radiant_troop_armor_aura", "abilities/neutral/waves/radiant_troop_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_troop_armor", "abilities/neutral/waves/radiant_troop_armor", LUA_MODIFIER_MOTION_NONE)

radiant_troop_armor = class({})

function radiant_troop_armor:GetIntrinsicModifierName()
	return "modifier_radiant_troop_armor_aura"
end

modifier_radiant_troop_armor_aura = class({})

function modifier_radiant_troop_armor_aura:IsHidden()
    return true
end

function modifier_radiant_troop_armor_aura:IsDebuff()
    return false
end

function modifier_radiant_troop_armor_aura:IsPurgable()
    return false
end

function modifier_radiant_troop_armor_aura:IsAura()
    return true
end

function modifier_radiant_troop_armor_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_radiant_troop_armor_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_radiant_troop_armor_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_radiant_troop_armor_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_radiant_troop_armor_aura:GetModifierAura()
	if self:GetAbility():GetCaster():PassivesDisabled() then return end
    return "modifier_radiant_troop_armor"
end

modifier_radiant_troop_armor = class({})

function modifier_radiant_troop_armor:IsHidden()
    return false
end

function modifier_radiant_troop_armor:IsDebuff()
    return false
end

function modifier_radiant_troop_armor:IsPurgable()
    return true
end

function modifier_radiant_troop_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOOLTIP,
    }
end

function modifier_radiant_troop_armor:GetModifierIncomingDamage_Percentage(params)
    if params.attacker:IsHero() and params.damage_type == DAMAGE_TYPE_PHYSICAL then
        return -self:GetAbility():GetSpecialValueFor("phys_res") or -60
    end

    return 0
end

function modifier_radiant_troop_armor:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("phys_res")
end