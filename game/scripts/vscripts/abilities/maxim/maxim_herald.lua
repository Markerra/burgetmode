LinkLuaModifier( "maxim_herald_modifier", "abilities/maxim/maxim_herald", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "maxim_herald_modifier_debuff", "abilities/maxim/maxim_herald", LUA_MODIFIER_MOTION_NONE )

maxim_herald = {}

function maxim_herald:GetIntrinsicModifierName()
	return "maxim_herald_modifier"
end

maxim_herald_modifier = {}

function maxim_herald_modifier:IsPurgable() return false end
function maxim_herald_modifier:IsHidden() return false end
function maxim_herald_modifier:IsDebuff() return false end

function maxim_herald_modifier:DeclareFunctions()
	return {
	MODIFIER_EVENT_ON_DEATH,
	MODIFIER_EVENT_ON_ATTACK_LANDED,
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end

function maxim_herald_modifier:OnDeath(params)

	if self:GetCaster():PassivesDisabled() then return end

	if not IsServer() then return end

	local dead 	   = params.unit
	local attacker = params.attacker
	local duration = self:GetAbility():GetSpecialValueFor("duration")

	if self:GetParent() == dead then -- если владелец способности умер
		self:IncrementStackCount()
		attacker:AddNewModifier(dead, self:GetAbility(), "maxim_herald_modifier_debuff", {duration = duration})
	end
end

function maxim_herald_modifier:GetModifierBonusStats_Agility()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_agility")
end

maxim_herald_modifier_debuff = {}

function maxim_herald_modifier_debuff:IsDebuff() return true end
function maxim_herald_modifier_debuff:IsPurgable() return false end

function maxim_herald_modifier_debuff:GetEffectName()
    return "particles/items_fx/gem_truesight_aura_magic.vpcf"
end

function maxim_herald_modifier_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function maxim_herald_modifier_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function maxim_herald_modifier_debuff:GetModifierProvidesFOWVision()
    return 1 
end

function maxim_herald_modifier_debuff:OnAttackLanded(params)
	local attacker = params.attacker
	local unit 	   = params.target
	local dmg 	   = self:GetAbility():GetSpecialValueFor("bonus_damage")

	if self:GetAbility():GetCaster() == attacker then -- если атакует владелец способности
		ApplyDamage({
            victim = unit,
            attacker = attacker,
            damage = dmg,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self:GetAbility()   
        })
	end
end