modifier_wave_creep_tracker = class({})

function modifier_wave_creep_tracker:IsPurgable() return false end
function modifier_wave_creep_tracker:IsHidden() return true end

function modifier_wave_creep_tracker:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_wave_creep_tracker:OnDeath( event )
	local unit = event.unit
end