modifier_arena_boss_sleep = class({})

function modifier_arena_boss_sleep:IsHidden() return true end
function modifier_arena_boss_sleep:IsDebuff() return true end
function modifier_arena_boss_sleep:IsPurgable() return false end
function modifier_arena_boss_sleep:IsPurgeException() return false end

function modifier_arena_boss_sleep:CheckState()
	return {
		[MODIFIER_STATE_NIGHTMARED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
end

function modifier_arena_boss_sleep:OnCreated( kv )
	_G.boss_stage = true

	if not IsServer() then return end
	local parent = self:GetParent()
	local fx = "particles/units/heroes/hero_riki/riki_shard_sleep.vpcf"
	self.particle = ParticleManager:CreateParticle(fx, PATTACH_OVERHEAD_FOLLOW, parent)
end

function modifier_arena_boss_sleep:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.particle, false)
	ParticleManager:ReleaseParticleIndex(self.particle)
end