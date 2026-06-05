---@diagnostic disable: undefined-global
SMODS.Challenge({
    key = "fb_back_on_track",
    loc_txt = { name = "Back On Track" },
    rules = {
        custom = {
            FB.challenge_rule("fb_sell_jokers_after_round"),
            FB.challenge_rule("fb_difficulty_5")
        },
        modifiers = {}
    },
    jokers = {},
    restrictions = FB.merge_challenge_restrictions(
        FB.challenge_restrictions({
            no_economy_bypass = true
        }),
        {
            banned_cards = {
                { id = "j_fb_immortality_elixir" },
                { id = "j_fb_one_way_ticket_to_heaven" },
                { id = "j_fb_qilin_egg" },
                { id = "j_fb_rigged_video_game" },
                { id = "j_fb_shi_qilin" },
                { id = "j_fb_health_insurance" },
                { id = "j_fb_lunchbox_medkit" }
            },
                banned_other = {
                    { id = "bl_tooth", type = "blind" },
                    { id = "bl_fb_rat", type = "blind" }
                }
        }
    )
})
