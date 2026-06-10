---@diagnostic disable: undefined-global

SMODS.Challenge({
    key = "fb_ascension_to_heaven",
    loc_txt = { name = "Ascension to Heaven" },

    rules = {
        custom = {
            FB.challenge_rule("fb_final_trial"),
            FB.challenge_rule("fb_zero_base_score"),
            FB.challenge_rule("fb_base_after_base"),
            FB.challenge_rule("fb_base_after_base_alt"),
            FB.challenge_rule("fb_spectral_shop"),
            FB.challenge_rule("fb_ascension_positive_decks_sleeves"),
            FB.challenge_rule("fb_win_ante", 39),
            FB.challenge_rule("fb_gl"),
            FB.challenge_rule("fb_difficulty_9")
        },

        modifiers = {
            { id = "hands", value = 8 },
            { id = "discards", value = 8 },
            { id = "joker_slots", value = 8 },
            { id = "dollars", value = 16 },
            { id = "hand_size", value = 10 }
        }
    },

    jokers = {},

    consumeables = {
        { id = "c_fool", edition = "negative" },
        { id = "c_fool", edition = "negative" },
        { id = "c_hex", edition = "negative" },
        { id = "c_soul", edition = "negative" },
        { id = "c_black_hole", edition = "negative" }
    },

    vouchers = {
        { id = "v_crystal_ball" },
        { id = "v_telescope" },
        { id = "v_tarot_merchant" },
        { id = "v_planet_merchant" },
        { id = "v_overstock_norm" },
        { id = "v_seed_money" },
        { id = "v_omen_globe" },
        { id = "v_observatory" },

        { id = "v_blank" },
        { id = "v_fb_ancient_treasure" },
        { id = "v_fb_golden_mountain" }
    },

    restrictions = {}
})