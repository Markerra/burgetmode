function particle_warning( caster, offset )
	local particle = "particles/custom/general/exclamation.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(effect, 0, caster:GetAbsOrigin()+Vector(0,0,offset))
	return effect
end

function particle_aoe( caster, radius )
	local effect = ParticleManager:CreateParticle( "particles/custom/general/range_finder_aoe.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(effect, 2, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(effect, 3, Vector( radius, radius, radius ) )
	return effect
end