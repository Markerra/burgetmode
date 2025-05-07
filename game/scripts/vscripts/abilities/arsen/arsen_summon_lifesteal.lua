LinkLuaModifier("modifier_arsen_summon_lifesteal", "abilities/arsen/arsen_summon_lifesteal", LUA_MODIFIER_MOTION_NONE)

arsen_summon_lifesteal = class({})

function arsen_summon_lifesteal:GetIntrinsicModifierName() return "modifier_arsen_summon_lifesteal" end

modifier_arsen_summon_lifesteal = class({})

function modifier_arsen_summon_lifesteal:IsHidden() return true end
function modifier_arsen_summon_lifesteal:IsPurgable() return false end

function modifier_arsen_summon_lifesteal:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_arsen_summon_lifesteal:OnAttackLanded(event)
	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local attacker = event.attacker
	local target = event.target
	local damage = event.damage

    local lifesteal_pct = ability:GetSpecialValueFor("lifesteal_pct") / 100

	if attacker == caster then
        caster:Heal(damage * lifesteal_pct, ability)
        SendOverheadEventMessage(nil, 10, caster, damage * lifesteal_pct, nil)
        if caster:GetOwner():HasModifier("modifier_arsen_quadrober_shard") then
            caster:GetOwner():Heal(damage * lifesteal_pct, ability)
            SendOverheadEventMessage(nil, 10, caster:GetOwner(), damage * lifesteal_pct, nil)
        end
    end
end