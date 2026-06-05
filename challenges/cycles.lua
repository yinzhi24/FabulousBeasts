---@diagnostic disable: undefined-global

SMODS.Challenge({
    key = "fb_cycles",
    loc_txt = { name = "Cycles" },
    rules = {
        custom = {
            FB.challenge_rule("fb_difficulty_3")
        },

        modifiers = {
            { id = "hands", value = 1 },
            { id = "discards", value = 9 }
        }
    },
    jokers = {},
    restrictions = {
        banned_cards = {
            { id = "j_fb_emergency_rations" },
            { id = "j_burglar" },
            { id = "j_troubadour" },
            { id = "j_burnt" },

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