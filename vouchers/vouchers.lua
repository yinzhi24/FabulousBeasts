---@diagnostic disable: undefined-global

local FB = FabulousBeasts or {}
FabulousBeasts = FB

FB.voucher_prefix = "fb"

FB.food_joker_keys = FB.food_joker_keys or {}
FB.beast_joker_keys = FB.beast_joker_keys or {}
FB.vanilla_food_joker_keys = FB.vanilla_food_joker_keys or {}

-- Tuning knobs. Change these freely after playtesting.
FB.legendary_shop_rate = FB.legendary_shop_rate or 0.003      -- 0.3% per shop Joker roll with Golden Mountain
FB.utensils_food_force_rate = FB.utensils_food_force_rate or 0.20 -- practical shop bump for Food Jokers

function FB.has_voucher(key)
    return G.GAME
        and G.GAME.used_vouchers
        and G.GAME.used_vouchers["v_fb_" .. key]
end

function FB.pixiu_luck_bonus()
    return FB.has_voucher("pixiu_luck") and 1 or 0
end

function FB.is_booster_center(center)
    return center and center.set == "Booster"
end

function FB.apply_pixiu_luck_to_booster_centers()
    if not (G and G.P_CENTERS) then return end

    local bonus = FB.pixiu_luck_bonus()

    for _, center in pairs(G.P_CENTERS) do
        if FB.is_booster_center(center)
        and center.config
        and type(center.config.extra) == "number" then
            center.config.fb_pixiu_luck_base_extra =
                center.config.fb_pixiu_luck_base_extra or center.config.extra

            center.config.extra =
                (center.config.fb_pixiu_luck_base_extra or center.config.extra or 0) + bonus
        end
    end
end

function FB.apply_pixiu_luck_to_booster_card(card)
    if not (card and card.config and FB.is_booster_center(card.config.center)) then return end
    if not (card.ability and type(card.ability.extra) == "number") then return end

    local center = card.config.center
    if center and center.config and type(center.config.extra) == "number" then
        card.ability.extra = center.config.extra
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

function FB.is_food_joker_key(key)
    if not key then return false end
    if FB.food_joker_keys[key] or FB.vanilla_food_joker_keys[key] then return true end

    local unprefixed = key:gsub("^j_fb_", ""):gsub("^j_", "")
    return FB.food_joker_keys[unprefixed] or FB.vanilla_food_joker_keys[unprefixed]
end

function FB.is_beast_joker_key(key)
    if not key then return false end
    if FB.beast_joker_keys[key] then return true end

    local unprefixed = key:gsub("^j_fb_", ""):gsub("^j_", "")
    return FB.beast_joker_keys[unprefixed]
end

function FB.is_food_joker_center(center)
    return center and FB.is_food_joker_key(center.key)
end

function FB.is_beast_joker_center(center)
    return center and FB.is_beast_joker_key(center.key)
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

function FB.random_legendary_joker_key()
    return FB.random_joker_key_from_rarity(4, "fb_golden_mountain_legendary")
end

function FB.joker_rarity_pool_names(rarity)
    if rarity == 1 or rarity == "Common" or rarity == "common" then
        return { "Common", 1, "common" }
    end

    if rarity == 2 or rarity == "Uncommon" or rarity == "uncommon" then
        return { "Uncommon", 2, "uncommon" }
    end

    if rarity == 3 or rarity == "Rare" or rarity == "rare" then
        return { "Rare", 3, "rare" }
    end

    if rarity == 4 or rarity == "Legendary" or rarity == "legendary" then
        return { "Legendary", 4, "legendary" }
    end

    return { rarity }
end

function FB.center_matches_rarity(center, rarity)
    if not center or center.set ~= "Joker" then return false end

    for _, candidate in ipairs(FB.joker_rarity_pool_names(rarity)) do
        if center.rarity == candidate then
            return true
        end
    end

    return false
end

function FB.random_joker_key_from_rarity(rarity, seed)
    local keys = {}

    if G.P_JOKER_RARITY_POOLS then
        for _, pool_name in ipairs(FB.joker_rarity_pool_names(rarity)) do
            local pool = G.P_JOKER_RARITY_POOLS[pool_name]

            if pool then
                for _, center in ipairs(pool) do
                    if center
                    and center.key
                    and not center.no_pool_flag
                    and FB.center_exists(center.key) then
                        keys[#keys + 1] = center.key
                    end
                end

                if #keys > 0 then break end
            end
        end
    end

    if #keys == 0 and G.P_CENTERS then
        for key, center in pairs(G.P_CENTERS) do
            if center
            and FB.center_matches_rarity(center, rarity)
            and not center.no_pool_flag then
                keys[#keys + 1] = key
            end
        end
    end

    if #keys == 0 then return nil end

    -- math.random is intentionally used here instead of pseudorandom(seed).
    -- This avoids repeated deterministic seeds making every shop slot select
    -- the same rarity/key.
    return keys[math.random(#keys)]
end

function FB.weighted_shop_joker_rarity_with_vouchers()
    local has_ancient = FB.has_voucher("ancient_treasure")
    local has_mountain = FB.has_voucher("golden_mountain")

    if not has_ancient and not has_mountain then
        return nil
    end

    local weights

    if has_ancient then
        weights = {
            { rarity = 1, weight = 70 },
            { rarity = 2, weight = 50 },
            { rarity = 3, weight = 15 },
        }
    else
        weights = {
            { rarity = 1, weight = 70 },
            { rarity = 2, weight = 25 },
            { rarity = 3, weight = 5 },
        }
    end

    -- Golden Mountain adds Legendary Jokers to the same weighted selection.
    -- This does NOT set _rarity = 4; it only chooses an exact Legendary key later.
    if has_mountain then
        weights[#weights + 1] = { rarity = 4, weight = 2 }
    end

    local total = 0
    for _, entry in ipairs(weights) do
        total = total + (tonumber(entry.weight) or 0)
    end

    if total <= 0 then return nil end

    local roll = math.random() * total
    local running = 0

    for _, entry in ipairs(weights) do
        running = running + (tonumber(entry.weight) or 0)
        if roll < running then
            return entry.rarity
        end
    end

    return weights[#weights] and weights[#weights].rarity or nil
end

function FB.random_shop_joker_key_with_vouchers()
    local rarity = FB.weighted_shop_joker_rarity_with_vouchers()
    if not rarity then return nil end

    return FB.random_joker_key_from_rarity(rarity, "fb_shop_voucher_exact_key")
end

function FB.roll_ancient_treasure_rarity(current_rarity)
    -- Legacy compatibility helper.
    -- IMPORTANT: Ancient Treasure should never force _rarity anymore.
    -- Shop logic now selects an exact forced_key instead.
    return current_rarity
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

function FB.divine_prosperity_bonus()
    return FB.has_voucher("divine_prosperity") and 1 or 0
end

function FB.apply_divine_prosperity_to_booster_centers()
    if not (G and G.P_CENTERS) then return end

    local bonus = FB.divine_prosperity_bonus()

    for _, center in pairs(G.P_CENTERS) do
        if FB.is_booster_center(center)
        and center.config
        and type(center.config.choose) == "number" then
            center.config.fb_divine_prosperity_base_choose =
                center.config.fb_divine_prosperity_base_choose or center.config.choose

            center.config.choose =
                (center.config.fb_divine_prosperity_base_choose or center.config.choose or 1) + bonus
        end
    end
end

function FB.apply_divine_prosperity_to_booster_card(card)
    if not (card and card.config and FB.is_booster_center(card.config.center)) then return end
    if not (card.ability and type(card.ability.choose) == "number") then return end

    local center = card.config.center
    if center and center.config and type(center.config.choose) == "number" then
        card.ability.choose = center.config.choose
    end
end

function FB.is_shop_joker_create(_type, area, forced_key)
    return _type == "Joker"
        and G
        and G.shop_jokers
        and area == G.shop_jokers
        and not forced_key
end

function FB.patch_shop_rarity_with_ancient_treasure(_rarity)
    -- Legacy compatibility helper.
    -- Do not force rarity numbers. Returning 1/2/3 here tells Balatro
    -- "force Common/Uncommon/Rare", which is exactly what caused the bug.
    return _rarity
end

if not FB.fb_voucher_hooks_installed then
    FB.fb_voucher_hooks_installed = true

    local vanilla_create_card = create_card

    function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        FB.apply_pixiu_luck_to_booster_centers()
        FB.apply_divine_prosperity_to_booster_centers()

        if FB.should_force_booster_talisman
        and FB.should_force_booster_talisman(_type, area, forced_key) then
            _type, forced_key = FB.force_talisman_create_args(_type, forced_key, "fb_booster_talisman_key")
        elseif FB.should_force_shop_talisman
        and FB.should_force_shop_talisman(_type, area, forced_key) then
            _type, forced_key = FB.force_talisman_create_args(_type, forced_key, "fb_shop_talisman_key")
        end

        local is_shop_joker = FB.is_shop_joker_create(_type, area, forced_key)

        if is_shop_joker then
            -- Ancient Treasure / Golden Mountain:
            -- NEVER force _rarity. Pick an exact Joker key from the weighted pool.
            -- This avoids Balatro treating _rarity = 3 as "force Rare Joker".
            if not forced_key and _rarity == nil then
                local voucher_key = FB.random_shop_joker_key_with_vouchers
                    and FB.random_shop_joker_key_with_vouchers()

                if voucher_key then
                    forced_key = voucher_key
                end
            end

            -- Utensils: can force Food Joker after voucher rarity logic.
            if not forced_key
            and FB.has_voucher("utensils")
            and FB.utensils_food_force_rate
            and pseudorandom("fb_utensils_shop_food") < FB.utensils_food_force_rate then
                local food_key = FB.random_food_joker_key and FB.random_food_joker_key()
                if food_key then
                    forced_key = food_key
                end
            end
        end

        local card = vanilla_create_card(
            _type,
            area,
            legendary,
            _rarity,
            skip_materialize,
            soulable,
            forced_key,
            key_append
        )

        if card and FB.apply_pixiu_luck_to_booster_card then
            FB.apply_pixiu_luck_to_booster_card(card)
        end

        if card and FB.apply_divine_prosperity_to_booster_card then
            FB.apply_divine_prosperity_to_booster_card(card)
        end

        if card and FB.apply_cookware then
            FB.apply_cookware(card)
        end

        return card
    end

    if create_UIBox_shop then
        local vanilla_create_UIBox_shop = create_UIBox_shop

        function create_UIBox_shop(...)
            FB.apply_pixiu_luck_to_booster_centers()
            FB.apply_divine_prosperity_to_booster_centers()

            local ret = vanilla_create_UIBox_shop(...)

            FB.apply_pixiu_luck_to_booster_centers()
            FB.apply_divine_prosperity_to_booster_centers()

            return ret
        end
    end
end

-- Talisman voucher helpers.
-- Otherworldly Veil: Talismans can appear in the shop.
-- Cultist Ritual: Talismans can appear in Tarot, Spectral, and Cuisine/Food booster packs.
FB.TALISMAN_SET = FB.TALISMAN_SET or "Talisman"
FB.talisman_shop_rate = FB.talisman_shop_rate or 0.18
FB.talisman_booster_rate = FB.talisman_booster_rate or 0.20
FB.TALISMAN_ALLOWED_BOOSTER_TYPES = FB.TALISMAN_ALLOWED_BOOSTER_TYPES or {
    Tarot = true,
    Spectral = true,
    Cuisine = true,
    Food = true,
}

function FB.can_spawn_talismans()
    return FB.has_voucher("otherworldly_veil")
        or (G and G.GAME and G.GAME.fb_otherworldly_veil)
end

function FB.can_spawn_talismans_in_boosters()
    return FB.has_voucher("cultist_ritual")
        or (G and G.GAME and G.GAME.fb_cultist_ritual)
end

function FB.get_talisman_weight(key)
    if key == "blank" then return 0 end
    return 1
end

function FB.is_talisman_allowed_booster_type(_type)
    return FB.TALISMAN_ALLOWED_BOOSTER_TYPES and FB.TALISMAN_ALLOWED_BOOSTER_TYPES[_type] or false
end

function FB.is_talisman_center(center)
    return center and center.set == (FB.TALISMAN_SET or "Talisman")
end

function FB.random_talisman_key(seed)
    local pool = {}

    -- pseudoseed() crashes if given a boolean, so sanitize all callers here.
    if type(seed) ~= "string" and type(seed) ~= "number" then
        seed = "fb_random_talisman"
    end

    if G and G.P_CENTERS then
        for key, center in pairs(G.P_CENTERS) do
            if FB.is_talisman_center(center)
            and not center.no_pool_flag
            and key ~= "c_fb_talisman_blank" then
                local raw_key = tostring(key):gsub("^c_fb_talisman_", ""):gsub("^c_fb_", ""):gsub("^c_", "")
                local weight = FB.get_talisman_weight(raw_key)

                for _ = 1, math.max(0, math.floor((weight or 1) * 100)) do
                    -- Return the full center key. create_card can consume this directly as forced_key.
                    pool[#pool + 1] = key
                end
            end
        end
    end

    if #pool == 0 then return nil end
    return pseudorandom_element(pool, pseudoseed(tostring(seed)))
end

function FB.is_shop_consumable_create(_type, area, forced_key)
    return not forced_key
        and G
        and G.shop_jokers
        and area == G.shop_jokers
        and (_type == "Tarot"
            or _type == "Planet"
            or _type == "Spectral"
            or _type == "Talisman"
            or _type == "Consumeables"
            or _type == "Consumable")
end

function FB.should_force_shop_talisman(_type, area, forced_key)
    return FB.can_spawn_talismans()
        and FB.is_shop_consumable_create(_type, area, forced_key)
        and pseudorandom("fb_shop_talisman") < (FB.talisman_shop_rate or 0.18)
end

function FB.should_force_booster_talisman(_type, area, forced_key)
    return FB.can_spawn_talismans_in_boosters()
        and not forced_key
        and G
        and G.pack_cards
        and area == G.pack_cards
        and FB.is_talisman_allowed_booster_type(_type)
        and pseudorandom("fb_booster_talisman") < (FB.talisman_booster_rate or 0.20)
end

function FB.force_talisman_create_args(_type, forced_key, seed)
    local talisman_key = FB.random_talisman_key(seed)
    if talisman_key then
        return FB.TALISMAN_SET or "Talisman", talisman_key
    end
    return _type, forced_key
end

SMODS.Atlas {
    key = "vouchers",
    path = "vouchers.png",
    px = 71,
    py = 95
}

SMODS.Voucher {
    key = "ancient_treasure",
    atlas = "vouchers",
    pos = { x = 0, y = 0 },
    cost = 10,
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = "Ancient Treasure",
        text = {
            "{C:uncommon}Uncommon{} Jokers appear",
            "{C:attention}2X{} as often",
            "{C:rare}Rare{} Jokers appear",
            "{C:attention}3X{} as often"
        }
    }
}

SMODS.Voucher {
    key = "golden_mountain",
    atlas = "vouchers",
    pos = { x = 0, y = 1 },
    cost = 10,
    requires = { "v_fb_ancient_treasure" },
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = "Golden Mountain",
        text = {
            "{C:legendary}Legendary{} Jokers may",
            "appear in the shop"
        }
    }
}

SMODS.Voucher {
    key = "utensils",
    atlas = "vouchers",
    pos = { x = 1, y = 0 },
    cost = 10,
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = "Utensils",
        text = {
            "{C:attention}Food{} Jokers appear",
            "{C:attention}2X{} as often"
        }
    }
}

SMODS.Voucher {
    key = "cookware",
    atlas = "vouchers",
    pos = { x = 1, y = 1 },
    cost = 10,
    requires = { "v_fb_utensils" },
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = "Cookware",
        text = {
            "{C:attention}Food{} Jokers always",
            "come with a random",
            "{C:dark_edition}Edition{}"
        }
    }
}

SMODS.Voucher {
    key = "pixiu_luck",
    atlas = "vouchers",
    pos = { x = 2, y = 0 },
    cost = 10,
    discovered = true,
    unlocked = true,
    redeem = function(self, card)
        FB.apply_pixiu_luck_to_booster_centers()
    end,
    loc_txt = {
        name = "Pixiu Luck",
        text = {
            "Booster Packs contain",
            "{C:attention}+1{} option"
        }
    }
}

SMODS.Voucher {
    key = "divine_prosperity",
    atlas = "vouchers",
    pos = { x = 2, y = 1 },
    cost = 10,
    requires = { "v_fb_pixiu_luck" },
    discovered = true,
    unlocked = true,
    redeem = function(self, card)
        FB.apply_divine_prosperity_to_booster_centers()
    end,
    loc_txt = {
        name = "Divine Prosperity",
        text = {
            "Choose {C:attention}+1{} card",
            "from Booster Packs"
        }
    }
}

SMODS.Voucher {
    key = "vision",
    atlas = "vouchers",
    pos = { x = 3, y = 0 },
    cost = 10,
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = "Vision",
        text = {
            "Reveals if Jokers have",
            "{C:purple}hidden interactions{}"
        }
    }
}

SMODS.Voucher {
    key = "true_sight",
    atlas = "vouchers",
    pos = { x = 3, y = 1 },
    cost = 10,
    requires = { "v_fb_vision" },
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = "True Sight",
        text = {
            "Reveals exactly what",
            "{C:purple}hidden interactions{} do"
        }
    }
}

SMODS.Voucher {
    key = "otherworldly_veil",
    atlas = "vouchers",
    pos = { x = 4, y = 0 },
    cost = 10,
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = "Otherworldly Veil",
        text = {
            "{C:attention}Talismans{} may",
            "appear in the {C:attention}Shop{}",
            "{C:inactive}(No Blank Talismans yet){}"
        }
    },
    redeem = function(self, card)
        G.GAME.fb_otherworldly_veil = true
    end,
}

SMODS.Voucher {
    key = "cultist_ritual",
    atlas = "vouchers",
    pos = { x = 4, y = 1 },
    cost = 10,
    requires = { "v_fb_otherworldly_veil" },
    discovered = true,
    unlocked = true,
    loc_txt = {
        name = "Cultist Ritual",
        text = {
            "{C:attention}Talismans{} may",
            "appear in {C:tarot}Tarot{},",
            "{C:spectral}Spectral{}, and",
            "{C:attention}Cuisine{} Packs"
        }
    },
    redeem = function(self, card)
        G.GAME.fb_cultist_ritual = true
    end,
}