LinkLuaModifier("modifier_item_maxim_abaddon", "items/maxim/item_maxim_abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fear_item_maxim_abaddon", "items/maxim/item_maxim_abaddon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_feardebuff_item_maxim_abaddon", "items/maxim/item_maxim_abaddon", LUA_MODIFIER_MOTION_NONE)

require("utils/funcs")

item_maxim_abaddon = {}

function item_maxim_abaddon:OnSpellStart()
	if not IsServer() then return end

	if not self:GetCaster():HasAbility("maxim_isaac") then return end

	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	is_explosion = false

	self:GetCaster():AddNewModifier(caster, self, "modifier_item_maxim_abaddon", 	  {duration = duration})
	self:GetParent():AddNewModifier(caster, self, "modifier_fear_item_maxim_abaddon", {duration = duration})

	caster:EmitSound("item_maxim_abaddon_cast")

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
	self:SetHasCustomTransmitterData(true)

	if not IsServer() then return end
	
	self.dmg_bonus = self:GetAbility():GetSpecialValueFor("dmg_bonus")
	self.ms_bonus = self:GetAbility():GetSpecialValueFor("ms_bonus")

	self:SendBuffRefreshToClients()
	self:StartIntervalThink(0.1)
end

function modifier_item_maxim_abaddon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
end

function modifier_item_maxim_abaddon:GetModifierBaseAttack_BonusDamage()
	return self.dmg_bonus
end

function modifier_item_maxim_abaddon:GetModifierMoveSpeedBonus_Constant()
	return self.ms_bonus
end

function modifier_item_maxim_abaddon:OnIntervalThink()
	local new_maxhealth = self:GetParent():GetMaxHealth() * 0.5
	if self:GetParent():GetHealth() <= new_maxhealth and not is_explosion == true then -- при хп < 50%
		local dmg 		=	self:GetSpecialValueFor("exp_dmg")
		local radius 	=   self:GetSpecialValueFor("exp_radius") or 500
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
		caster:EmitSound("Hero_Phoenix.SuperNova.Explode")
		self.effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_WORLDORIGIN, nil)
   		ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetOrigin())
   		is_explosion = true
   		self:Destroy()
   		local isFearAttack = caster:HasModifier("modifier_fear_item_maxim_abaddon")
   		if isFearAttack then
   			caster:FindModifierByName("modifier_fear_item_maxim_abaddon"):Destroy()
   		end
	end
	--self:SendBuffRefreshToClients()
end

function modifier_item_maxim_abaddon:AddCustomTransmitterData()
	local data = {
		dmg_bonus = self.dmg_bonus,
		ms_bonus = self.ms_bonus,
	}

	return data
end

function modifier_item_maxim_abaddon:HandleCustomTransmitterData(data)
	self.dmg_bonus = data.dmg_bonus
	self.ms_bonus  = data.ms_bonus
end


modifier_fear_item_maxim_abaddon = {}

function modifier_fear_item_maxim_abaddon:IsHidden() return true end
function modifier_fear_item_maxim_abaddon:IsDebuff() return true end
function modifier_fear_item_maxim_abaddon:IsPurgable() return true end

function modifier_fear_item_maxim_abaddon:OnCreated()
	self:SetHasCustomTransmitterData(true)
	
	if not IsServer() then return end

	self.chance = self:GetAbility():GetSpecialValueFor("fear_chance")
	self.duration = self:GetAbility():GetSpecialValueFor("fear_duration")

	self:SendBuffRefreshToClients()
end

function modifier_fear_item_maxim_abaddon:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_fear_item_maxim_abaddon:OnAttackLanded(params)
	if not IsServer() then return end
    if params.attacker == self:GetParent() then
        if RollPercentage(self.chance) then
			print("FEAR!")
            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), 
			"modifier_feardebuff_item_maxim_abaddon", {duration = self.duration})
        end
    end
end

function modifier_fear_item_maxim_abaddon:AddCustomTransmitterData()
	local data = {
		chance = self.chance,
		duration = self.duration,
	}

	return data
end

function modifier_fear_item_maxim_abaddon:HandleCustomTransmitterData(data)
	self.chance    = data.chance
	self.duration  = data.duration
end


modifier_feardebuff_item_maxim_abaddon = {}

function modifier_feardebuff_item_maxim_abaddon:OnCreated()
	if not IsServer() then return end

	-- if neutral, set disarm to run back towards camp
	if self:GetParent():IsNeutralUnitType() then
		self.neutral = true
	end

	local hero = self:GetParent()

	local targetTower = GetTowerByTeam(hero:GetTeam(), true)

	if not targetTower then return end

	if self:GetParent():IsCreep() then
		self:GetParent():SetForceAttackTargetAlly( targetTower ) -- for creeps
	end

	self:GetParent():MoveToPosition( targetTower:GetOrigin() )

	self:GetParent():EmitSound("Hero_DarkWillow.Fear.Target")
end

function modifier_feardebuff_item_maxim_abaddon:OnRefresh()
	self:GetParent():StopSound("Hero_DarkWillow.Fear.Target")
	self:GetParent():EmitSound("Hero_DarkWillow.Fear.Target")
end

function modifier_feardebuff_item_maxim_abaddon:OnDestroy()
	if not IsServer() then return end

	-- stop running
	self:GetParent():Stop()
	if self:GetParent():IsCreep() then
		self:GetParent():SetForceAttackTargetAlly( nil ) -- for creeps
	end
end

function modifier_feardebuff_item_maxim_abaddon:IsHidden() return true end
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
        [MODIFIER_STATE_DISARMED] = self.neutral,
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