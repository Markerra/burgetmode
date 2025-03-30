LinkLuaModifier("modifier_boss_roshan_dispel", "abilities/neutral/boss/boss_roshan_dispel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_roshan_dispel_debuff", "abilities/neutral/boss/boss_roshan_dispel", LUA_MODIFIER_MOTION_NONE)

boss_roshan_dispel = class({})

function boss_roshan_dispel:GetIntrinsicModifierName()
    return "modifier_boss_roshan_dispel"
end

modifier_boss_roshan_dispel = class({})

function modifier_boss_roshan_dispel:IsPurgable() return false end
function modifier_boss_roshan_dispel:IsAura() return true end
function modifier_boss_roshan_dispel:GetAuraRadius() return self.radius end
function modifier_boss_roshan_dispel:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_boss_roshan_dispel:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_boss_roshan_dispel:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_boss_roshan_dispel:GetModifierAura() return "modifier_boss_roshan_dispel_debuff" end

function modifier_boss_roshan_dispel:OnCreated()
    if not IsServer() then return end

    self:SetStackCount(1)

    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.stacks_per_second = 1
    self.max_stacks = self:GetAbility():GetSpecialValueFor("dispel") + 1
    
    self:StartIntervalThink(1)
end

function modifier_boss_roshan_dispel:OnIntervalThink()
    if not IsServer() then return end

    if self:GetCaster():PassivesDisabled() then return end

    local units = FindUnitsInRadius(
    self:GetCaster():GetTeam(),
    self:GetCaster():GetAbsOrigin(), 
    nil,
    self.radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_CLOSEST,
    true)

    if #units == 0 then self:SetStackCount(1) return end

    local current_stack_count = self:GetStackCount()
    self:SetStackCount(current_stack_count + self.stacks_per_second)

    if self:GetStackCount() >= self.max_stacks then
        self:GetParent():Purge(false, true, false, true, true)
        local fx = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(fx, 1, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(fx)

        local fx2 = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(fx2, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(fx2)
        self:GetCaster():EmitSoundParams("Hero_Omniknight.Purification", 0, 0.3, 0)

        self:SetStackCount(1)
    end
end

modifier_boss_roshan_dispel_debuff = class({})

function modifier_boss_roshan_dispel_debuff:IsDebuff() return true end
function modifier_boss_roshan_dispel_debuff:IsHidden() return false end
function modifier_boss_roshan_dispel_debuff:IsPurgable() return true end

function modifier_boss_roshan_dispel_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_boss_roshan_dispel_debuff:GetModifierMoveSpeedBonus_Percentage()
    local distance = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
    local max_distance = self:GetAbility():GetSpecialValueFor("radius")
    local cap = self:GetAbility():GetSpecialValueFor("movespeed_cap")
    
    local slow_percentage = 0
    if distance < max_distance and distance > 150 then
        slow_percentage = (1 - (distance / max_distance)) * 50
    end

    local bonus = math.min(slow_percentage, cap)

    return -bonus
end