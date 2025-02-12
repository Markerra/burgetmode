if GameMode == nil then
	_G.GameMode = class({})
end

require("game-mode/game_mode_init")


function Precache( context )

	PrecacheResource("soundfile", "soundevents/game_sounds.vsndevts", context) 

--================================================================================================================================================
--------------------- WEATHER
--================================================================================================================================================
	--PrecacheResource("particle", "particles/winter_fx/weather_frostivus_snow.vpcf", context) -- snow
	--PrecacheResource("particle", "particles/rain_fx/econ_weather_spring.vpcf", context) -- spring

--================================================================================================================================================
--------------------- SEVA
--================================================================================================================================================
	PrecacheResource("model_folder", "models/heroes/pudge/", context) -- hero_model

	PrecacheResource("soundfile", "soundevents/seva_sounds.vsndevts", context)

	PrecacheResource("particle", "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", context) -- seva_tether
	PrecacheResource("particle", "particles/econ/items/wisp/wisp_tether_ti7.vpcf", context) -- seva_tether	
			
	PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", context) -- seva_box
	PrecacheResource("particle", "particles/econ/events/ti9/shovel_revealed_loot_variant_0_treasure.vpcf", context) -- seva_box

	PrecacheResource("particle", "particles/econ/items/riki/riki_head_ti8/riki_smokebomb_ti8_crimson_smoke_ground.vpcf", context) -- seva_phone

--================================================================================================================================================
--------------------- MAXIM
--================================================================================================================================================
	PrecacheResource("model_folder", "models/heroes/shadow_fiend", context ) -- hero_model
	PrecacheModel("models/heroes/nevermore/nevermore.vmdl", context) -- abilitiy_model

	PrecacheResource("soundfile", "soundevents/maxim_sounds.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context) -- item_maxim_abaddon

	PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", context) -- item_maxim_abaddon
	PrecacheResource("particle", "particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf", context) -- item_maxim_abaddon
	PrecacheResource("particle", "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_smoke.vpcf", context) -- item_maxim_abaddon
	PrecacheResource("particle", "particles/econ/events/ti6/mjollnir_shield_ti6.vpcf", context) -- item_maxim_thewafer
	PrecacheResource("particle", "particles/econ/courier/courier_babyroshan_ti10/courier_babyroshan_ti10_ambient_flying.vpcf", context) -- item_maxim_relevation
	PrecacheResource("particle", "particles/items_fx/ethereal_copycat.vpcf", context) -- item_maxim_godhead
	PrecacheResource("particle", "particles/items_fx/ethereal_blade_reverse.vpcf", context) -- item_maxim_godhead
	PrecacheResource("particle", "particles/items_fx/ethereal_blade_reverse.vpcf", context) -- item_maxim_godhead
	PrecacheResource("particle", "particles/items_fx/revenant_brooch_projectile.vpcf", context) -- item_maxim_godhead
	PrecacheResource("particle", "particles/items5_fx/revenant_brooch.vpcf", context) -- item_maxim_godhead

	PrecacheResource("particle", "particles/items_fx/gem_truesight_aura_magic.vpcf", context) -- item_herald
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", context) -- maxim_zxc
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_triple.vpcf", context) -- maxim_zxc
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_double.vpcf", context) -- maxim_zxc
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_rope.vpcf", context) -- maxim_zxc
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_wings_grow_rope.vpcf", context) -- maxim_zxc
	PrecacheResource("particle", "particles/econ/items/dazzle/dazzle_ti9/dazzle_shadow_wave_ti9_crimson_impact_damage.vpcf", context) -- maxim_creep

--================================================================================================================================================
--------------------- SERGOPY
--================================================================================================================================================
	PrecacheResource("model_folder", "models/heroes/bristleback/", context) -- sergopy_hero_model
	PrecacheResource( "model_folder", "models/heroes/huskar/", context ) -- marker_hero_model
	PrecacheModel( "models/props_gameplay/dummy/dummy_large.vmdl", context ) -- marker_dance_ability_model
	PrecacheResource( "model_folder", "models/heroes/invoker/", context ) -- matvey_hero_model
	
	PrecacheResource( "soundfile", "soundevents/marker_sounds.vsndevts", context )

--================================================================================================================================================
--------------------- ITEMS
--================================================================================================================================================
	PrecacheResource("particle", "particles/econ/events/spring_2021/teleport_start_spring_2021.vpcf", context) -- item_tpscroll
	PrecacheResource("particle", "particles/econ/events/spring_2021/teleport_end_spring_2021.vpcf", context) -- item_tpscroll

--================================================================================================================================================
--------------------- NEUTRAL CREEPS
--================================================================================================================================================
	PrecacheResource( "particle_folder", "particles/custom/neutral", context )

	PrecacheModel( "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl", context ) -- npc_troll_skelet
	PrecacheModel( "models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl", context ) -- npc_ursa_red
	PrecacheModel( "models/creeps/neutral_creeps/n_creep_beast/n_creep_beast.vmdl", context ) -- npc_ursa_yellow
	PrecacheModel( "models/heroes/beastmaster/beastmaster_beast.vmdl", context ) -- npc_boar_a
	PrecacheModel( "models/items/beastmaster/boar/fotw_wolf/fotw_wolf.vmdl", context ) -- npc_boar_b
	PrecacheModel( "models/heroes/life_stealer/life_stealer.vmdl", context ) -- npc_ghoul
	PrecacheModel( "models/heroes/blood_seeker/blood_seeker.vmdl", context ) -- npc_blood_seeker

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts", context ) -- boar_amp
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context ) -- blood_seeker_rupture
	PrecacheResource( "particle", "particles/generic_gameplay/generic_lifesteal.vpcf", context ) -- blood_seeker_attack 
	PrecacheResource( "particle", "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", context ) -- ursa_red_clap 
	PrecacheResource( "particle", "particles/custom/general/exclamation.vpcf", context ) -- ursa_red_clap 
	PrecacheResource( "particle", "particles/neutral_fx/dark_troll_ensnare.vpcf", context ) -- boar_roor
	PrecacheResource( "particle", "particles/generic_gameplay/generic_purge.vpcf", context ) -- boar_slow
	PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", context ) -- blood_seeker_rupture 

--================================================================================================================================================
--------------------- OTHER
--================================================================================================================================================
	PrecacheResource( "particle", "particles/custom/portal/purple/portal_open.vpcf", context ) -- wave_portal	
end

-- Create the game mode when we activate
function Activate()
	GameMode:Init()
	GameMode:SetupColors()

	if IsInToolsMode() then

		GameMode:InitFast() -- быстрый пик героев (для тестов)
		GameMode:GiveAdminItems() -- выдать админ-предметы

	end

end

