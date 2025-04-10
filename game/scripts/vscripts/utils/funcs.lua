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