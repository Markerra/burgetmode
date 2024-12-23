
if GameMode == nil then
	GameMode = class({})
end

require("utils/timers")
require("weather")

require("panorama/custom_top_bar")
require("panorama/debug_panel")

function GameMode:Init()

	local mode = GameRules:GetGameModeEntity()

	if IsInToolsMode() then
		PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_CUSTOM_1)
		GameRules:SetCustomGameSetupTimeout(0)
	end

	GameRules:SetSameHeroSelectionEnabled(true)

	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetSafeToLeave(true)

	GameRules:SetShowcaseTime( 0.0 )
	GameRules:SetStrategyTime( 10.0 )
	GameRules:SetPreGameTime(5)

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 0 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS,  0 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 ) 
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )

	mode:SetGiveFreeTPOnDeath(false)

	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'EntKilled'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnStateChange'), self)

	CustomGameEventManager:RegisterListener("spawn_bot_admin", Dynamic_Wrap(self, 'Admin_SpawnBot'))
	CustomGameEventManager:RegisterListener("give_item_admin", Dynamic_Wrap(self, 'Admin_GiveItem'))
	CustomGameEventManager:RegisterListener("wtf_mode_admin", Dynamic_Wrap(self, 'Admin_WTFMode'))
	CustomGameEventManager:RegisterListener("refresh_admin",   Dynamic_Wrap(self, 'Admin_Refresh'))
	CustomGameEventManager:RegisterListener("lvlup_admin", Dynamic_Wrap(self, 'Admin_lvlUp'))
	CustomGameEventManager:RegisterListener("gold_admin", Dynamic_Wrap(self, 'Admin_GiveGold'))

	SendHeroDataToClient(0.34, false) -- panorama/custom_top_bar.lua 

end

function GameMode:InitFast()
	local mode = GameRules:GetGameModeEntity()

	mode:SetCustomGameForceHero("npc_dota_hero_nevermore")
	GameRules:SetStrategyTime(0)
	GameRules:SetPreGameTime(0)
end

function GameMode:EntKilled(data)
	local unit = EntIndexToHScript(data.entindex_killed) 
	local team = unit:GetTeam()
	local team_number = unit:GetTeamNumber()

	-- team numbers:
	---- custom1 = 6
	---- custom2 = 7
	---- custom3 = 8
	---- custom4 = 9
	---- custom5 = 10
	---- custom6 = 11
	---- custom7 = 12
	---- custom8 = 13

	if unit:GetUnitName() == "npc_dota_custom_tower_main" then
		print(unit:GetUnitName())
		
		local players = {}
    	for player_id = 0, PlayerResource:GetPlayerCount() - 1 do
    	    local player = PlayerResource:GetPlayer(player_id)
    	    if player and player:GetTeamNumber() == team_number then
    	        table.insert(players, player_id)
    	    end
    	end

    	-- Выбывание каждого игрока из команды
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

	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:SetTimeOfDay(0.25)
		GameRules:SpawnNeutralCreeps()
		Timers:CreateTimer(10, function() -- спустя 10 минут активирует возможность атаковать фонтан
			local fountain = Entities:FindByClassname(nil, "ent_dota_fountain") 
			while fountain do
				print("Found fountain:", fountain)
			    fountain:RemoveModifierByName("modifier_invulnerable")
			    print("Removed invulnerability from fountain")
			    fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
			end

		end)
	end

end
