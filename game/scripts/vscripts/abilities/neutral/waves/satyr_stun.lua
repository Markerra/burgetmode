require("utils/particles_presets")

LinkLuaModifier("modifier_satyr_stun_slow", "abilities/neutral/waves/satyr_stun", LUA_MODIFIER_MOTION_NONE)

satyr_stun = class({})

function satyr_stun:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	self.effect = particle_warning(caster, 10)
end

function satyr_stun:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
	if not IsServer() then return end
    ParticleManager:DestroyParticle(self.effect, false)
    ParticleManager:ReleaseParticleIndex(self.effect)
end

function satyr_stun:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local team = caster:GetTeamNumber()
	local point = caster:GetAbsOrigin()

	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	local slow_duration = self:GetSpecialValueFor("slow_duration")

	caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    ParticleManager:DestroyParticle(self.effect, false)
    ParticleManager:ReleaseParticleIndex(self.effect)

	local enemies = FindUnitsInRadius(
			team,
			point, 
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			true)

    for _,enemy in pairs(enemies) do
		ApplyDamage({
			victim=enemy,
			attacker=caster,
			damage=damage,
			damage_type=self:GetAbilityDamageType(),
			ability=self,
		})
		enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = duration})
		enemy:AddNewModifier(caster, self, "modifier_satyr_stun_slow", {duration = duration + slow_duration})
	end
	self:PlayEffects( caster )
end

function satyr_stun:PlayEffects( caster )
	local particle = "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf"
	self.effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(self.effect, 0, caster:GetAbsOrigin())
	EmitSoundOn("Hero_Centaur.HoofStomp", caster)
end

modifier_satyr_stun_slow = class({})

function modifier_satyr_stun_slow:IsHidden() return false end
function modifier_satyr_stun_slow:IsDebuff() return true end
function modifier_satyr_stun_slow:IsPurgable() return true end

function modifier_satyr_stun_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_satyr_stun_slow:GetModifierMoveSpeedBonus_Percentage()
	local slow = self:GetAbility():GetSpecialValueFor("slow")
    return -slow
end