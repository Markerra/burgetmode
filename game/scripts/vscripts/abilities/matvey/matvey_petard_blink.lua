matvey_petard_blink = class({})

function matvey_petard_blink:Spawn()
    if not IsServer() then return end
    self:SetActivated(false)
end

function matvey_petard_blink:GetBehavior()
    local caster = self:GetCaster()

    if caster:HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
    else
        return DOTA_ABILITY_BEHAVIOR_HIDDEN
    end

end

function matvey_petard_blink:OnSpellStart()
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("matvey_petard")

    if not ability.missile then return end

	local pos = ability.missile:GetAbsOrigin()

	local start_fx = "particles/econ/events/ti6/blink_dagger_start_ti6.vpcf"
	local start_p = ParticleManager:CreateParticle(start_fx, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(start_p, 0, caster:GetAbsOrigin())

	EmitSoundOn("DOTA_Item.BlinkDagger.Activate", caster)

	FindClearSpaceForUnit(caster, pos, true)

	local end_fx = "particles/econ/events/ti6/blink_dagger_end_ti6.vpcf"
	local end_p = ParticleManager:CreateParticle(end_fx, PATTACH_WORLDORIGIN, ability.missile)
	ParticleManager:SetParticleControl(end_p, 0, pos)

    StopSoundOn("Hero_Gyrocopter.HomingMissile", ability.missile)
	ability.missile:Destroy()

    if ability.target:GetUnitName() == "npc_dota_companion" then
        ability.target:Destroy()
    end

    self:SetActivated(false)

    ability:SetActivated(true)
    ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
end