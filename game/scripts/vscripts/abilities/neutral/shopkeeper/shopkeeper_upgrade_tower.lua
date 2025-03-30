LinkLuaModifier("modifier_shopkeeper_upgrade_tower", 
"abilities/neutral/shopkeeper/shopkeeper_upgrade_tower", 
LUA_MODIFIER_MOTION_NONE)

require("utils/funcs")
require("utils/timers")

shopkeeper_upgrade_tower = class({})

function shopkeeper_upgrade_tower:GetGoldCost()
    if self.maxed then return 0 end
end

function shopkeeper_upgrade_tower:GetAbilityTextureName()
    if not self.maxed then
        return "shopkeeper_upgrade_tower"
    else
        return "shopkeeper_upgrade_tower_max"
    end
end

function shopkeeper_upgrade_tower:Spawn()
    if not IsServer() then return end
    Timers:CreateTimer(3.0, function()
        local caster = self:GetCaster()
        local player = GetPlayerByTeam(caster:GetTeam())
        caster:SetControllableByPlayer(0, false)
        caster:SetOwner(player:GetAssignedHero())
        caster:AddNewModifier(caster, nil, "modifier_invulnerable", {})
    end)
end

function shopkeeper_upgrade_tower:OnSpellStart()
    local caster = self:GetCaster()
    local team = caster:GetTeam()

	local tower_main = GetTowerByTeam(caster:GetTeamNumber(), true)
    local modif_main = tower_main:FindModifierByName("modifier_shopkeeper_upgrade_tower")
    
    if modif_main then
        local lvl = modif_main.UpgradeLevel
        tower_main:AddNewModifier(caster, self, "modifier_shopkeeper_upgrade_tower", {UpgradeLevel = lvl + 1, tower_type = 0})
    else
        modif_main = tower_main:AddNewModifier(caster, self, "modifier_shopkeeper_upgrade_tower", {UpgradeLevel = 1, tower_type = 0})
    end

    local fx_main = "particles/creatures/aghanim/aghanim_beam_channel.vpcf"
    local particle_main = ParticleManager:CreateParticle(fx_main, PATTACH_WORLDORIGIN, tower_main)
    ParticleManager:SetParticleControl(particle_main, 0, tower_main:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_main)

    EmitSoundOn("Hero_Luna.LucentBeam.Cast", tower_main)    

    local tower_1 = GetTowerByTeam(caster:GetTeamNumber(), false)
    local modif_1 = tower_1:FindModifierByName("modifier_shopkeeper_upgrade_tower")
    
    if modif_1 then
        local lvl = modif_1.UpgradeLevel
        tower_1:AddNewModifier(caster, self, "modifier_shopkeeper_upgrade_tower", {UpgradeLevel = lvl + 1, tower_type = 1})
    else
        modif_1 = tower_1:AddNewModifier(caster, self, "modifier_shopkeeper_upgrade_tower", {UpgradeLevel = 1, tower_type = 1})
    end

    local fx_1 = "particles/creatures/aghanim/aghanim_beam_channel.vpcf"
    local particle_1 = ParticleManager:CreateParticle(fx_1, PATTACH_WORLDORIGIN, tower_1)
    ParticleManager:SetParticleControl(particle_1, 0, tower_1:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_1)
    EmitSoundOn("Hero_Luna.LucentBeam.Cast", tower_1)

    EmitSoundOn("DOTA_Item.HavocHammer.Cast", caster)
end

modifier_shopkeeper_upgrade_tower = class({})

function modifier_shopkeeper_upgrade_tower:IsPurgable() return false end
function modifier_shopkeeper_upgrade_tower:IsDebuff() return false end
function modifier_shopkeeper_upgrade_tower:IsHidden() return false end

function modifier_shopkeeper_upgrade_tower:OnCreated( kv )
    if not IsServer() then return end

    self.UpgradeLevel = kv.UpgradeLevel
    self.tower_type = kv.tower_type

    self:GetAbility():SetLevel(self.UpgradeLevel + 1)
    self:SetStackCount(self.UpgradeLevel or 1)

    self:SetHasCustomTransmitterData( true )
end

function modifier_shopkeeper_upgrade_tower:OnRefresh( kv )
    if not IsServer() then return end

    self:SendBuffRefreshToClients()

    self.UpgradeLevel = kv.UpgradeLevel
    self.tower_type = kv.tower_type

    local ability = self:GetAbility()
    if self.UpgradeLevel < ability:GetMaxLevel() then
        ability:SetLevel(self.UpgradeLevel + 1) 
    end
    if self.UpgradeLevel == ability:GetMaxLevel() then
        ability:SetActivated(false)
        ability.maxed = true
    end

    self:SetStackCount(self.UpgradeLevel)
end

function modifier_shopkeeper_upgrade_tower:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,        
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end


function modifier_shopkeeper_upgrade_tower:OnTooltip()
    return self.UpgradeLevel
end

function modifier_shopkeeper_upgrade_tower:GetModifierExtraHealthBonus()
    local ability = self:GetAbility()
    if self.tower_type == 1 then
        local pct = ability:GetSpecialValueFor("second_tower_pct") / 100
        local bonus = ability:GetLevelSpecialValueFor("hp", self.UpgradeLevel)
        return bonus - (bonus * pct)
    else
        return ability:GetLevelSpecialValueFor("hp", self.UpgradeLevel)
    end
end

function modifier_shopkeeper_upgrade_tower:GetModifierAttackSpeedBonus_Constant()
    local ability = self:GetAbility()
    if self.tower_type == 1 then
        local pct = ability:GetSpecialValueFor("second_tower_pct") / 100
        local bonus = ability:GetLevelSpecialValueFor("at", self.UpgradeLevel)
        return bonus - (bonus * pct)
    else
        return ability:GetLevelSpecialValueFor("at", self.UpgradeLevel)
    end
end

function modifier_shopkeeper_upgrade_tower:GetModifierPreAttack_BonusDamage()
    local ability = self:GetAbility()
    if self.tower_type == 1 then
        local pct = ability:GetSpecialValueFor("second_tower_pct") / 100
        local bonus = ability:GetLevelSpecialValueFor("dmg", self.UpgradeLevel)
        return bonus - (bonus * pct)
    else
        return ability:GetLevelSpecialValueFor("dmg", self.UpgradeLevel)
    end
end

function modifier_shopkeeper_upgrade_tower:GetModifierPhysicalArmorBonus()
    local ability = self:GetAbility()
    if self.tower_type == 1 then
        local pct = ability:GetSpecialValueFor("second_tower_pct") / 100
        local bonus = ability:GetLevelSpecialValueFor("armor", self.UpgradeLevel)
        return bonus - (bonus * pct)
    else
        return ability:GetLevelSpecialValueFor("armor", self.UpgradeLevel)
    end
end

function modifier_shopkeeper_upgrade_tower:GetModifierConstantHealthRegen()
    local ability = self:GetAbility()
    if self.tower_type == 1 then
        local pct = ability:GetSpecialValueFor("second_tower_pct") / 100
        local bonus = ability:GetLevelSpecialValueFor("hp_regen", self.UpgradeLevel)
        return bonus - (bonus * pct)
    else
        return ability:GetLevelSpecialValueFor("hp_regen", self.UpgradeLevel)
    end
end

function modifier_shopkeeper_upgrade_tower:OnAttackLanded( event )
    local parent = self:GetParent()
    local attacker = event.attacker
    local target = event.target
    local damage = event.damage

    if attacker == parent then
        local ability = self:GetAbility()
        local magic_dmg = 0
        if self.tower_type == 1 then
            local pct = ability:GetSpecialValueFor("second_tower_pct") / 100
            local bonus = ability:GetLevelSpecialValueFor("magic_dmg", self.UpgradeLevel)
            magic_dmg = bonus - (bonus * pct)
        else
            magic_dmg = ability:GetLevelSpecialValueFor("magic_dmg", self.UpgradeLevel)
        end
        ApplyDamage({
            victim = target,
            attacker = parent,
            damage = damage * (magic_dmg / 100),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability
        })
    end
end

function modifier_shopkeeper_upgrade_tower:AddCustomTransmitterData()
    local data = {
        UpgradeLevel = self.UpgradeLevel,
        tower_type = self.tower_type,
    }
    return data
end

function modifier_shopkeeper_upgrade_tower:HandleCustomTransmitterData(data)
    self.UpgradeLevel = data.UpgradeLevel
    self.tower_type = data.tower_type
end