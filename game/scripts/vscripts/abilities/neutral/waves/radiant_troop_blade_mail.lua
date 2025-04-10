LinkLuaModifier("modifier_radiant_troop_blade_mail", "abilities/neutral/waves/radiant_troop_blade_mail", LUA_MODIFIER_MOTION_NONE)

radiant_troop_blade_mail = class({})

function radiant_troop_blade_mail:GetIntrinsicModifierName()
    return "modifier_radiant_troop_blade_mail"
end

modifier_radiant_troop_blade_mail = class({})

function modifier_radiant_troop_blade_mail:IsHidden() return true end
function modifier_radiant_troop_blade_mail:IsPurgable() return false end

function modifier_radiant_troop_blade_mail:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DAMAGE_CALCULATED
    }
end

function modifier_radiant_troop_blade_mail:OnDamageCalculated( event )
    if not IsServer() then return end

    local ability = self:GetAbility()
    local chance = ability:GetSpecialValueFor("chance")
    local mp = ability:GetSpecialValueFor("damage_reflection")

    local caster = self:GetParent()
    local attacker = event.attacker
    local target = event.target

    if caster:PassivesDisabled() then return end

    if target == caster then
        if RollPercentage(chance) then
            local damage = event.damage * (mp / 100)
            if event.damage_type == DAMAGE_TYPE_PHYSICAL then
                if event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
                    damage = attacker:GetAttackDamage()
                else damage = 50 * event.damage * (mp / 100) end
            end
            ApplyDamage({
                victim=attacker,
                attacker=target,
                damage=damage,
                damage_type=self:GetAbility():GetAbilityDamageType(),
                damage_flags=DOTA_DAMAGE_FLAG_REFLECTION,
                ability=self,
            })
            self:PlayEffects( target )
            caster:EmitSound("Hero_Centaur.Retaliate.Target")
            target:EmitSound("DOTA_Item.BladeMail.Damage")
        end
    end
end

function modifier_radiant_troop_blade_mail:PlayEffects( target )
    local particle_cast = "particles/units/heroes/hero_centaur/centaur_return.vpcf"

    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        0,
        self:GetParent(),
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        self:GetParent():GetOrigin(),
        true
    )
    ParticleManager:SetParticleControlEnt(
        effect_cast,
        1,
        target,
        PATTACH_POINT_FOLLOW,
        "attach_hitloc",
        target:GetOrigin(),
        true
    )
end