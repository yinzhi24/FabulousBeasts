---@diagnostic disable: undefined-global
SMODS.Challenge({
    key = "fb_little_three",
    loc_txt = { name = "Little Three" },
    rules = {
        custom = {
            FB.challenge_rule("fb_zero_base_score"),
            FB.challenge_rule("fb_start_mult_aces"),
            FB.challenge_rule("fb_start_blue_seal_twos"),
            FB.challenge_rule("fb_start_purple_seal_threes"),
            FB.challenge_rule("fb_standard_packs_only"),
            FB.challenge_rule("fb_spectral_shop"),
            FB.challenge_rule("no_shop_jokers"),
            FB.challenge_rule("fb_difficulty_8"),
            { id = "joker_slots", value = 0 }
        },
        modifiers = {}
    },

    deck = FB.challenge_standard_deck({
        mult_aces = true,
        blue_seal_twos = true,
        purple_seal_threes = true
    }),
    jokers = {},
    restrictions = {
        banned_cards = {
            { id = "p_arcana_normal_1" },
            { id = "p_arcana_normal_2" },
            { id = "p_arcana_normal_3" },
            { id = "p_arcana_normal_4" },
            { id = "p_arcana_jumbo_1" },
            { id = "p_arcana_jumbo_2" },
            { id = "p_arcana_mega_1" },
            { id = "p_arcana_mega_2" },

            { id = "p_celestial_normal_1" },
            { id = "p_celestial_normal_2" },
            { id = "p_celestial_normal_3" },
            { id = "p_celestial_normal_4" },
            { id = "p_celestial_jumbo_1" },
            { id = "p_celestial_jumbo_2" },
            { id = "p_celestial_mega_1" },
            { id = "p_celestial_mega_2" },

            { id = "p_spectral_normal_1" },
            { id = "p_spectral_normal_2" },
            { id = "p_spectral_jumbo_1" },
            { id = "p_spectral_mega_1" },

            { id = "p_buffoon_normal_1" },
            { id = "p_buffoon_normal_2" },
            { id = "p_buffoon_jumbo_1" },
            { id = "p_buffoon_mega_1" },

            { id = "p_fb_cuisine_pack_1" },
            { id = "p_fb_cuisine_pack_2" },
            { id = "p_fb_jumbo_cuisine_pack" },
            { id = "p_fb_buffet_pack" },
            { id = "p_fb_beast_pack_1" },
            { id = "p_fb_beast_pack_2" },
            { id = "p_fb_heavenly_beast_pack_1" },
            { id = "p_fb_heavenly_beast_pack_2" },

            { id = "c_judgement" },
            { id = "c_wraith" },
            {  id = "c_ectoplasm" },
            { id = "c_soul" },
            { id = "c_ankh" },
            { id = "c_hex" },
            { id = "c_temperance" },

            { id = "v_hone" },
            { id = "v_glow_up" },
            { id = "v_blank" },
            { id = "v_antimatter" },
            { id = "v_fb_utensils" },
            { id = "v_fb_cookware" },
            { id = "v_fb_ancient_treasure" },
            { id = "v_fb_golden_mountain" },
            { id = "v_fb_vision" },
            { id = "v_fb_true_sight" }
        },

        banned_tags = {
            { id = "tag_charm" },
            { id = "tag_meteor" },
            { id = "tag_ethereal" },
            { id = "tag_buffoon" },
            { id = "tag_uncommon" },
            { id = "tag_rare" },
            { id = "tag_negative" },
            { id = "tag_foil" },
            { id = "tag_holographic" },
            { id = "tag_polychrome" },
            { id = "tag_buffoon" },
            { id = "tag_top_up" }
        },
        banned_other = {
            { id = "bl_flint", type = "blind" },
            { id = "bl_final_leaf", type = "blind" },
            { id = "bl_final_heart", type = "blind" },
            { id = "bl_fb_wood_ape", type = "blind" },
            { id = "bl_final_acorn", type = "blind" }
        }
    }
})
