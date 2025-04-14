LinkLuaModifier("modifier_matvey_bf", "abilities/matvey/matvey_bf", LUA_MODIFIER_MOTION_NONE)

require("utils/funcs")

matvey_bf = class({})

function matvey_bf:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:AddNewModifier(caster, self, "modifier_matvey_bf", {duration = duration})
    self:SetActivated(false)
    self:EndCooldown()
end

modifier_matvey_bf = class({})

function modifier_matvey_bf:IsPurgable() return false end
function modifier_matvey_bf:IsHidden() return false end
function modifier_matvey_bf:IsDebuff() return false end

function modifier_matvey_bf:OnCreated(kv)
    if not IsServer() then return end
    self.angle = Vector(0, 0, 0)
    self.active = false
    local caster = self:GetCaster()
    local cast_particle = ParticleManager:CreateParticle(
        "particles/custom/matvey/matvey_bf/matvey_bf.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(cast_particle, 0, caster:GetAbsOrigin())
    self.particle = ParticleManager:CreateParticle(
        "particles/econ/events/fall_2021/groundglow_fall_2021.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControl(self.particle, 0, caster:GetAbsOrigin())
    caster:EmitSound("matvey_bf_cast")
    caster:EmitSound("Hero_Dark_Seer.Ion_Shield_Start.TI8")
    caster:EmitSound("Hero_ObsidianDestroyer.IdleLoop")
end

function modifier_matvey_bf:OnRefresh(kv)
    if not IsServer() then return end
    local caster = self:GetCaster()

    caster:EmitSound("Hero_Dark_Seer.Ion_Shield_Start.TI8")
end

function modifier_matvey_bf:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end
-- if not event.damage_category == 1 then return end

function modifier_matvey_bf:OnAttack(event)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local attacker = event.attacker
    local target = event.target
    
    if attacker == caster then
        self.active = true
        self.angle = attacker:GetForwardVector()

        local min_dmg = attacker:GetBaseDamageMin()
        local max_dmg = attacker:GetBaseDamageMax()

        self.companion = CreateUnitByName("npc_dota_companion", target:GetAbsOrigin(), false, nil, nil, 0)
        self.companion:SetBaseDamageMin(min_dmg)
        self.companion:SetBaseDamageMax(max_dmg)
        self.companion:SetForwardVector(self.angle)
        self.companion:AddNewModifier(self.target, nil, "modifier_phased", {})
        self.companion:AddNewModifier(self.target, nil, "modifier_invulnerable", {})
        self.companion:AddNewModifier(self.target, nil, "modifier_unselect", {})
    end
end

function modifier_matvey_bf:OnAttackLanded(event)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local attacker = event.attacker
    local target = event.target
    local damage = event.damage
    
    local ability = self:GetAbility()
    local radius = ability:GetSpecialValueFor("radius") -- 300
    local cleave_damage = ability:GetSpecialValueFor("cleave_damage") -- 30
    local distance = 450

    if attacker == caster and self.active then
        local units = FindUnitsInCone(
            attacker:GetTeamNumber(),
            self.angle,
            target:GetAbsOrigin(),
            radius / 2,
            radius,
            distance,
            nil,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HEROES_AND_CREEPS,
            DOTA_DAMAGE_FLAG_NONE,
            FIND_CLOSEST,
            true
        )

        for _, unit in pairs(units) do
           print(unit:GetUnitName())
           local modif = caster:FindModifierByName("matvey_magic_modifier")
           local event2 = event
           local cleave_mult = ability:GetSpecialValueFor("cleave_mult")
           event2.cleave = true
           event2.cleave_mult = cleave_mult / 100
           event2.target = unit
           modif:OnAttackLanded(event2)
            ApplyDamage({
                victim = unit,
                attacker = attacker,
                damage = damage * (cleave_mult / 100),
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = ability
            })
        end

        local fx = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf"
        local particle = ParticleManager:CreateParticle(fx, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControlTransformForward(particle, 0, target:GetAbsOrigin(), self.angle)
        ParticleManager:ReleaseParticleIndex(particle)
        self.companion:Destroy()
        target:EmitSound("Hero_Sven.GreatCleave")
    end
end

function modifier_matvey_bf:ManaRestore(damage)
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    local mana_restore = ability:GetSpecialValueFor("mana_restore")

    caster:GiveMana(damage * mana_restore)
end

function modifier_matvey_bf:OnDestroy()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    ability:SetActivated(true)
    ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    caster:StopSound("Hero_ObsidianDestroyer.IdleLoop")
    caster:EmitSound("Hero_Dark_Seer.Ion_Shield_end.TI8")

end