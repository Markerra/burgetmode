require("utils/timers")

LinkLuaModifier("modifier_boss_roshan_lotus", "abilities/neutral/boss/boss_roshan_lotus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_roshan_lotus_active", "abilities/neutral/boss/boss_roshan_lotus", LUA_MODIFIER_MOTION_NONE)

boss_roshan_lotus = class({})

function boss_roshan_lotus:GetIntrinsicModifierName()
	return "modifier_boss_roshan_lotus"
end

modifier_boss_roshan_lotus = class({})

function modifier_boss_roshan_lotus:IsHidden() return true end
function modifier_boss_roshan_lotus:IsPurgable() return false end

function modifier_boss_roshan_lotus:OnCreated()
	if not IsServer() then return end
	self:GetParent().tOldSpells = {}
	self.absorb = true
	self.dispel = GameMode.current_wave > 10
	Timers:CreateTimer(0.1, function() 
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_boss_roshan_lotus_active", {absorb=self.absorb, dispel=self.dispel})
		self:StartIntervalThink( FrameTime() )
	end)
end

function modifier_boss_roshan_lotus:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	for i=#caster.tOldSpells,1,-1 do
	    local hSpell = caster.tOldSpells[i]
	    if hSpell:NumModifiersUsingAbility() <= -1 and not hSpell:IsChanneling() then
	        hSpell:RemoveSelf()
	        table.remove(caster.tOldSpells,i)
	    end
	end
	if self:GetAbility():IsCooldownReady() and not self:GetParent():HasModifier("modifier_boss_roshan_lotus_active") then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_boss_roshan_lotus_active", {absorb=self.absorb, dispel=self.dispel})
	end
end

modifier_boss_roshan_lotus_active = class({})

function modifier_boss_roshan_lotus_active:IsPurgable() return false end
function modifier_boss_roshan_lotus_active:IsPurgeException() return false end

function modifier_boss_roshan_lotus_active:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = false
	}
end

function modifier_boss_roshan_lotus_active:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_REFLECT_SPELL,
	} 
end

function modifier_boss_roshan_lotus_active:OnCreated(params)
	if not IsServer() then return end

	local shield_pfx = "particles/custom/neutral/boss/boss_lotus_orb_shield.vpcf"
	self.reflect_pfx = "particles/custom/neutral/boss/boss_lotus_orb_reflect.vpcf"

	if params.absorb then self.absorb = params.absorb end
	if params.dispel then self.dispel = params.dispel end

	if params.dispel then
		self:GetParent():Purge(false, true, false, false, false)
	end

	self.pfx = ParticleManager:CreateParticle(shield_pfx, PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:GetCaster():EmitSound("Item.LotusOrb.Target")
end

function modifier_boss_roshan_lotus_active:GetAbsorbSpell(params)
	if self:GetAbility():GetAbilityName() == "boss_roshan_lotus" then
		return nil
	end

	if params.ability then
		--print("Ability absorbed:", params.ability:GetAbilityName())
	end

	if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return nil
	end

	if not self.absorb then return 0 end

	self:GetCaster():EmitSound("Item.LotusOrb.Activate")
	
	return 1
end

local function SpellReflect(parent, params)
	local reflected_spell_name = params.ability:GetAbilityName()
	local target = params.ability:GetCaster()
	
	
	local main_ability = parent:FindAbilityByName("antimage_counterspell_custom")
	
	
	target:EmitSound("Hero_Antimage.Counterspell.Target")
	if target:GetTeamNumber() == parent:GetTeamNumber() then
	    return nil
	end
	
	if target:HasModifier("modifier_item_lotus_orb_active") then
	    return nil
	end
	
	if target:HasModifier("modifier_item_mirror_shield") then
	    return nil
	end
	
	if target:HasModifier("modifier_boss_roshan_lotus_active") then
	    return nil
	end
	
	if params.ability.spell_shield_reflect then
	    return nil
	end
	
	local old_spell = false
	for _,hSpell in pairs(parent.tOldSpells) do
	    if hSpell ~= nil and hSpell:GetAbilityName() == reflected_spell_name then
	        old_spell = true
	        break
	    end
	end
	if old_spell then
	    ability = parent:FindAbilityByName(reflected_spell_name)
	else
	    ability = parent:AddAbility(reflected_spell_name)
	    ability:SetStolen(true)
	    ability:SetHidden(true)
	    ability.spell_shield_reflect = true
	    ability:SetRefCountsModifiers(true)
	    table.insert(parent.tOldSpells, ability)
	end
	ability:SetLevel(params.ability:GetLevel())
	parent:SetCursorCastTarget(target)
	ability:OnSpellStart()
	
	if ability.OnChannelFinish then
	    ability:OnChannelFinish(false)
	end
	
	if ability:GetIntrinsicModifierName() ~= nil then
	    local modifier_intrinsic = parent:FindModifierByName(ability:GetIntrinsicModifierName())
	    if modifier_intrinsic then
	        parent:RemoveModifierByName(modifier_intrinsic:GetName())
	    end
	end
	return false
end

function modifier_boss_roshan_lotus_active:GetReflectSpell( params )
	if not IsServer() then return end
	if not params.ability:GetCaster() then return end 
	if params.ability:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then return end 
	if params.ability:GetCaster():IsCreep() then 
	    params.ability:GetCaster():EmitSound("Hero_Antimage.Counterspell.Target")
	    return end
	local pfx2 = ParticleManager:CreateParticle(self.reflect_pfx, PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(pfx2)
	self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
	self:GetParent():RemoveModifierByName("modifier_boss_roshan_lotus_active")
	local damage = self:GetAbility():GetSpecialValueFor("damage")
	ApplyDamage({
		victim=params.ability:GetCaster(),
		attacker=self:GetParent(),
		damage=damage,
		damage_type=DAMAGE_TYPE_PURE,
		ability=self:GetAbility()
	})
	local hp = (self:GetParent():GetMaxHealth() - self:GetParent():GetHealth()) * (self:GetAbility():GetSpecialValueFor("heal_pct") / 100)
	self:GetParent():Heal(hp, self:GetAbility())
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), hp, nil)
	return SpellReflect(self:GetParent(), params)
end

function modifier_boss_roshan_lotus_active:OnRemoved()
	if not IsServer() then return end

	self:GetCaster():EmitSound("Item.LotusOrb.Destroy")

	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end