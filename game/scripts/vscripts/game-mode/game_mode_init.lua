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

	-- Teams
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

	-- Lua Listeners
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'EntKilled'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnStateChange'), self)

	-- JS Listeners
	---- Debug Panel
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