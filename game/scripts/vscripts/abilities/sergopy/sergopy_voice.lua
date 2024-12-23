LinkLuaModifier("modifier_sergopy_voice_pull", "abilities/sergopy/sergopy_voice", LUA_MODIFIER_MOTION_NONE)

function HasTalent(unit, talent_name)
    local talent = unit:FindAbilityByName(talent_name)
    if talent and talent:GetLevel() > 0 then
        return true
    end
    return false
end

sergopy_voice = class({})

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

        enemy:AddNewModifier(caster, ability, "modifier_sergopy_voice_pull", { duration = pull_duration })

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

function modifier_sergopy_voice_pull:OnCreated(kv)
    if not IsServer() then return end

    self.pull_speed    = self:GetAbility():GetSpecialValueFor("pull_speed")
    self.pull_center   = self:GetCaster():GetAbsOrigin()
    self.safe_distance = 200

    self:StartIntervalThink(0.001)
end

function modifier_sergopy_voice_pull:OnIntervalThink()
    if not IsServer() then return end
    self.safe_distance = self.safe_distance
    local parent = self:GetParent()
    local direction = (self.pull_center - parent:GetAbsOrigin()):Normalized()
    local new_position = parent:GetAbsOrigin() + RandomInt(-30, 30) + direction * self.pull_speed * 0.001
    local distance = (self.pull_center - parent:GetAbsOrigin()):Length2D()

    if distance > self.safe_distance then
        local move_distance = math.min(self.pull_speed * 0.001, distance - self.safe_distance)
        local new_position = parent:GetAbsOrigin() + direction * move_distance

        FindClearSpaceForUnit(parent, new_position, true)
    end
end

function modifier_sergopy_voice_pull:OnDestroy()
    if not IsServer() then return end

    self:GetParent():SetAbsOrigin(GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent()))
end
