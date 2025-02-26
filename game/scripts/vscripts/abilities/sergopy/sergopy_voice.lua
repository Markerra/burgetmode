LinkLuaModifier("modifier_sergopy_voice_pull", "abilities/sergopy/sergopy_voice", LUA_MODIFIER_MOTION_HORIZONTAL)

function HasTalent(unit, talent_name)
    local talent = unit:FindAbilityByName(talent_name)
    if talent and talent:GetLevel() > 0 then
        return true
    end
    return false
end

sergopy_voice = class({})

function sergopy_voice:Precache( context )
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_queenofpain.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf", context)
end

function sergopy_voice:OnSpellStart()
    local caster  = self:GetCaster()
    local ability = self
    local radius  = self:GetSpecialValueFor("radius")
    local damage  = self:GetSpecialValueFor("damage")
    local pull_duration = self:GetSpecialValueFor("pull_duration")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)

    caster:EmitSound("Hero_QueenOfPain.ScreamOfPain")

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

        if enemy:IsDebuffImmune() then return end

        local silence_duration = self:GetSpecialValueFor("silence_duration")

        if HasTalent(caster, "special_bonus_unique_sergopy_voice_silence") then
            enemy:AddNewModifier(caster, ability, "modifier_silence", { duration = silence_duration })
        end

        if not enemy.wave_creep or not enemy:GetUnitName() == "npc_boss_roshan" then
            enemy:AddNewModifier(caster, ability, "modifier_sergopy_voice_pull", { duration = pull_duration })
        end

        local damage_table = {
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
        }

        ApplyDamage(damage_table)

    end
end

-- модификатор отталкивания 
modifier_sergopy_voice_pull = class({})

function modifier_sergopy_voice_pull:IsHidden() return true end
function modifier_sergopy_voice_pull:IsDebuff() return true end
function modifier_sergopy_voice_pull:IsPurgable() return true end

function modifier_sergopy_voice_pull:OnCreated()
    if not IsServer() then return end

    local parent = self:GetParent()

    self.speed    = self:GetAbility():GetSpecialValueFor("pull_speed")
    self.pull_center   = self:GetCaster():GetAbsOrigin()
    self.safe_distance = 200

    self.direction = self.pull_center - parent:GetAbsOrigin()

    self.direction.z = 0
    self.direction = self.direction:Normalized()

    if not self:ApplyHorizontalMotionController() then
        self:Destroy()
    end
end

function modifier_sergopy_voice_pull:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController( self )
end

function modifier_sergopy_voice_pull:UpdateHorizontalMotion( me, dt )
    local target = me:GetOrigin() + self.direction * self.speed * dt
    me:SetOrigin( target )
end

function modifier_sergopy_voice_pull:OnHorizontalMotionInterrupted()
    self:Destroy()
end