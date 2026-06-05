---@diagnostic disable: undefined-global

SMODS.Challenge({
    key = "fb_keeping_spirits_high",
    loc_txt = { name = "Keeping Spirits High" },
    rules = {
        custom = {
            { id = "no_shop_jokers" },
            FB.challenge_rule("fb_difficulty_5"),
        },
        modifiers = {
            { id = "joker_slots", value = 1 }
        }
    },
    jokers = {
        {
            id = "j_fb_shanque",
            eternal = true,
            pinned = true
        }
    },
    restrictions = {
        banned_cards = {
            { id = "p_buffoon_normal_1" },
            { id = "p_buffoon_normal_2" },
            { id = "p_buffoon_jumbo_1" },
            { id = "p_buffoon_mega_1" },

            { id = "p_fb_cuisine_pack_1" },
            { id = "p_fb_cuisine_pack_2" },
            { id = "p_fb_jumbo_cuisine_pack" },
            { id = "p_fb_buffet_pack" },
            { id = "p_fb_beast_pack_1" },
            { id = "p_fb_beast_pack_2" },
            { id = "p_fb_heavenly_beast_pack_1" },
            { id = "p_fb_heavenly_beast_pack_2" },

            { id = "c_judgement" },
            { id = "c_wraith" },
            {  id = "c_ectoplasm" },
            { id = "c_soul" },
            { id = "c_ankh" },
            { id = "c_hex" },
            { id = "c_temperance" },

            { id = "v_hone" },
            { id = "v_glow_up" },
            { id = "v_blank" },
            { id = "v_antimatter" },
            { id = "v_fb_utensils" },
            { id = "v_fb_cookware" },
            { id = "v_fb_ancient_treasure" },
            { id = "v_fb_golden_mountain" },
            { id = "v_fb_vision" },
            { id = "v_fb_true_sight" }
        },
        banned_tags = {
            { id = "tag_uncommon" },
            { id = "tag_rare" },
            { id = "tag_negative" },
            { id = "tag_foil" },
            { id = "tag_holo" },
            { id = "tag_polychrome" },
            { id = "tag_buffoon" },
            { id = "tag_top_up" },
            { id = "tag_buffoon" },
            { id = "tag_charm" },
            { id = "tag_ethereal" },
            { id = "tag_top_up" }
        },
        banned_other = {}
    }
})