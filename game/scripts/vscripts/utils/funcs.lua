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
	  print("\n============INFO============")
	  print("Team:", team)
	  print("Player:", player)
	  print("Player name:", PlayerResource:GetPlayerName(pid))
	  print("Valid:", PlayerResource:IsValidPlayerID(pid))
	  if not player or not PlayerResource:IsValidPlayerID(pid) then
		print("============================\n")
		return
	  end
	  print("Hero:", player:GetAssignedHero())
	  print("Hero Name:", player:GetAssignedHero():GetUnitName())
	  print("============================\n")
end