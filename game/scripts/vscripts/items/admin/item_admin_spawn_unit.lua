LinkLuaModifier("item_admin_spawn_unit_modifier", "items/admin/item_admin_spawn_unit", LUA_MODIFIER_MOTION_NONE)

item_admin_spawn_unit = class({})

function item_admin_spawn_unit:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	require("game-mode/waves")

	local units = GameMode:GetWaveCreeps(2)
	local unit_team = caster:GetTeamNumber() + 1
	local level = 1

	for i=1, #units do
		if not units then return end
		local creep = CreateUnitByName(units[i], point, true, caster, caster, unit_team)
    	creep:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    	creep:AddNewModifier(caster, self, "item_admin_spawn_unit_modifier", {})
    	FindClearSpaceForUnit(creep, point, true)
    	creep:CreatureLevelUp( (creep:GetLevel() - level) * (-1) )
    	EmitSoundOnClient("NeutralStack.Success", caster)
	end  
end

item_admin_spawn_unit_modifier = class({})

function item_admin_spawn_unit_modifier:IsHidden() return true end
function item_admin_spawn_unit_modifier:IsPurgable() return false end

function item_admin_spawn_unit_modifier:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
    }
end

function item_admin_spawn_unit_modifier:GetModifierProvidesFOWVision()
    return 1 
end
