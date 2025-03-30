LinkLuaModifier( "modifier_boss_roshan_clap", "abilities/neutral/boss/boss_roshan_clap", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_arc_lua", "modifiers/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH )

boss_roshan_clap = class({})

--------------------------------------------------------------------------------
-- Ability Start
function boss_roshan_clap:OnAbilityPhaseStart()
	if not IsServer() then return end
	self:PlayEffects1()
	return true
end

function boss_roshan_clap:OnAbilityPhaseInterrupted()
	if not IsServer() then return end
	self:StopEffects1( true )
end


function boss_roshan_clap:OnSpellStart()
    local caster = self:GetCaster()

    self:StopEffects1(false)

    local fx = "particles/neutral_fx/roshan_slam.vpcf"
    local particle = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    EmitSoundOn("Roshan.Slam", caster)

    ScreenShake(caster:GetAbsOrigin(), 800, 1.1, 0.3, 4000, 0, true)

    local name = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf"
    local distance = self:GetSpecialValueFor("radius")
    local radius = self:GetSpecialValueFor("shock_width")
    local speed = self:GetSpecialValueFor("shock_speed")

    local num_projectiles = self:GetSpecialValueFor( "amout" )
    local angle_increment = 360 / num_projectiles 

    for i = 0, num_projectiles - 1 do
        local angle = i * angle_increment
        local rad = math.rad(angle)
        local direction = Vector(math.cos(rad), math.sin(rad), 0)

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
            bDeleteOnHit = true,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            EffectName = name,
            fDistance = distance,
            fStartRadius = radius,
            fEndRadius = radius,
            vVelocity = direction * speed,
        }
        ProjectileManager:CreateLinearProjectile(info)
    end

    -- play effects
    local sound_cast = "Hero_Magnataur.ShockWave.Particle"
    EmitSoundOn(sound_cast, caster)
end

--------------------------------------------------------------------------------
-- Projectile
function boss_roshan_clap:OnProjectileHit( target, location )
	if not target then return end

	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor( "shock_damage" )
	local duration = self:GetSpecialValueFor( "slow_duration" )

	local pull_duration = self:GetSpecialValueFor( "pull_duration" )
	local pull_distance = self:GetSpecialValueFor( "pull_distance" )

	-- damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- pull
	local mod = target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_arc_lua", -- modifier name
		{
			target_x = location.x,
			target_y = location.y,
			duration = pull_duration,
			distance = pull_distance,
			activity = ACT_DOTA_FLAIL,
		} -- kv
	)

	-- slow
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_boss_roshan_clap", -- modifier name
		{ duration = duration } -- kv
	)

	-- play effects
	self:PlayEffects2( target, mod )

	return false
end

--------------------------------------------------------------------------------
-- Effects
function boss_roshan_clap:PlayEffects2( target, mod )

	if not target or not mod then return end

	local particle_cast = "particles/units/heroes/hero_magnataur/magnataur_shockwave_hit.vpcf"
	local sound_cast = "Hero_Magnataur.ShockWave.Target"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	mod:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end

function boss_roshan_clap:PlayEffects1()
	local caster = self:GetCaster()

	local particle_cast = "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf"
	local sound_cast = "Hero_Magnataur.ShockWave.Cast"


	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		caster,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	self.effect_cast = effect_cast

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)

	EmitSoundOn( sound_cast, caster )
end

function boss_roshan_clap:StopEffects1( bInterrupted )
	ParticleManager:DestroyParticle( self.effect_cast, bInterrupted )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
	self:GetCaster():FadeGesture(ACT_DOTA_CAST_ABILITY_3)
	local sound_cast = "Hero_Magnataur.ShockWave.Cast"
	StopSoundOn( sound_cast, self:GetCaster() )
end

modifier_boss_roshan_clap = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_boss_roshan_clap:IsHidden()
	return false
end

function modifier_boss_roshan_clap:IsDebuff()
	return true
end

function modifier_boss_roshan_clap:IsStunDebuff()
	return false
end

function modifier_boss_roshan_clap:IsPurgable()
	return true
end

function modifier_boss_roshan_clap:OnCreated( kv )
	self.slow = -self:GetAbility():GetSpecialValueFor( "movement_slow" )
	if not IsServer() then return end
end

function modifier_boss_roshan_clap:OnRefresh( kv )
	end

function modifier_boss_roshan_clap:OnRemoved()
end

function modifier_boss_roshan_clap:OnDestroy()
end

function modifier_boss_roshan_clap:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_boss_roshan_clap:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_boss_roshan_clap:GetEffectName()
	return "particles/units/heroes/hero_magnataur/magnataur_skewer_debuff.vpcf"
end

function modifier_boss_roshan_clap:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end