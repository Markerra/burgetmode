require("game-mode/game_mode_settings")
require("game-mode/game_mode_init")

function Precache( context )

	PrecacheResource("soundfile", "soundevents/game_sounds.vsndevts", context) 

--================================================================================================================================================
--------------------- WEATHER
--================================================================================================================================================
	PrecacheResource("particle", "particles/winter_fx/weather_frostivus_snow.vpcf", context) -- snow
	PrecacheResource("particle", "particles/rain_fx/econ_weather_spring.vpcf", context) -- spring

--================================================================================================================================================
--------------------- SEVA
--================================================================================================================================================
	PrecacheResource("soundfile", "soundevents/seva_sounds.vsndevts", context)

	PrecacheResource("particle", "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", context) -- seva_tether
	PrecacheResource("particle", "particles/econ/items/wisp/wisp_tether_ti7.vpcf", context) -- seva_tether	
			
	PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", context) -- seva_box
	PrecacheResource("particle", "particles/econ/events/ti9/shovel_revealed_loot_variant_0_treasure.vpcf", context) -- seva_box

	PrecacheResource("particle", "particles/econ/items/riki/riki_head_ti8/riki_smokebomb_ti8_crimson_smoke_ground.vpcf", context) -- seva_phone

--================================================================================================================================================
--------------------- MAXIM
--================================================================================================================================================
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
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_queenofpain.vsndevts", context) -- sergopy_voice
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_disruptor.vsndevts", context) -- sergopy_ivl
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context) -- sergopy_refresh
	PrecacheResource("soundfile", "soundevents/game_sounds_items.vsndevts", context) -- sergopy_refresh

	PrecacheResource("particle", "particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf", context) -- sergopy_voice

	PrecacheResource("particle", "particles/econ/events/fall_2022/regen/fountain_regen_fall2022_lvl2.vpcf", context) -- sergopy_ivl
	PrecacheResource("particle", "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_crit_impact_travel_spray.vpcf", context) -- sergopy_ivl
	PrecacheResource("particle", "particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf", context) -- sergopy_ivl
	PrecacheResource("particle", "particles/units/heroes/hero_disruptor/disruptor_kineticfield.vpcf", context) -- sergopy_ivl

	PrecacheResource("particle", "particles/items2_fx/refresher.vpcf", context) -- sergopy_refresh
	PrecacheResource("particle", "particles/items2_fx/refresher_b.vpcf", context) -- sergopy_refresh
	PrecacheResource("particle", "particles/items2_fx/refresher_c.vpcf", context) -- sergopy_refresh

--================================================================================================================================================
--------------------- MARKER
--================================================================================================================================================
	PrecacheResource( "soundfile", "soundevents/marker_sounds.vsndevts", context )

	PrecacheResource( "particle", "particles/items_fx/armlet.vpcf", context) -- marker_armlet
	
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context ) -- marker_chill
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context ) -- marker_chill
	
	PrecacheResource( "particle", "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf", context ) -- marker_chill
	PrecacheResource( "particle", "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf", context ) -- marker_chill
	PrecacheResource( "particle", "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf", context ) -- marker_chill
	
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context) -- marker_hammer
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context ) -- marker_hammer
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context ) -- marker_hammer
	
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_calavera_hammer_projectile.vpcf", context ) -- marker_hammer
	PrecacheResource( "particle", "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf", context ) -- marker_hammer
	PrecacheResource( "particle", "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_crimson_ti8_immortal_pitofmalice_stun.vpcf", context ) -- marker_hammer
	PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf", context ) -- marker_hammer
	
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context ) -- marker_shot
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context ) -- marker_shot
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_luna.vsndevts", context ) -- marker_shot
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sniper.vsndevts", context ) -- marker_shot
	
	PrecacheResource( "particle", "particles/econ/events/winter_major_2017/dagon_wm07_tgt_sparks.vpcf", context ) -- marker_shot
	PrecacheResource( "particle", "particles/econ/items/luna/luna_lucent_ti5/luna_lucent_beam_cast_ti_5.vpcf", context ) -- marker_shot
	PrecacheResource( "particle", "particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_cast_moonfall.vpcf", context ) -- marker_shot
	PrecacheResource( "particle", "particles/units/heroes/hero_luna/luna_lucent_beam_impact_bits.vpcf", context ) -- marker_shot

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ember_spirit.vsndevts", context ) -- marker_dance
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_chen.vsndevts", context ) -- marker_dance
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_muerta.vsndevts", context ) -- marker_dance
	PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf", context ) -- marker_dance
	PrecacheResource( "particle", "particles/units/heroes/hero_leshrac/leshrac_disco_tnt.vpcf", context ) -- marker_dance
	PrecacheResource( "particle", "particles/ui_mouseactions/range_finder_aoe.vpcf", context ) -- marker_dance
	PrecacheResource( "particle", "particles/econ/items/oracle/oracle_fortune_ti7/oracle_fortune_ti7_aoe_ground_splash.vpcf", context ) -- marker_dance
	PrecacheResource( "particle", "particles/econ/events/ti10/hot_potato/disco_ball_channel.vpcf", context ) -- marker_dance

--================================================================================================================================================
--------------------- TOWER
--================================================================================================================================================
	PrecacheResource("particle", "particles/econ/events/ti8/shivas_guard_ti8_slow.vpcf", context) -- tower_soul_drain

--================================================================================================================================================
--------------------- ITEMS
--================================================================================================================================================
	PrecacheResource("particle", "particles/econ/events/spring_2021/teleport_start_spring_2021.vpcf", context) -- item_tpscroll
	PrecacheResource("particle", "particles/econ/events/spring_2021/teleport_end_spring_2021.vpcf", context) -- item_tpscroll

end

-- Create the game mode when we activate
function Activate()
	GameMode:Init()

	if IsInToolsMode() then

		GameMode:InitFast() -- быстрый пик героев (для тестов)
		GameMode:GiveAdminItems() -- выдать админ-предметы

	end

end

