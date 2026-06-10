---@diagnostic disable: undefined-global
-- Fabulous Beasts - Baize quote module
-- Put this in baize.lua.
--
-- This file does NOT register Baize as a Joker.
-- It only provides quote data + helper functions for Baize's Joker implementation.
--
-- In legendary.lua, Baize should use:
--
-- loc_txt = {
--     name = "Baize",
--     text = {
--         "I know many things.",
--         "Hover me in different places",
--         "to hear different advice."
--     }
-- },
--
-- loc_vars = function(self, info_queue, card)
--     return FB.baize_loc_vars(card)
-- end

local FB = _G.FB or FabulousBeasts or {}
_G.FB = FB
FabulousBeasts = FB

-- =========================================================
-- KEY / NAME HELPERS
-- =========================================================

function FB.baize_clean_key(key)
    if not key then return nil end

    key = tostring(key)

    key = key:gsub("^j_fb_", "")
    key = key:gsub("^j_", "")

    key = key:gsub("^c_fb_", "")
    key = key:gsub("^c_", "")

    key = key:gsub("^v_fb_", "")
    key = key:gsub("^v_", "")

    key = key:gsub("^p_fb_", "")
    key = key:gsub("^p_", "")

    key = key:gsub("^bl_fb_", "")
    key = key:gsub("^bl_", "")

    return key
end

function FB.baize_card_center(card)
    return card and card.config and card.config.center
end

function FB.baize_card_key(card)
    local center = FB.baize_card_center(card)
    return center and center.key
end

function FB.baize_card_set(card)
    local center = FB.baize_card_center(card)
    return center and center.set
end

function FB.baize_is_fb_key(key)
    return type(key) == "string" and (
        key:sub(1, 5) == "j_fb_"
        or key:sub(1, 5) == "c_fb_"
        or key:sub(1, 5) == "v_fb_"
        or key:sub(1, 5) == "p_fb_"
        or key:sub(1, 6) == "bl_fb_"
    )
end

function FB.baize_display_name(key, set)
    if not key then return "Unknown" end

    local ok, name = pcall(function()
        return localize({
            type = "name_text",
            set = set or "Joker",
            key = key
        })
    end)

    if ok and name and name ~= "ERROR" then
        return name
    end

    local center = G and G.P_CENTERS and G.P_CENTERS[key]
    if center then
        if center.loc_txt and center.loc_txt.name then
            return center.loc_txt.name
        end
        if center.name then
            return center.name
        end
    end

    return tostring(key)
        :gsub("^j_fb_", "")
        :gsub("^j_", "")
        :gsub("^c_fb_", "")
        :gsub("^c_", "")
        :gsub("^v_fb_", "")
        :gsub("^v_", "")
        :gsub("^p_fb_", "")
        :gsub("^p_", "")
        :gsub("_", " ")
        :gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest
        end)
end

function FB.baize_random_index(seed, count)
    if not count or count <= 1 then return 1 end

    if pseudorandom then
        return math.floor(pseudorandom(seed or "fb_baize_quote") * count) + 1
    end

    return math.random(count)
end

function FB.baize_pick_quote(card, tag, pool)
    if not pool or #pool == 0 then
        return {
            "I have no quote for this yet.",
            "Future wisdom pending."
        }
    end

    card.ability = card.ability or {}
    card.ability.extra = card.ability.extra or {}
    card.ability.extra.fb_baize_cache = card.ability.extra.fb_baize_cache or {}

    local cache = card.ability.extra.fb_baize_cache

    if cache.tag ~= tag then
        cache.tag = tag
        cache.index = FB.baize_random_index("fb_baize_" .. tostring(tag), #pool)
    end

    return pool[cache.index] or pool[1]
end

-- =========================================================
-- SELECTED / HOVERED CARD DETECTION
-- =========================================================

function FB.baize_valid_target(card, baize_card)
    return card
        and card ~= baize_card
        and card.config
        and card.config.center
        and card.config.center.key
end

function FB.baize_pick_from_area(area, baize_card)
    if not area then return nil end

    if area.highlighted then
        for _, card in ipairs(area.highlighted) do
            if FB.baize_valid_target(card, baize_card) then
                return card
            end
        end
    end

    if area.cards then
        for _, card in ipairs(area.cards) do
            if FB.baize_valid_target(card, baize_card) and card.highlighted then
                return card
            end
        end
    end

    return nil
end

function FB.baize_selected_target(baize_card)
    -- Booster choice should win while opening packs.
    local pack_card = FB.baize_pick_from_area(G and G.pack_cards, baize_card)
    if pack_card then return pack_card, "pack_choice" end

    -- Shop selections.
    local shop_card =
        FB.baize_pick_from_area(G and G.shop_jokers, baize_card)
        or FB.baize_pick_from_area(G and G.shop_vouchers, baize_card)
        or FB.baize_pick_from_area(G and G.shop_booster, baize_card)

    if shop_card then return shop_card, "shop_choice" end

    -- Current Joker / consumable areas.
    local joker = FB.baize_pick_from_area(G and G.jokers, baize_card)
    if joker then return joker, "joker" end

    local consumable = FB.baize_pick_from_area(G and G.consumeables, baize_card)
    if consumable then return consumable, "consumable" end

    -- Playing cards.
    local hand_card = FB.baize_pick_from_area(G and G.hand, baize_card)
    if hand_card then return hand_card, "playing_card" end

    local play_card = FB.baize_pick_from_area(G and G.play, baize_card)
    if play_card then return play_card, "playing_card" end

    -- Controller hover fallback.
    local hover = G
        and G.CONTROLLER
        and G.CONTROLLER.hovering
        and G.CONTROLLER.hovering.target

    if FB.baize_valid_target(hover, baize_card) then
        return hover, "hover"
    end

    return nil, nil
end

-- =========================================================
-- BLIND CONTEXT
-- =========================================================

function FB.baize_current_blind_key()
    local blind = G and G.GAME and G.GAME.blind
    if not blind then return nil end

    local key =
        blind.key
        or (blind.config and blind.config.blind and blind.config.blind.key)
        or blind.name

    if not key then return nil end

    key = tostring(key)
    key = key:gsub("^bl_fb_", "")
    key = key:gsub("^bl_", "")
    key = key:gsub("^The ", "")
    key = key:gsub("^the ", "")
    key = key:lower():gsub("%s+", "_")

    return key
end

function FB.baize_current_blind_name()
    local blind = G and G.GAME and G.GAME.blind
    return (blind and blind.name) or FB.baize_current_blind_key() or "this Blind"
end

-- =========================================================
-- QUOTE FORMAT
--
-- Every quote category is:
--
-- key = {
--     {
--         "Quote one, line one",
--         "Quote one, line two"
--     },
--     {
--         "Quote two, line one",
--         "Quote two, line two",
--         "Quote two, line three"
--     }
-- }
-- =========================================================

FB.baize_quotes = FB.baize_quotes or {}

-- =========================================================
-- GENERAL CONTEXT QUOTES
-- =========================================================

FB.baize_quotes.context = {
    collection = {
        {},
        {},
        {}
    },

    shop = {
        {},
        {},
        {}
    },

    shop_choice = {
        {},
        {},
        {}
    },

    blind_select = {
        {},
        {},
        {}
    },

    small_blind = {
        {},
        {},
        {}
    },

    big_blind = {
        {},
        {},
        {}
    },

    pack = {
        {},
        {},
        {}
    },

    pack_choice = {
        {},
        {},
        {}
    },

    fallback = {
        {},
        {},
        {}
    }
}

-- =========================================================
-- VANILLA BOSS BLINDS
-- =========================================================

FB.baize_quotes.vanilla_bosses = {
    hook = {{}, {}, {}},
    ox = {{}, {}, {}},
    house = {{}, {}, {}},
    wall = {{}, {}, {}},
    wheel = {{}, {}, {}},
    arm = {{}, {}, {}},
    club = {{}, {}, {}},
    fish = {{}, {}, {}},
    psychic = {{}, {}, {}},
    goad = {{}, {}, {}},
    water = {{}, {}, {}},
    window = {{}, {}, {}},
    manacle = {{}, {}, {}},
    eye = {{}, {}, {}},
    mouth = {{}, {}, {}},
    plant = {{}, {}, {}},
    serpent = {{}, {}, {}},
    pillar = {{}, {}, {}},
    needle = {{}, {}, {}},
    head = {{}, {}, {}},
    tooth = {{}, {}, {}},
    flint = {{}, {}, {}},
    mark = {{}, {}, {}},
    final_acorn = {{}, {}, {}},
    final_leaf = {{}, {}, {}},
    final_vessel = {{}, {}, {}},
    final_heart = {{}, {}, {}},
    final_bell = {{}, {}, {}}
}

-- =========================================================
-- FABULOUS BEASTS BOSS BLINDS
-- =========================================================

FB.baize_quotes.fb_bosses = {
    rat = {{}, {}, {}},
    cow = {{}, {}, {}},
    tiger = {{}, {}, {}},
    rabbit = {{}, {}, {}},
    dragon = {{}, {}, {}},
    snake = {{}, {}, {}},
    horse = {{}, {}, {}},
    goat = {{}, {}, {}},
    monkey = {{}, {}, {}},
    rooster = {{}, {}, {}},
    dog = {{}, {}, {}},
    boar = {{}, {}, {}},

    armor = {{}, {}, {}},
    twist = {{}, {}, {}},
    blaze = {{}, {}, {}},
    focus = {{}, {}, {}},
    balance = {{}, {}, {}},
    self = {{}, {}, {}},
    force = {{}, {}, {}},
    pain = {{}, {}, {}},
    flood = {{}, {}, {}},
    mist = {{}, {}, {}},
    shadow = {{}, {}, {}},
    light = {{}, {}, {}},

    metal_tiger = {{}, {}, {}},
    fire_bird = {{}, {}, {}},
    water_deer = {{}, {}, {}},
    wood_ape = {{}, {}, {}},
    earth_bear = {{}, {}, {}},
    air_dragon = {{}, {}, {}}
}

-- =========================================================
-- FABULOUS BEASTS JOKERS ONLY
-- =========================================================

FB.baize_quotes.fb_jokers = {
    -- Common
    album_cover = {{}, {}, {}},
    alternate_album_cover = {{}, {}, {}},
    ambrosia = {{}, {}, {}},
    beijing_license_plate = {{}, {}, {}},
    bullet_comment = {{}, {}, {}},
    cardboard_box = {{}, {}, {}},
    dew_cloud = {{}, {}, {}},
    divine_herb = {{}, {}, {}},
    dog_food = {{}, {}, {}},
    emergency_rations = {{}, {}, {}},
    food = {{}, {}, {}},
    food_reserve = {{}, {}, {}},
    foraged_mushrooms = {{}, {}, {}},
    health_insurance = {{}, {}, {}},
    heavenly_cumin = {{}, {}, {}},
    immortality_elixir = {{}, {}, {}},
    hellspice_hotpot = {{}, {}, {}},
    knockout = {{}, {}, {}},
    lakeside_pond = {{}, {}, {}},
    laurel_branch = {{}, {}, {}},
    mini_theater = {{}, {}, {}},
    mooncake = {{}, {}, {}},
    mortal_realm = {{}, {}, {}},
    pay_stub = {{}, {}, {}},
    rat_poison = {{}, {}, {}},
    shunshui_express = {{}, {}, {}},
    skewered_kebab = {{}, {}, {}},
    teacup = {{}, {}, {}},
    temporal_confinement = {{}, {}, {}},
    tile_cat = {{}, {}, {}},
    tulou = {{}, {}, {}},
    underworld_cash = {{}, {}, {}},

    -- Uncommon
    bestiary = {{}, {}, {}},
    chicken_mushroom_stew = {{}, {}, {}},
    demolition_notice = {{}, {}, {}},
    do_not_imitate = {{}, {}, {}},
    feirenzai_manga = {{}, {}, {}},
    followers_request = {{}, {}, {}},
    gold_sculpture = {{}, {}, {}},
    heavenly_elixirs = {{}, {}, {}},
    hellish_delicacies = {{}, {}, {}},
    lunchbox_medkit = {{}, {}, {}},
    mapo_tofu = {{}, {}, {}},
    moon_palace = {{}, {}, {}},
    mooncake_cannon = {{}, {}, {}},
    open_for_business = {{}, {}, {}},
    oxen_cart = {{}, {}, {}},
    paw_hole_cave = {{}, {}, {}},
    pixiu_fur = {{}, {}, {}},
    qilin_egg = {{}, {}, {}},
    questionable_fanart = {{}, {}, {}},
    rigged_video_game = {{}, {}, {}},
    teapot = {{}, {}, {}},
    underworlds_blacklist = {{}, {}, {}},

    -- Rare
    ["9th_heaven"] = {{}, {}, {}},
    baby_bixie = {{}, {}, {}},
    baby_tianlu = {{}, {}, {}},
    body_swap_mushroom = {{}, {}, {}},
    bone_mask = {{}, {}, {}},
    cintamani = {{}, {}, {}},
    divine_garment = {{}, {}, {}},
    divine_hair_growth_elixir = {{}, {}, {}},
    divine_light = {{}, {}, {}},
    divine_warsword = {{}, {}, {}},
    dreamscape = {{}, {}, {}},
    giant_kun_fish = {{}, {}, {}},
    interdimensional_cave = {{}, {}, {}},
    jade_bird = {{}, {}, {}},
    laurel_tree = {{}, {}, {}},
    deermans = {{}, {}, {}},
    magpie_bridge = {{}, {}, {}},
    one_way_ticket_to_heaven = {{}, {}, {}},
    pixiu_horn = {{}, {}, {}},
    underworld = {{}, {}, {}},

    -- Legendary
    bajin = {{}, {}, {}},
    bilibili = {{}, {}, {}},
    bibi = {{}, {}, {}},
    bixie = {{}, {}, {}},
    christina = {{}, {}, {}},
    chugou = {{}, {}, {}},
    dijiang = {{}, {}, {}},
    diting = {{}, {}, {}},
    erliang = {{}, {}, {}},
    fenz = {{}, {}, {}},
    fuku_fuzai = {{}, {}, {}},
    hetao = {{}, {}, {}},
    hundun = {{}, {}, {}},
    jinchi_dapeng = {{}, {}, {}},
    jinjiao = {{}, {}, {}},
    kulou = {{}, {}, {}},
    luo_tianyi = {{}, {}, {}},
    lord_phoenix = {{}, {}, {}},
    qiongqi = {{}, {}, {}},
    shanque = {{}, {}, {}},
    sibuxiang = {{}, {}, {}},
    taotie = {{}, {}, {}},
    taowu = {{}, {}, {}},
    tianlu = {{}, {}, {}},
    tubaoshu = {{}, {}, {}},
    tuye_tony = {{}, {}, {}},
    xiaolizhi = {{}, {}, {}},
    xiezhi = {{}, {}, {}},
    yinjiao = {{}, {}, {}},
    zhanhu = {{}, {}, {}},
    baize = {{}, {}, {}},

    -- Exotic
    bixie_true_form = {{}, {}, {}},
    rainbow_mountain_range = {{}, {}, {}},
    qishiqi = {{}, {}, {}},
    shi_qilin = {{}, {}, {}},
    qilin_sibuxiang = {{}, {}, {}},
    tianlu_true_form = {{}, {}, {}},

    -- Divine
    happy_ending = {{}, {}, {}},
    super_lollipop = {{}, {}, {}}
}

-- =========================================================
-- FABULOUS BEASTS VOUCHERS
-- =========================================================

FB.baize_quotes.fb_vouchers = {
    ancient_treasure = {{}, {}, {}},
    golden_mountain = {{}, {}, {}},
    utensils = {{}, {}, {}},
    cookware = {{}, {}, {}},
    pixiu_luck = {{}, {}, {}},
    divine_prosperity = {{}, {}, {}},
    vision = {{}, {}, {}},
    true_sight = {{}, {}, {}}
}

-- =========================================================
-- FABULOUS BEASTS BOOSTERS / PACKS
-- =========================================================

FB.baize_quotes.fb_boosters = {
    cuisine_pack = {{}, {}, {}},
    jumbo_cuisine_pack = {{}, {}, {}},
    buffet_pack = {{}, {}, {}},
    beast_pack = {{}, {}, {}},
    heavenly_beast_pack = {{}, {}, {}}
}

-- =========================================================
-- VANILLA TAROTS
-- =========================================================

FB.baize_quotes.tarots = {
    fool = {{}, {}, {}},
    magician = {{}, {}, {}},
    high_priestess = {{}, {}, {}},
    empress = {{}, {}, {}},
    emperor = {{}, {}, {}},
    hierophant = {{}, {}, {}},
    lovers = {{}, {}, {}},
    chariot = {{}, {}, {}},
    justice = {{}, {}, {}},
    hermit = {{}, {}, {}},
    wheel_of_fortune = {{}, {}, {}},
    strength = {{}, {}, {}},
    hanged_man = {{}, {}, {}},
    death = {{}, {}, {}},
    temperance = {{}, {}, {}},
    devil = {{}, {}, {}},
    tower = {{}, {}, {}},
    star = {{}, {}, {}},
    moon = {{}, {}, {}},
    sun = {{}, {}, {}},
    judgement = {{}, {}, {}},
    world = {{}, {}, {}}
}

-- =========================================================
-- VANILLA PLANETS
-- =========================================================

FB.baize_quotes.planets = {
    mercury = {{}, {}, {}},
    venus = {{}, {}, {}},
    earth = {{}, {}, {}},
    mars = {{}, {}, {}},
    jupiter = {{}, {}, {}},
    saturn = {{}, {}, {}},
    uranus = {{}, {}, {}},
    neptune = {{}, {}, {}},
    pluto = {{}, {}, {}},
    planet_x = {{}, {}, {}},
    ceres = {{}, {}, {}},
    eris = {{}, {}, {}}
}

-- =========================================================
-- VANILLA SPECTRALS
-- =========================================================

FB.baize_quotes.spectrals = {
    familiar = {{}, {}, {}},
    grim = {{}, {}, {}},
    incantation = {{}, {}, {}},
    talisman = {{}, {}, {}},
    aura = {{}, {}, {}},
    wraith = {{}, {}, {}},
    sigil = {{}, {}, {}},
    ouija = {{}, {}, {}},
    ectoplasm = {{}, {}, {}},
    immolate = {{}, {}, {}},
    ankh = {{}, {}, {}},
    deja_vu = {{}, {}, {}},
    hex = {{}, {}, {}},
    trance = {{}, {}, {}},
    medium = {{}, {}, {}},
    cryptid = {{}, {}, {}},
    soul = {{}, {}, {}},
    black_hole = {{}, {}, {}}
}

-- =========================================================
-- VANILLA BOOSTER PACKS
-- =========================================================

FB.baize_quotes.vanilla_boosters = {
    arcana_normal = {{}, {}, {}},
    arcana_jumbo = {{}, {}, {}},
    arcana_mega = {{}, {}, {}},

    celestial_normal = {{}, {}, {}},
    celestial_jumbo = {{}, {}, {}},
    celestial_mega = {{}, {}, {}},

    spectral_normal = {{}, {}, {}},
    spectral_jumbo = {{}, {}, {}},
    spectral_mega = {{}, {}, {}},

    standard_normal = {{}, {}, {}},
    standard_jumbo = {{}, {}, {}},
    standard_mega = {{}, {}, {}},

    buffoon_normal = {{}, {}, {}},
    buffoon_jumbo = {{}, {}, {}},
    buffoon_mega = {{}, {}, {}}
}

-- =========================================================
-- UNKNOWN / FALLBACK POOLS
-- =========================================================

FB.baize_quotes.unknown = {
    vanilla_joker = {
        {},
        {},
        {}
    },

    modded_joker = {
        {},
        {},
        {}
    },

    vanilla_consumable = {
        {},
        {},
        {}
    },

    modded_consumable = {
        {},
        {},
        {}
    },

    vanilla_booster = {
        {},
        {},
        {}
    },

    modded_booster = {
        {},
        {},
        {}
    },

    anything_else = {
        {},
        {},
        {}
    }
}

-- =========================================================
-- QUOTE LOOKUP
-- =========================================================

function FB.baize_quote_from_target(card, target, target_context)
    if not target then return nil, nil end

    local center = FB.baize_card_center(target)
    if not center then return nil, nil end

    local key = center.key
    local clean = FB.baize_clean_key(key)
    local set = center.set or FB.baize_card_set(target)

    if set == "Joker" then
        if FB.baize_is_fb_key(key) and FB.baize_quotes.fb_jokers[clean] then
            return "fb_joker:" .. clean, FB.baize_quotes.fb_jokers[clean]
        end

        if type(key) == "string" and key:sub(1, 2) == "j_" then
            return "unknown:vanilla_joker:" .. tostring(clean), FB.baize_quotes.unknown.vanilla_joker
        end

        return "unknown:modded_joker:" .. tostring(clean), FB.baize_quotes.unknown.modded_joker
    end

    if set == "Tarot" then
        if FB.baize_quotes.tarots[clean] then
            return "tarot:" .. clean, FB.baize_quotes.tarots[clean]
        end
        return "unknown:vanilla_consumable:" .. tostring(clean), FB.baize_quotes.unknown.vanilla_consumable
    end

    if set == "Planet" then
        if FB.baize_quotes.planets[clean] then
            return "planet:" .. clean, FB.baize_quotes.planets[clean]
        end
        return "unknown:vanilla_consumable:" .. tostring(clean), FB.baize_quotes.unknown.vanilla_consumable
    end

    if set == "Spectral" then
        if FB.baize_quotes.spectrals[clean] then
            return "spectral:" .. clean, FB.baize_quotes.spectrals[clean]
        end
        return "unknown:vanilla_consumable:" .. tostring(clean), FB.baize_quotes.unknown.vanilla_consumable
    end

    if set == "Voucher" then
        if FB.baize_is_fb_key(key) and FB.baize_quotes.fb_vouchers[clean] then
            return "fb_voucher:" .. clean, FB.baize_quotes.fb_vouchers[clean]
        end

        -- Vanilla vouchers are intentionally not listed by request.
        return "unknown:anything_else:" .. tostring(clean), FB.baize_quotes.unknown.anything_else
    end

    if set == "Booster" then
        if FB.baize_is_fb_key(key) and FB.baize_quotes.fb_boosters[clean] then
            return "fb_booster:" .. clean, FB.baize_quotes.fb_boosters[clean]
        end

        if FB.baize_quotes.vanilla_boosters[clean] then
            return "vanilla_booster:" .. clean, FB.baize_quotes.vanilla_boosters[clean]
        end

        if type(key) == "string" and key:sub(1, 2) == "p_" then
            return "unknown:vanilla_booster:" .. tostring(clean), FB.baize_quotes.unknown.vanilla_booster
        end

        return "unknown:modded_booster:" .. tostring(clean), FB.baize_quotes.unknown.modded_booster
    end

    return "unknown:anything_else:" .. tostring(clean), FB.baize_quotes.unknown.anything_else
end

function FB.baize_quote_from_blind(card)
    local blind = G and G.GAME and G.GAME.blind
    if not blind then return nil, nil end

    local key = FB.baize_current_blind_key()

    if blind.boss then
        if FB.baize_quotes.fb_bosses[key] then
            return "fb_boss:" .. key, FB.baize_quotes.fb_bosses[key]
        end

        if FB.baize_quotes.vanilla_bosses[key] then
            return "vanilla_boss:" .. key, FB.baize_quotes.vanilla_bosses[key]
        end

        return "unknown_boss:" .. tostring(key), {
            {
                FB.baize_current_blind_name() .. " is a Boss Blind.",
                "I have no specific note for it yet."
            }
        }
    end

    local blind_name = tostring(blind.name or ""):lower()

    if blind_name:find("big") then
        return "context:big_blind", FB.baize_quotes.context.big_blind
    end

    return "context:small_blind", FB.baize_quotes.context.small_blind
end

function FB.baize_quote_pool_for_context(card)
    local target, target_context = FB.baize_selected_target(card)

    if target then
        return FB.baize_quote_from_target(card, target, target_context)
    end

    if G and G.STATE == G.STATES.COLLECTION then
        return "context:collection", FB.baize_quotes.context.collection
    end

    if G and G.pack_cards and G.pack_cards.cards and #G.pack_cards.cards > 0 then
        return "context:pack", FB.baize_quotes.context.pack
    end

    if G and G.STATE == G.STATES.SHOP then
        return "context:shop", FB.baize_quotes.context.shop
    end

    if G and (G.STATE == G.STATES.BLIND_SELECT or G.blind_select) then
        return "context:blind_select", FB.baize_quotes.context.blind_select
    end

    local blind = G and G.GAME and G.GAME.blind
    if blind and blind.name then
        return FB.baize_quote_from_blind(card)
    end

    return "context:fallback", FB.baize_quotes.context.fallback
end

function FB.baize_lines_for_context(card)
    local tag, pool = FB.baize_quote_pool_for_context(card)
    return FB.baize_pick_quote(card, tag or "fallback", pool or FB.baize_quotes.context.fallback)
end

function FB.baize_apply_text(card)
    local center = card and card.config and card.config.center
    if not (center and center.loc_txt) then return end

    local lines = FB.baize_lines_for_context(card)

    center.loc_txt.text = {}

    for _, line in ipairs(lines or {}) do
        if line and line ~= "" then
            center.loc_txt.text[#center.loc_txt.text + 1] = line
        end
    end

    if #center.loc_txt.text == 0 then
        center.loc_txt.text = {
            "I have nothing to say yet.",
            "Write me a quote in baize.lua."
        }
    end
end

function FB.baize_loc_vars(card)
    FB.baize_apply_text(card)
    return { vars = {} }
end
