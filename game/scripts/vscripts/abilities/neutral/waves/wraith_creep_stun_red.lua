LinkLuaModifier("modifier_wraith_creep_stun_red", "abilities/neutral/waves/wraith_creep_stun_red", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_wraith_creep_stun_red_slow", "abilities/neutral/waves/wraith_creep_stun_red", LUA_MODIFIER_MOTION_NONE )

wraith_creep_stun_red = class({})

function wraith_creep_stun_red:OnSpellStart()
	local target = self:GetCursorTarget()
	local projectile_speed = 1000
	local projectile_name = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_red.vpcf"

	local info = {
		EffectName = projectile_name,
		Ability = self,
		iMoveSpeed = projectile_speed,
		Source = self:GetCaster(),
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
	}
	ProjectileManager:CreateTrackingProjectile( info )

	self:PlayEffects1()
end

function wraith_creep_stun_red:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:IsMagicImmune() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
		local stun_duration = self:GetSpecialValueFor( "stun_duration" )
		local stun_damage = self:GetSpecialValueFor("stun_damage")
		local dot_duration = self:GetSpecialValueFor( "slow_duration" )

		ApplyDamage({
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = stun_damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		})

		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_wraith_creep_stun_red", { duration = stun_duration } )
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_wraith_creep_stun_red_slow", { duration = stun_duration + dot_duration } )

		self:PlayEffects2( hTarget )
	end

	return true
end

function wraith_creep_stun_red:PlayEffects1()
	local sound_cast = "Hero_SkeletonKing.Hellfire_Blast"
	self:GetCaster():EmitSound( sound_cast )
end
function wraith_creep_stun_red:PlayEffects2( target )
	local sound_impact = "Hero_SkeletonKing.Hellfire_BlastImpact"
	target:EmitSound( sound_impact )
end


modifier_wraith_creep_stun_red = class({})

function modifier_wraith_creep_stun_red:IsHidden() return true end
function modifier_wraith_creep_stun_red:IsDebuff() return true end
function modifier_wraith_creep_stun_red:IsPurgable() return true end

function modifier_wraith_creep_stun_red:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_wraith_creep_stun_red:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end

function modifier_wraith_creep_stun_red:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end

function modifier_wraith_creep_stun_red:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end


modifier_wraith_creep_stun_red_slow = class({})

function modifier_wraith_creep_stun_red_slow:IsDebuff()
	return true
end

function modifier_wraith_creep_stun_red_slow:OnCreated( kv )
	self.dot_damage = self:GetAbility():GetSpecialValueFor("burn_damage")
	self.dot_slow = self:GetAbility():GetSpecialValueFor("slow")
	self.tick = 0
	self.interval = self:GetRemainingTime()/kv.duration
	self.duration = kv.duration

	self:StartIntervalThink( self.interval )
end

function modifier_wraith_creep_stun_red_slow:OnRefresh( kv )
	self.dot_damage = self:GetAbility():GetSpecialValueFor("burn_damage")
	self.dot_slow = self:GetAbility():GetSpecialValueFor("slow")
	self.tick = 0
	self.interval = self:GetRemainingTime()/kv.duration 
	self.duration = kv.duration

	self:StartIntervalThink( self.interval )
end

function modifier_wraith_creep_stun_red_slow:OnDestroy()
	if IsServer() then
		if self.tick < self.duration then
			self:OnIntervalThink()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_wraith_creep_stun_red_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_wraith_creep_stun_red_slow:GetModifierMoveSpeedBonus_Percentage( params )
	return -self.dot_slow
end

--------------------------------------------------------------------------------

function modifier_wraith_creep_stun_red_slow:OnIntervalThink()
	if IsServer() then
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.dot_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
	end

	self.tick = self.tick + 1
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_wraith_creep_stun_red_slow:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff_red.vpcf"
end

function modifier_wraith_creep_stun_red_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end