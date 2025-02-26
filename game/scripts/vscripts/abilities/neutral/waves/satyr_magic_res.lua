LinkLuaModifier("modifier_satyr_magic_res_aura", "abilities/neutral/waves/satyr_magic_res", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_satyr_magic_res", "abilities/neutral/waves/satyr_magic_res", LUA_MODIFIER_MOTION_NONE)

satyr_magic_res = class({})

function satyr_magic_res:GetIntrinsicModifierName()
    return "modifier_satyr_magic_res_aura"
end

modifier_satyr_magic_res_aura = class({})

function modifier_satyr_magic_res_aura:IsHidden()
    return true
end

function modifier_satyr_magic_res_aura:IsDebuff()
    return false
end

function modifier_satyr_magic_res_aura:IsPurgable()
    return false
end

function modifier_satyr_magic_res_aura:IsAura()
    return true
end

function modifier_satyr_magic_res_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_satyr_magic_res_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_satyr_magic_res_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_satyr_magic_res_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_satyr_magic_res_aura:GetModifierAura()
	if self:GetAbility():GetCaster():PassivesDisabled() then return end
    return "modifier_satyr_magic_res"
end

modifier_satyr_magic_res = class({})

function modifier_satyr_magic_res:IsHidden()
    return false
end

function modifier_satyr_magic_res:IsDebuff()
    return false
end

function modifier_satyr_magic_res:IsPurgable()
    return true
end

function modifier_satyr_magic_res:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_satyr_magic_res:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_satyr_magic_res:GetModifierMagicalResistanceBonus()
    if not self:GetAbility() then return end
    return self:GetAbility():GetSpecialValueFor("magic_res")
end
