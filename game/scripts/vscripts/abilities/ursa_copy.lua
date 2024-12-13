LinkLuaModifier( "modifier_ursa_copy", "abilities/ursa_copy", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ursa_copy_debuff", "abilities/ursa_copy", LUA_MODIFIER_MOTION_NONE )

ursa_copy = {}

function ursa_copy:GetIntrinsicModifierName()
	return "modifier_ursa_copy"
end

------------------------------------------------------

modifier_ursa_copy = {}
modifier_ursa_copy_debuff = {}

function modifier_ursa_copy:IsHidden()
	return true
end

function modifier_ursa_copy_debuff:IsDebuff()
	return true
end

function modifier_ursa_copy:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

------------------------------------------------------

function modifier_ursa_copy:OnAttackLanded(props)
	if self:GetParent() == props.attacker then
		local modif = props.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ursa_copy_debuff", { duration = self:GetAbility():GetSpecialValueFor("duration") })
		modif:IncrementStackCount()
		ApplyDamage({
			victim = props.target,
			attacker = props.attacker,
			damage = modif:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_stack"),
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = self:GetAbility()
		})
	end
end