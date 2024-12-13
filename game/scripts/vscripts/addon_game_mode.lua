require("game_mode")

function Precache( context )

	PrecacheResource("soundfile", "soundevents/game_sounds.vsndevts", context) 

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
	PrecacheResource("particle", "particles/items_fx/armlet.vpcf", context) -- marker_armlet
end

-- Create the game mode when we activate
function Activate()
	GameMode:Init()
	GameMode:InitFast()
end

