LinkLuaModifier("modifier_arsen_summoner", "abilities/arsen/arsen_summoner", LUA_MODIFIER_MOTION_NONE)

arsen_summoner = class({})

function arsen_summoner:GetIntrinsicModifierName() return "modifier_arsen_summoner" end

modifier_arsen_summoner = class({})

function modifier_arsen_summoner:IsHidden() return true end
function modifier_arsen_summoner:IsDebuff() return false end
function modifier_arsen_summoner:IsPurgable() return false end


function modifier_arsen_summoner:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
        MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
    }
end

function modifier_arsen_summoner:OnDeath(event)
    local parent = self:GetParent()
    local attacker = event.attacker
    local target = event.unit

    if parent:PassivesDisabled() then return end

    if (attacker == parent or attacker:GetOwner() == parent) and not target:IsBuilding() then
        local ability = self:GetAbility()
        local chance = ability:GetSpecialValueFor("chance")
        local hero_mult = ability:GetSpecialValueFor("hero_mult")

        if target:IsHero() then chance = chance * hero_mult end

        if RollPercentage(chance) and ability:IsCooldownReady() then
            local point = target:GetAbsOrigin()
            local duration = ability:GetSpecialValueFor("duration")
            local level = 1 --ability:GetSpecialValueFor("level")
            local creep = {
                health = ability:GetSpecialValueFor("health"),
                damage = ability:GetSpecialValueFor("damage")
            }

            self:Summon(point, level, duration, creep)
            ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))

            local fx = "particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf"
            local particle = ParticleManager:CreateParticle(fx, PATTACH_WORLDORIGIN, target)
            ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)

            target:EmitSound("Hero_Broodmother.SpawnSpiderlings")
        end
    end
end

function modifier_arsen_summoner:Summon(point, level, duration, data)
    local parent = self:GetParent()
    local name = "npc_arsen_summon"
    local creep = CreateUnitByName(name, point, true, parent, parent, parent:GetTeamNumber())
    if PlayerResource:IsValidPlayerID(parent:GetPlayerID()) then
    creep:SetControllableByPlayer(parent:GetPlayerID(), true) end
    creep:AddNewModifier(parent, nil, "modifier_kill", { duration = duration })
    FindClearSpaceForUnit(creep, point, true)
    creep:SetHealth(data.health)
    creep:SetMaxHealth(data.health)
    creep:SetBaseDamageMin(data.damage - 3)
    creep:SetBaseDamageMax(data.damage + 3)
    --creep:CreatureLevelUp( (creep:GetLevel() - level) * (-1) )
end

function modifier_arsen_summoner:GetModifierOverrideAbilitySpecial(keys)
    local ability = keys.ability

    if not ability then return end
    if not ability:GetAbilityName() == "arsen_summoner" then return 0 end
    if keys.ability_special_value == "chance" then return 1 end
end

function modifier_arsen_summoner:GetModifierOverrideAbilitySpecialValue(keys)
    local parent = self:GetParent()
    local lvl = parent:GetLevel()
    local ability = keys.ability

    if not ability then return end
    if not ability:GetAbilityName() == "arsen_summoner" then return 0 end
    if keys.ability_special_value == "chance" then
        local gain = ability:GetLevelSpecialValueNoOverride("chance_gain",  keys.ability_special_level)
        local value = ability:GetLevelSpecialValueNoOverride(keys.ability_special_value, keys.ability_special_level)
        if lvl == 30 then value = value + 1 end
    return value + (lvl * gain) end
end