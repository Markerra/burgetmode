LinkLuaModifier("modifier_item_maxim_abaddon", "items/maxim/item_maxim_abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fear_item_maxim_abaddon", "items/maxim/item_maxim_abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_feardebuff_item_maxim_abaddon", "items/maxim/item_maxim_abaddon", LUA_MODIFIER_MOTION_NONE)

item_maxim_abaddon = {}

function item_maxim_abaddon:OnSpellStart()
	if not IsServer() then return end

	if not self:GetCaster():HasAbility("maxim_isaac") then return end

	local caster    = self:GetCaster()

	exp_radius						 = self:GetSpecialValueFor("exp_radius")
	duration  						 = self:GetSpecialValueFor("duration")
	fear_duration_item_maxim_abaddon = self:GetSpecialValueFor("fear_duration")
	chance_item_maxim_abaddon 	   	 = self:GetSpecialValueFor("fear_chance")
	ms_bonus_item_maxim_abaddon	     = self:GetSpecialValueFor("ms_bonus")
	dmg_bonus_item_maxim_abaddon	 = self:GetSpecialValueFor("dmg_bonus")
	exp_dmg						  	 = self:GetSpecialValueFor("exp_dmg")

	is_explosion = false

	self:GetCaster():AddNewModifier(caster, self, "modifier_item_maxim_abaddon", 	  {duration = duration})
	self:GetParent():AddNewModifier(caster, self, "modifier_fear_item_maxim_abaddon", {duration = duration})

	EmitSoundOn("item_maxim_abaddon_cast", caster)

	local removed_item = caster:TakeItem(self)
	if removed_item then
        UTIL_Remove(removed_item)
    end

end

modifier_item_maxim_abaddon = {}

function modifier_item_maxim_abaddon:GetTexture() return "modifiers/modifier_maxim_abaddon" end
function modifier_item_maxim_abaddon:IsDebuff()   return false end
function modifier_item_maxim_abaddon:IsPurgable() return true end 

function modifier_item_maxim_abaddon:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_item_maxim_abaddon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_item_maxim_abaddon:GetModifierBaseAttack_BonusDamage()
	return dmg_bonus_item_maxim_abaddon
end

function modifier_item_maxim_abaddon:GetModifierMoveSpeedBonus_Constant()
	return ms_bonus_item_maxim_abaddon
end

function modifier_item_maxim_abaddon:OnIntervalThink()
	local new_maxhealth = self:GetParent():GetMaxHealth() * 0.5
	if self:GetParent():GetHealth() <= new_maxhealth and not is_explosion == true then -- при хп < 50%
		local dmg 		=	exp_dmg
		local radius 	=   exp_radius or 500
		local caster 	=	self:GetParent()
		local enemies   =   FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 1 + 18, 0, 0, false)
    	for _,value in ipairs(enemies) do
    	    value:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = 1})
    	    ApplyDamage({
    	        victim   	= value,
    	        attacker 	= caster,
    	        damage   	= dmg,
    	        damage_type = DAMAGE_TYPE_PURE,
    	        ability 	= self:GetAbility()   
    	    })
    	end
    	caster:Purge(false, true, false, true, false)
		EmitGlobalSound("Hero_Phoenix.SuperNova.Explode")
		self.effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_WORLDORIGIN, nil)
   		ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetOrigin())
   		is_explosion = true
   		self:Destroy()
   		local isFearAttack = caster:HasModifier("modifier_fear_item_maxim_abaddon")
   		if isFearAttack then
   			caster:FindModifierByName("modifier_fear_item_maxim_abaddon"):Destroy()
   		end
	end
end


modifier_fear_item_maxim_abaddon = {}


function modifier_fear_item_maxim_abaddon:IsHidden() return true end
function modifier_fear_item_maxim_abaddon:IsPurgable() return true end
function modifier_fear_item_maxim_abaddon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_fear_item_maxim_abaddon:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
    	local chance = chance_item_maxim_abaddon
        if RollPercentage(chance) then
        	local duration = fear_duration_item_maxim_abaddon
            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_feardebuff_item_maxim_abaddon", {duration = duration})
        end
    end
end


modifier_feardebuff_item_maxim_abaddon = {}

function modifier_feardebuff_item_maxim_abaddon:OnCreated()
	if self:GetParent():IsNeutralUnitType() then
		self.neutral = true
	end

	-- find enemy fountain
	local buildings = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		Vector(0,0,0),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_BUILDING,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	local fountain = nil
	for _,building in pairs(buildings) do
		if building:GetClassname()=="ent_dota_fountain" then
			fountain = building
			break
		end
	end

	-- if no fountain, just don't do anything
	if not fountain then return end

	-- for lane creep, MoveToPosition won't work, so use this
	if self:GetParent():IsCreep() then
		self:GetParent():SetForceAttackTargetAlly( fountain ) -- for creeps
	end

	-- for others, order to run to fountain
	self:GetParent():MoveToPosition( fountain:GetOrigin() )
end

function modifier_feardebuff_item_maxim_abaddon:OnDestroy()
	if not IsServer() then return end

	-- stop running
	self:GetParent():Stop()
	if self:GetParent():IsCreep() then
		self:GetParent():SetForceAttackTargetAlly( nil ) -- for creeps
	end
end

function modifier_feardebuff_item_maxim_abaddon:IsHidden() 	 return false end
function modifier_feardebuff_item_maxim_abaddon:IsPurgable() return true end

function modifier_feardebuff_item_maxim_abaddon:GetEffectName()
    return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_smoke.vpcf"
end

function modifier_feardebuff_item_maxim_abaddon:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_feardebuff_item_maxim_abaddon:CheckState()
    return {
        [MODIFIER_STATE_FEARED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

function modifier_feardebuff_item_maxim_abaddon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end

function modifier_feardebuff_item_maxim_abaddon:GetModifierMoveSpeed_Absolute()
    return 300
end
