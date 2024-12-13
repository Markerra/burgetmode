LinkLuaModifier("modifier_marker_chill", "abilities/marker/marker_chill", LUA_MODIFIER_MOTION_NONE)

marker_chill = class({})

function marker_chill:GetIntrinsicModifierName()
    return "modifier_marker_chill"
end

modifier_marker_chill = class({})

function modifier_marker_chill:IsHidden() return true end
function modifier_marker_chill:IsPurgable() return false end

function modifier_marker_chill:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_marker_chill:OnCreated()

    local ability = self:GetAbility()

    self.idle_time         = 0 
    self.max_idle_time     = ability:GetSpecialValueFor("max_bonus")  
    self.regen_per_second  = ability:GetSpecialValueFor("bonus_regen")  
    self.damage_per_second = ability:GetSpecialValueFor("bonus_dmg")  

    self.health_regen_bonus = 0
    self.damage_bonus       = 0

    self:StartIntervalThink(0.3)
end

function modifier_marker_chill:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()

    if caster:IsIdle() then
        self.idle_time = math.min(self.idle_time + 1*0.3, self.max_idle_time)
        print("idle")
        print(self.idle_time)
    else
        self.idle_time = 0
    end
    self.health_regen_bonus = self.regen_per_second * self.idle_time
    self.damage_bonus = self.damage_per_second * self.idle_time
    --print(self.health_regen_bonus.." "..self.regen_per_second )
    --print(self.damage_bonus.." "..self.damage_per_second )


end


function modifier_marker_chill:GetModifierConstantHealthRegen()
    return self.health_regen_bonus
end

function modifier_marker_chill:GetModifierPreAttack_BonusDamage()
    return self.damage_bonus
end