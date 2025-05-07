LinkLuaModifier("modifier_arsen_summon_defense", "abilities/arsen/arsen_summon_defense", LUA_MODIFIER_MOTION_NONE)

arsen_summon_defense = class({})

function arsen_summon_defense:GetIntrinsicModifierName() return "modifier_arsen_summon_defense" end

modifier_arsen_summon_defense = class({})

function modifier_arsen_summon_defense:IsHidden() return true end
function modifier_arsen_summon_defense:IsPurgable() return false end

function modifier_arsen_summon_defense:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DAMAGE_CALCULATED
    }
end

function modifier_arsen_summon_defense:OnDamageCalculated(event)
    local caster = self:GetCaster()
    local attacker = event.attacker
    local target = event.target
    local damage = event.damage
    local dmg_type = event.damage_type

    local phys_resist = self:GetAbility():GetSpecialValueFor("phys_resist") / 100
    local magic_resist = self:GetAbility():GetSpecialValueFor("magic_resist") / 100

    if target == caster and (attacker:IsCreep() or attacker:IsNeutralUnitType()) then
        if dmg_type == DAMAGE_TYPE_PHYSICAL then
            caster:Heal(damage - (damage * phys_resist), nil)
            print(damage * phys_resist)
        end
        if dmg_type == DAMAGE_TYPE_MAGICAL then
            caster:Heal(damage - (damage * magic_resist), nil)
            print(damage * magic_resist)
        end
    end
end