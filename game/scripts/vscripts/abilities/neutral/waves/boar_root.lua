LinkLuaModifier("modifier_boar_root_debuff", "abilities/neutral/waves/boar_root", LUA_MODIFIER_MOTION_NONE)

boar_root = class({})

function boar_root:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("n_creep_Kobold.Whip")
	self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
end

function boar_root:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("n_creep_Kobold.Whip")
	self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
end

function boar_root:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")

	if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(caster, self, "modifier_boar_root_debuff", {duration = duration,})
end

modifier_boar_root_debuff = class({})

function modifier_boar_root_debuff:IsDebuff() return true end
function modifier_boar_root_debuff:IsPurgable() return true end

function modifier_boar_root_debuff:OnCreated()
	caster:EmitSound("n_creep_TrollWarlord.Ensnare")
	if not IsServer() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local particle = "particles/neutral_fx/dark_troll_ensnare.vpcf"
	self.effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, parent)
end

function modifier_boar_root_debuff:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.effect, true)
	ParticleManager:ReleaseParticleIndex(self.effect)
end

function modifier_boar_root_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end