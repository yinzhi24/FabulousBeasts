---@diagnostic disable: undefined-global

SMODS.Challenge({
    key = "out_of_the_spotlight",
    loc_txt = {
        name = "Out of the Spotlight"
    },
    rules = {
        custom = {
            FB.challenge_rule("fb_win_ante", 9),
            FB.challenge_rule("fb_base_after_base"),
            FB.challenge_rule("fb_base_after_base_alt"),
            FB.challenge_rule("fb_out_of_spotlight"),
            FB.challenge_rule("fb_difficulty_4")
        },
        modifiers = {}
    }
})
