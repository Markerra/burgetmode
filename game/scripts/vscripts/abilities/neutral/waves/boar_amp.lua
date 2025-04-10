LinkLuaModifier("modifier_boar_amp", 
	"abilities/neutral/waves/boar_amp", LUA_MODIFIER_MOTION_NONE)

boar_amp = class({})

function boar_amp:OnAbilityPhaseStart()
	self.sound = "Hero_Lycan.Howl"
	self:GetCaster():EmitSound(self.sound)
	self:GetCaster():StartGesture(ACT_DOTA_SPAWN)
end

function boar_amp:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound(self.sound)
	self:GetCaster():FadeGesture(ACT_DOTA_SPAWN)
end

function boar_amp:OnSpellStart()
	local caster = self:GetCaster()

	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	
	local units = FindUnitsInRadius(
		caster:GetTeam(),
		caster:GetAbsOrigin(), 
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		true)

	for k, unit in pairs(units) do
		unit:AddNewModifier(caster, self, 
			"modifier_boar_amp", {duration = duration})
	end
end

modifier_boar_amp = class({})

function modifier_boar_amp:IsPurgable() return true end

function modifier_boar_amp:OnCreated()
	parent:EmitSound("Hero_Lycan.Wolf.GeistForm")
	if not IsServer() then return end
	local parent = self:GetParent()
	local particle = "particles/custom/neutral/amplify_damage.vpcf"
	self.effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, parent)
end

function modifier_boar_amp:OnRefresh()
	local stacks = self:GetStackCount()
	self:SetStackCount( stacks+1 )
	self:GetParent():EmitSound("Hero_Lycan.Wolf.GeistForm")
end

function modifier_boar_amp:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.effect, false)
	ParticleManager:ReleaseParticleIndex(self.effect)
end

function modifier_boar_amp:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_boar_amp:GetModifierPreAttack_BonusDamage()
	local amp = self:GetAbility():GetSpecialValueFor("damage_amp") 
	local stacks = self:GetStackCount()
	if stacks == 0 then return amp
	else return amp * self:GetStackCount() end
end