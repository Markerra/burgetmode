LinkLuaModifier("modifier_fountain_custom_upgrade", "abilities/unit/fountain/fountain_custom_upgrade", LUA_MODIFIER_MOTION_NONE)

require("game-mode/custom_params")

fountain_custom_upgrade = class({})

function fountain_custom_upgrade:GetIntrinsicModifierName()
    return "modifier_fountain_custom_upgrade"
end

modifier_fountain_custom_upgrade = class({})

function modifier_fountain_custom_upgrade:IsHidden()
    return false
end

function modifier_fountain_custom_upgrade:IsDebuff()
    return false
end

function modifier_fountain_custom_upgrade:IsPurgable()
    return false
end

function modifier_fountain_custom_upgrade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, --GetModifierAttackSpeedBonus_Constant
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, --GetModifierPreAttack_BonusDamage
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, --GetModifierPhysicalArmorBonus
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, --GetModifierConstantHealthRegen
    }
end

function modifier_fountain_custom_upgrade:OnCreated(kv)
    self:SetStackCount(0)

    self.hp       = self:GetAbility():GetSpecialValueFor("hp_upgrade")
    self.at       = self:GetAbility():GetSpecialValueFor("at_upgrade")   
    self.regen    = self:GetAbility():GetSpecialValueFor("regen_upgrade") 
    self.armor    = self:GetAbility():GetSpecialValueFor("armor_upgrade") 
    self.damage   = self:GetAbility():GetSpecialValueFor("damage_upgrade")
    self.interval = self:GetAbility():GetSpecialValueFor("upgrade_interval")
    self:StartIntervalThink(self.interval)
end

function modifier_fountain_custom_upgrade:GetModifierAttackSpeedBonus_Constant()
    local stacks = self:GetStackCount()
    return self.at * stacks
end

function modifier_fountain_custom_upgrade:GetModifierConstantHealthRegen()
    local stacks = self:GetStackCount()
    return self.regen * stacks
end

function modifier_fountain_custom_upgrade:GetModifierPhysicalArmorBonus()
    local stacks = self:GetStackCount()
    return self.armor * stacks
end

function modifier_fountain_custom_upgrade:GetModifierPreAttack_BonusDamage()
    local stacks = self:GetStackCount()
    return self.damage * stacks
end

function modifier_fountain_custom_upgrade:OnIntervalThink()
    if not IsServer() then return end
    local stacks = self:GetStackCount() + 1
    local caster = self:GetParent()
    if not caster or caster:IsNull() then return end
    self:IncrementStackCount()
    if CUSTOM_DEBUG_MODE then
    print("-- Fountain Upgraded", "Current Fountain Level: "..stacks)
    end
    caster:SetMaxHealth(caster:GetMaxHealth() + (self.hp))
    caster:Heal(self.hp, self:GetAbility())
    return self.interval
end
