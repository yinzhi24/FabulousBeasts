---@diagnostic disable: undefined-global

SMODS.Challenge({
    key = "fb_cant_let_go",
    loc_txt = { name = "Can't Let Go" },
    rules = {
        custom = {
            FB.challenge_rule("fb_difficulty_2")
        },

        modifiers = {
            { id = "hands", value = 9 },
            { id = "discards", value = 0 }
        }
    },
    jokers = {},
    restrictions = {
        banned_cards = {
            { id = "j_fb_emergency_rations" },
            { id = "j_burglar" },
            { id = "j_faceless" },
            { id = "j_drunkard" },
            { id = "j_castle" },
            { id = "j_troubadour" },
            { id = "j_merry_andy" },
            { id = "j_yorick" },
            { id = "j_burnt" },
            { id = "j_ramen" },

            { id = "v_wasteful" },
            { id = "v_recyclomancy" },
            { id = "v_grabber" },
            { id = "v_nacho_tong" },
            { id = "v_hieroglyph" },
            { id = "v_petroglyph" }
        },
        banned_tags = {},
        banned_other = {
            { id = "bl_fb_goat", type = "blind" },
            { id = "bl_fb_cow", type = "blind" },
            { id = "bl_fb_rooster", type = "blind" },
            { id = "bl_needle", type = "blind" },
            { id = "bl_water", type = "blind" }
        }
    }
})