require("utils/timers")
require("utils/particles_presets")

LinkLuaModifier("ursa_red_clap_debuff", 
	"abilities/neutral/waves/ursa_red_clap", LUA_MODIFIER_MOTION_NONE)

ursa_red_clap = class({})

function ursa_red_clap:GetCastAnimation()
	return ACT_DOTA_IDLE
end

function ursa_red_clap:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:ClearActivityModifiers()
	self.effect = particle_warning(caster, 50)
end

function ursa_red_clap:OnAbilityPhaseInterrupted()
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster:FadeGesture(ACT_DOTA_IDLE)
	caster:StopSound("n_creep_Ursa.Clap")
	ParticleManager:DestroyParticle(self.effect, false)
	ParticleManager:ReleaseParticleIndex(self.effect)
end

function ursa_red_clap:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local damage = self:GetSpecialValueFor("damage")

	caster:FadeGesture(ACT_DOTA_IDLE)
	caster:AddNewModifier(caster, self, "modifier_rooted", {duration=0.4})

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	caster:EmitSound("n_creep_Ursa.Clap")

	Timers:CreateTimer(0.3, function()
		if caster:IsStunned() or not caster:IsAlive()  then 
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
			caster:StopSound("n_creep_Ursa.Clap")
			return 
		end

		local units = FindUnitsInRadius(
			caster:GetTeam(),
			caster:GetAbsOrigin(), 
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			true)
	
		for k, unit in pairs(units) do
			unit:AddNewModifier(caster, self, "ursa_red_clap_debuff", {duration = duration})
			unit:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration})
			ApplyDamage({
				victim=unit,
				attacker=caster,
				damage=damage,
				damage_type=self:GetAbilityDamageType(),
				ability=self
			})
		end
	
		self:PlayEffects()
	end)
end

function ursa_red_clap:PlayEffects()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local particle = "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf"
	local effect = ParticleManager:CreateParticle( particle, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( effect, 0, caster:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( effect )
end

ursa_red_clap_debuff = class({})

function ursa_red_clap_debuff:IsDebuff() return true end
function ursa_red_clap_debuff:IsPurgable() return true end

function ursa_red_clap_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function ursa_red_clap_debuff:GetModifierMoveSpeedBonus_Percentage()
	local slow = self:GetAbility():GetSpecialValueFor("slow")
    return ( slow * (-1) )
end