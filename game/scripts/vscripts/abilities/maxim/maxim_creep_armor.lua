LinkLuaModifier("modifier_maxim_creep_aura", "abilities/maxim/maxim_creep_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maxim_creep_aura_effect", "abilities/maxim/maxim_creep_armor", LUA_MODIFIER_MOTION_NONE)

maxim_creep_armor = class({})

function maxim_creep_armor:GetIntrinsicModifierName()
	return "modifier_maxim_creep_aura"
end

modifier_maxim_creep_aura = class({})

function modifier_maxim_creep_aura:IsAura() return true end
function modifier_maxim_creep_aura:IsHidden() return true end
function modifier_maxim_creep_aura:IsPurgable() return false end
function modifier_maxim_creep_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_maxim_creep_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_maxim_creep_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_maxim_creep_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_maxim_creep_aura:GetModifierAura() return "modifier_maxim_creep_aura_effect" end

modifier_maxim_creep_aura_effect = class({})

function modifier_maxim_creep_aura_effect:IsHidden() return false end
function modifier_maxim_creep_aura_effect:IsDebuff() return true end
function modifier_maxim_creep_aura_effect:IsPurgable() return true end

function modifier_maxim_creep_aura_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_maxim_creep_aura_effect:GetModifierPhysicalArmorBonus()
	local armor_change = self:GetAbility():GetSpecialValueFor("armor_change")
    return armor_change
end
