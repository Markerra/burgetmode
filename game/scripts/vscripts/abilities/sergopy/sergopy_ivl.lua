LinkLuaModifier("modifier_sergopy_ivl_debuff", "abilities/sergopy/sergopy_ivl", LUA_MODIFIER_MOTION_NONE)

function HasTalent(unit, talent_name)
    local talent = unit:FindAbilityByName(talent_name)
    if talent and talent:GetLevel() > 0 then
        return true
    end
    return false
end

sergopy_ivl = class({})

function sergopy_ivl:OnSpellStart()
    local caster   = self:GetCaster()
    local ability  = self
    local radius   = self:GetSpecialValueFor("radius")
    local damage   = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_kineticfield.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius-10, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)
    EmitSoundOn("Hero_Disruptor.ThunderStrike.Cast", caster)

    -- Find enemies in radius
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in pairs(enemies) do
        

        local damage_table = {
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
        }

        ApplyDamage(damage_table)


        if not HasTalent(caster, "special_bonus_unique_sergopy_ivl_bkb") then
            if enemy:IsDebuffImmune() then return end

        end
        enemy:AddNewModifier(caster, ability, "modifier_sergopy_ivl_debuff", { duration = duration })
    end
end


modifier_sergopy_ivl_debuff = class({})

function modifier_sergopy_ivl_debuff:IsHidden() return false end
function modifier_sergopy_ivl_debuff:IsDebuff() return true end
function modifier_sergopy_ivl_debuff:IsPurgable() return false end
function modifier_sergopy_ivl_debuff:IsPurgeException() return true end

function modifier_sergopy_ivl_debuff:OnCreated()
    self:SetHasCustomTransmitterData( true )

    if not IsServer() then return end

    self.hp_regen = self:GetParent():GetHealthRegen() * (1 - self:GetParent():GetStatusResistance())

    self:StartIntervalThink(1.0)

    self:SetStackCount(1)

    self.stacks_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.stacks_particle, 1, Vector(0, 1, 0))
    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin_persona/pa_persona_crit_impact_travel_spray.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle2, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle2)
    self.particle = ParticleManager:CreateParticle("particles/econ/events/fall_2022/regen/fountain_regen_fall2022_lvl2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 1, Vector(radius, 0, 0))

    EmitSoundOn("Hero_Disruptor.StaticStorm.End", self:GetParent())
    
    self:SendBuffRefreshToClients()
end

function modifier_sergopy_ivl_debuff:AddCustomTransmitterData()
    local data = {
        hp_regen = self.hp_regen
    }
    return data
end

function modifier_sergopy_ivl_debuff:HandleCustomTransmitterData(data)
    self.hp_regen = data.hp_regen
end

function modifier_sergopy_ivl_debuff:OnRefresh()
    if not IsServer() then return end

    self.hp_regen = self:GetParent():GetHealthRegen()

    local max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
    if self:GetStackCount() + 1 > max_stacks then self:SetStackCount(max_stacks) return end
    self:IncrementStackCount()

    if self:GetStackCount() >= 10 and self:GetStackCount() < 20 then
        ParticleManager:SetParticleControl(self.stacks_particle, 1, Vector(1, self:GetStackCount()-10, 0))
    elseif self:GetStackCount() >= 20 then
        ParticleManager:SetParticleControl(self.stacks_particle, 1, Vector(2, self:GetStackCount()-20, 0))
    else
        ParticleManager:SetParticleControl(self.stacks_particle, 1, Vector(0, self:GetStackCount(), 0))
    end
    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin_persona/pa_persona_crit_impact_travel_spray.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle2, 3, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle2)
    EmitSoundOn("Hero_Disruptor.Attack", self:GetParent())
end

function modifier_sergopy_ivl_debuff:OnIntervalThink()
    if not IsServer() then return end

    local bonus = self:GetAbility():GetSpecialValueFor("stack_damage_bonus")

    local stacks = self:GetStackCount()
    
    local damage_table = {
        victim = self:GetParent(),
        attacker = self:GetAbility():GetCaster(),
        damage = bonus * stacks,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
    }

    ApplyDamage(damage_table)

    self:SendBuffRefreshToClients() 
end

function modifier_sergopy_ivl_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_sergopy_ivl_debuff:GetModifierConstantHealthRegen()
    local stacks = self:GetStackCount()
    local bonus = self:GetAbility():GetSpecialValueFor("stack_regen_bonus")
    local regen_reduction = self:GetAbility():GetSpecialValueFor("regen_reduction")
    local bonus_reduction = -bonus * stacks
    local total = -(regen_reduction / 100) + (bonus_reduction / 100)
    if self.hp_regen then
        return total * self.hp_regen
    else return total * self.hp_regen end
end

function modifier_sergopy_ivl_debuff:GetModifierMoveSpeedBonus_Percentage()
    local stacks = self:GetStackCount()
    local bonus = self:GetAbility():GetSpecialValueFor("stack_slow_bonus")
    local slow = self:GetAbility():GetSpecialValueFor("slow")
    return -slow + (-bonus * stacks)
end

function modifier_sergopy_ivl_debuff:OnDestroy()
    if not IsServer() then return end

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:DestroyParticle(self.stacks_particle, false)
end

function modifier_sergopy_ivl_debuff:GetAttributes()
    local caster = self:GetCaster()

    if HasTalent(caster, "special_bonus_unique_sergopy_ivl_bkb") then
        return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
    end
end