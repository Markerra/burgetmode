LinkLuaModifier("matvey_metka_modifier", "abilities/matvey/matvey_metka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("matvey_metka_modifier_debuff", "abilities/matvey/matvey_metka", LUA_MODIFIER_MOTION_NONE)

matvey_metka = class({})

function matvey_metka:OnAbilityPhaseStart()
	if not IsServer() then return end

	self.target = self:GetCursorTarget()

	self.sound_effect = "Hero_TemplarAssassin.Trap.Cast"
	self.target:EmitSoundParams(
	self.sound_effect, 0, 1.5, 0)
end

function matvey_metka:OnAbilityPhaseInterrupted()
	if not IsServer() then return end
	self.target:StopSound(self.sound_effect)
end

function matvey_metka:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	local particle = "particles/custom/matvey/matvey_metka/matvey_metka_marker.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.target)

	self.target:AddNewModifier(caster, self, "matvey_metka_modifier_debuff", 
	{duration = duration, effect = effect})
end

matvey_metka_modifier_debuff = class({})


function matvey_metka_modifier_debuff:IsDebuff() return true end
function matvey_metka_modifier_debuff:IsHidden() return false end
function matvey_metka_modifier_debuff:IsPurgable() return true end

function matvey_metka_modifier_debuff:OnCreated( kv )
	local sound1    = "Hero_Kez.GrapplingClaw.Katana.Slow"
	self.sound_loop = "Hero_Oracle.PurifyingFlames"
	self:GetParent():EmitSound(sound1)
	self:GetParent():EmitSound(self.sound_loop)

	self.effect = kv.effect
end

function matvey_metka_modifier_debuff:OnRefresh()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.effect, true)
	ParticleManager:ReleaseParticleIndex(self.effect)
end

function matvey_metka_modifier_debuff:OnDestroy()
	if not IsServer() then return end

	ParticleManager:DestroyParticle(self.effect, false)
	ParticleManager:ReleaseParticleIndex(self.effect)
end

function matvey_metka_modifier_debuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	} 
end

function matvey_metka_modifier_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function matvey_metka_modifier_debuff:GetModifierMagicalResistanceBonus()
	return -self:GetAbility():GetSpecialValueFor("resist_decrease")
end

function matvey_metka_modifier_debuff:OnDeath( event )
	if not IsServer() then return end

	local unit = event.unit
	local target = self:GetAbility().target
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	if target == unit then
		local modif = caster:FindModifierByName("matvey_metka_modifier")

		if modif then
			local stacks = modif:GetStackCount()
			modif:SetStackCount(stacks + 1)
		else
			modif = caster:AddNewModifier(caster, ability, "matvey_metka_modifier", {})
		end
		EmitSoundOnLocationForAllies(target:GetAbsOrigin(), "Hero_Muerta.Ofrenda.Destroy", caster)
	end
end

matvey_metka_modifier = class({})

function matvey_metka_modifier:IsDebuff() return false end
function matvey_metka_modifier:IsHidden() return false end
function matvey_metka_modifier:IsPurgable() return false end

function matvey_metka_modifier:OnCreated()
	if not IsServer() then return end

	self:SetStackCount(1)
end

function matvey_metka_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	} 
end

function matvey_metka_modifier:GetModifierBonusStats_Intellect()
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	return ability:GetSpecialValueFor("kill_bonus_int") * stacks
end

function matvey_metka_modifier:GetModifierBonusStats_Agility()
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	return ability:GetSpecialValueFor("kill_bonus_ag") * stacks
end