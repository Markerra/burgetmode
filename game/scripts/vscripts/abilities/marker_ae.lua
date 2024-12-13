LinkLuaModifier( "modifier_marker_ae", "abilities/marker_ae", LUA_MODIFIER_MOTION_NONE )

marker_ae = class({})

function marker_ae:GetIntrinsicModifierName()
	return "modifier_marker_ae"
end

modifier_marker_ae = class({})

function modifier_marker_ae:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function modifier_marker_ae:OnAbilityExecuted()
	return
end