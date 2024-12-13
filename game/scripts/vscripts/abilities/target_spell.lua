LinkLuaModifier("target_spell_modifier", "abilities/target_spell", LUA_MODIFIER_MOTION_NONE)

target_spell = {}

function target_spell:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	target:AddNewModifier(caster, self, "target_spell_modifier", {duration = 5})

end

target_spell_modifier = {}

function target_spell_modifier:IsHidden()
	return false
end

function target_spell_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
end

function target_spell_modifier:GetModifierMoveSpeedBonus_Constant()
	return -150
end

function target_spell_modifier:OnCreated()
	self:StartIntervalThink(0.5)
end

function target_spell_modifier:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = 50,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility()
	})
	
end