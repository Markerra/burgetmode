LinkLuaModifier("modifier_wraith_creep_crit", "abilities/neutral/waves/wraith_creep_crit", LUA_MODIFIER_MOTION_NONE)

wraith_creep_crit = class({})

function wraith_creep_crit:GetIntrinsicModifierName()
	return "modifier_wraith_creep_crit"
end

modifier_wraith_creep_crit = class({})

function modifier_wraith_creep_crit:IsHidden()
	return true
end

function modifier_wraith_creep_crit:IsDebuff()
	return false
end

function modifier_wraith_creep_crit:OnCreated( kv )
	self.crit_chance = self:GetAbility():GetSpecialValueFor( "chance" )
	self.crit_mult = self:GetAbility():GetSpecialValueFor( "crit_damage" )
end

function modifier_wraith_creep_crit:OnRefresh( kv )
	self.crit_chance = self:GetAbility():GetSpecialValueFor( "chance" )
	self.crit_mult = self:GetAbility():GetSpecialValueFor( "crit_damage" )
end

function modifier_wraith_creep_crit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
	}
end

function modifier_wraith_creep_crit:GetModifierPreAttack_CriticalStrike( event )
	if IsServer() then
		local pass = false
		if event.target:GetTeamNumber()~=self:GetParent():GetTeamNumber() then
			pass = true
		end

		if pass and RollPercentage(self.crit_chance) then
			self.attack_record = event.record
			return self.crit_mult
		end
	end
end

function modifier_wraith_creep_crit:GetModifierProcAttack_Feedback( event )
	if IsServer() then
		-- filter
		local pass = false
		if self.attack_record and event.record==self.attack_record then
			pass = true
		end

		-- logic
		if pass then
			self:PlayEffects( event.target )
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_wraith_creep_crit:PlayEffects( target )
	-- get resource
	local particle_impact = "particles/econ/items/chaos_knight/chaos_knight_ti9_weapon/chaos_knight_ti9_weapon_crit_tgt.vpcf"
	local sound_impact = "Hero_SkeletonKing.CriticalStrike"

	-- play effect
	local effect_impact = ParticleManager:CreateParticle( particle_impact, PATTACH_ABSORIGIN_FOLLOW, target )
	-- todo: find correct particle control
	ParticleManager:SetParticleControl( effect_impact, 2, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_impact )

	-- play sound
	target:EmitSound( sound_impact )
end