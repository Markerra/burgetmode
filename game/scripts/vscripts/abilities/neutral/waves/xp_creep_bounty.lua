LinkLuaModifier("modifier_xp_creep_bounty", "abilities/neutral/waves/xp_creep_bounty", LUA_MODIFIER_MOTION_NONE)

xp_creep_bounty = class({})

function xp_creep_bounty:GetIntrinsicModifierName()
	return "modifier_xp_creep_bounty"
end

modifier_xp_creep_bounty = class({})

function modifier_xp_creep_bounty:IsPurgable() return false end
function modifier_xp_creep_bounty:IsDebuff() return false end
function modifier_xp_creep_bounty:IsHidden() return true end

function modifier_xp_creep_bounty:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_xp_creep_bounty:OnAttackLanded( event )
	local parent = self:GetParent()
	local target = event.target
	local attacker = event.attacker

	if target == parent and attacker:IsHero() then
		local xp = self:GetAbility():GetSpecialValueFor("xpa")
		attacker:AddExperience(xp, DOTA_ModifyXP_HeroKill, false, false)
		SendOverheadEventMessage(nil, 3, attacker, xp, nil)
	end
end

function modifier_xp_creep_bounty:OnDeath( event )
	local attacker = event.attacker
	local target = event.unit
	local parent = self:GetParent()
	local xp = self:GetAbility():GetSpecialValueFor("bounty")

	if target == parent and attacker and attacker:IsHero() then
		attacker:AddExperience(xp, DOTA_ModifyXP_HeroKill, false, false)
		SendOverheadEventMessage(nil, 3, attacker, xp, nil)
		EmitSoundOn("Rune.XP", parent)

		local particle = "particles/base_static/experience_shrine_crack_glow_burst_flare.vpcf"
		local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, parent)
		ParticleManager:ReleaseParticleIndex(effect)
	end
end