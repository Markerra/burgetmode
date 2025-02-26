LinkLuaModifier("modifier_blood_seeker_attack", "abilities/neutral/waves/blood_seeker_attack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blood_seeker_attack_debuff", "abilities/neutral/waves/blood_seeker_attack", LUA_MODIFIER_MOTION_NONE)

blood_seeker_attack = class({})

function blood_seeker_attack:GetIntrinsicModifierName()
	return "modifier_blood_seeker_attack"
end

modifier_blood_seeker_attack = class({})

function modifier_blood_seeker_attack:IsHidden() return true end
function modifier_blood_seeker_attack:IsPurgable() return false end

function modifier_blood_seeker_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_blood_seeker_attack:OnAttackLanded( event )
	if not IsServer() then return end

	local ability = self:GetAbility()
	local chance = ability:GetSpecialValueFor("chance")
	local duration = ability:GetSpecialValueFor("duration")
	local lifesteal = ability:GetSpecialValueFor("lifesteal_pct")

	local caster = self:GetParent()
	local attacker = event.attacker
	local target = event.target

	if caster:PassivesDisabled() then return end

	if attacker == caster then
		if RollPercentage(chance) then
			local hp = event.damage * (lifesteal / 100)
			caster:Heal( hp, caster )
			SendOverheadEventMessage(nil, 10, caster, hp, nil)
			self:PlayEffects()
			target:AddNewModifier(
				caster, 
				ability, 
				"modifier_blood_seeker_attack_debuff", 
				{duration = duration})
		end
	end
end

function modifier_blood_seeker_attack:PlayEffects()
	local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_blood_seeker_attack_debuff = class({})

function modifier_blood_seeker_attack_debuff:IsHidden() return false end
function modifier_blood_seeker_attack_debuff:IsPurgable() return false end
function modifier_blood_seeker_attack_debuff:IsDebuff() return true end

function modifier_blood_seeker_attack_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
	}
end

function modifier_blood_seeker_attack_debuff:GetModifierHPRegenAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("health_regen_amp")
end