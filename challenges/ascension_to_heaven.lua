---@diagnostic disable: undefined-global
SMODS.Challenge({
    key = "fb_ascension_to_heaven",
    loc_txt = { name = "Ascension to Heaven" },
    rules = {
        custom = {
            FB.challenge_rule("fb_final_trial"),
            FB.challenge_rule("fb_base_after_base"),
            FB.challenge_rule("fb_base_after_base_alt"),
            FB.challenge_rule("fb_spectral_shop"),
            FB.challenge_rule("fb_zero_base_score"),
            FB.challenge_rule("fb_win_ante", 39),
            FB.challenge_rule("fb_gl"),
            FB.challenge_rule("fb_difficulty_9")
        },
        modifiers = {
            { id = "joker_slots", value = 1 }
        }
    },
    jokers = {},
    consumeables = {
        { id = "c_soul", edition = "negative" },
        { id = "c_black_hole", edition = "negative" }
    },

    vouchers = {
        { id = "v_blank" },
        { id = "v_fb_ancient_treasure" },
        { id = "v_fb_golden_mountain" }
    },
    restrictions = {}
})
