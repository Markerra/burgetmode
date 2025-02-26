LinkLuaModifier( "modifier_satyr_linken", "abilities/neutral/waves/satyr_linken", LUA_MODIFIER_MOTION_NONE )

satyr_linken = class({})

function satyr_linken:GetIntrinsicModifierName()
	return "modifier_satyr_linken"
end

modifier_satyr_linken = class({})

function modifier_satyr_linken:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSORB_SPELL,
	}
end

function modifier_satyr_linken:GetAbsorbSpell(params)
	if self:GetAbility():IsCooldownReady() and not self:GetParent():IsMuted() and not self:GetParent():PassivesDisabled() and params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		ApplyDamage({
			victim=params.ability:GetCaster(),
			attacker=self:GetParent(),
			damage=damage,
			damage_type=self:GetAbility():GetAbilityDamageType(),
			ability=self:GetAbility()
		})
		ParticleManager:CreateParticle( "particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		self:GetAbility():StartCooldown( self:GetAbility():GetCooldown(self:GetAbility():GetLevel()) )
		return 1
	end
end

function modifier_satyr_linken:IsHidden()
	return true
end

function modifier_satyr_linken:IsDebuff()
	return false
end

function modifier_satyr_linken:IsPurgable()
	return true
end