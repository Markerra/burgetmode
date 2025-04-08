LinkLuaModifier("modifier_marker_chill", "abilities/marker/marker_chill", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marker_chill_tracker", "abilities/marker/marker_chill", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marker_chill_shard", "abilities/marker/marker_chill", LUA_MODIFIER_MOTION_NONE)

marker_chill = class({})

function marker_chill:GetIntrinsicModifierName()
    return "modifier_marker_chill"
end

modifier_marker_chill = class({})

function modifier_marker_chill:IsDebuff() return false end
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

    self.delay             = ability:GetSpecialValueFor("delay") 
    self.idle_time         = 1 - self.delay

    self.interval = ability:GetSpecialValueFor("interval")

    self.health_regen_bonus = 0
    self.damage_bonus       = 0

    self:SetHasCustomTransmitterData(true)

    self:StartIntervalThink( self.interval )
end

function modifier_marker_chill:OnRefresh()
    local ability = self:GetAbility()
    
    self.regen_per_second  = ability:GetSpecialValueFor("bonus_regen")  
    self.damage_per_second = ability:GetSpecialValueFor("bonus_dmg")
end

function modifier_marker_chill:OnIntervalThink()
    local caster = self:GetCaster()

    if caster:PassivesDisabled() then
        self.idle_time = 1 - self.delay
        if self.tracker then
            caster:RemoveModifierByName("modifier_marker_chill_tracker")
        end
        return 
    end

    if not IsServer() then return end

    local maxtime = self:GetAbility():GetSpecialValueFor("max_bonus")
    local amp = 0

    if not caster:IsMoving() then
        self.idle_time = math.min(self.idle_time + 1 * self.interval, maxtime)
        amp = math.floor(self.idle_time)
        if amp >= 1 then
            self.tracker = caster:AddNewModifier(caster, self:GetAbility(), "modifier_marker_chill_tracker", {})
            self.tracker:SetStackCount(amp)
        end
    else
        self.idle_time = 1 - self.delay
        if self.tracker then
            caster:RemoveModifierByName("modifier_marker_chill_tracker")
        end
    end

    self.health_regen_bonus = self.regen_per_second * amp
    self.damage_bonus = self.damage_per_second * amp

    self:SendBuffRefreshToClients() 
end

function modifier_marker_chill:AddCustomTransmitterData()
    local data = {
        health_regen_bonus = self.health_regen_bonus,
        damage_bonus = self.damage_bonus,  
    }
    return data
end

function modifier_marker_chill:HandleCustomTransmitterData(data)
    self.health_regen_bonus = data.health_regen_bonus
    self.damage_bonus = data.damage_bonus
end

function modifier_marker_chill:GetModifierConstantHealthRegen()
    return self.health_regen_bonus
end

function modifier_marker_chill:GetModifierPreAttack_BonusDamage()
    return self.damage_bonus
end

modifier_marker_chill_tracker = class({})

function modifier_marker_chill_tracker:IsHidden() return false end
function modifier_marker_chill_tracker:IsDebuff() return false end
function modifier_marker_chill_tracker:IsPurgable() return false end

function modifier_marker_chill_tracker:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()

    self.effect = ParticleManager:CreateParticle(
        "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf", 
        PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(self.effect, 0, parent:GetAbsOrigin())

    parent:EmitSoundParams("Hero_Huskar.BerserkersBlood.Cast", 1, 0.6, 0)
end

function modifier_marker_chill_tracker:OnDestroy()
    if not IsServer() then return end

    local parent = self:GetParent()

    local shard = parent:HasModifier("modifier_item_aghanims_shard")
    local dur = self:GetAbility():GetSpecialValueFor("shard_duration")

    ParticleManager:DestroyParticle(self.effect, false)
    ParticleManager:ReleaseParticleIndex(self.effect)

    StopSoundOn("Hero_Huskar.BerserkersBlood.Cast", parent)

    if not shard then
        parent:EmitSoundParams("DOTA_Item.Nullifier.Slow", 0, 0.5, 0)
        local effect2 = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf", 
        PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControl(effect2, 0, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect2, 1, parent:GetAbsOrigin())
        return 
    end

    if parent:HasModifier("modifier_marker_chill_shard") then
        parent:RemoveModifierByName("modifier_marker_chill_shard") 
    end
    parent:AddNewModifier(parent, self:GetAbility(), "modifier_marker_chill_shard", {duration = dur})
end

modifier_marker_chill_shard = class({})

function modifier_marker_chill_shard:IsHidden() return false end
function modifier_marker_chill_shard:IsDebuff() return false end
function modifier_marker_chill_shard:IsPurgable() return true end

function modifier_marker_chill_shard:OnCreated()
    if not IsServer() then return end

    local caster = self:GetAbility():GetCaster()
    local particle = "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"

    caster:EmitSoundParams("Hero_Dark_Seer.Surge", 0, 0.3, 0)
    self.effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
end

function modifier_marker_chill_shard:OnDestroy()
    if not IsServer() then return end
    
    ParticleManager:DestroyParticle(self.effect, false)
    ParticleManager:ReleaseParticleIndex(self.effect)
end

function modifier_marker_chill_shard:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end

function modifier_marker_chill_shard:GetModifierMoveSpeedBonus_Constant()
    local bonus = self:GetAbility():GetSpecialValueFor("shard_bonus_ms")
    return bonus
end