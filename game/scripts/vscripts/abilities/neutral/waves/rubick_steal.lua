LinkLuaModifier("modifier_rubick_steal", 
	"abilities/neutral/waves/rubick_steal", LUA_MODIFIER_MOTION_NONE)

rubick_steal = class({})

function rubick_steal:GetIntrinsicModifierName()
	return "modifier_rubick_steal"
end

function rubick_steal:OnSpellStart()
	if not isServer() then return end
	
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local modif = caster:FindModifierByName("modifier_rubick_steal")
	
	if not modif then return end
	if not modif.ability then
		self:StartCooldown(self:GetCooldown(self:GetLevel()))
		return
	end
	
	local name = modif.ability:GetAbilityName()
	local behav = modif.ability:GetBehavior()
	
	caster:AddAbility(name)
	
	if behav == 4 or behav == 4 + 128 then 
		caster:CastAbilityNoTarget(name, 1) 
	end
	if behav == 8 or behav == 8 + 128 then 
		caster:CastAbilityOnTarget(target, modif.ability, 1) 
	end
	if behav == 16 or behav == 16 + 128 or behav == 16 + 32 then
		local pos = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
		caster:CastAbilityOnPosition(pos, modif.ability, 1)
	end
	
	caster:RemoveAbility(name)
end

modifier_rubick_steal = class({})

function modifier_rubick_steal:IsHidden() return true end
function modifier_rubick_steal:IsPurgable() return false end

function modifier_rubick_steal:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function modifier_rubick_steal:OnAbilityExecuted(event)
	if not isServer() then return end

	local parent = self:GetParent()
	local radius = 2100
	if event.ability:IsItem() then return end
	    local units = FindUnitsInRadius(
        parent:GetTeamNumber(),      
        parent:GetAbsOrigin(),       
        nil,                         
        radius,                      
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO,        
        DOTA_UNIT_TARGET_FLAG_NONE,  
        FIND_CLOSEST,              
        false                        
    )

    for _, unit in ipairs(units) do 
		if unit == event.ability:GetCaster() then
			self.ability = event.ability
		end
	end
end