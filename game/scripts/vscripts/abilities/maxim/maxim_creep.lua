maxim_creep = class({})

function maxim_creep:OnAbilityPhaseStart()
    print(self:GetSpecialValueFor("duration"))
    local caster = self:GetCaster()
    EmitSoundOn("maxim_creep_pre", caster)
end

function maxim_creep:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    StopSoundOn("maxim_creep_pre", caster)
end

function maxim_creep:OnSpellStart()
    local caster         = self:GetCaster()
    local forward_vector = caster:GetForwardVector()
    local lvl            = self:GetLevel()
    local spawn_distance = 150 
    local spawn_point    = caster:GetAbsOrigin() + forward_vector * spawn_distance
    local duration       = self:GetSpecialValueFor("duration") 

    local creep = CreateUnitByName("npc_dota_maxim_creep", spawn_point, true, caster, caster, caster:GetTeamNumber())
    creep:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    creep:AddNewModifier(caster, nil, "modifier_kill", { duration = duration })

    if lvl == 2 then
        creep:CreatureLevelUp(1)
    elseif lvl == 3 then
        creep:CreatureLevelUp(2)
    elseif lvl == 4 then
        creep:CreatureLevelUp(3)
    end

    local particle = "particles/econ/items/dazzle/dazzle_ti9/dazzle_shadow_wave_ti9_crimson_impact_damage.vpcf"
    local fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, creep)
    ParticleManager:ReleaseParticleIndex(fx)

    EmitSoundOn("maxim_creep_cast", caster)

    local rnd = RandomInt(1, 3)
    if rnd == 1 then
        EmitSoundOn("maxim_creep_cast1", caster)
    elseif rnd == 2 then
        EmitSoundOn("maxim_creep_cast2", caster)
    elseif rnd == 3 then
        EmitSoundOn("maxim_creep_cast3", caster)
    end


    local hp_regen = self:GetSpecialValueFor("hp_regen")
    local max_mana = self:GetSpecialValueFor("max_mana")
    local dmg_sep  = self:GetSpecialValueFor("dmg_sep")
    local max_hp   = self:GetSpecialValueFor("max_hp")
    local armor    = self:GetSpecialValueFor("creep_armor")

    -- Задаем параметры крипа
    local base_damage = caster:GetBaseDamageMin()
    creep:SetBaseDamageMin(base_damage / dmg_sep)
    creep:SetBaseDamageMax(base_damage / dmg_sep)
    creep:SetBaseHealthRegen(hp_regen)
    creep:SetPhysicalArmorBaseValue(armor)
    creep:SetMaxHealth(max_hp)
    creep:SetHealth(max_hp)
    creep:SetMana(max_mana)
end

