require("utils/timers")

LinkLuaModifier("marker_hammer_debuff", "abilities/marker/marker_hammer", LUA_MODIFIER_MOTION_NONE)

marker_hammer = class({})

function marker_hammer:Precache( context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context)
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_calavera_hammer_projectile.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_crimson_ti8_immortal_pitofmalice_stun.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf", context )
end

function marker_hammer:OnSpellStart()
    local caster = self:GetCaster()
    self.point = self:GetCursorPosition()

    local speed = 900
    local distance = self:GetCastRange(caster:GetOrigin(), caster)
    local direction = self.point - caster:GetOrigin()
    local radius = self:GetSpecialValueFor("radius")

    self.target_position = caster:GetOrigin() + direction:Normalized() * distance

    local info = {
        EffectName = " ",
        Ability = self,
        Source = caster,
        vSpawnOrigin = caster:GetOrigin(),
        fStartRadius = radius - 50,
        fEndRadius = radius,
        fDistance = distance,
        iMoveSpeed = speed,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        vVelocity = direction:Normalized() * speed,
        bProvidesVision = true,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iVisionNumber = 200,
}
    self.projectile = ProjectileManager:CreateLinearProjectile(info)

    if self.projectile then
        self.hammer_particle = self:PlayEffects1(caster:GetAbsOrigin(), distance, direction:Normalized() * speed, speed)
    end
    self:SetActivated(false)
    self:EndCooldown()
end

function marker_hammer:GetAOERadius()
    local radius = self:GetSpecialValueFor("radius")    
    return radius
end

function marker_hammer:OnProjectileHit(target)

    local caster = self:GetCaster()

	if not target then
        local facet = caster:GetHeroFacetID()
        if facet == 4 then -- marker_hammer Facet
            local manacost = self:GetManaCost(self:GetLevel() - 1)
            local mana = manacost * (self:GetSpecialValueFor("mana_restore") / 100)
            local cooldown = self:GetCooldown(self:GetLevel())
             * (self:GetSpecialValueFor("cooldown_reduction") / 100)

            self:StartCooldown(cooldown)
            print(self:GetLevel())

            caster:GiveMana(mana)
            SendOverheadEventMessage(nil, 11, caster, mana, nil)
        end

        StopSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Projectile", caster)
        ParticleManager:DestroyParticle(self.hammer_particle, false)
        ParticleManager:ReleaseParticleIndex(self.hammer_particle)

		local exp_particle = "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf"
    	local exp_effect = ParticleManager:CreateParticle(exp_particle, PATTACH_WORLDORIGIN, nil)
    	ParticleManager:SetParticleControl(exp_effect, 0, self.target_position + Vector(0, 0, 120))
        ParticleManager:ReleaseParticleIndex(exp_effect)
    	EmitSoundOnLocationWithCaster(self.target_position, "Hero_Dawnbreaker.Celestial_Hammer.Impact", self:GetCaster())
		self:SetActivated(true)
        if not facet == 4 then self:StartCooldown(self:GetCooldown(self:GetLevel())) end
        return 
	end

    local radius = self:GetSpecialValueFor("radius")

    local units = FindUnitsInRadius(
        caster:GetTeamNumber(),      
        target:GetAbsOrigin(),       
        nil,                         
        radius,                      
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO,        
        DOTA_UNIT_TARGET_FLAG_NONE,  
        FIND_ANY_ORDER,              
        false                        
    )

    for _, unit in ipairs(units) do
        if unit:TriggerSpellAbsorb(self) then return end
    	local dmg = self:GetSpecialValueFor("damage")
    	ApplyDamage({
    		victim = unit,
    		attacker = caster,
    		damage = dmg,
    		damage_type = 2,
    		ability = self,
    	})
        unit:AddNewModifier(caster, self, "marker_hammer_debuff", {duration = self:GetSpecialValueFor("duration")})
    end

    self:SetActivated(true)
    self:StartCooldown(self:GetCooldown(self:GetLevel()))

    StopSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Projectile", self:GetCaster())
    ParticleManager:DestroyParticle(self.hammer_particle, false)
    ParticleManager:ReleaseParticleIndex(self.hammer_particle)

    EmitSoundOn("Hero_Dawnbreaker.Solar_Guardian.Stun", target)

    return true
end


function Direction2D(v1, v2)
    local direction = v2 - v1
    direction = direction:Normalized()
    return direction
end

function marker_hammer:PlayEffects1( start, distance, velocity, speed )

	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Cast"

	local min_rate = 1
	local duration = distance/velocity:Length2D()
	local rotation = 0.01


	local rate = rotation/duration
	while rate<min_rate do
		rotation = rotation + 1
		rate = rotation/duration
	end

	local hCaster = self:GetCaster()

	self.vOrigin = hCaster:GetAbsOrigin()
    local vDir = Direction2D(self.vOrigin, self.point)
    effect_cast = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_dawnbreaker/dawnbreaker_calavera_hammer_projectile.vpcf", PATTACH_WORLDORIGIN,
        nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.vOrigin)
    ParticleManager:SetParticleControl(effect_cast, 1, vDir * speed)
    ParticleManager:SetParticleControl(effect_cast, 4, Vector(3, 0, 0))

	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn("Hero_Dawnbreaker.Celestial_Hammer.Projectile", self:GetCaster())

	return effect_cast
end

marker_hammer_debuff = class({})

function marker_hammer_debuff:IsDebuff() return true end
function marker_hammer_debuff:IsHidden() return false end

function marker_hammer_debuff:OnCreated()

	local parent = self:GetParent()

	local effect1 = "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf"

	local effect2 = "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_crimson_ti8_immortal_pitofmalice_stun.vpcf"

	self.particle = ParticleManager:CreateParticle(effect1, PATTACH_ABSORIGIN, parent)
	self.particle2 = ParticleManager:CreateParticle(effect2, PATTACH_ABSORIGIN, parent)

	EmitSoundOn( "Hero_AbyssalUnderlord.Pit.TargetHero", parent )
end

function marker_hammer_debuff:OnDestroy()
	ParticleManager:DestroyParticle(self.particle, false)
	ParticleManager:ReleaseParticleIndex(self.particle)

	ParticleManager:DestroyParticle(self.particle2, true)
	ParticleManager:ReleaseParticleIndex(self.particle2)
end

function marker_hammer_debuff:DeclareFuncitons()
	return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end

function marker_hammer_debuff:GetModifierIncomingDamage_Percentage()
	local amp = self:GetAbility():GetSpecialValueFor("dmg_decrease")
	return -amp
end

function marker_hammer_debuff:CheckState()
    return {
    	[MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }
end