LinkLuaModifier( "modifier_ursa_yellow_swipes", "abilities/neutral/waves/ursa_yellow_swipes", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ursa_yellow_swipes_debuff", "abilities/neutral/waves/ursa_yellow_swipes", LUA_MODIFIER_MOTION_NONE )

ursa_yellow_swipes = {}

function ursa_yellow_swipes:GetIntrinsicModifierName()
	return "modifier_ursa_yellow_swipes"
end

------------------------------------------------------

modifier_ursa_yellow_swipes = {}
modifier_ursa_yellow_swipes_debuff = {}

function modifier_ursa_yellow_swipes:IsHidden()
	return true
end

function modifier_ursa_yellow_swipes_debuff:IsDebuff()
	return true
end

function modifier_ursa_yellow_swipes_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_ursa_yellow_swipes:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

------------------------------------------------------

function modifier_ursa_yellow_swipes:OnAttackLanded( props )
	if self:GetCaster():PassivesDisabled() then return end

	if self:GetParent() == props.attacker then
		local modif = props.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ursa_yellow_swipes_debuff", { duration = self:GetAbility():GetSpecialValueFor("duration") })
		modif:IncrementStackCount()
		ApplyDamage({
			victim = props.target,
			attacker = props.attacker,
			damage = modif:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_stack"),
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility()
		})
	end
end

function modifier_ursa_yellow_swipes_debuff:OnTooltip()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_stack")
end