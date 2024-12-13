LinkLuaModifier("modifier_item_maxim_godhead", "items/maxim/item_maxim_godhead", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_maxim_godhead_debuff", "items/maxim/item_maxim_godhead", LUA_MODIFIER_MOTION_NONE)

item_maxim_godhead = {}

function item_maxim_godhead:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()

	if not caster:HasAbility("maxim_isaac") then return end

	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_item_maxim_godhead", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_item_maxim_godhead_debuff", {duration = duration})

	EmitSoundOn("item_maxim_godhead_cast", caster)

	local removed_item = caster:TakeItem(self)
	if removed_item then
        UTIL_Remove(removed_item)
    end

end

modifier_item_maxim_godhead = {}

function modifier_item_maxim_godhead:GetTexture() return "modifiers/modifier_maxim_godhead" end
function modifier_item_maxim_godhead:IsDebuff()   return false end
function modifier_item_maxim_godhead:IsPurgable() return true end 

function modifier_item_maxim_godhead:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end


function modifier_item_maxim_godhead:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        local original_damage = params.damage
        --ApplyDamage({
        --    victim = params.target,
        --    attacker = self:GetParent(),
        --    damage = original_damage,
        --    damage_type = DAMAGE_TYPE_PURE,
        --    damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
        --    ability = self:GetAbility(),
        --})
    end
end

modifier_item_maxim_godhead_debuff = {}

local disarm_modifier_whitelist = {
	["modifier_item_ethereal_blade_ethereal"] = true,
	["modifier_ghost_state"] = true,
}
local disarm_modifier_blacklist = {
	["modifier_heavens_halberd_debuff"] = true,
}

function modifier_item_maxim_godhead_debuff:IsPurgable() return false end 
function modifier_item_maxim_godhead_debuff:IsHidden()   return true end
function modifier_item_maxim_godhead_debuff:IsDebuff()   return true end


function modifier_item_maxim_godhead_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,

		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_MAGICAL, -- allow attack ethereal units
		
		MODIFIER_PROPERTY_ALWAYS_ALLOW_ATTACK, -- allow attack while disarmed (with twists)
		MODIFIER_EVENT_ON_ATTACK_FINISHED,
		MODIFIER_EVENT_ON_ATTACK_CANCELLED,

		-- -- not working
		-- MODIFIER_PROPERTY_ALWAYS_ETHEREAL_ATTACK,
		-- MODIFIER_PROPERTY_PROCATTACK_CONVERT_PHYSICAL_TO_MAGICAL,
		-- MODIFIER_PROPERTY_PHYSICALDAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end



function modifier_item_maxim_godhead_debuff:OnCreated( kv )
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.transforming = true

	if not IsServer() then return end

	self.undisarm_modifier = nil
end

function modifier_item_maxim_godhead_debuff:OnRefresh( kv )
end

function modifier_item_maxim_godhead_debuff:OnRemoved()
end

function modifier_item_maxim_godhead_debuff:OnDestroy()
	if not IsServer() then return end

	if self.undisarm_modifier then
		self.undisarm_modifier:Destroy()
		self.undisarm_modifier = nil
	end

	self:PlayEffectsEnd()
end

function modifier_item_maxim_godhead_debuff:GetModifierProjectileName()
	return "particles/items_fx/revenant_brooch_projectile.vpcf"
end

function modifier_item_maxim_godhead_debuff:GetAttackSound()
	return "item_maxim_godhead_attack"
end

function modifier_item_maxim_godhead_debuff:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_maxim_godhead_debuff:GetOverrideAttackMagical( params )
	return 1
end

function modifier_item_maxim_godhead_debuff:GetModifierTotalDamageOutgoing_Percentage( params )
	if params.inflictor then return 0 end
	if params.damage_category~=DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end
	if params.damage_type~=DAMAGE_TYPE_PHYSICAL then return 0 end

	if not params.target:IsMagicImmune() then
		local damageTable = {
			victim = params.target,
			attacker = self.parent,
			damage = params.original_damage,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flag = DOTA_DAMAGE_FLAG_MAGIC_AUTO_ATTACK,
			ability = self.ability, --Optional.
		}
		ApplyDamage( damageTable )

		EmitSoundOn( "Hero_Muerta.PierceTheVeil.ProjectileImpact", params.target )
	else
		EmitSoundOn( "Hero_Muerta.PierceTheVeil.ProjectileImpact.MagicImmune", params.target )
	end

	return -200
end

function modifier_item_maxim_godhead_debuff:GetAlwaysAllowAttack( params )
	-- filter disarm sources (ideally uses whitelist instead, e.g. ethereal modifiers)
	local should_disarm = false
	for modifier,_ in pairs(disarm_modifier_blacklist) do
		if self.parent:HasModifier(modifier) then
			should_disarm = true
			break
		end
	end
	if should_disarm then return 0 end

	-- add undisarm_modifier modifier 
	self.undisarm_modifier = self.parent:AddNewModifier(
		self.parent,
		self.ability,
		"modifier_item_maxim_godhead_debuff_undisarm",
		{duration = 1}
	)

	return 1
end

function modifier_item_maxim_godhead_debuff:OnAttackFinished( params )
	if params.attacker~=self.parent then return end
	if self.undisarm_modifier then
		self.undisarm_modifier:Destroy()
		self.undisarm_modifier = nil
	end
end

-- same as above
function modifier_item_maxim_godhead_debuff:OnAttackCancelled( params )
	self:OnAttackFinished( params )
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_item_maxim_godhead_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_TARGET_BUILDINGS] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations

function modifier_item_maxim_godhead_debuff:GetEffectName()
	return "particles/items5_fx/revenant_brooch.vpcf"
end

function modifier_item_maxim_godhead_debuff:GetEffectAttachType()
	return 1
end

function modifier_item_maxim_godhead_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_maxim_godhead_debuff:PlayEffectsEnd()
	-- Get Resources
	local particle_cast = "particles/items_fx/ethereal_blade_reverse.vpcf" 

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end