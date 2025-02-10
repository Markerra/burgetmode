LinkLuaModifier("modifier_boar_slow", "abilities/neutral/waves/boar_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boar_slow_debuff", "abilities/neutral/waves/boar_slow", LUA_MODIFIER_MOTION_NONE)

boar_slow = class({})

function boar_slow:GetIntrinsicModifierName()
	return "modifier_boar_slow"
end

modifier_boar_slow = class({})

function modifier_boar_slow:IsHidden() return true end

function modifier_boar_slow:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_boar_slow:OnAttackLanded( event )
	if self:GetCaster():PassivesDisabled() then return end

	local ability = self:GetAbility()
	local chance = ability:GetSpecialValueFor("chance")
	local duration = ability:GetSpecialValueFor("duration")

	local caster = self:GetCaster()
	local target = event.target

	if event.attacker == caster then
		if RollPercentage(chance) then 
			target:AddNewModifier(
				caster, 
				ability, 
				"modifier_boar_slow_debuff", 
				{duration = duration})
			target:Purge(true, false, false, false, false)
			local particle = "particles/generic_gameplay/generic_purge.vpcf"
			self.effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:ReleaseParticleIndex(self.effect)
			EmitSoundOn("n_creep_SatyrTrickster.Cast", target)
		end
	end
end

modifier_boar_slow_debuff = class({})

function modifier_boar_slow_debuff:IsDebuff() return true end
function modifier_boar_slow_debuff:IsPurgable() return true end

function modifier_boar_slow_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_boar_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
	local slow = self:GetAbility():GetSpecialValueFor("slow")
    return ( slow * (-1) )
end

function modifier_boar_slow_debuff:GetModifierAttackSpeedBonus_Constant()
	local slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    return ( slow * (-1) )
end