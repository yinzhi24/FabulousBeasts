---@diagnostic disable: undefined-global

local FB = FabulousBeasts or {}
FabulousBeasts = FB

FB.food_joker_keys = FB.food_joker_keys or {}
FB.beast_joker_keys = FB.beast_joker_keys or {}
FB.vanilla_food_joker_keys = FB.vanilla_food_joker_keys or {}


local function fb_merge_keys(target, defaults)
    for key, enabled in pairs(defaults or {}) do
        if target[key] == nil then target[key] = enabled end
    end
end

-- Safety defaults so packs do not become random Joker packs if this file loads
-- before the main Joker-list file.
fb_merge_keys(FB.food_joker_keys, {
    ambrosia = true,
    divine_herb = true,
    dog_food = true,
    emergency_rations = true,
    food = true,
    food_reserve = true,
    foraged_mushrooms = true,
    heavenly_cumin = true,
    hellspice_hotpot = true,
    mooncake = true,
    skewered_kebab = true,
    teacup = true,
    chicken_mushroom_stew = true,
    heavenly_elixirs = true,
    hellish_delicacies = true,
    lunchbox_medkit = true,
    mapo_tofu = true,
    moon_palace = true,
    mooncake_cannon = true,
})

fb_merge_keys(FB.vanilla_food_joker_keys, {
    j_gros_michel = true,
    j_cavendish = true,
    j_ice_cream = true,
    j_popcorn = true,
    j_ramen = true,
    j_seltzer = true,
    j_egg = true,
    j_turtle_bean = true,
})

FB.food_pack_funny_names = FB.food_pack_funny_names or {
    "Mmm... tasty...",
    "Yum yum in my tum tum",
    "Looks appetizing",
    "Making my money's worth",
    "Is there a menu?",
    "Fresh from the kitchen",
    "Today's special",
    "Chef's recommendation",
    "Five stars",
    "Still warm",
    "Smells delicious",
    "Needs more spice",
    "Extra crispy",
    "Would order again",
    "Not microwave safe",
    "Calories don't count here",
    "A balanced meal",
    "Bon appetit",
    "One more bite",
    "Straight from the wok",
    "Someone cooked",
    "All you can eat",
    "The health inspector left",
    "The chef fears me",
    "Unlimited refills",
    "I paid for the whole restaurant",
    "Today's special: everything",
    "There is no menu anymore",
    "The buffet has become sentient",
    "Nezha is made of lotus roots",
    "Sun Wukong once ate immortal peaches",
    "Taotie would eat the world if given the chance",
    "The Queen Mother grows peaches that ripen every 3,000 years",
    "Chang'e may live on the Moon with a rabbit making medicine",
    "Pixiu eats treasure but has no rear end",
    "The Eight Immortals have probably eaten better than you",
    "Dragon meat is not on today's menu",
    "This meal is Taotie-approved",
    "Dijiang has no face but still somehow eats",
    "Qiongqi would probably eat the waiter",
    "This pack contains zero actual food",
    "Nutrition facts unavailable",
    "May contain traces of mythology",
    "Calories are hidden until True Sight is obtained",
    "The chef rolled a natural 20",
    "Food not evaluated by the FDA",
    "Spectral cards are technically edible once",
    "Do not ask where the ingredients came from",
    "Side effects may include becoming immortal",
    "The buffet is now a raid boss",
}

FB.food_pack_rare_names = FB.food_pack_rare_names or {
    "Baize already ate this.",
    "ERROR",
    "The chef has become the meal.",
    "Among us.",
    "You found the secret ingredient.",
}

function FB.random_food_pack_display_name(seed)
    -- Very rare silly lines. The normal line pool is still the main behavior.
    if pseudorandom((seed or "fb_food_pack_name") .. "_rare") < 0.01 then
        return pseudorandom_element(FB.food_pack_rare_names, pseudoseed((seed or "fb_food_pack_name") .. "_rare_pick"))
    end
    return pseudorandom_element(FB.food_pack_funny_names, pseudoseed(seed or "fb_food_pack_name"))
end


function FB.clear_food_pack_open_message()
    if FB.food_pack_message_uibox then
        pcall(function() FB.food_pack_message_uibox:remove() end)
        FB.food_pack_message_uibox = nil
    end
end

function FB.show_food_pack_open_message(seed)
    local msg = FB.random_food_pack_display_name(seed or "fb_food_pack_open")

    -- Use a real UIBox instead of attention_text. attention_text gets covered/cleared
    -- when pack cards draw in, while this stays anchored below the Jokers area.
    FB.clear_food_pack_open_message()

    if not (G and G.E_MANAGER and UIBox and G.UIT) then return end

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        blocking = false,
        blockable = false,
        func = function()
            local major = G.jokers or G.ROOM_ATTACH or G.hand
            if not major then return true end

            FB.food_pack_message_uibox = UIBox({
                definition = {
                    n = G.UIT.ROOT,
                    config = { align = "cm", colour = G.C.CLEAR, padding = 0 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                align = "cm",
                                padding = 0.08,
                                r = 0.08,
                                colour = G.C.UI.TRANSPARENT_DARK
                            },
                            nodes = {
                                {
                                    n = G.UIT.T,
                                    config = {
                                        text = msg,
                                        scale = 0.4,
                                        colour = G.C.WHITE,
                                        shadow = true
                                    }
                                }
                            }
                        }
                    }
                },
                config = {
                    align = "cm",
                    major = major,
                    offset = { x = 0, y = 2 },
                    bond = "Weak"
                }
            })

            return true
        end
    }))

    -- Safety cleanup. This is intentionally long so it survives normal pack opening.
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 10,
        blocking = false,
        blockable = false,
        func = function()
            FB.clear_food_pack_open_message()
            return true
        end
    }))
end


function FB.ensure_booster_localization()
    if not (G and G.localization and G.localization.misc and G.localization.misc.dictionary) then return end

    local dict = G.localization.misc.dictionary
    dict.k_fb_cuisine_pack = dict.k_fb_cuisine_pack or "Cuisine Pack"
    dict.k_fb_jumbo_cuisine_pack = dict.k_fb_jumbo_cuisine_pack or "Jumbo Cuisine Pack"
    dict.k_fb_buffet_pack = dict.k_fb_buffet_pack or "Buffet Pack"
    dict.k_fb_beast_pack = dict.k_fb_beast_pack or "Beast Pack"
    dict.k_fb_heavenly_beast_pack = dict.k_fb_heavenly_beast_pack or "Heavenly Beast Pack"
end

FB.ensure_booster_localization()

function FB.has_voucher(key)
    return G.GAME
        and G.GAME.used_vouchers
        and G.GAME.used_vouchers["v_fb_" .. key]
end

function FB.extra_booster_options()
    return FB.has_voucher("pixiu_luck") and 1 or 0
end

function FB.food_pack_weights()
    -- Secret Vision/True Sight synergy.
    if FB.has_voucher("true_sight") then
        return {
            Planet = 25,
            Tarot = 25,
            Spectral = 25,
            FoodJoker = 25
        }
    elseif FB.has_voucher("vision") then
        return {
            Planet = 30,
            Tarot = 30,
            Spectral = 20,
            FoodJoker = 20
        }
    end

    return {
        Planet = 35,
        Tarot = 35,
        Spectral = 10,
        FoodJoker = 20
    }
end

function FB.weighted_choice(weights, seed)
    local total = 0
    for _, weight in pairs(weights) do
        total = total + weight
    end

    local roll = pseudorandom(seed or "fb_weighted_choice") * total
    local current = 0

    for key, weight in pairs(weights) do
        current = current + weight
        if roll <= current then
            return key
        end
    end
end

function FB.center_key_variants(key)
    return {
        key,
        "j_fb_" .. key,
        "j_" .. key,
        key and key:gsub("^j_fb_", "") or key,
        key and key:gsub("^j_", "") or key,
    }
end

function FB.center_exists(key)
    return key and G.P_CENTERS and G.P_CENTERS[key]
end

function FB.random_key_from_table(tbl, seed)
    local keys = {}

    for key, enabled in pairs(tbl or {}) do
        if enabled then
            for _, candidate in ipairs(FB.center_key_variants(key)) do
                if FB.center_exists(candidate) then
                    keys[#keys + 1] = candidate
                    break
                end
            end
        end
    end

    if #keys == 0 then return nil end
    return pseudorandom_element(keys, pseudoseed(seed or "fb_random_key"))
end

function FB.random_food_joker_key()
    local combined = {}

    for key, enabled in pairs(FB.food_joker_keys or {}) do
        if enabled then combined[key] = true end
    end

    for key, enabled in pairs(FB.vanilla_food_joker_keys or {}) do
        if enabled then combined[key] = true end
    end

    return FB.random_key_from_table(combined, "fb_food_joker")
end

FB.beast_pack_excluded_keys = FB.beast_pack_excluded_keys or {
    bixie = true,
    tianlu = true,
    j_fb_bixie = true,
    j_fb_tianlu = true,
}

function FB.is_exotic_or_divine_center(center)
    local rarity = center and center.rarity

    if type(rarity) == "string" then
        rarity = string.lower(rarity)
        return rarity:find("exotic", 1, true) ~= nil
            or rarity:find("divine", 1, true) ~= nil
    end

    if type(rarity) == "table" then
        local key = tostring(rarity.key or rarity.name or rarity.id or ""):lower()
        return key:find("exotic", 1, true) ~= nil
            or key:find("divine", 1, true) ~= nil
    end

    return false
end

function FB.is_legendary_center(center)
    local rarity = center and center.rarity

    if rarity == 4 then return true end

    if type(rarity) == "string" then
        local r = rarity:lower()
        return r == "legendary" or r:find("legendary", 1, true) ~= nil
    end

    if type(rarity) == "table" then
        local key = tostring(rarity.key or rarity.name or rarity.id or ""):lower()
        return key == "legendary" or key:find("legendary", 1, true) ~= nil
    end

    return false
end

function FB.is_beast_center(center)
    local category = center and center.fb_category

    if type(category) == "string" then
        return string.find(string.lower(category), "beast", 1, true) ~= nil
    end

    if type(category) == "table" then
        for _, value in pairs(category) do
            if type(value) == "string" and value:lower():find("beast", 1, true) then
                return true
            end
        end
    end

    return false
end

function FB.is_beast_pack_candidate_center(key, center)
    if not (key and center and center.set == "Joker") then return false end
    if not tostring(key):find("^j_fb_") then return false end
    if FB.is_beast_pack_excluded_key(key) then return false end
    if FB.is_exotic_or_divine_center(center) then return false end

    -- Registry/category support for normal Beasts, plus numeric rarity-4
    -- support so Legendary Beast Jokers appear even when older Joker files
    -- do not define fb_category. Bixie/Tianlu are still excluded above.
    local unprefixed = tostring(key):gsub("^j_fb_", ""):gsub("^j_", "")
    return FB.beast_joker_keys[key] == true
        or FB.beast_joker_keys[unprefixed] == true
        or FB.is_beast_center(center)
        or FB.is_legendary_center(center)
end

function FB.is_beast_pack_excluded_key(key)
    if not key then return true end

    local unprefixed = key:gsub("^j_fb_", ""):gsub("^j_", "")
    return FB.beast_pack_excluded_keys[key] == true
        or FB.beast_pack_excluded_keys[unprefixed] == true
end

function FB.beast_pack_keys()
    local pool = {}

    -- Explicit registry support, for hand-picked beast keys from Joker files.
    for key, enabled in pairs(FB.beast_joker_keys or {}) do
        if enabled and not FB.is_beast_pack_excluded_key(key) then
            for _, candidate in ipairs(FB.center_key_variants(key)) do
                local center = FB.center_exists(candidate)
                if center and not FB.is_exotic_or_divine_center(center) then
                    pool[candidate] = true
                    break
                end
            end
        end
    end

    -- Dynamic fallback/support: include every loaded Fabulous Beasts Beast Joker,
    -- plus Legendary Fabulous Beasts Jokers from older files that do not define
    -- fb_category. Normal Bixie/Tianlu and Exotic/Divine cards stay excluded.
    if G and G.P_CENTERS then
        for key, center in pairs(G.P_CENTERS) do
            if FB.is_beast_pack_candidate_center(key, center) then
                pool[key] = true
            end
        end
    end

    -- Tianlu and Bixie are allowed in Beast Packs only as babies.
    for _, baby_key in ipairs({ "baby_tianlu", "baby_bixie", "j_fb_baby_tianlu", "j_fb_baby_bixie" }) do
        for _, candidate in ipairs(FB.center_key_variants(baby_key)) do
            local center = FB.center_exists(candidate)
            if center and not FB.is_exotic_or_divine_center(center) then
                pool[candidate] = true
                break
            end
        end
    end

    return pool
end

function FB.random_beast_joker_key()
    return FB.random_key_from_table(FB.beast_pack_keys(), "fb_beast_joker")
end

function FB.random_heavenly_beast_joker_key()
    -- Heavenly Beast Packs use the full non-Exotic Beast pool too.
    return FB.random_beast_joker_key()
end

function FB.is_food_joker_key(key)
    if not key then return false end
    if FB.food_joker_keys[key] or FB.vanilla_food_joker_keys[key] then return true end

    local unprefixed = key:gsub("^j_fb_", ""):gsub("^j_", "")
    return FB.food_joker_keys[unprefixed] or FB.vanilla_food_joker_keys[unprefixed]
end

function FB.is_food_joker_center(center)
    return center and FB.is_food_joker_key(center.key)
end

function FB.random_edition_table()
    local editions = {
        { edition = { foil = true }, weight = 45 },
        { edition = { holo = true }, weight = 35 },
        { edition = { polychrome = true }, weight = 15 },
        { edition = { negative = true }, weight = 5 },
    }

    local total = 0
    for _, entry in ipairs(editions) do total = total + entry.weight end

    local roll = pseudorandom("fb_random_edition") * total
    local current = 0

    for _, entry in ipairs(editions) do
        current = current + entry.weight
        if roll <= current then return entry.edition end
    end

    return { foil = true }
end

function FB.apply_cookware(card)
    if not (card and FB.has_voucher("cookware")) then return end
    if not (card.config and card.config.center and FB.is_food_joker_center(card.config.center)) then return end
    if card.edition then return end

    card:set_edition(FB.random_edition_table(), true)
end

function FB.create_exact_joker_card(key, area, key_append)
    if not (key and FB.center_exists(key)) then return nil end

    local card
    if SMODS and SMODS.create_card then
        card = SMODS.create_card({
            set = "Joker",
            area = area or G.pack_cards,
            key = key,
            skip_materialize = true,
            soulable = true,
            key_append = key_append or "fb_exact_joker"
        })
    else
        card = create_card("Joker", area or G.pack_cards, nil, nil, true, true, key, key_append or "fb_exact_joker")
    end

    -- Hard safety: if create_card ignored forced_key, forcibly set the ability.
    if card and card.config and card.config.center and card.config.center.key ~= key and G.P_CENTERS[key] then
        card:set_ability(G.P_CENTERS[key], true)
    end

    return card
end

function FB.create_food_joker_pack_card()
    local key = FB.random_food_joker_key()

    -- Absolute safety: never let FoodJoker fallback create a random Joker.
    if not key then
        print("[Fabulous Beasts] Food pack could not find a food Joker key; falling back to Tarot.")
        return create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, "fb_food_pack_fallback")
    end

    local card = FB.create_exact_joker_card(key, G.pack_cards, "fb_food_pack")

    -- Second safety: if something still went wrong, replace with a consumable instead
    -- of leaking random non-food Jokers like Hallucination into Cuisine Packs.
    if not (card and card.config and card.config.center and FB.is_food_joker_center(card.config.center)) then
        print("[Fabulous Beasts] Blocked non-food Joker from Food Pack: " .. tostring(card and card.config and card.config.center and card.config.center.key))
        return create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, "fb_food_pack_blocked")
    end

    FB.apply_cookware(card)
    return card
end

function FB.create_food_pack_card()
    local choice = FB.weighted_choice(FB.food_pack_weights(), "fb_food_pack_choice")

    if choice == "Planet" then
        return create_card("Planet", G.pack_cards, nil, nil, true, true, nil, "fb_food_pack")
    end

    if choice == "Tarot" then
        return create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, "fb_food_pack")
    end

    if choice == "Spectral" then
        return create_card("Spectral", G.pack_cards, nil, nil, true, true, nil, "fb_food_pack")
    end

    if choice == "FoodJoker" then
        return FB.create_food_joker_pack_card()
    end

    return create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, "fb_food_pack_default")
end

function FB.create_beast_pack_card(heavenly)
    local key = heavenly and FB.random_heavenly_beast_joker_key() or FB.random_beast_joker_key()
    local card = FB.create_exact_joker_card(key, G.pack_cards, heavenly and "fb_heavenly_beast_pack" or "fb_beast_pack")

    -- Beast packs are expensive; fail loudly-ish instead of silently rolling random Jokers.
    if not card then
        print("[Fabulous Beasts] Beast pack could not find a valid Beast Joker key.")
    end

    return card
end

SMODS.Atlas {
    key = "fb_boosters",
    path = "boosters.png",
    px = 71,
    py = 95
}

local function make_booster(def)
    SMODS.Booster {
        key = def.key,
        atlas = "fb_boosters",
        pos = def.pos,
        discovered = true,
        unlocked = true,
        cost = def.cost,
        weight = def.weight,
        draw_hand = def.draw_hand,
        kind = def.pack_kind or def.name,
        group_key = def.group_key,
        config = {
            extra = def.extra,
            choose = def.choose
        },
        loc_txt = {
            name = def.name,
            text = {
                "Choose {C:attention}#1#{} of",
                "{C:attention}#2#{} cards"
            }
        },
        loc_vars = function(self, info_queue, card)
            FB.ensure_booster_localization()
            return {
                vars = {
                    self.config.choose,
                    self.config.extra + FB.extra_booster_options()
                }
            }
        end,
        create_card = function(self, card, i)
            if def.kind == "food" then
                if i == 1 then
                    FB.show_food_pack_open_message(def.key)
                end
                return FB.create_food_pack_card()
            elseif def.kind == "beast" then
                return FB.create_beast_pack_card(false)
            elseif def.kind == "heavenly_beast" then
                return FB.create_beast_pack_card(true)
            end
        end,
        ease_background_colour = function(self)
            if def.kind == "food" then
                ease_colour(G.C.DYN_UI.MAIN, G.C.RED)
                ease_background_colour({
                    new_colour = G.C.RED,
                    special_colour = G.C.ORANGE,
                    contrast = 2
                })
            elseif def.kind == "beast" then
                ease_colour(G.C.DYN_UI.MAIN, G.C.GREEN)
                ease_background_colour({
                    new_colour = G.C.GREEN,
                    special_colour = G.C.BLUE,
                    contrast = 2
                })
            else
                ease_colour(G.C.DYN_UI.MAIN, G.C.PURPLE)
                ease_background_colour({
                    new_colour = G.C.PURPLE,
                    special_colour = G.C.GOLD,
                    contrast = 2
                })
            end
        end
    }
end

local booster_defs = {
    {
        key = "cuisine_pack_1",
        name = "Cuisine Pack",
        group_key = "k_fb_cuisine_pack",
        pack_kind = "Cuisine Pack",
        kind = "food",
        random_name = true,
        draw_hand = true,
        pos = { x = 0, y = 0 },
        cost = 5,
        weight = 1,
        extra = 4,
        choose = 1
    },
    {
        key = "cuisine_pack_2",
        name = "Cuisine Pack",
        group_key = "k_fb_cuisine_pack",
        pack_kind = "Cuisine Pack",
        kind = "food",
        random_name = true,
        draw_hand = true,
        pos = { x = 1, y = 0 },
        cost = 5,
        weight = 1,
        extra = 4,
        choose = 1
    },
    {
        key = "jumbo_cuisine_pack",
        name = "Jumbo Cuisine Pack",
        group_key = "k_fb_jumbo_cuisine_pack",
        pack_kind = "Jumbo Cuisine Pack",
        kind = "food",
        random_name = true,
        draw_hand = true,
        pos = { x = 0, y = 1 },
        cost = 7,
        weight = 0.8,
        extra = 6,
        choose = 1
    },
    {
        key = "buffet_pack",
        name = "Buffet Pack",
        group_key = "k_fb_buffet_pack",
        pack_kind = "Buffet Pack",
        kind = "food",
        random_name = true,
        draw_hand = true,
        pos = { x = 3, y = 1 },
        cost = 10,
        weight = 0.6,
        extra = 6,
        choose = 2
    },
    {
        key = "beast_pack_1",
        name = "Beast Pack",
        group_key = "k_fb_beast_pack",
        pack_kind = "Beast Pack",
        kind = "beast",
        pos = { x = 2, y = 2 },
        cost = 30,
        weight = 0.03,
        extra = 2,
        choose = 1
    },
    {
        key = "beast_pack_2",
        name = "Beast Pack",
        group_key = "k_fb_beast_pack",
        pack_kind = "Beast Pack",
        kind = "beast",
        pos = { x = 3, y = 2 },
        cost = 30,
        weight = 0.03,
        extra = 2,
        choose = 1
    },
    {
        key = "heavenly_beast_pack_1",
        name = "Heavenly Beast Pack",
        group_key = "k_fb_heavenly_beast_pack",
        pack_kind = "Heavenly Beast Pack",
        kind = "heavenly_beast",
        pos = { x = 2, y = 0 },
        cost = 50,
        weight = 0.01,
        extra = 4,
        choose = 1
    },
    {
        key = "heavenly_beast_pack_2",
        name = "Heavenly Beast Pack",
        group_key = "k_fb_heavenly_beast_pack",
        pack_kind = "Heavenly Beast Pack",
        kind = "heavenly_beast",
        pos = { x = 3, y = 0 },
        cost = 50,
        weight = 0.01,
        extra = 4,
        choose = 1
    },
}

for _, def in ipairs(booster_defs) do
    make_booster(def)
end
