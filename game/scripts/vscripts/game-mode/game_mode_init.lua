function GameMode:Init()

	local mode = GameRules:GetGameModeEntity()

	GameRules:SetSameHeroSelectionEnabled(true)

	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetSafeToLeave(true)

	GameRules:SetShowcaseTime( 0.0 )
	GameRules:SetStrategyTime( 60.0 )
	GameRules:SetPreGameTime(25)

	mode:SetCustomScanMaxCharges(1)
	mode:SetAnnouncerDisabled( true )
	mode:SetCustomBackpackCooldownPercent(1)
	mode:SetTPScrollSlotItemOverride("item_tpscroll_custom")

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
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'npcSpawned'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'EntKilled'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnStateChange'), self)

	-- JS Listeners
	---- Debug Panel

	require("panorama/debug_panel")

	CustomGameEventManager:RegisterListener("spawn_bot_admin", Dynamic_Wrap(self, 'Admin_SpawnBot'))
	CustomGameEventManager:RegisterListener("give_item_admin", Dynamic_Wrap(self, 'Admin_GiveItem'))
	CustomGameEventManager:RegisterListener("wtf_mode_admin", Dynamic_Wrap(self, 'Admin_WTFMode'))
	CustomGameEventManager:RegisterListener("refresh_admin",   Dynamic_Wrap(self, 'Admin_Refresh'))
	CustomGameEventManager:RegisterListener("lvlup_admin", Dynamic_Wrap(self, 'Admin_lvlUp'))
	CustomGameEventManager:RegisterListener("gold_admin", Dynamic_Wrap(self, 'Admin_GiveGold'))
	CustomGameEventManager:RegisterListener("admin_steamID", Dynamic_Wrap(self, 'Admin_SteamID_Check'))

	---- Top Bar Panel

	require("panorama/custom_top_bar")

	CustomGameEventManager:RegisterListener("top_bar_select", Dynamic_Wrap(self, 'TopBar_Select'))
	
	SendHeroDataToClient(0.25, false) -- panorama/custom_top_bar.lua 

end


function GameMode:SetupColors()

    if not IsServer() then return end 
	-- Handle Team Colors
    self.m_TeamColors = {}
    self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 102, 0, 255 } --  "Ярик Кент"
    self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 102, 255 } --  "Сева Крейзи"
    self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 153, 51, 255 } --  "Матвей Баклажан"
    self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 255, 214, 51 } --  "Максим Кукуруза"
    self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 0, 204, 102} --  "Арсений Огурец"
    self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 242, 242, 242 } --  "Сергеп Про"
    self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 0, 204, 102 } --  "Миша Бургер"
    self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 0, 0, 0 } --  "Антон Яйцо"

    for team = 0, (DOTA_TEAM_COUNT-1) do
      color = self.m_TeamColors[ team ]
      if color then
        SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
      end
    end
end


function GameMode:InitFast()
	local mode = GameRules:GetGameModeEntity()

	mode:SetCustomGameForceHero("npc_dota_hero_huskar")

	PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_CUSTOM_1)

	GameRules:SetStrategyTime(0)
	GameRules:SetPreGameTime(25)
	GameRules:SetCustomGameSetupTimeout(0)
end


function GameMode:GiveAdminItems()
	GameRules:GetGameModeEntity().GiveAdminItems = true
end