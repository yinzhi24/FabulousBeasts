---@diagnostic disable: undefined-global
SMODS.Challenge({
    key = "fb_angels",
    loc_txt = { name = "Angels" },
    rules = {
        custom = {
            FB.challenge_rule("no_shop_jokers"),
            FB.challenge_rule("fb_nine_heavens"),
            FB.challenge_rule("fb_spectral_shop"),
            FB.challenge_rule("fb_difficulty_4")
        },
        modifiers = {
            { id = "joker_slots", value = 9 }
        }
    },
    jokers = {},
    restrictions = {
        banned_cards = {
            { id = "p_buffoon_normal_1" },
            { id = "p_buffoon_normal_2" },
            { id = "p_buffoon_jumbo_1" },
            { id = "p_buffoon_mega_1" },
            { id = "c_judgement" },
            { id = "c_wraith" },
            { id = "c_soul" },
            { id = "c_ankh" },
            { id = "c_hex" },
            { id = "c_ectoplasm" },
            { id = "v_hone" },
            { id = "v_glow_up" },
            { id = "v_fb_ancient_treasure" },
            { id = "v_fb_golden_mountain" },
            { id = "v_fb_utensils" },
            { id = "v_fb_cookware" },
            { id = "v_fb_vision" },
            { id = "v_fb_true_sight" },
            { id = "v_antimatter" }
        },
        banned_tags = {
            { id = "tag_uncommon" },
            { id = "tag_rare" },
            { id = "tag_negative" },
            { id = "tag_foil" },
            { id = "tag_holographic" },
            { id = "tag_polychrome" },
            { id = "tag_buffoon" },
            { id = "tag_top_up" }
        }
    }
})
