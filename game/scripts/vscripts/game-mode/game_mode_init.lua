_G.timer = 0
_G.max_timer = 0

_G.game_end = false

_G.start_wave = 1
_G.test_waves = false
_G.low_net_waves = { 6, 10, 15 }

_G.boss_stage = false

_G.portal_delay = 5.0

_G.enable_waves = true

local winner_team = nil
local current_player_count = 1

require("game-mode/custom_params")
require("game-mode/waves")
require("utils/timers")
require("utils/funcs")

function GameMode:Init()
	local mode = GameRules:GetGameModeEntity()
	
	current_player_count = PlayerResource:GetPlayerCount()

	if IsServer() then

		GameRules:SetSameHeroSelectionEnabled(true)
		GameRules:SetUseUniversalShopMode(false)
		GameRules:SetSafeToLeave(true)
		GameRules:SetShowcaseTime( 0.0 )
		GameRules:SetStrategyTime( 60.0 )
		GameRules:SetPreGameTime(25)
		GameRules:SetRuneSpawnTime(20)
		GameRules:SetStartingGold(CUSTOM_START_GOLD)
		
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

		for t=DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_8 do
			GameRules:IncreaseItemStock(t, "item_ward_observer", CUSTOM_WARD_STOCK_COUNT-2, -1)
			GameRules:IncreaseItemStock(t, "item_ward_sentry", 2*(CUSTOM_WARD_STOCK_COUNT-4), -1)
		end

		mode:SetCustomScanMaxCharges(1)
		mode:SetAnnouncerDisabled(true)
		mode:SetCustomBackpackCooldownPercent(1)
		mode:SetTPScrollSlotItemOverride("item_tpscroll_custom")
		mode:SetCustomBuybackCostEnabled(CUSTOM_BUYBACK_COST_ENABLED)
		mode:SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
		mode:SetFreeCourierModeEnabled(true)
		mode:SetPowerRuneSpawnInterval(25)
		mode:SetGiveFreeTPOnDeath(false)
		mode:SetRuneSpawnFilter(Dynamic_Wrap(GameMode, "RuneSpawnFilter"), self)
		
		for i = 0, 10 do
			if i == 1 then
				mode:SetRuneEnabled(i, true)
			else
				mode:SetRuneEnabled(i, false)
			end
		end
		
		--mode:SetThink( "OnThink", self, "GlobalThink", 0 )
	end

	-- Lua Listeners
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'npcSpawned'), self)
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(self, 'EntHurt'), self)
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

	---- Custom Chat Wheel
	require("chat_wheel")
	CustomGameEventManager:RegisterListener( "SelectVO", Dynamic_Wrap(chat_wheel, 'SelectVO'))
	CustomGameEventManager:RegisterListener( "SelectHeroVO", Dynamic_Wrap(chat_wheel, 'SelectHeroVO'))
	CustomGameEventManager:RegisterListener( "select_chatwheel_player", Dynamic_Wrap(chat_wheel, 'SelectChatWheel'))
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

	local mode = GameRules:GetGameModeEntity()

    for team = 0, (DOTA_TEAM_COUNT-1) do
      color = self.m_TeamColors[ team ]
      if color then
        SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
      end
    end
end


function GameMode:InitFast()
	local mode = GameRules:GetGameModeEntity()

	mode:SetCustomGameForceHero("npc_dota_hero_"..CUSTOM_FORCE_HERO)

	PlayerResource:SetCustomTeamAssignment(0, DOTA_TEAM_CUSTOM_1)

	GameRules:SetStrategyTime(0)
	GameRules:SetPreGameTime(25)
	GameRules:SetCustomGameSetupTimeout(0)
	if test_waves then GameRules:SetPreGameTime(3) end
end

function GameMode:RuneSpawnFilter(keys)

	keys.rune_type = 1

	return true
end

function GameMode:GiveAdminItems()
	GameRules:GetGameModeEntity().GiveAdminItems = true
end

function GameMode:npcSpawned( event )
	local unit = EntIndexToHScript(event.entindex)

	if unit:IsHero() and unit.bFirstSpawned ~= false then
		if IsServer() then
			local fx = "particles/prime/hero_spawn_hero_level_6_delay.vpcf"
			local particle = ParticleManager:CreateParticle(fx, PATTACH_ABSORIGIN_FOLLOW, unit)
			ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end
	
	if unit:IsHero() then
		local isVerified = false
		local playerSteamID = PlayerResource:GetSteamID(unit:GetPlayerID()):__tostring()
		for _, allowedID in ipairs(CUSTOM_ALLOWED_STEAMIDS) do
            if playerSteamID == allowedID then
                isVerified = true
                break
            end
        end
		local adminItems = GameRules:GetGameModeEntity().GiveAdminItems
		if (adminItems or GameRules:IsCheatMode()) and isVerified then
			if not unit:HasItemInInventory("item_admin_tp_hero") and unit.bFirstSpawned ~= false then
				unit:AddItemByName("item_admin_tp_hero")
				unit:AddItemByName("item_admin_gold_reset")
				unit:AddItemByName("item_admin_spawn_unit")

				unit.bFirstSpawned = false
			end
		end
	end

	--unit.bFirstSpawned = true
	--if not unit:HasItemInInventory("item_tpscroll_custom") and unit.bFirstSpawned == true then
	--	unit:AddItemByName("item_tpscroll_custom")
	--	unit.bFirstSpawned = false
	--end

end

function GameMode:EntHurt( event )
	local attacker = EntIndexToHScript(event.entindex_attacker)
	local target = EntIndexToHScript(event.entindex_killed)
end

function GameMode:EntKilled( event )
	local attacker = EntIndexToHScript(event.entindex_attacker)
	local target = EntIndexToHScript(event.entindex_killed)

	local team = target:GetTeamNumber()

	if target:GetUnitName() == "npc_dota_custom_tower_main" then -- система выбывания игроков при потере главного тавера
		print("ENT_KILLED: "..target:GetUnitName())
		--if current_player_count ~= 2 then
			if self:DefeatTeam(target) == true then
				self:SetWinner(attacker, 1)
			end
		--end
	end
end

function GameMode:OnStateChange()
	local state = GameRules:State_Get()

	if CUSTOM_DEBUG_MODE then
		print("GameMode StateChange:", state)
	end

	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		GameMode:OnPreGame()
	elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameMode:OnGameInProgress()
	end
end

function GameMode:OnPreGame()
	Timers:CreateTimer(3.0, function()

    if CUSTOM_DEBUG_MODE then
		for id=0, PlayerResource:GetPlayerCount() - 1 do
			GetPlayerInfo(id)
		end
	end

	end)
end

function GameMode:OnGameInProgress() -- запускается при начале игры (0:00 на таймере)
	local mode = GameRules:GetGameModeEntity()

	GameRules:SetTimeOfDay(0.251) -- игра начинается со дня

	for t=DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_8 do
		local couriers = Entities:FindAllByName("npc_dota_courier")
		if COURIER_MAX then
			for key,courier in pairs(couriers) do
				courier:UpgradeCourier(30)
				courier:AddNewModifier(nil, nil, "modifier_turbo_courier_haste", {})
				courier:AddNewModifier(nil, nil, "modifier_courier_autodeliver", {})
				courier:AddNewModifier(nil, nil, "modifier_turbo_courier_invulnerable", {})
			end
		end
	end

	GameRules:SpawnNeutralCreeps() -- спавн нейтральных крипов во всех кемпах

	ActivateFountainInvul() -- активирует неуязвимость фонтана
	DeactivateFountainsInvul(CUSTOM_FOUNTAIN_VUL_DELAY)

	GiveTPScroll()

	local shopkeepers = Entities:FindAllByName("npc_custom_shopkeeper")
	for _, unit in pairs(shopkeepers) do
		if not IsServer() then return end
		local player = GetPlayerByTeam(unit:GetTeam())
		if player then
			unit:SetControllableByPlayer(player:GetPlayerID(), false)
			unit:SetOwner(player:GetAssignedHero())
		end
		unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})		
	end

	mode:SetThink( waves_think, "", 1 )
end

function GameMode:DefeatTeam( unit )
	local team = unit:GetTeamNumber()
	local players_array = {}
	local current_player_count = 1
    for player_id = 0, PlayerResource:GetPlayerCount() - 1 do
        local player = PlayerResource:GetPlayer(player_id)
        if player and player:GetTeamNumber() == team then
            table.insert(players_array, player_id)
            player.defeated = true
        end
        if player.defeated == false then
         current_player_count = current_player_count + 1 end
    end

    for _, player_id in pairs(players_array) do
    	local player = PlayerResource:GetPlayer(player_id)
        local hero = PlayerResource:GetSelectedHeroEntity(player_id)
        if hero then
            hero:SetBuyBackDisabledByReapersScythe(true)
            hero:SetRespawnsDisabled(true)
            hero:ForceKill(false)
            player.place = current_player_count
            if player.place == 2 then return true
            else return false end
        end
    end
    print("!!! Команда №"..team.." выбывает из игры !!!")
    return false
end

function GameMode:SetWinner( unit, delay )
	local player = unit:GetPlayerOwner()
	local team = PlayerResource:GetCustomTeamAssignment()
	if current_player_count == 1 then
		_G.Game_end = true
		player.place = 1,
		print("!!! Команда №"..team.." побеждает !!!")
		Timers:CreateTimer(delay, function()
			GameRules:SetGameWinner(team)
		end)
	end
end

function MaxTime(n)
	local t = 70
	if n >= 1  then t = 30  end
	if n >= 2  then t = 45  end
	if n >= 3  then t = 80  end
	if n >= 8  then t = 85  end
	if n >= 16 then t = 95  end
	if n >= 25 then t = 120 end
	if BossTime(n) then 
	 t = 150 - portal_delay end -- 12:00
	if test_waves then t = 20 end	
	return t + portal_delay
end

function BossTime(n)
	local b = false
	if n == 10 then b = true elseif
	   n == 20 then b = true elseif 
	   n == 30 then b = true else
				    b = false end
	return b
end

function CreepLevel(n)
	local t = 70
	if n >= 1  then t = 1 end
	if n >= 5  then t = 2 end
	if n >= 11 then t = 3 end
	if n >= 16 then t = 4 end
	return t
end

function GetLowestNet( getTeam )
	local players = { }
	local networth_table = { }
	--for i=1, #low_net_waves do
	--	if not GameMode.current_wave 
	--end
    for player_id = 0, PlayerResource:GetPlayerCount() - 1 do
        local networth = PlayerResource:GetNetWorth(player_id)
        table.insert(players, player_id)
        table.insert(networth_table, networth)
    end
    table.sort(networth_table)
    for i=1, #networth_table do
    	if PlayerResource:GetNetWorth(i-1) == networth_table[1] then
    		local player = PlayerResource:GetPlayer(i-1)
    		if getTeam then return player:GetTeamNumber()
    		else return player end
    	end
    end
end

local gtimer = timer

function waves_think()
	if enable_waves == false then return end
	if game_end then return end
	max_timer = MaxTime(GameMode.current_wave)
	boss_wave = BossTime(GameMode.current_wave)
	--print("Next wave in: "..max_timer-timer.."s")

	--if boss_wave and not boss_stage then
--
	--	print("boss_stage")
--
	--	local wave_number = GameMode.current_wave
	--	local wave_name = "?????"
--
	--	for id=0, 8 do
	--		if PlayerResource:IsValidPlayerID(id) then
	--			local max = max_timer
	--			if boss_stage then max = 0 end
	--			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(id), 'timer_progress',  {upgrade = true, necro = false , units = -1, units_max = -1, time = timer, max = boss_timer, name = wave_name, skills = skills, mkb = mkb, number = wave_number})
	--		end
	--	end
--
	--	if boss_wave then
	--		print("Current wave: "..wave_number.." (BOSS WAVE)")
	--		GameMode:SpawnBoss( RandomInt(1, 2) )
	--	end
	--end

	if not boss_stage then
		timer = timer + 1
		gtimer = gtimer + 1
		if boss_wave then 
			local wave_number = GameMode.current_wave
			local wave_name = GameMode:GetWave(wave_number)
			local skills = GameMode:GetWaveSkills(wave_number)
			local mkb = GameMode:GetMkb(wave_number)
			for id=0, 8 do
				if PlayerResource:IsValidPlayerID(id) then
					GameMode:SetActiveWave(id)
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(id), 'timer_progress',  {upgrade = true, necro = false , units = -1, units_max = -1, time = timer, max = max_timer, name = GameMode:GetWave(GameMode.current_wave), skills = skills, mkb = 0, number = GameMode.current_wave})
				end
			end
			if timer == max_timer then
			for id=0, 8 do
				if PlayerResource:IsValidPlayerID(id) then				
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(id), 'timer_hide', {})
				end
			end
			print("Current wave: "..wave_number.." (BOSS WAVE)")
			GameMode.current_wave = GameMode.current_wave + 1
			GameMode:SpawnBoss( RandomInt(1, 2) )
			timer = 0
			end
		else
			local wave_number = GameMode.current_wave
			local wave_name = GameMode:GetWave(wave_number)
			local skills = GameMode:GetWaveSkills(wave_number)
			local mkb = GameMode:GetMkb(wave_number)
			for id=0, 8 do
				if PlayerResource:IsValidPlayerID(id) then
					GameMode:SetActiveWave(id)
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(id), 'timer_show', {})
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(id), 'timer_progress',  {upgrade = true, necro = false , units = -1, units_max = -1, time = timer, max = max_timer, name = GameMode:GetWave(GameMode.current_wave), skills = skills, mkb = 0, number = GameMode.current_wave})
				end
			end
			if timer == max_timer then
			print("Current wave: "..wave_number)
			GameMode.current_wave = GameMode.current_wave + 1
			for team=DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_8 do
				if team == GetLowestNet( true ) then give_lownet = true end
					local level = CreepLevel(wave_number)
					GameMode:SpawnWave( team, wave_number, level, give_lownet )
				end
			timer = 0
			end
		end
	end

	return 1
end