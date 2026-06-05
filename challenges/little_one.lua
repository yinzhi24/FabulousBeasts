---@diagnostic disable: undefined-global
SMODS.Challenge({
    key = "fb_little_one",
    loc_txt = { name = "Little One" },
    rules = {
        custom = {
            FB.challenge_rule("fb_zero_base_score"),
            FB.challenge_rule("fb_start_mult_aces"),
            FB.challenge_rule("fb_difficulty_6")
        },
        modifiers = {}

    },

    deck = FB.challenge_standard_deck({
        mult_aces = true
    }),
    jokers = {},
    restrictions = {
        banned_other = {
             { id = "bl_flint", type = "blind" },
         }
    }
})
