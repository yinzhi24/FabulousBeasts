SMODS.Challenge({
    key = "picnic_day",
    loc_txt = {
        name = "Picnic Day"
    },

    jokers = {
        {
            id = FB.key("health_insurance"),
            edition = "negative",
            eternal = true,
            pinned = true
        },
        {
            id = FB.key("lunchbox_medkit"),
            edition = "negative",
            eternal = true,
            pinned = true
        }
    },

    rules = {
        custom = {
            { id = "no_shop_jokers" }
        },
        modifiers = {}
    },

    restrictions = {
        banned_cards = {
            { id = "p_buffoon_normal_1" },
            { id = "p_buffoon_normal_2" },
            { id = "p_buffoon_jumbo_1" },
            { id = "p_buffoon_mega_1" },
            { id = "c_judgement" },
            { id = "c_wraith" },
            { id = "c_soul" }
        },
        banned_tags = {
            { id = "tag_uncommon" },
            { id = "tag_rare" },
            { id = "tag_negative" },
            { id = "tag_foil" },
            { id = "tag_holo" },
            { id = "tag_polychrome" },
            { id = "tag_buffoon" },
            { id = "tag_top_up" }
        }
    }
})