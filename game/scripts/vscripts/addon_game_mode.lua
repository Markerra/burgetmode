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
	PrecacheResource( "particle_folder", "particles/custom/neutral/boss", context )

	PrecacheModel( "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl", context ) -- npc_troll_skelet
	PrecacheModel( "models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl", context ) -- npc_ursa_red
	PrecacheModel( "models/creeps/neutral_creeps/n_creep_beast/n_creep_beast.vmdl", context ) -- npc_ursa_yellow
	PrecacheModel( "models/heroes/beastmaster/beastmaster_beast.vmdl", context ) -- npc_boar_a
	PrecacheModel( "models/items/beastmaster/boar/fotw_wolf/fotw_wolf.vmdl", context ) -- npc_boar_b
	PrecacheModel( "models/heroes/life_stealer/life_stealer.vmdl", context ) -- npc_ghoul
	PrecacheModel( "models/heroes/blood_seeker/blood_seeker.vmdl", context ) -- npc_blood_seeker
	PrecacheModel( "models/creeps/neutral_creeps/n_creep_satyr_spawn_a/n_creep_satyr_spawn_a.vmdl", context ) -- npc_satyr_a
	PrecacheModel( "models/creeps/neutral_creeps/n_creep_satyr_spawn_a/n_creep_satyr_spawn_b.vmdl", context ) -- npc_satyr_b
	PrecacheModel( "models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_melee.vmdl", context ) -- npc_radiant_troop_a
	PrecacheModel( "models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_melee_mega.vmdl", context ) -- npc_radiant_troop_b
	PrecacheModel( "models/items/wraith_king/wk_ti8_creep/wk_ti8_creep.vmdl", context ) -- npc_wraith_creep_a
	PrecacheModel( "models/items/wraith_king/wk_ti8_creep/wk_ti8_creep_crimson.vmdl", context ) -- npc_wraith_creep_b
	PrecacheModel( "models/courier/greevil/gold_greevil.vmdl", context ) -- npc_gold_creep
	PrecacheModel( "models/creeps/lane_creeps/creep_bad_melee/creep_crystal_bad_melee.vmdl", context ) -- npc_xp_creep
	PrecacheModel( "models/creeps/roshan/roshan.vmdl", context ) -- npc_boss_roshan

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts", context ) -- boar_amp
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context ) -- blood_seeker_rupture
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context ) -- blood_seeker_rupture
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context ) -- satyr_stun
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", context ) -- radiant_troop_root
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context ) -- radiant_troop_stone
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skeletonking.vsndevts", context ) -- brood_spider
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context ) -- boss_roshan_lotus
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", context ) -- boss_roshan_clap
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context ) -- boss_roshan_amp
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context ) -- boss_roshan_amp
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context ) -- boss_roshan_amp
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_primal_beast.vsndevts", context ) -- boss_roshan_rocks
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context ) -- boss_roshan_dispel
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context ) -- boss_roshan_dispel
	PrecacheResource( "particle", "particles/generic_gameplay/generic_lifesteal.vpcf", context ) -- blood_seeker_attack 
	PrecacheResource( "particle", "particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", context ) -- ursa_red_clap 
	PrecacheResource( "particle", "particles/custom/general/exclamation.vpcf", context ) -- ursa_red_clap 
	PrecacheResource( "particle", "particles/neutral_fx/dark_troll_ensnare.vpcf", context ) -- boar_roor
	PrecacheResource( "particle", "particles/generic_gameplay/generic_purge.vpcf", context ) -- boar_slow
	PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", context ) -- blood_seeker_rupture 
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_life_stealer/", context ) -- ghoul_infest
	PrecacheResource( "particle", "particles/items_fx/immunity_sphere.vpcf", context ) -- satyr_linken
	PrecacheResource( "particle", "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", context ) -- satyr_stun
	PrecacheResource( "particle", "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_small.vpcf", context ) -- radiant_troop_root
	PrecacheResource( "particle", "particles/units/heroes/hero_treant/treant_naturesguise_cast.vpcf", context ) -- radiant_troop_root
	PrecacheResource( "particle", "particles/units/heroes/hero_centaur/centaur_return.vpcf", context ) -- radiant_troop_blade_mail
	PrecacheResource( "particle", "particles/units/heroes/hero_tiny/tiny_avalanche_projectile.vpcf", context ) -- radiant_troop_stone
	PrecacheResource( "particle", "particles/units/heroes/hero_tiny/tiny_avalanche.vpcf", context ) -- radiant_troop_stone
	PrecacheResource( "particle", "particles/econ/items/chaos_knight/chaos_knight_ti9_weapon/chaos_knight_ti9_weapon_crit_tgt.vpcf", context ) -- wraith_creep_crit
	PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_red.vpcf", context ) -- wraith_creep_stun_red
	PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff_red.vpcf", context ) -- wraith_creep_stun_red
	PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate_red.vpcf", context ) -- wraith_creep_reincarnate_red
	PrecacheResource( "particle", "particles/base_static/experience_shrine_crack_glow_burst_flare.vpcf", context ) -- xp_creep_bounty
	PrecacheResource( "particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf", context ) -- boss_roshan_clap
	PrecacheResource( "particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf", context ) -- boss_roshan_clap
	PrecacheResource( "particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave_hit.vpcf", context ) -- boss_roshan_clap
	PrecacheResource( "particle", "particles/units/heroes/hero_magnataur/magnataur_skewer_debuff.vpcf", context ) -- boss_roshan_clap
	PrecacheResource( "particle", "particles/neutral_fx/roshan_slam.vpcf", context ) -- boss_roshan_clap
	PrecacheResource( "particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", context ) -- boss_roshan_amp
	PrecacheResource( "particle", "particles/econ/items/juggernaut/ancient_exile/ancient_exile_healing_ward.vpcf", context ) -- boss_roshan_amp
	PrecacheResource( "particle", "particles/units/heroes/hero_primal_beast/primal_beast_rock_throw_impact.vpcf", context ) -- boss_roshan_rocks
	PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_stunned_symbol.vpcf", context ) -- boss_roshan_rocks
	PrecacheResource( "particle", "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", context ) -- boss_roshan_dispel
	PrecacheResource( "particle", "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", context ) -- boss_roshan_dispel
--================================================================================================================================================
--------------------- OTHER
--================================================================================================================================================
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context ) -- wave_portal
	PrecacheResource( "particle", "particles/custom/portal/purple/portal_open.vpcf", context ) -- wave_portal
	PrecacheResource( "particle", "particles/generic_gameplay/generic_stunned.vpcf", context )
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

