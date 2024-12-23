LinkLuaModifier("modifier_fountain_custom_heal_aura", "abilities/unit/fountain/fountain_custom_heal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fountain_custom_heal", "abilities/unit/fountain/fountain_custom_heal", LUA_MODIFIER_MOTION_NONE)

fountain_custom_heal = class({})

function fountain_custom_heal:GetIntrinsicModifierName()
    return "modifier_fountain_custom_heal_aura"
end

modifier_fountain_custom_heal_aura = class({})

function modifier_fountain_custom_heal_aura:IsHidden()
    return false
end

function modifier_fountain_custom_heal_aura:IsAura()
    return true
end

function modifier_fountain_custom_heal_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_fountain_custom_heal_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_fountain_custom_heal_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_fountain_custom_heal_aura:GetModifierAura()
    return "modifier_fountain_custom_heal"
end

modifier_fountain_custom_heal = class({})

function modifier_fountain_custom_heal:IsHidden()
    return false
end

function modifier_fountain_custom_heal:IsPurgable()
    return false
end

function modifier_fountain_custom_heal:OnCreated()
    self.hp_regen 	= self:GetAbility():GetSpecialValueFor("hp_regen")		
	self.mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen")	
    self.dmg_resist = self:GetAbility():GetSpecialValueFor("damage_resist")	
end

function modifier_fountain_custom_heal:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,  -- регенерация хп
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,	-- регенерация маны
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,   -- снижение урноа
    }
end

function modifier_fountain_custom_heal:GetModifierHealthRegenPercentage()
    return self.hp_regen
end

function modifier_fountain_custom_heal:GetModifierTotalPercentageManaRegen()
    return self.mana_regen
end

function modifier_fountain_custom_heal:GetModifierIncomingDamage_Percentage()
    return -self.dmg_resist
end
