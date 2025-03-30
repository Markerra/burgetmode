modifier_wtf = class({})

function modifier_wtf:IsPurgable() return false end
function modifier_wtf:IsHidden()   return true end

function modifier_wtf:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT,
		MODIFIER_PROPERTY_MANACOST_REDUCTION_CONSTANT,
	}
end

function modifier_wtf:GetModifierManacostReduction_Constant()
	return 1000
end

function modifier_wtf:GetModifierCooldownReduction_Constant()
	return 1000
end