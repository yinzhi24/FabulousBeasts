---@diagnostic disable: undefined-global

SMODS.Challenge({
    key = "fb_aleph_0",
    loc_txt = { name = "Aleph-0" },
    rules = {
        custom = {
            FB.challenge_rule("fb_win_ante", 39),
            FB.challenge_rule("fb_gl"),
            FB.challenge_rule("fb_difficulty_7"),
        },
        modifiers = {}
    },
    jokers = {},
    restrictions = {}
})
