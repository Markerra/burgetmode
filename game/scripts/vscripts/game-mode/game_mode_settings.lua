
if GameMode == nil then
	GameMode = class({})
end

require("utils/timers")
require("weather")

require("game-mode/custom_params")

require("panorama/custom_top_bar")
require("panorama/debug_panel")

function GameMode:npcSpawned(data)
	local unit = EntIndexToHScript(data.entindex)
	--unit.bFirstSpawned = true
	--if not unit:HasItemInInventory("item_tpscroll_custom") and unit.bFirstSpawned == true then
	--	unit:AddItemByName("item_tpscroll_custom")
	--	unit.bFirstSpawned = false
	--end
end

function GameMode:EntKilled(data)
	local unit = EntIndexToHScript(data.entindex_killed) 
	local team = unit:GetTeam()
	local team_number = unit:GetTeamNumber()

	if unit:GetUnitName() == "npc_dota_custom_tower_main" then -- система выбывания игроков при потере главного тавера
		print(unit:GetUnitName())
		
		local players = {}
    	for player_id = 0, PlayerResource:GetPlayerCount() - 1 do
    	    local player = PlayerResource:GetPlayer(player_id)
    	    if player and player:GetTeamNumber() == team_number then
    	        table.insert(players, player_id)
    	    end
    	end

    	-- выбывание каждого игрока из команды
    	for _, player_id in ipairs(players) do
    	    local hero = PlayerResource:GetSelectedHeroEntity(player_id)
    	    if hero then
    	        hero:SetBuyBackDisabledByReapersScythe(true)
    	        hero:SetRespawnsDisabled(true)
    	        hero:ForceKill(false)
    	    end
    	end

	end
end

function GameMode:OnStateChange(data)
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then -- запускается при начале игры (после горна)

		GameRules:SetTimeOfDay(0.25) -- игра начинается со дня

		GameRules:SpawnNeutralCreeps() -- спавн нейтральных крипов во всех кемпах

		Timers:CreateTimer(fountain_vul_delay, function() -- спустя 10 минут активирует возможность атаковать фонтан
			local fountain = Entities:FindByClassname(nil, "ent_dota_fountain") 
			while fountain do
			    fountain:RemoveModifierByName("modifier_invulnerable")
			    print("Removed invulnerability from fountain")
			    fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
			end
		end)

		print(HeroList:GetHeroCount())

		for i=1, HeroList:GetHeroCount() do
			local hero = HeroList:GetHero(i-1)
			hero:AddItemByName("item_tpscroll_custom")
		end

	end

end
