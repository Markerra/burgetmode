LinkLuaModifier("modifier_blood_seeker_rupture_debuff", "abilities/neutral/waves/blood_seeker_rupture", LUA_MODIFIER_MOTION_NONE)


blood_seeker_rupture = class({})

function blood_seeker_rupture:OnSpellStart(target)
	local hTarget = target or self:GetCursorTarget()
	local caster = self:GetCaster()

	if not IsServer() then return end
	
	if target then
		hTarget:AddNewModifier(caster, self, "modifier_blood_seeker_rupture_debuff", {duration = 0.3})
	else
		if hTarget:TriggerSpellAbsorb(self) then return end
		hTarget:AddNewModifier(caster, self, "modifier_blood_seeker_rupture_debuff", {duration = self:GetSpecialValueFor("duration")})
		EmitSoundOn("Hero_Bloodseeker.Rupture.Cast", caster)
		EmitSoundOn("Hero_Bloodseeker.Rupture", hTarget)
	end
end

modifier_blood_seeker_rupture_debuff = class({})

function modifier_blood_seeker_rupture_debuff:CalculateDistance(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local distance = (pos1 - pos2):Length2D()
	return distance
end

function modifier_blood_seeker_rupture_debuff:IsPurgable()
	return false
end

if IsServer() then
	function modifier_blood_seeker_rupture_debuff:OnCreated()
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()

		self.movedamage = self:GetParent():GetHealth() * self.ability:GetSpecialValueFor("movement_damage_pct") / 100 / 100
		self.castdamage = self.ability:GetSpecialValueFor("cast_damage")
		self.damagecap = 500
		self.prevLoc = self.parent:GetAbsOrigin()
		
		self.movedamage_think = self.ability:GetSpecialValueFor("movement_damage_pct") / 100
		
		self:StartIntervalThink( 0.25 )
	end

	function modifier_blood_seeker_rupture_debuff:OnRefresh()
		self:OnCreated()
	end

	function modifier_blood_seeker_rupture_debuff:OnIntervalThink()
		if self:CalculateDistance(self.prevLoc, self.parent) < self.damagecap then
			self.movedamage = self.movedamage_think
		
			local move_damage = self:CalculateDistance(self.prevLoc, self.parent) * self.movedamage
			if move_damage > 0 then
				ApplyDamage({victim = self.parent, attacker = self.caster, damage = move_damage, damage_type = self.ability:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self.ability})
				self.caster:Heal(move_damage * (self.ability:GetSpecialValueFor("regen_pct") / 100), self.ability)
				local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, self.caster)
				ParticleManager:ReleaseParticleIndex(healFX)
			end
		end
		self.prevLoc = self:GetParent():GetAbsOrigin()
	end

	function modifier_blood_seeker_rupture_debuff:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_ABILITY_START
		}
	end

	function modifier_blood_seeker_rupture_debuff:OnAbilityStart(params)
		if params.unit == self.parent then
			ApplyDamage({victim = self.parent, attacker = self.caster, damage = self.castdamage, damage_type = self.ability:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL, ability = self.ability})
			self.caster:Heal(self.castdamage, self.ability)
			local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, self.caster)
			ParticleManager:ReleaseParticleIndex(healFX)
		end
	end

	function modifier_blood_seeker_rupture_debuff:OnDestroy()
	end
end

function modifier_blood_seeker_rupture_debuff:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end