---@diagnostic disable: undefined-global
SMODS.Challenge({
    key = "fb_base_after_base",
    loc_txt = { name = "Base After Base" },
    rules = {
        custom = {
            FB.challenge_rule("fb_base_after_base"),
            FB.challenge_rule("fb_base_after_base_alt"),
            FB.challenge_rule("fb_difficulty_5")
        },
        modifiers = {}
    },
    jokers = {},
    restrictions = {}
})
