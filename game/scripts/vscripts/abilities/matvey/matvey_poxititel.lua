LinkLuaModifier("matvey_poxititel_modifier", 
	"abilities/matvey/matvey_poxititel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("matvey_poxititel_buff", 
	"abilities/matvey/matvey_poxititel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("matvey_poxititel_debuff", 
	"abilities/matvey/matvey_poxititel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_matvey_poxititel_shard", 
	"abilities/matvey/matvey_poxititel", LUA_MODIFIER_MOTION_NONE)

matvey_poxititel = class({})

function matvey_poxititel:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function matvey_poxititel:GetCooldown(iLevel)
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return self:GetSpecialValueFor("shard_cooldown")
	else
		return 0
	end
end

function matvey_poxititel:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("shard_duration")
	caster:AddNewModifier(caster, self, "modifier_matvey_poxititel_shard", {duration = duration})
end

function matvey_poxititel:GetIntrinsicModifierName()
	return "matvey_poxititel_modifier"
end

matvey_poxititel_modifier = class({})

function matvey_poxititel_modifier:IsHidden() return true end
function matvey_poxititel_modifier:IsPurgable() return true end

function matvey_poxititel_modifier:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function matvey_poxititel_modifier:OnAttackLanded( event )
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = ability:GetCaster()

	if caster:PassivesDisabled() then return end

	local attacker = event.attacker
	local target = event.target

	local chance = ability:GetSpecialValueFor("chance")

	if target:IsCreep() or target:IsNeutralUnitType() then 
		chance = chance / 2
	end

	if attacker == caster and not attacker:IsIllusion() and not target:IsBuilding() then
		local shard_modif = caster:FindModifierByName("modifier_matvey_poxititel_shard")
		local shard_chance_bonus = ability:GetSpecialValueFor("shard_chance_bonus")
		if shard_modif then chance = chance + shard_chance_bonus end 
		if RollPercentage(chance) then 
			local name1 = "matvey_poxititel_buff"
			local name2 = "matvey_poxititel_debuff"
	
			local modif1 = caster:FindModifierByName(name1)
			local modif2 = target:FindModifierByName(name2)
	
			local dur = ability:GetSpecialValueFor("duration")
	
			if modif1 and modif2 then
				local attribute_steal = ability:GetSpecialValueFor("attribute_steal")
				if modif1:GetStackCount() < ability:GetSpecialValueFor("max_stacks") * attribute_steal then
					modif1:SetStackCount(modif1:GetStackCount() + attribute_steal)
				end
	
				if modif2:GetStackCount() < ability:GetSpecialValueFor("max_stacks") * attribute_steal then
					modif2:SetStackCount(modif2:GetStackCount() + attribute_steal)
				end
	
				modif1 = caster:AddNewModifier(caster, ability, name1, {duration = dur})
				modif2 = target:AddNewModifier(caster, ability, name2, {duration = dur})
				print(caster:GetHeroFacetID())
				if caster:GetHeroFacetID() == 6 then -- matvey_manasteal Facet
					local mana = ability:GetSpecialValueFor("mana_steal")

					target:SpendMana(mana, ability)
		
					caster:GiveMana(mana)
					SendOverheadEventMessage(nil, 11, caster, mana, nil)
				end
			end
			if not modif1 then
				modif1 = caster:AddNewModifier(caster, ability, name1, {duration = dur})
			end
			if not modif2 then
				modif2 = target:AddNewModifier(caster, ability, name2, {duration = dur})
			end

			self:PlayEffects(caster, target)
		end
	end
end

function matvey_poxititel_modifier:PlayEffects( caster, target )
	local sound = "Hero_Antimage.ManaBreak"
	local effect = "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf"

	target:EmitSound(sound)

	local particle = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle)
end

matvey_poxititel_buff = class({})

function matvey_poxititel_buff:IsPurgable() return true end
function matvey_poxititel_buff:IsDebuff() return false end

function matvey_poxititel_buff:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
	self:SetStackCount(ability:GetSpecialValueFor("attribute_steal"))
end

function matvey_poxititel_buff:OnRefresh()
	if not IsServer() then return end
	self:GetParent():CalculateStatBonus(true)
end

function matvey_poxititel_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function matvey_poxititel_buff:GetModifierBonusStats_Strength()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	return stacks 
end

function matvey_poxititel_buff:GetModifierBonusStats_Agility()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	return stacks 
end

function matvey_poxititel_buff:GetModifierBonusStats_Intellect()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	return stacks 
end

matvey_poxititel_debuff = class({})

function matvey_poxititel_debuff:IsPurgable() return true end
function matvey_poxititel_debuff:IsDebuff() return true end

function matvey_poxititel_debuff:GetEffectName()
	return "particles/units/heroes/hero_antimage/antimage_manabreak_enemy_debuff.vpcf"
end

function matvey_poxititel_debuff:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
	self:SetStackCount(ability:GetSpecialValueFor("attribute_steal"))
end

function matvey_poxititel_debuff:OnRefresh()
	if not IsServer() then return end
	self:GetParent():CalculateStatBonus(true)
end

function matvey_poxititel_debuff:OnDestroy()
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local parent = self:GetParent()

	local name = "matvey_poxititel_buff"

	if caster:HasModifier(name) and parent:IsAlive() then
		caster:RemoveModifierByName(name)
	end
end

function matvey_poxititel_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function matvey_poxititel_debuff:GetModifierBonusStats_Strength()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	return -stacks 
end

function matvey_poxititel_debuff:GetModifierBonusStats_Agility()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	return -stacks 
end

function matvey_poxititel_debuff:GetModifierBonusStats_Intellect()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local stacks = self:GetStackCount()
	return -stacks 
end

modifier_matvey_poxititel_shard = class({})

function modifier_matvey_poxititel_shard:IsPurgable() return true end
function modifier_matvey_poxititel_shard:IsHidden() return false end
function modifier_matvey_poxititel_shard:IsDebuff() return false end

function modifier_matvey_poxititel_shard:GetEffectName()
	return "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_mask_of_madness.vpcf"
end

function modifier_matvey_poxititel_shard:OnCreated(kv)
	if not IsServer() then return end
	local parent = self:GetParent()
	parent:EmitSound("DOTA_Item.MaskOfMadness.Activate")
end

function modifier_matvey_poxititel_shard:CheckState() 
	return {
		[MODIFIER_STATE_SILENCED] = true
	}
end

function modifier_matvey_poxititel_shard:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	} 
end

function modifier_matvey_poxititel_shard:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()
	return ability:GetSpecialValueFor("shard_attack_speed_bonus")
end