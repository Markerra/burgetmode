LinkLuaModifier( "modifier_ghoul_wounds_debuff", "abilities/neutral/waves/ghoul_wounds", LUA_MODIFIER_MOTION_NONE )

ghoul_wounds = class({})

function ghoul_wounds:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb( self ) then return end

	local duration = self:GetSpecialValueFor("duration")

	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_ghoul_wounds_debuff", -- modifier name
		{ duration = duration } -- kv
	)

	local sound_cast = "Hero_LifeStealer.OpenWounds.Cast"
	local sound_target = "Hero_LifeStealer.OpenWounds"
	caster:EmitSound( sound_cast )
	target:EmitSound( sound_target )
end

modifier_ghoul_wounds_debuff = class({})

function modifier_ghoul_wounds_debuff:IsHidden() return false end
function modifier_ghoul_wounds_debuff:IsDebuff() return true end
function modifier_ghoul_wounds_debuff:IsPurgable() return true end


function modifier_ghoul_wounds_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

function modifier_ghoul_wounds_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_ghoul_wounds_debuff:OnAttacked( params )
	if IsServer() then
		if params.target~=self:GetParent() then return end
		if params.attacker:GetTeamNumber()~=self:GetCaster():GetTeamNumber() then return end

		local vamp = self:GetAbility():GetSpecialValueFor( "bonus_vamp" ) / 100
		local heal_hp = vamp * params.damage
		params.attacker:Heal( heal_hp, self:GetCaster() )
		SendOverheadEventMessage(nil, 10, self:GetCaster(), heal_hp, nil)

		self:PlayEffects( params.attacker )
	end
end

function modifier_ghoul_wounds_debuff:GetEffectName()
	return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end

function modifier_ghoul_wounds_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ghoul_wounds_debuff:PlayEffects( target )
	local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end