LinkLuaModifier( "modifier_seva_big", "abilities/seva/seva_big", LUA_MODIFIER_MOTION_NONE )

seva_big = {}

function seva_big:GetIntrinsicModifierName()
	return "modifier_seva_big"
end

function seva_big:GetCooldown() return self:GetSpecialValueFor("time_stack") end

------------------------------------------------------

modifier_seva_big = {}

function modifier_seva_big:DeclareFunctions()
    return { 
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MODEL_SCALE_CONSTANT
    }
end

function modifier_seva_big:IsHidden() return true end
function modifier_seva_big:IsDebuff() return false end
function modifier_seva_big:IsPurgable() return false end

function modifier_seva_big:OnCreated()
    self:SetHasCustomTransmitterData(true)
    if not IsServer() then return end
    local ts = self:GetAbility():GetSpecialValueFor("time_stack")
    self:SetStackCount(0)
    self.stacks = 0
    self.hp_per_stack = self:GetAbility():GetSpecialValueFor("hp_per_stack")
    self.scale_per_stack = 0.005
    self:StartIntervalThink(ts)
end

function modifier_seva_big:AddCustomTransmitterData()
    local data = {
        scale_per_stack = self.scale_per_stack,
        hp_per_stack = self.hp_per_stack,
        stacks = self.stacks,
    }
    return data
end

function modifier_seva_big:HandleCustomTransmitterData(data)
    self.scale_per_stack = data.scale_per_stack
    self.hp_per_stack = data.hp_per_stack
    self.stacks = data.stacks
end


function modifier_seva_big:GetModifierHealthBonus()
    return (self.stacks + 1) * self.hp_per_stack
end

function modifier_seva_big:GetModifierModelScaleConstant()
    return 1 + ((self.stacks + 1) * self.scale_per_stack)
end

function modifier_seva_big:OnIntervalThink()
    
    local caster = self:GetParent()
    local ability = self:GetAbility()
    self.stacks = self:GetStackCount()
    
    if not caster or caster:IsNull() then return end
    
    self:SetStackCount(self.stacks + 1)
    self:SendBuffRefreshToClients()
    caster:CalculateStatBonus(true)

    caster:Heal(self.hp_per_stack, self:GetAbility())
    
    print("Stacks: ", self.stacks + 1, " Max Health: ", caster:GetMaxHealth())

    ability:StartCooldown(ability:GetCooldown(1))
end