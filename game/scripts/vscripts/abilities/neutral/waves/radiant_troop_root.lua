LinkLuaModifier("modifier_radiant_troop_root", "abilities/neutral/waves/radiant_troop_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_radiant_troop_root_debuff", "abilities/neutral/waves/radiant_troop_root", LUA_MODIFIER_MOTION_NONE)

radiant_troop_root = class({})

function radiant_troop_root:GetIntrinsicModifierName()
	return "modifier_radiant_troop_root"
end

modifier_radiant_troop_root = class({})

function modifier_radiant_troop_root:IsHidden() return true end
function modifier_radiant_troop_root:IsPurgable() return true end

function modifier_radiant_troop_root:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_radiant_troop_root:OnAttackLanded( event )
	if not IsServer() then return end

	local ability = self:GetAbility()
	local chance = ability:GetSpecialValueFor("chance")
	local duration = ability:GetSpecialValueFor("duration")

	local caster = self:GetParent()
	local attacker = event.attacker
	local target = event.target

	if caster:PassivesDisabled() then return end

	if attacker == caster and target:IsHero() then
		if RollPercentage(chance) then
			target:AddNewModifier(
				caster, 
				ability, 
				"modifier_radiant_troop_root_debuff", 
				{duration = duration})
			EmitSoundOn("Hero_Treant.NaturesGrasp.Cast", caster)
			EmitSoundOn("Hero_Treant.NaturesGrasp.Spawn", target)
		end
	end
end


modifier_radiant_troop_root_debuff = class({})

function modifier_radiant_troop_root_debuff:IsHidden() return false end
function modifier_radiant_troop_root_debuff:IsPurgable() return false end
function modifier_radiant_troop_root_debuff:IsDebuff() return true end

function modifier_radiant_troop_root_debuff:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_radiant_troop_root_debuff:OnCreated( kv )
	if not IsServer() then return end

	self.interval = kv.duration * 0.1 -- 2 * 0.1 = 0.2
	self:StartIntervalThink(self.interval)

	local particle_cast = "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_small.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetAbsOrigin())
	local particle_cast2 = "particles/units/heroes/hero_treant/treant_naturesguise_cast.vpcf"
	self.effect_cast2 = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl(self.effect_cast2, 1, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.effect_cast2, 2, self:GetParent():GetAbsOrigin())
end

function modifier_radiant_troop_root_debuff:OnIntervalThink()
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local damage = ability:GetSpecialValueFor("damage") * self.interval

	ApplyDamage({
		victim=parent,
		attacker=caster,
		damage=damage,
		damage_type=ability:GetAbilityDamageType(),
		ability=ability
	})

	EmitSoundOn("Hero_Treant.NaturesGrasp.Damage", parent)
	--SendOverheadEventMessage(nil, 6, caster, damage, nil)
end

function modifier_radiant_troop_root_debuff:OnDestroy()
	if not IsServer() then return end

	local parent = self:GetParent()
	StopSoundOn("Hero_Treant.NaturesGrasp.Damage", parent)
	EmitSoundOn("Hero_Treant.NaturesGrasp.Destroy", parent)

	ParticleManager:DestroyParticle(self.effect_cast, false)
	ParticleManager:DestroyParticle(self.effect_cast2, false)
end