-- Cleave-like cone search - returns the units in front of the caster in a cone.
function FindUnitsInCone(teamNumber, vDirection, vPosition, startRadius, endRadius, flLength, hCacheUnit, targetTeam, targetUnit, targetFlags, findOrder, bCache)
	local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
	local enemies = FindUnitsInRadius(teamNumber, vPosition, hCacheUnit, endRadius + flLength, targetTeam, targetUnit, targetFlags, findOrder, bCache )
	local unitTable = {}
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			if enemy ~= nil then
				local vToPotentialTarget = enemy:GetOrigin() - vPosition
				local flSideAmount = math.abs( vToPotentialTarget.x * vDirectionCone.x + vToPotentialTarget.y * vDirectionCone.y + vToPotentialTarget.z * vDirectionCone.z )
				local enemy_distance_from_caster = ( vToPotentialTarget.x * vDirection.x + vToPotentialTarget.y * vDirection.y + vToPotentialTarget.z * vDirection.z )
				
				-- Author of this "increase over distance": Fudge, pretty proud of this :D 
				
				-- Calculate how much the width of the check can be higher than the starting point
				local max_increased_radius_from_distance = endRadius - startRadius
				
				-- Calculate how close the enemy is to the caster, in comparison to the total distance
				local pct_distance = enemy_distance_from_caster / flLength
				
				-- Calculate how much the width should be higher due to the distance of the enemy to the caster.
				local radius_increase_from_distance = max_increased_radius_from_distance * pct_distance
				
				if ( flSideAmount < startRadius + radius_increase_from_distance ) and ( enemy_distance_from_caster > 0.0 ) and ( enemy_distance_from_caster < flLength ) then
					table.insert(unitTable, enemy)
				end
			end
		end
	end
	return unitTable
end

-- Checks if the attacker's damage is classified as "hero damage".	More `or`s may need to be added.
function IsHeroDamage(attacker, damage)
	if damage > 0 then
		if(attacker:GetName() == "npc_dota_roshan" or attacker:IsControllableByAnyPlayer() or attacker:GetName() == "npc_dota_shadowshaman_serpentward") then
			return true
		else
			return false
		end
	end
end

-- Returns true if a value is in a table, false if it is not.
function CheckIfInTable(table, searched_value, optional_number_of_table_rows_to_search_through)
	-- Searches through the ENTIRE table
	if not optional_number_of_table_rows_to_search_through then
		for _,table_value in pairs(table) do
			if table_value == searched_value then
				return true
			end
		end
	else
	
		-- Searches through the first few rows
		for i=1, optional_number_of_table_rows_to_search_through do
			if i <= #table then
				if table[i] == searched_value then
					return true
				end
			end
		end
	end
	return false
end

function GetTowerByTeam( team, isMain )
    local alltowers = {}
	local towerCount = 8
    
	for i=1, towerCount do
		local name = ""
        if isMain then
			name = "dota_custom"..tostring(i).."_tower_main"
        else
			name = "dota_custom"..tostring(i).."_tower_1"
		end
    	local towers = Entities:FindAllByName(name)
    	table.insert(alltowers, towers)
	end

	local targetTower = alltowers[team-5]
    return targetTower[1]
end

function GetPlayerByTeam( team )
	for id = 0, 8 do
		if PlayerResource:IsValidPlayerID(id) then
			local player = PlayerResource:GetPlayer(id)
			if player then
				local hero = player:GetAssignedHero()
				if hero:GetTeam() == team then return player end
			end
		end
	end
end

function HasTalent(unit, talent_name)
    local talent = unit:FindAbilityByName(talent_name)
    if talent and talent:GetLevel() > 0 then
        return true
    end
    return false
end

function GetPlayerInfo(pid)
	local player = PlayerResource:GetPlayer(pid)
	print("\n=====================INFO=====================")
	print("Player:", player)
	print("Player name:", PlayerResource:GetPlayerName(pid))
	print("Valid:", PlayerResource:IsValidPlayerID(pid))
	if not player or not player:GetAssignedHero() then
		print("==============================================\n")
		return
	end
	print("Team:", player:GetAssignedHero():GetTeam())
	print("Hero:", player:GetAssignedHero())
	print("Hero Name:", player:GetAssignedHero():GetUnitName())
	print("==============================================\n")
end

function ActivateFountainInvul()
	for index=1, DOTA_MAX_PLAYERS do
		local fountain = Entities:FindByName(nil, "dota_custom"..index.."_fountain")
		while fountain do
			fountain:AddNewModifier(nil, nil, "modifier_invulnerable", nil)
			print("Added invulnerability to fountain #"..index)
			fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
		end
	end
end

function DeactivateFountainsInvul(delay)
	Timers:CreateTimer(delay, function()
		for index=1, DOTA_MAX_PLAYERS do
			local fountain = Entities:FindByName(nil, "dota_custom"..index.."_fountain")
			while fountain do
			    fountain:RemoveModifierByName("modifier_invulnerable")
			    print("Removed invulnerability from fountain #"..index)
			    fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
			end
		end
	end)
end

function GiveTPScroll()
	for i=1, HeroList:GetHeroCount() do
		local hero = HeroList:GetHero(i-1)
		hero:AddItemByName("item_tpscroll_custom")
	end
end

