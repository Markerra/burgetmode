matvey_petard_blink = class({})

function matvey_petard_blink:ProcsMagicStick() return false end

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

------------------------------------------------------------------------------------------------

    local enemies = FindUnitsInRadius(caster:GetTeam(), pos, nil, 900,
	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	for _, enemy in pairs(enemies) do
        local damage = ability:GetSpecialValueFor("damage")
		ApplyDamage({
			victim = enemy,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability,
		})
		local duration = ability:GetSpecialValueFor("stun_duration")
		enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = duration})
    end

    local exp = ParticleManager:CreateParticle( "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_WORLDORIGIN, ability.missile )
    ParticleManager:SetParticleControl(exp, 3, ability.missile:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(exp)
    EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Explode", ability.missile)

------------------------------------------------------------------------------------------------

    StopSoundOn("Hero_Gyrocopter.HomingMissile", ability.missile)
	ability.missile:Destroy()

    if ability.target:GetUnitName() == "npc_dota_companion" then
        ability.target:Destroy()
    end

    self:SetActivated(false)

    ability:SetActivated(true)
    ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
end