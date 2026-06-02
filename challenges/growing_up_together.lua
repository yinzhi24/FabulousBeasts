---@diagnostic disable: undefined-global

---@diagnostic disable: undefined-global

local function fb_growing_up_banned_cards()
    local banned = {}

    local banned_joker_creators = {
        -- Tarot
        "c_judgement",

        -- Spectral
        "c_soul",
        "c_wraith",
        "c_ankh",
        "c_hex",

        -- Joker booster packs
        "p_buffoon_normal_1",
        "p_buffoon_normal_2",
        "p_buffoon_jumbo_1",
        "p_buffoon_mega_1",

        -- Vouchers that enable Joker-related nonsense
        "v_blank",
        "v_antimatter"
    }

    for _, id in ipairs(banned_joker_creators) do
        banned[#banned + 1] = { id = id }
    end

    return banned
end

SMODS.Challenge({
    key = "growing_up_together",

    loc_txt = {
        name = "Growing Up Together"
    },

    rules = {
        custom = {
            { id = "no_shop_jokers" },
            { id = "all_eternal" }
        },
        modifiers = {
            { id = "joker_slots", value = 2 }
        }
    },

    jokers = {
        { id = "j_fb_baby_tianlu", eternal = true },
        { id = "j_fb_baby_bixie", eternal = true }
    },

    restrictions = {
        banned_cards = fb_growing_up_banned_cards,

        banned_tags = {
            { id = "tag_uncommon" },
            { id = "tag_rare" },
            { id = "tag_negative" },
            { id = "tag_foil" },
            { id = "tag_holographic" },
            { id = "tag_polychrome" },
            { id = "tag_buffoon" },
            { id = "tag_top_up" }
        },

        banned_other = {}
    }
})