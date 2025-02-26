require("utils/timers")

LinkLuaModifier("modifier_wraith_creep_reincarnate_red", "abilities/neutral/waves/wraith_creep_reincarnate_red", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wraith_creep_reincarnate_red_debuff", "abilities/neutral/waves/wraith_creep_reincarnate_red", LUA_MODIFIER_MOTION_NONE)

wraith_creep_reincarnate_red = class({})

function wraith_creep_reincarnate_red:GetIntrinsicModifierName()
	return "modifier_wraith_creep_reincarnate_red"
end

modifier_wraith_creep_reincarnate_red = class({})

function modifier_wraith_creep_reincarnate_red:IsHidden()
	return false
end

function modifier_wraith_creep_reincarnate_red:IsPurgable()
	return false
end

function modifier_wraith_creep_reincarnate_red:OnCreated()
	local parent = self:GetParent()
	self.reincarnate_time = self:GetAbility():GetSpecialValueFor( "reincarnate_time" )
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" )
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )

	if not IsServer() then return end

	parent:SetMinimumGoldBounty(0)
	parent:SetMaximumGoldBounty(0)
	parent:SetDeathXP(0)
end

function modifier_wraith_creep_reincarnate_red:OnRefresh()
	self.reincarnate_time = self:GetAbility():GetSpecialValueFor( "reincarnate_time" )
	self.slow_radius = self:GetAbility():GetSpecialValueFor( "slow_radius" )
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "aura_radius" )
end

function modifier_wraith_creep_reincarnate_red:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_REINCARNATION,
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_wraith_creep_reincarnate_red:OnDeath( event )
	local parent = self:GetParent()
	local unit = event.unit
	local ability = self:GetAbility()
	if parent:PassivesDisabled() then return end
	if unit == parent then
		local name = parent:GetUnitName()
		local pos = parent:GetAbsOrigin()
		local team = parent:GetTeamNumber()
		local health = parent:GetMaxHealth()
		local bat = parent:GetBaseAttackTime()
		local wave_creep = parent:HasModifier("modifier_wave_upgrade")
		local reincarnate = false

		local health_amp = ability:GetSpecialValueFor("health_amp")
		local health_cap = ability:GetSpecialValueFor("health_cap")

		local allies = FindUnitsInRadius(
			team,	-- int, your team number
			pos,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			2000,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _, ally in pairs(allies) do
			if ally:GetUnitName() == "npc_wraith_creep_a" then reincarnate = true end
		end

		if not reincarnate then return end
		Timers:CreateTimer(self:ReincarnateTime(), function()
			local new_creep = CreateUnitByName(name, pos, true, nil, nil, team or DOTA_TEAM_BADGUYS)
			new_creep.wave_creep = true
			new_creep.reincarnated = true
			new_creep:SetMaxHealth(math.min( health_cap , health * health_amp) )
			new_creep:SetHealth(new_creep:GetMaxHealth())
			new_creep:SetBaseAttackTime(bat - (bat * 0.15))
			if wave_creep then
				new_creep:AddNewModifier(nil, nil, "modifier_wave_upgrade", {})
			end
		end)
	end
end

function modifier_wraith_creep_reincarnate_red:ReincarnateTime()
	if not IsServer() then return end
	self:Reincarnate()
	return self.reincarnate_time
end

--------------------------------------------------------------------------------
-- Helper Function
function modifier_wraith_creep_reincarnate_red:Reincarnate()

	-- find affected enemies
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.slow_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- apply slow
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_wraith_creep_reincarnate_red_debuff",
			{ duration = self.slow_duration }
		)
	end

	self:PlayEffects()
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_wraith_creep_reincarnate_red:PlayEffects()
	-- get resources
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate_red.vpcf"
	local sound_cast = "Hero_SkeletonKing.Reincarnate"

	-- play particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.reincarnate_time, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- play sound
	EmitSoundOn( sound_cast, self:GetParent() )
end


modifier_wraith_creep_reincarnate_red_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_wraith_creep_reincarnate_red_debuff:IsHidden()
	return false
end

function modifier_wraith_creep_reincarnate_red_debuff:IsDebuff()
	return true
end

function modifier_wraith_creep_reincarnate_red_debuff:IsStunDebuff()
	return false
end

function modifier_wraith_creep_reincarnate_red_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_wraith_creep_reincarnate_red_debuff:OnCreated( kv )
	-- references
	self.move_slow = self:GetAbility():GetSpecialValueFor( "slow" )
	self.attack_slow = self:GetAbility():GetSpecialValueFor( "attackslow" )
end

function modifier_wraith_creep_reincarnate_red_debuff:OnRefresh( kv )
	-- references
	self.move_slow = self:GetAbility():GetSpecialValueFor( "slow" )
	self.attack_slow = self:GetAbility():GetSpecialValueFor( "attackslow" )
end

function modifier_wraith_creep_reincarnate_red_debuff:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_wraith_creep_reincarnate_red_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_wraith_creep_reincarnate_red_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self.attack_slow
end

function modifier_wraith_creep_reincarnate_red_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_wraith_creep_reincarnate_red_debuff:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate_slow_debuff.vpcf"
end

function modifier_wraith_creep_reincarnate_red_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end