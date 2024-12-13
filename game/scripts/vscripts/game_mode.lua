
if GameMode == nil then
	GameMode = class({})
end


function GameMode:Init()

	local mode = GameRules:GetGameModeEntity()

	if IsInToolsMode() then
		PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_CUSTOM_2)
		GameRules:SetCustomGameSetupTimeout(0)
	end

	GameRules:SetSameHeroSelectionEnabled(true)

	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetSafeToLeave(true)
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:SetStrategyTime( 10.0 )
	GameRules:SetPreGameTime(10)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 ) 
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )

	mode:SetGiveFreeTPOnDeath(false)

	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnSpawned'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnStateChange'), self)

end

function GameMode:InitFast()
	local mode = GameRules:GetGameModeEntity()

	mode:SetCustomGameForceHero("npc_dota_hero_huskar")
	GameRules:SetStrategyTime(0)
	GameRules:SetPreGameTime(0)
end

function GameMode:OnSpawned(data)
	local npc = EntIndexToHScript(data.entindex)

	if IsInToolsMode() and bFirstSpawned == nil then
		npc:AddItemByName("item_blink")
		bFirstSpawned = false
	end
end

function GameMode:OnStateChange(data)
	local state = GameRules:State_Get()

	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:SetTimeOfDay(0.25)
	end
end
