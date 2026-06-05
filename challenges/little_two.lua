---@diagnostic disable: undefined-global
SMODS.Challenge({
    key = "fb_little_two",
    loc_txt = { name = "Little Two" },
    rules = {
        custom = {
            FB.challenge_rule("fb_zero_base_score"),
            FB.challenge_rule("fb_start_mult_aces"),
            FB.challenge_rule("fb_start_blue_seal_twos"),
            FB.challenge_rule("fb_standard_packs_only"),
            FB.challenge_rule("fb_spectral_shop"),
            FB.challenge_rule("fb_difficulty_7"),
        },
        modifiers = {}
    },

    deck = FB.challenge_standard_deck({
        mult_aces = true,
        blue_seal_twos = true
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
            { id = "p_fb_heavenly_beast_pack_2" }
        },

        banned_tags = {
            { id = "tag_charm" },
            { id = "tag_meteor" },
            { id = "tag_ethereal" },
            { id = "tag_buffoon" }
        },
        banned_other = {
            { id = "bl_flint", type = "blind" }
        }
    }
})

