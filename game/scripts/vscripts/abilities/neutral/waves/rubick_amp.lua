LinkLuaModifier("modifier_rubick_amp_aura", 
	"abilities/neutral/waves/rubick_amp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_amp", 
	"abilities/neutral/waves/rubick_amp", LUA_MODIFIER_MOTION_NONE)

rubick_amp = class({})

function rubick_amp:GetIntrinsicModifierName()
	return "modifier_rubick_amp_aura"
end

modifier_rubick_amp_aura = class({})

function modifier_rubick_amp_aura:IsHidden() return true end
function modifier_rubick_amp_aura:IsDebuff() return false end
function modifier_rubick_amp_aura:IsPurgable() return false end
function modifier_rubick_amp_aura:IsAura() return true end

function modifier_rubick_amp_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_rubick_amp_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_rubick_amp_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC
end

function modifier_rubick_amp_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_rubick_amp_aura:GetModifierAura()
	if self:GetAbility():GetCaster():PassivesDisabled() then return end
	return "modifier_rubick_amp"
end

modifier_rubick_amp = class({})

function modifier_rubick_amp:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_rubick_amp:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp")
end