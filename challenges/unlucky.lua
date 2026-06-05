---@diagnostic disable: undefined-global

local function fb_lookup(list)
    local t = {}
    for _, v in ipairs(list or {}) do
        t[v] = true
    end
    return t
end

local function fb_ban_pool_except(pool, allowed)
    local banned = {}
    local allowed_lookup = fb_lookup(allowed)

    for _, center in ipairs(pool or {}) do
        local key = center.key
        if key and not allowed_lookup[key] then
            banned[#banned + 1] = { id = key }
        end
    end

    return banned
end

local fb_unlucky_allowed_jokers = {
    "j_8_ball",
    "j_misprint",
    "j_gros_michel",
    "j_business",
    "j_space",
    "j_sixth_sense",
    "j_superposition",
    "j_todo_list",
    "j_cavendish",
    "j_madness",
    "j_seance",
    "j_riff_raff",
    "j_reserved_parking",
    "j_mail",
    "j_hallucination",
    "j_lucky_cat",
    "j_ancient",
    "j_castle",
    "j_bloodstone",
    "j_glass",
    "j_ring_master",
    "j_blueprint",
    "j_oops",
    "j_idol",
    "j_invisible",
    "j_brainstorm",
    "j_perkeo",

    "j_fb_bullet_comment",
    "j_fb_dew_cloud",
    "j_fb_foraged_mushrooms",
    "j_fb_mini_theater",
    "j_fb_mortal_realm",
    "j_fb_tile_cat",
    "j_fb_underworld_cash",
    "j_fb_feirenzai_manga",
    "j_fb_followers_request",
    "j_fb_lunchbox_medkit",
    "j_fb_mapo_tofu",
    "j_fb_open_for_business",
    "j_fb_qilin_egg",
    "j_fb_divine_warsword",
    "j_fb_interdimensional_cave",
    "j_fb_laurel_tree",
    "j_fb_pixiu_fur",
    "j_fb_pixiu_horn",
    "j_fb_rigged_video_game",
    "j_fb_sibuxiang",
    "j_fb_taowu",
    "j_fb_xiaolizhi"
}

local fb_unlucky_allowed_tarots = {
    "c_fool",
    "c_magician",
    "c_high_priestess",
    "c_emperor",
    "c_justice",
    "c_hermit",
    "c_wheel_of_fortune",
    "c_strength",
    "c_hanged_man",
    "c_death",
    "c_temperance",
    "c_star",
    "c_moon",
    "c_sun",
    "c_judgement",
    "c_world"
}

local fb_unlucky_allowed_spectrals = {
    "c_aura",
    "c_wraith",
    "c_sigil",
    "c_ectoplasm",
    "c_immolate",
    "c_ankh",
    "c_hex",
    "c_trance",
    "c_medium",
    "c_soul",
    "c_black_hole"
}

local function fb_unlucky_banned_cards()
    local banned = {}

    for _, v in ipairs(fb_ban_pool_except(G.P_CENTER_POOLS.Joker, fb_unlucky_allowed_jokers)) do
        banned[#banned + 1] = v
    end

    for _, v in ipairs(fb_ban_pool_except(G.P_CENTER_POOLS.Tarot, fb_unlucky_allowed_tarots)) do
        banned[#banned + 1] = v
    end

    for _, v in ipairs(fb_ban_pool_except(G.P_CENTER_POOLS.Spectral, fb_unlucky_allowed_spectrals)) do
        banned[#banned + 1] = v
    end

    -- Ban non-Glass/non-Lucky enhancements
    banned[#banned + 1] = { id = "m_bonus" }
    banned[#banned + 1] = { id = "m_mult" }
    banned[#banned + 1] = { id = "m_wild" }
    banned[#banned + 1] = { id = "m_steel" }
    banned[#banned + 1] = { id = "m_stone" }
    banned[#banned + 1] = { id = "m_gold" }

    return banned
end

SMODS.Challenge({
    key = "unlucky",

    loc_txt = {
        name = "Unlucky",
        text = {
            "Start with a {C:attention}Negative{}, {C:attention}Eternal{},",
            "{C:attention}Pinned{} Xiaolizhi",
            "Only chance-based cards may appear",
            "Only {C:attention}Glass{} and {C:attention}Lucky{} cards are allowed",
            "{C:attention}The Wheel{} will always appear once in any run"
        }
    },

    rules = {
        custom = {
            { id = "fb_unlucky_wheel" },
            { id = "fb_unlucky_seals" },
            FB.challenge_rule("fb_difficulty_2")
        },

        modifiers = {}
    },

    jokers = {
        {
            id = "j_fb_xiaolizhi",
            eternal = true,
            pinned = true,
            edition = "negative"
        }
    },

    consumeables = {
        { id = "c_justice" },
        { id = "c_magician" }
    },

    vouchers = {
        { id = "v_crystal_ball" },
        { id = "v_omen_globe" }
    },

    restrictions = {
        banned_cards = fb_unlucky_banned_cards,

        banned_tags = {
            { id = "tag_investment" },
            { id = "tag_handy" },
            { id = "tag_garbage" },
            { id = "tag_coupon" },
            { id = "tag_juggle" },
            { id = "tag_speed" },
            { id = "tag_economy" }
        },

        banned_other = {}
    }
})