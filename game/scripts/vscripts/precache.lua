print("Precache Init")

particles = {
	"particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", -- seva_tether
	"particles/econ/items/wisp/wisp_tether_ti7.vpcf", -- seva_tether	
	"particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", -- seva_box
	"particles/econ/events/ti9/shovel_revealed_loot_variant_0_treasure.vpcf", -- seva_box
	"particles/econ/items/riki/riki_head_ti8/riki_smokebomb_ti8_crimson_smoke_ground.vpcf", -- seva_phone
	"particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", -- item_maxim_abaddon
	"particles/status_fx/status_effect_dark_willow_wisp_fear.vpcf", -- item_maxim_abaddon
	"particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_smoke.vpcf", -- item_maxim_abaddon
	"particles/econ/events/ti6/mjollnir_shield_ti6.vpcf", -- item_maxim_thewafer
	"particles/econ/courier/courier_babyroshan_ti10/courier_babyroshan_ti10_ambient_flying.vpcf", -- item_maxim_relevation
	"particles/items_fx/ethereal_copycat.vpcf", -- item_maxim_godhead
	"particles/items_fx/ethereal_blade_reverse.vpcf", -- item_maxim_godhead
	"particles/items_fx/ethereal_blade_reverse.vpcf", -- item_maxim_godhead
	"particles/items_fx/revenant_brooch_projectile.vpcf", -- item_maxim_godhead
	"particles/items5_fx/revenant_brooch.vpcf", -- item_maxim_godhead
	"particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", -- item_herald
	"particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_triple.vpcf", -- maxim_zxc
	"particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_double.vpcf", -- maxim_zxc
	"particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_rope.vpcf", -- maxim_zxc
	"particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_wings_grow_rope.vpcf", -- maxim_zxc
	"particles/econ/items/dazzle/dazzle_ti9/dazzle_shadow_wave_ti9_crimson_impact_damage.vpcf", -- maxim_creep
	"particles/econ/events/fall_2022/regen/fountain_regen_fall2022_lvl2.vpcf",
	"particles/units/heroes/hero_phantom_assassin_persona/pa_persona_crit_impact_travel_spray.vpcf",
	"particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf",
	"particles/units/heroes/hero_disruptor/disruptor_kineticfield.vpcf",
	"particles/items2_fx/refresher.vpcf",
	"particles/items2_fx/refresher_b.vpcf",
	"particles/items2_fx/refresher_c.vpcf",
	"particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf",
	"particles/econ/events/spring_2021/teleport_start_spring_2021.vpcf", -- item_tpscroll
	"particles/econ/events/spring_2021/teleport_end_spring_2021.vpcf", -- item_tpscroll
	"particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf",
	"particles/units/heroes/hero_leshrac/leshrac_disco_tnt.vpcf",
	"particles/custom/general/range_finder_aoe.vpcf",
	"particles/econ/items/oracle/oracle_fortune_ti7/oracle_fortune_ti7_aoe_ground_splash.vpcf",
	"particles/econ/events/ti10/hot_potato/disco_ball_channel.vpcf",
	"particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf",
	"particles/units/heroes/hero_antimage/antimage_manabreak_enemy_debuff.vpcf",
	"particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf",
	"particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf",
	"particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf",
	"particles/units/heroes/hero_dawnbreaker/dawnbreaker_calavera_hammer_projectile.vpcf",
	"particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf",
	"particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_crimson_ti8_immortal_pitofmalice_stun.vpcf",
	"particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf",
	"particles/econ/events/winter_major_2017/dagon_wm07_tgt_sparks.vpcf",
	"particles/econ/items/luna/luna_lucent_ti5/luna_lucent_beam_cast_ti_5.vpcf",
	"particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_cast_moonfall.vpcf",
	"particles/units/heroes/hero_luna/luna_lucent_beam_impact_bits.vpcf",
	"particles/generic_gameplay/generic_lifesteal.vpcf", -- blood_seeker_attack 
	"particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", -- ursa_red_clap 
	"particles/custom/general/exclamation.vpcf", -- ursa_red_clap 
	"particles/neutral_fx/dark_troll_ensnare.vpcf", -- boar_roor
	"particles/generic_gameplay/generic_purge.vpcf", -- boar_slow
	"particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", -- blood_seeker_rupture 
	"particles/items_fx/immunity_sphere.vpcf", -- satyr_linken
	"particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", -- satyr_stun
	"particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_small.vpcf", -- radiant_troop_root
	"particles/units/heroes/hero_treant/treant_naturesguise_cast.vpcf", -- radiant_troop_root
	"particles/units/heroes/hero_centaur/centaur_return.vpcf", -- radiant_troop_blade_mail
	"particles/units/heroes/hero_tiny/tiny_avalanche_projectile.vpcf", -- radiant_troop_stone
	"particles/units/heroes/hero_tiny/tiny_avalanche.vpcf", -- radiant_troop_stone
	"particles/econ/items/chaos_knight/chaos_knight_ti9_weapon/chaos_knight_ti9_weapon_crit_tgt.vpcf", -- wraith_creep_crit
	"particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_red.vpcf", -- wraith_creep_stun_red
	"particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff_red.vpcf", -- wraith_creep_stun_red
	"particles/units/heroes/hero_skeletonking/wraith_king_reincarnate_red.vpcf", -- wraith_creep_reincarnate_red
	"particles/base_static/experience_shrine_crack_glow_burst_flare.vpcf", -- xp_creep_bounty
	"particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf", -- boss_roshan_clap
	"particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf", -- boss_roshan_clap
	"particles/units/heroes/hero_magnataur/magnataur_shockwave_hit.vpcf", -- boss_roshan_clap
	"particles/units/heroes/hero_magnataur/magnataur_skewer_debuff.vpcf", -- boss_roshan_clap
	"particles/neutral_fx/roshan_slam.vpcf", -- boss_roshan_clap
	"particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", -- boss_roshan_amp
	"particles/econ/items/juggernaut/ancient_exile/ancient_exile_healing_ward.vpcf", -- boss_roshan_amp
	"particles/units/heroes/hero_primal_beast/primal_beast_rock_throw_impact.vpcf", -- boss_roshan_rocks
	"particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_stunned_symbol.vpcf", -- boss_roshan_rocks
	"particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", -- boss_roshan_dispel
	"particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", -- boss_roshan_dispel
	"particles/custom/portal/purple/portal_open.vpcf", -- wave_portal
	"particles/generic_gameplay/generic_stunned.vpcf",
	"particles/units/heroes/hero_riki/riki_shard_sleep.vpcf", -- modifier_arena_boss_sleep
	"particles/creatures/aghanim/aghanim_beam_channel.vpcf", -- shopkeeper_upgrade_tower

}

soundfiles = {
	"soundevents/game_sounds.vsndevts",
	"soundevents/game_sounds_items.vsndevts",
	"soundevents/seva_sounds.vsndevts",
	"soundevents/maxim_sounds.vsndevts",
	"soundevents/marker_sounds.vsndevts",
	"soundevents/voscripts/game_sounds_vo_announcer.vsndevts", -- announcer
	"soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", -- item_maxim_abaddon
	"soundevents/game_sounds_heroes/game_sounds_kez.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_oracle.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_ember_spirit.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_chen.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_muerta.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_visage.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_luna.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_sniper.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_disruptor.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_queenofpain.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts", -- boar_amp
	"soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", -- blood_seeker_rupture
	"soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", -- blood_seeker_rupture
	"soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", -- satyr_stun
	"soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", -- radiant_troop_root
	"soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", -- radiant_troop_stone
	"soundevents/game_sounds_heroes/game_sounds_skeletonking.vsndevts", -- brood_spider
	"soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", -- boss_roshan_lotus
	"soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", -- boss_roshan_clap
	"soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", -- boss_roshan_amp
	"soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", -- boss_roshan_amp
	"soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", -- boss_roshan_amp
	"soundevents/game_sounds_heroes/game_sounds_primal_beast.vsndevts", -- boss_roshan_rocks
	"soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", -- boss_roshan_dispel
	"soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", -- boss_roshan_dispel
	"soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", -- wave_portal
	"soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", -- modifier_arena_boss_sleep

}

models = {
	"models/props_gameplay/npc/shopkeeper_the_lost_meepo/shopkeeper_the_lost_meepo.vmdl", --npc_custom_shopkeeper
	"models/heroes/nevermore/nevermore.vmdl", -- maxim_creep abilitiy_model
	"models/props_gameplay/dummy/dummy_large.vmdl", -- marker_dance ability_model
	"models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl", -- npc_troll_skelet
	"models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl", -- npc_ursa_red
	"models/creeps/neutral_creeps/n_creep_beast/n_creep_beast.vmdl", -- npc_ursa_yellow
	"models/heroes/beastmaster/beastmaster_beast.vmdl", -- npc_boar_a
	"models/items/beastmaster/boar/fotw_wolf/fotw_wolf.vmdl", -- npc_boar_b
	"models/heroes/life_stealer/life_stealer.vmdl", -- npc_ghoul
	"models/heroes/blood_seeker/blood_seeker.vmdl", -- npc_blood_seeker
	"models/creeps/neutral_creeps/n_creep_satyr_spawn_a/n_creep_satyr_spawn_a.vmdl", -- npc_satyr_a
	"models/creeps/neutral_creeps/n_creep_satyr_spawn_a/n_creep_satyr_spawn_b.vmdl", -- npc_satyr_b
	"models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_melee.vmdl", -- npc_radiant_troop_a
	"models/creeps/lane_creeps/creep_2021_radiant/creep_2021_radiant_melee_mega.vmdl", -- npc_radiant_troop_b
	"models/items/wraith_king/wk_ti8_creep/wk_ti8_creep.vmdl", -- npc_wraith_creep_a
	"models/items/wraith_king/wk_ti8_creep/wk_ti8_creep_crimson.vmdl", -- npc_wraith_creep_b
	"models/courier/greevil/gold_greevil.vmdl", -- npc_gold_creep
	"models/creeps/lane_creeps/creep_bad_melee/creep_crystal_bad_melee.vmdl", -- npc_xp_creep
	"models/creeps/roshan/roshan.vmdl", -- npc_boss_roshan

}

model_folders = {
	"models/heroes/pudge/",
	"models/heroes/shadow_fiend",
	"models/heroes/bristleback/",
	"models/heroes/huskar/",
	"models/heroes/invoker/",

}

particle_folders = {
	"particles/custom/neutral",
	"particles/custom/neutral/boss",
	"particles/units/heroes/hero_life_stealer",

}