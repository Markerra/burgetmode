LinkLuaModifier( "modifier_seva_big", "abilities/seva/seva_big", LUA_MODIFIER_MOTION_NONE )

seva_big = {}

function seva_big:OnSpellStart()
    AddNewModifier(self:GetCaster(), self, "modifier_seva_big", {duration = -1})
end

function seva_big:GetIntrinsicModifierName()
	return "modifier_seva_big"
end

------------------------------------------------------

modifier_seva_big = {}

function modifier_seva_big:DeclareFunctions()
    return { MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS }
end

function modifier_seva_big:IsHidden()
	return true
end

function modifier_seva_big:IsPurgable()
    return false
end

function modifier_seva_big:OnCreated()
    if not IsServer() then return end
    local ts = self:GetAbility():GetSpecialValueFor("time_stack")
    self:SetStackCount(0)
    self:StartIntervalThink(ts)
end


function modifier_seva_big:GetModifierExtraHealthBonus()
    local hp_per_stack = self:GetAbility():GetSpecialValueFor("hp_per_stack")
    local stacks = self:GetStackCount()
    --print("Extra Health Bonus: ", hp_per_stack * stacks)
    return hp_per_stack * stacks 
end

function modifier_seva_big:OnIntervalThink()
    local caster = self:GetParent()
    if not caster or caster:IsNull() then return end
    local current_stacks = self:GetStackCount()
    self:SetStackCount(current_stacks + 1)
    local extra_health_bonus = self:GetModifierExtraHealthBonus()
    caster:CalculateStatBonus(true)
    local ms = caster:GetModelScale()
    caster:SetModelScale(ms * 1.002)

    local current_health_percent = caster:GetHealth() / caster:GetMaxHealth()

    caster:SetHealth(caster:GetMaxHealth() * current_health_percent)

    --print("Stacks: ", current_stacks + 1, " Max Health: ", caster:GetMaxHealth())
end


------------------------------------------------------
