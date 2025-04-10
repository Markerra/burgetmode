require("game-mode/custom_params")
require("utils/timers")

LinkLuaModifier( "modifier_wave_upgrade", "modifiers/modifier_wave_upgrade", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wave_mkb", "modifiers/modifier_wave_mkb", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_damage_tracker", "modifiers/modifier_damage_tracker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_unselect", "modifiers/modifier_unselect", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_arena_boss_sleep", "modifiers/modifier_arena_boss_sleep", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_upgrade", "modifiers/modifier_boss_upgrade", LUA_MODIFIER_MOTION_NONE )

wave_types = {

	--[[#1]] { 0, false, { "npc_troll_skelet_a", "npc_troll_skelet_a", "npc_troll_skelet_b", "npc_troll_skelet_b", "npc_troll_skelet_c" },
             	{ "npc_troll_skelet_a", "npc_troll_skelet_b", "npc_troll_skelet_b", "npc_troll_skelet_c", "npc_troll_skelet_c" } },

	--[[#2]] { 0, false, { "npc_ursa_red", "npc_ursa_red", "npc_ursa_red", "npc_ursa_yellow", "npc_ursa_yellow"},
             	{ "npc_ursa_red", "npc_ursa_red", "npc_ursa_yellow", "npc_ursa_yellow", "npc_ursa_yellow" } },

	--[[#3]] { 0, false, { "npc_boar_a", "npc_boar_b", "npc_boar_b", "npc_boar_b" },
	 			{ "npc_boar_a", "npc_boar_a", "npc_boar_b", "npc_boar_b" } },

  --[[#4]] { 0, true, { "npc_blood_seeker", "npc_blood_seeker", "npc_ghoul", "npc_ghoul" },
        { "npc_blood_seeker", "npc_ghoul", "npc_ghoul", "npc_ghoul" } },

  --[[#5]] { 0, false, { "npc_satyr_a", "npc_satyr_a", "npc_satyr_b", "npc_satyr_b" },
        { "npc_satyr_a", "npc_satyr_b", "npc_satyr_b", "npc_satyr_b" } },

  --[[#6]] { 0, false, { "npc_radiant_troop_a", "npc_radiant_troop_a", "npc_radiant_troop_b", "npc_radiant_troop_b" },
        { "npc_radiant_troop_a", "npc_radiant_troop_b", "npc_radiant_troop_b", "npc_radiant_troop_b" } },

  --[[#7]] { 0, false, { "npc_wraith_creep_a", "npc_wraith_creep_a", "npc_wraith_creep_b", "npc_wraith_creep_b" },
        { "npc_wraith_creep_a", "npc_wraith_creep_a", "npc_wraith_creep_a", "npc_wraith_creep_b" } },

  --[[#8]] { 0, false, { "npc_gold_creep", "npc_gold_creep", "npc_gold_creep", "npc_gold_creep" } },

  --[[#9]] { 0, false, { "npc_xp_creep", "npc_xp_creep", "npc_xp_creep", "npc_xp_creep" } },

  --[[#10]] { 3, false, { "npc_boss_roshan" },--[[ { "npc_boss_warden" } ]]},

}

--[[

{ 0, 			     false,    { {"creep_1", 	"creep_2",   ... },      {"creep_2", "creep_1",   ... },       } }
  ↑ type       ↑ has mkb      ↑ unit1     ↑ unit2 (1st variant)     ↑ unit2    ↑ unit1 (2nd variant)
  0 > normal
  1 > necr
  2 > special
  3 > boss
]] 

wave_abilities = {

  --[[#1]] { "troll_skelet_aura_a", "troll_skelet_aura_b", "troll_skelet_aura_c" },

  --[[#2]] { "ursa_red_clap", "ursa_yellow_swipes", "furbolg_enrage_attack_speed" },

  --[[#3]] { "boar_root", "boar_slow", "boar_amp" },

  --[[#4]] { "blood_seeker_attack", "blood_seeker_rupture", "ghoul_infest", "ghoul_wounds" },

  --[[#5]] { "satyr_stun", "satyr_magic_res", "satyr_purge", "satyr_linken" },

  --[[#6]] { "radiant_troop_armor", "radiant_troop_root", "radiant_troop_stone", "radiant_troop_blade_mail" },

  --[[#7]] { "wraith_creep_stun", "wraith_creep_crit", "wraith_creep_stun_red", "wraith_creep_reincarnate_red" },

  --[[#8]] { "gold_creep_bounty" },

  --[[#9]] { "xp_creep_bounty" },

  --[[#10]] { "boss_roshan_clap", "boss_roshan_rocks", "boss_roshan_amp", "boss_roshan_dispel", "boss_roshan_lotus" },

}

GameMode.current_wave = start_wave

function GameMode:GetWaveCreeps( wave )
	if not wave_types[wave] then
		print("GetWaveCreeps() - wave #"..wave.." not found!") return false end
	local wave = wave_types[wave][RandomInt(3, #wave_types[wave])]
	local creeps = {}
	for _, creep in pairs(wave) do
		table.insert(creeps, creep)
	end
	return creeps
end

function GameMode:GetWaveUnits( n, pid )
    local player = PlayerResource:GetPlayer(pid)
    local hero   = player:GetAssignedHero()

    local max = GameMode:GetWaveCreeps(n)
    local wave_creeps = {}
    local units = FindUnitsInRadius(hero:GetTeamNumber(), 
      hero:GetAbsOrigin(), nil, 
      FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, 
      DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
      FIND_CLOSEST, false)

    for _, unit in pairs(units) do
        if unit.wave_creep then 
          table.insert(wave_creeps, unit) end
    end

    if not units then return {units_max = #wave_creeps} else
    return {units = #wave_creeps, units_max = #max} end
end

function GameMode:GetWave( wave )
    return wave_types[wave][3][1]
end

function GameMode:GetWaveType( wave )
    return wave_types[wave][1]
end

function GameMode:GetWaveSkills( wave )
  if not wave_abilities[wave] then
  print("GetWaveSkills() - wave #"..wave.." abilities not found!") return false end
  local abilitiesList = {}
  for i=1, #wave_abilities[wave] do
      local ability = wave_abilities[wave][i]
      table.insert(abilitiesList, ability)
  end
  return abilitiesList
end

function GameMode:GetMkb( wave )
    return wave_types[wave][2]
end

function GameMode:CheckActiveWave( pid )
    local player = PlayerResource:GetPlayer(pid)
    local hero   = player:GetAssignedHero()

    local wave_creeps = {}
    local units = FindUnitsInRadius(hero:GetTeamNumber(), 
      hero:GetAbsOrigin(), nil, 
      FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, 
      DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
      FIND_CLOSEST, false)

    for _, unit in pairs(units) do
        if unit.wave_creep then 
          table.insert(wave_creeps, unit) end
    end

    if #wave_creeps >= 1 then return true else return false end
end

function GameMode:SetActiveWave( pid )
    local player = PlayerResource:GetPlayer(pid)
    player.active_wave = self:CheckActiveWave(pid)
end

function CreatePortal( pos, data )
	--local portal_particle = "particles/units/heroes/heroes_underlord/abbysal_underlord_portal_ambient.vpcf"
	 
   	local teleport_center = CreateUnitByName("npc_dota_companion", pos, false, nil, nil, 0)
    teleport_center:AddNewModifier(teleport_center, nil, "modifier_phased", {})
    teleport_center:AddNewModifier(teleport_center, nil, "modifier_invulnerable", {})
    teleport_center:AddNewModifier(teleport_center, nil, "modifier_unselect", {})

    teleport_center:EmitSound("Hero_AbyssalUnderlord.DarkRift.Cast")

		teleport_center.nWarningFX = ParticleManager:CreateParticle( "particles/custom/portal/purple/portal_open.vpcf", PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl( teleport_center.nWarningFX, 0, teleport_center:GetAbsOrigin() )

    if teleport_center == nil then return false end
    --local creeps_array = {}
    Timers:CreateTimer(portal_delay, function()
    	local allys = {}
    	local units = data.units
    	local level = data.lvl

		for i=1, #units do
			if units == false then return false end
			local creep = CreateUnitByName(units[i], pos, true, nil, nil, DOTA_TEAM_BADGUYS)
			allys[i] = creep
      if GameMode:GetMkb(data.wave) == true then
        creep:AddNewModifier(creep, nil, "modifier_wave_mkb", nil) end
        creep.mkb = true
			creep:AddNewModifier(creep, nil, "modifier_wave_upgrade", nil)
    	FindClearSpaceForUnit(creep, pos, true)
    	allys[i].ally = allys
    	allys[i].number = i
    	creep:CreatureLevelUp(level - 1)
      creep.wave_creep = true
      --table.insert(creeps_array, creep)
		end 

    	ParticleManager:DestroyParticle(teleport_center.nWarningFX, false)
    	teleport_center:StopSound("Hero_AbyssalUnderlord.DarkRift.Cast")
 		  teleport_center:EmitSound("Hero_AbyssalUnderlord.DarkRift.Complete")
    	teleport_center:Destroy()
    end)
    return true
end

function GameMode:SpawnWave( team, number, level, give_lownet )
    local player = nil

    for player_id = 0, PlayerResource:GetPlayerCount() - 1 do
        player = PlayerResource:GetPlayer(player_id)
        if player and player:GetTeamNumber() == team then
            if player.defeated == true then
            local name = PlayerResource:GetPlayerName(player_id)
            print("SpawnWave() - player <"..name.."> is defeated") return end
        end
        if player or not PlayerResource:IsValidPlayerID(player_id) or not player:GetAssignedHero() then
            print("SpawnWave() - player in <"..team.."> team does not exist") return
        end
    end

    local portal = Entities:FindByName(nil, "custom".. team-5 .."_wave_portal")
    if not portal then return -1 end

    local point = portal:GetAbsOrigin()

   	local units = self:GetWaveCreeps(number)

   	if units ~= false and units ~= nil then
   		CreatePortal(point, {units=units, lvl=level, wave=number})
   	else
      CreatePortal(point, {units=units, lvl=level, wave=self:GetWaveCreeps(#wave_types-number) * (-1)})
    end

    if give_lownet then
      print("LOWNET WAVE FOR: "..PlayerResource:GetPlayerName(player:GetPlayerID()))
    end
end

function GameMode:SpawnBoss( type )
  if not IsServer() then return end

  if type == 1 then
    --
  elseif type == 2 then
    --
  end

  local boss = CreateUnitByName("npc_boss_roshan", Vector( 0, 0, 0 ), true, nil, nil, DOTA_TEAM_BADGUYS)

  if not boss then return end

  boss:AddNewModifier(nil, nil, "modifier_damage_tracker", {})
  boss:AddNewModifier(nil, nil, "modifier_boss_upgrade", {})
  boss:AddNewModifier(nil, nil, "modifier_arena_boss_sleep", {duration = 5.5})

  local particle = "particles/econ/items/dazzle/dazzle_ti9/dazzle_shadow_wave_ti9_crimson_impact_damage.vpcf"
  local spawn_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, boss)
  ParticleManager:ReleaseParticleIndex(spawn_fx)

  for team = DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_8 do
    local player = nil
    local hero   = nil

    for player_id = 0, PlayerResource:GetPlayerCount() - 1 do
        player = PlayerResource:GetPlayer(player_id)
        if player and player:GetTeamNumber() == team then
            if player.defeated == true then
            local name = PlayerResource:GetPlayerName(player_id)
            print("SpawnWave() - player <"..name.."> is defeated") return end
        end
        if player or not PlayerResource:IsValidPlayerID(player_id) or not player:GetAssignedHero() then
            print("SpawnWave() - player in <"..team.."> team does not exist") return
        end
    end

    hero = player:GetAssignedHero()
    print("BOSS_ROSHAN_TELEPORT FOR ", hero:GetUnitName())
    if not hero:IsAlive() then
      hero:RespawnHero(false, false)
      hero:RemoveModifierByName("modifier_fountain_invulnerability")
    end

    local teleport = Entities:FindByName(nil, "arena_boss_tp_".. team-5)
    if not teleport then return -1 end

    local point = teleport:GetAbsOrigin()

    hero:Stop()
    FindClearSpaceForUnit(hero, point, true)
    hero:AddNewModifier(nil, nil, "modifier_arena_boss_sleep", {duration = 5.0})

    PlayerResource:SetCameraTarget(player:GetPlayerID(), hero)
    Timers:CreateTimer(0.5, function()
      PlayerResource:SetCameraTarget(player:GetPlayerID(), nil)
    end)

    hero:SetHealth(hero:GetMaxHealth())
    hero:Purge(true, true, false, true, true)

    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability and ability:GetCooldown(-1) > 0 then
            ability:EndCooldown()
        end
    end

  end

  EmitGlobalSound("Hero_LegionCommander.Duel.Cast.Arcana")

end