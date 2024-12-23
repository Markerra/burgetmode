LinkLuaModifier("modifier_sergopy_bristleback", "abilities/sergopy/sergopy_bristleback.lua", LUA_MODIFIER_MOTION_NONE)

sergopy_bristleback = class({})

function sergopy_bristleback:GetIntrinsicModifierName()
    return "modifier_sergopy_bristleback"
end

modifier_sergopy_bristleback = class({})

function modifier_sergopy_bristleback:IsHidden() return false end
function modifier_sergopy_bristleback:IsDebuff() return false end
function modifier_sergopy_bristleback:IsPurgable() return false end

function modifier_sergopy_bristleback:GetTexture() return "modifiers/sergopy_bristleback" end

function modifier_sergopy_bristleback:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_sergopy_bristleback:OnCreated()
    if not IsServer() then return end
    self.bonus_spell_amp = 0
    self:SetStackCount(0)
end

function modifier_sergopy_bristleback:OnAbilityExecuted(params)
    if not IsServer() then return end

    local ability = params.ability

    if not ability or ability:IsItem() or ability:GetCooldown(-1) <= 0 then
        return
    end

    local parent = self:GetParent()
    if params.unit == parent then
       	local spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
        local duration  = self:GetAbility():GetSpecialValueFor("duration")
        self.bonus_spell_amp = self.bonus_spell_amp + spell_amp
        self:SetStackCount(self:GetStackCount() + spell_amp)
        self:StartIntervalThink(duration)
    end
end

function modifier_sergopy_bristleback:OnIntervalThink()
    if not IsServer() then return end

    self.bonus_spell_amp = self.bonus_spell_amp - self:GetStackCount()
    if self.bonus_spell_amp <= 0 then
        self.bonus_spell_amp = 0
        self:SetStackCount(0)
        self:StartIntervalThink(-1)
    end
end

function modifier_sergopy_bristleback:GetModifierSpellAmplify_Percentage()
    return self.bonus_spell_amp
end

