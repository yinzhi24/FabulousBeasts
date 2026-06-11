---@diagnostic disable: undefined-global

FB = FB or {}
FB.hidden_synergy = FB.hidden_synergy or {}

FB.hidden_synergy.data = {
    tianlu = {
        bixie = {
            "Gain {X:chips,C:white}0.1X{} chips per {C:money}$1{} at round start",
            "No longer lose all money at round start",
            "Each Cintamani you sell has a {C:green}1 in 100{} chance to evolve",
            "{C:blue}Tianlu{} into true form"
        }
    },

    bixie = {
        tianlu = {
            "Gain {X:mult,C:white}1X{} mult every time you use a discard",
            "Evolves into true form when you sell {C:blue}Tianlu{}"
        },
        sibuxiang = {
            "When you sell {C:blue}Tianlu{}, also destroy Sibuxiang"
        }
    },

    jade_bird = {
        bixie = {
            "Destroy {C:red}Bixie{} along with Jade Bird",
            "If Sibuxiang is also in your hand,",
            "then evolve Sibuxiang into",
            "Qilin Sibuxiang and restore {C:red}Bixie{}",
            "after {C:attention}1{} round"
        }
    },

    hundun = {
        dijiang = {
            "Gain {X:mult,C:white}1.5X{} mult for each",
            "card and joker triggered",
            "If Dijiang is debuffed, also debuff Hundun",
            "When Dijiang {C:red}self destructs{},",
            "Hundun also {C:red}self destructs{}",
            "Create {C:attention}Rainbow Mountain Range{} right after"
        }
    },

    dijiang = {
        hundun = {
            "{C:hearts}Heart{} suit cards also give",
            "{X:mult,C:white}1X{} mult equal to your current {C:chips}chips{}"
        }
    },

    chugou = {
        shanque = {
            "Earn {C:money}$1.1X{} for each card triggered",
            "Guarantees at least {C:money}$1{}",
            "Always rounds down"
        }
    },

    shanque = {
        chugou = {
            "Gain {X:mult,C:white}X1.1{} mult every time Chugou is triggered"
        }
    },

    diting = {
        kulou = {
            "Kulou gains {X:mult,C:white}1X{} mult every round as long",
            "as Diting is also in your hand"
        }
    },

    kulou = {
        diting = {
            "Gain {C:attention}+1{} hand size",
            "Gain {C:consumable}+1{} consumable slot",
            "Gain {C:attention}+1{} joker slot"
        }
    },

    fuku_fuzai = {
        hetao = {
            "Triggered food jokers give {X:mult,C:white}X3{} mult"
        }
    },

    hetao = {
        fuku_fuzai = {
            "Triggered food jokers give {X:mult,C:white}X3{} mult"
        },
        dreamscape = {
            "Jokers with editions also give",
            "{X:chips,C:white}2X{} chips and {X:mult,C:white}2X{} mult"
        },
        cardboard_box = {
            "Gain {C:attention}+1{} joker slot"
        }
    },

    tuye_tony = {
        sibuxiang = {
            "{C:common}Common{} jokers give {X:chips,C:white}1.5X{} chips",
            "{C:uncommon}Uncommon{} jokers give {X:mult,C:white}1.5X{} mult",
            "{C:rare}Rare{} jokers give {X:mult,C:white}2X{} mult",
            "{C:legendary}Legendary{} jokers give {X:chips,C:white}2X{} chips and {X:mult,C:white}3X{} mult",
            "Exotic jokers give {X:chips,C:white}3X{} chips and {X:mult,C:white}5X{} mult"
        },
        zhanhu = {
            "Also retrigger all {C:chips}XChips{} jokers"
        }
    },

    bibi = {
        christina = {
            "Gain {C:attention}+1{} joker slot"
        },
        lord_phoenix = {
            "Scored cards without {C:attention}enhancements{}",
            "give {X:mult,C:white}2X{} mult"
        }
    },

    christina = {
        bibi = {
            "Gain {C:attention}+1{} joker slot"
        },
        jinchi_dapeng = {
            "Retrigger stone cards once",
            "for each played stone card"
        }
    },

    lord_phoenix = {
        jinchi_dapeng = {
            "{C:red}Debuff{} each other",
            "When you have both {C:uncommon}Bibi{} and {C:rare}Christina{},",
            "Lord Phoenix and Jinchi Dapeng",
            "no longer self debuff each other"
        }
    },

    jinchi_dapeng = {
        lord_phoenix = {
            "{C:red}Debuff{} each other",
            "When you have both {C:uncommon}Bibi{} and {C:rare}Christina{},",
            "Lord Phoenix and Jinchi Dapeng",
            "no longer self debuff each other"
        }
    },

    bajin = {
        erliang = {
            "Retrigger food jokers once"
        }
    },

    erliang = {
        bajin = {
            "Create a random food joker every round"
        }
    },

    taowu = {
        qiongqi = {
            "Taowu will not be debuffed by Qiongqi"
        }
    },

    taotie = {
        qiongqi = {
            "Taotie will not be debuffed by Qiongqi"
        }
    },

    qiongqi = {
        taowu = {
            "Both jokers are {C:attention}eternal{}"
        }
    },

    jinjiao = {
        yinjiao = {
            "{C:money}Gold{} and {C:attention}steel{} are considered",
            "the same enhancement"
        }
    },

    yinjiao = {
        jinjiao = {
            "{C:money}Gold{} and {C:attention}steel{} are considered",
            "the same enhancement"
        }
    }
}

function FB.clean_joker_key(key)
    if not key then return nil end
    key = tostring(key)
    key = key:gsub("^j_fb_", "")
    key = key:gsub("^j_", "")
    return key
end

function FB.full_joker_key(key)
    key = FB.clean_joker_key(key)
    return key and ("j_fb_" .. key) or nil
end

function FB.raw_key(card_or_key)
    if not card_or_key then
        return nil
    end

    local t = type(card_or_key)

    if t == "string" then
        return FB.clean_joker_key(card_or_key)
    end

    if t ~= "table" then
        return nil
    end

    local center = card_or_key.config and card_or_key.config.center

    return FB.clean_joker_key(
        (center and center.key)
        or (card_or_key.ability and card_or_key.ability.name)
    )
end

FB.is_joker_key = FB.is_joker_key or function(card_or_key, key)
    local card_key = FB.raw_key(card_or_key)

    if not card_key then
        return false
    end

    return card_key == FB.clean_joker_key(key)
end

function FB.secret_joker_name(key)
    local clean = FB.clean_joker_key(key)
    if not clean then return "Unknown Joker" end

    local full = FB.full_joker_key(clean)

    local center =
        (G and G.P_CENTERS and G.P_CENTERS[full])
        or (G and G.P_CENTERS and G.P_CENTERS["j_fb_" .. clean])
        or (G and G.P_CENTERS and G.P_CENTERS[clean])

    if center then
        if center.loc_txt and center.loc_txt.name then
            return center.loc_txt.name
        end

        if center.name then
            return center.name
        end
    end

    return clean:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest
    end)
end

FB.joker_cards = FB.joker_cards or function()
    return (G and G.jokers and G.jokers.cards) or {}
end

function FB.find_joker(key)
    key = FB.clean_joker_key(key)
    if not key then return nil end
    for _, joker in ipairs(FB.joker_cards()) do
        if FB.raw_key(joker) == key then return joker end
    end
    return nil
end

function FB.has_joker_key(key)
    return FB.find_joker(key) ~= nil
end

function FB.center_key_for_joker(key)
    local clean = FB.clean_joker_key(key)
    if not clean then return nil end

    local candidates = {
        "j_fb_" .. clean,
        "j_" .. clean,
        clean
    }

    for _, candidate in ipairs(candidates) do
        if G and G.P_CENTERS and G.P_CENTERS[candidate] then
            return candidate
        end
    end

    return nil
end

function FB.hidden_has_vision()
    return G and G.STATE ~= G.STATES.COLLECTION
        and G.GAME and G.GAME.used_vouchers
        and (G.GAME.used_vouchers.v_fb_vision or G.GAME.used_vouchers.v_fb_true_sight)
end

function FB.hidden_has_true_sight()
    return G and G.STATE ~= G.STATES.COLLECTION
        and G.GAME and G.GAME.used_vouchers
        and G.GAME.used_vouchers.v_fb_true_sight
end

function FB.can_use_secret_synergies()
    return FB.hidden_has_vision()
end

function FB.secret_synergy_active(card_or_key, partner_key)
    if not FB.can_use_secret_synergies() then return false end
    local key = FB.raw_key(card_or_key)
    partner_key = FB.clean_joker_key(partner_key)
    if not key or not partner_key then return false end
    return FB.hidden_synergy.data[key]
        and FB.hidden_synergy.data[key][partner_key]
        and FB.has_joker_key(partner_key)
end

function FB.secret_pair_active(a, b)
    return FB.can_use_secret_synergies() and FB.has_joker_key(a) and FB.has_joker_key(b)
end

function FB.sold_card_from_context(context)
    if not context then return nil end

    -- Only report a sold card in actual selling contexts.
    -- The old version returned context.card in every context, which can
    -- accidentally make unrelated scoring/retrigger contexts look like sales.
    if not (context.selling_card or context.selling_self) then return nil end

    if type(context.selling_card) == "table" then return context.selling_card end
    if type(context.card) == "table" then return context.card end
    if type(context.selling_self) == "table" then return context.selling_self end
    return nil
end

function FB.hidden_wrap_text(text, max_len)
    text = tostring(text or "")
    max_len = max_len or 34

    local lines = {}
    local current = ""

    for word in text:gmatch("%S+") do
        if current == "" then
            current = word
        elseif #current + #word + 1 <= max_len then
            current = current .. " " .. word
        else
            lines[#lines + 1] = current
            current = word
        end
    end

    if current ~= "" then
        lines[#lines + 1] = current
    end

    if #lines == 0 then
        lines[1] = ""
    end

    return lines
end

function FB.make_hidden_other_loc(key, name, text)
    if not (G and G.localization and G.localization.descriptions) then return end
    G.localization.descriptions.Other = G.localization.descriptions.Other or {}

    local entry = G.localization.descriptions.Other[key] or {}
    entry.name = name
    entry.text = text
    entry.text_parsed = {}

    -- Balatro's generate_card_ui/localize path for `set = "Other"` reads
    -- `text_parsed`, not only `text`. If this is missing, hovering a Joker
    -- crashes with "bad argument #1 to 'ipairs' (table expected, got nil)".
    for _, line in ipairs(text or {}) do
        if loc_parse_string then
            entry.text_parsed[#entry.text_parsed + 1] = loc_parse_string(line)
        else
            -- Defensive fallback. In normal Balatro/Steamodded this should not be used,
            -- but keeping a table here is still safer than leaving text_parsed nil.
            entry.text_parsed[#entry.text_parsed + 1] = line
        end
    end

    G.localization.descriptions.Other[key] = entry
end

function FB.ensure_hidden_synergy_localization()
    FB.make_hidden_other_loc(
        "fb_vision_synergy",
        "Vision",
        {"{C:attention}Has a synergy with #1#{}"}
    )

    FB.make_hidden_other_loc(
        "fb_true_sight_header",
        "True Sight",
        {"{C:attention}With #1#:{}"}
    )

    FB.make_hidden_other_loc(
        "fb_true_sight_line",
        "Secret Effect",
        {"#1#"}
    )
end

function FB.card_is_in_run_joker_area(card)
    return G and G.jokers and card and card.area == G.jokers
end

function FB.safe_loc_key(s)
    s = tostring(s or "unknown")
    s = s:gsub("[^%w_]", "_")
    return s
end

function FB.add_secret_synergy_info(info_queue, card)
    if not info_queue or not FB.card_is_in_run_joker_area(card) then return end
    if not FB.hidden_has_vision() then return end

    local key = FB.raw_key(card)
    local data = key and FB.hidden_synergy.data[key]
    if not data then return end

    local partners = {}

    for partner_key, effects in pairs(data) do
        if effects and #effects > 0 then
            partners[#partners + 1] = partner_key
        end
    end

    if #partners <= 0 then return end

    table.sort(partners, function(a, b)
        return FB.secret_joker_name(a) < FB.secret_joker_name(b)
    end)

    if FB.hidden_has_true_sight() then
        for _, partner_key in ipairs(partners) do
            local partner_name = FB.secret_joker_name(partner_key)
            local loc_key = "fb_true_sight_" .. FB.safe_loc_key(key) .. "_" .. FB.safe_loc_key(partner_key)

            local text = {
                "{C:attention}With " .. partner_name .. ":{}"
            }

            for _, line in ipairs(data[partner_key]) do
                text[#text + 1] = line
            end

            FB.make_hidden_other_loc(loc_key, "True Sight", text)

            info_queue[#info_queue + 1] = {
                key = loc_key,
                set = "Other"
            }
        end
    else
        local names = {}

        for _, partner_key in ipairs(partners) do
            names[#names + 1] = FB.secret_joker_name(partner_key)
        end

        local loc_key = "fb_vision_synergy_" .. FB.safe_loc_key(key)

        FB.make_hidden_other_loc(loc_key, "Vision", {
            "{C:attention}Has a synergy with " .. table.concat(names, ", ") .. "{}"
        })

        info_queue[#info_queue + 1] = {
            key = loc_key,
            set = "Other"
        }
    end
end

function FB.secret_set_slot_flag(card, flag, active, joker_delta, consumable_delta, hand_delta)
    if not card or not card.ability then return end
    card.ability.fb_secret_slot_flags = card.ability.fb_secret_slot_flags or {}
    local was_active = card.ability.fb_secret_slot_flags[flag] == true
    if active and not was_active then
        if joker_delta and joker_delta ~= 0 and FB.safe_change_joker_slots then FB.safe_change_joker_slots(joker_delta) end
        if hand_delta and hand_delta ~= 0 and FB.safe_change_hand_size then FB.safe_change_hand_size(hand_delta) end
        if consumable_delta and consumable_delta ~= 0 and G and G.consumeables and G.consumeables.config then
            G.consumeables.config.card_limit = G.consumeables.config.card_limit + consumable_delta
        end
        card.ability.fb_secret_slot_flags[flag] = true
    elseif not active and was_active then
        if joker_delta and joker_delta ~= 0 and FB.safe_change_joker_slots then FB.safe_change_joker_slots(-joker_delta) end
        if hand_delta and hand_delta ~= 0 and FB.safe_change_hand_size then FB.safe_change_hand_size(-hand_delta) end
        if consumable_delta and consumable_delta ~= 0 and G and G.consumeables and G.consumeables.config then
            G.consumeables.config.card_limit = G.consumeables.config.card_limit - consumable_delta
        end
        card.ability.fb_secret_slot_flags[flag] = nil
    end
end

function FB.sync_secret_synergy_slots(card)
    local key = FB.raw_key(card)
    if key == "bibi" then
        FB.secret_set_slot_flag(card, "bibi_christina_joker_slot", FB.secret_synergy_active(card, "christina"), 1, 0, 0)
    elseif key == "christina" then
        FB.secret_set_slot_flag(card, "christina_bibi_joker_slot", FB.secret_synergy_active(card, "bibi"), 1, 0, 0)
    elseif key == "hetao" then
        FB.secret_set_slot_flag(card, "hetao_cardboard_box_joker_slot", FB.secret_synergy_active(card, "cardboard_box"), 1, 0, 0)
    elseif key == "kulou" then
        FB.secret_set_slot_flag(card, "kulou_diting_slots", FB.secret_synergy_active(card, "diting"), 1, 1, 1)
    else
        return
    end
end

function FB.secret_rarity_bonus(card)
    local r = card and card.config and card.config.center and card.config.center.rarity

    if r == 1 then
        return { x_chips = 1.5 }
    end

    if r == 2 then
        return { x_mult = 1.5 }
    end

    if r == 3 then
        return { x_mult = 2 }
    end

    if r == 4 then
        return { x_chips = 2, x_mult = 3 }
    end

    if r == "fb_exotic" or r == "exotic" or r == "fb_divine" or r == "divine" then
        return { x_chips = 3, x_mult = 5 }
    end

    return {}
end

function FB.secret_is_xchips_joker(card)
    local text = card and card.config and card.config.center and card.config.center.loc_txt and card.config.center.loc_txt.text
    if type(text) == "table" then
        for _, line in ipairs(text) do
            if type(line) == "string" and line:find("X:chips", 1, true) then return true end
        end
    end
    return false
end

function FB.secret_card_has_modifier(card)
    if not card then return false end
    local center = card.config and card.config.center
    return card.edition ~= nil or card.seal ~= nil or (center and center ~= G.P_CENTERS.c_base)
end

function FB.secret_card_has_no_modifier(card)
    return not FB.secret_card_has_modifier(card)
end

function FB.secret_is_gold_or_steel(card)
    return (FB.is_gold and FB.is_gold(card)) or (FB.is_steel and FB.is_steel(card))
end

function FB.secret_has_any_seal(card)
    return card and card.seal ~= nil
end

function FB.secret_card_has_enhancement(card)
    if not (card and card.config and card.config.center) then return false end
    return G and G.P_CENTERS and card.config.center ~= G.P_CENTERS.c_base
end

function FB.secret_card_has_edition(card)
    return card and card.edition ~= nil
end

function FB.secret_card_is_suit(card, suit)
    if not card then return false end

    if card.is_suit then
        local ok, result = pcall(function()
            return card:is_suit(suit, nil, true)
        end)
        if ok then return result == true end
    end

    return card.base and card.base.suit == suit
end

function FB.secret_deck_has_suit(suit)
    local seen = {}
    local zones = {
        G and G.playing_cards,
        G and G.deck and G.deck.cards,
        G and G.hand and G.hand.cards,
        G and G.discard and G.discard.cards,
        G and G.play and G.play.cards
    }

    for _, cards in ipairs(zones) do
        if type(cards) == "table" then
            for _, c in ipairs(cards) do
                if c and not seen[c] then
                    seen[c] = true
                    if FB.secret_card_is_suit(c, suit) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function FB.secret_deck_has_hearts()
    return FB.secret_deck_has_suit("Hearts")
end

function FB.secret_try_evolve_card_once(card, target_key, flag)
    if not (card and card.ability) then return false end
    target_key = FB.clean_joker_key(target_key)
    flag = flag or ("fb_evolving_to_" .. tostring(target_key))

    if card.ability[flag] or FB.is_joker_key(card, target_key) then
        return false
    end

    card.ability[flag] = true
    return FB.secret_evolve_card(card, target_key)
end

FB.food_joker_registry = FB.food_joker_registry or {
    -- Vanilla food jokers
    "gros_michel", "cavendish", "ice_cream", "popcorn", "ramen", "seltzer", "egg", "turtle_bean",

    -- Fabulous Beasts food jokers
    "ambrosia", "ambrosia_blender", "divine_herb", "dog_food", "emergency_rations",
    "food", "food_reserve", "foraged_mushrooms", "heavenly_cumin", "hellspice_hotpot",
    "mooncake", "skewered_kebab", "teacup", "chicken_mushroom_stew", "heavenly_elixirs",
    "hellish_delicacies", "lunchbox_medkit", "mapo_tofu", "moon_palace", "mooncake_cannon"
}

function FB.food_joker_registry_lookup()
    if FB._food_joker_registry_lookup then return FB._food_joker_registry_lookup end

    local lookup = {}
    for _, key in ipairs(FB.food_joker_registry or {}) do
        lookup[FB.clean_joker_key(key)] = true
    end

    FB._food_joker_registry_lookup = lookup
    return lookup
end

function FB.is_food_joker(card_or_key)
    local key = FB.raw_key(card_or_key)
    if not key then return false end
    return FB.food_joker_registry_lookup()[key] == true
end

function FB.random_food_joker_center_key(seed)
    local pool = {}

    for _, key in ipairs(FB.food_joker_registry or {}) do
        local center_key = FB.center_key_for_joker(key)
        if center_key then
            pool[#pool + 1] = center_key
        end
    end

    if #pool <= 0 then return nil end

    if pseudorandom_element and pseudoseed then
        return pseudorandom_element(pool, pseudoseed(seed or "fb_food_joker"))
    end

    return pool[math.random(#pool)]
end

function FB.create_random_food_joker(seed)
    local center_key = FB.random_food_joker_center_key(seed)
    if not center_key then return false end

    if SMODS and SMODS.add_card then
        SMODS.add_card({ key = center_key, area = G and G.jokers })
        return true
    end

    return false
end

function FB.secret_evolve_card(card, target_key)
    local full = FB.full_joker_key(target_key)
    if not (card and G and G.P_CENTERS and G.P_CENTERS[full]) then return false end
    G.E_MANAGER:add_event(Event({
        func = function()
            card:set_ability(G.P_CENTERS[full], nil, true)
            card:juice_up(0.5, 0.5)
            return true
        end
    }))
    return true
end

function FB.secret_create_joker(key)
    local center_key = FB.center_key_for_joker(key)
    if not center_key then return false end

    if SMODS and SMODS.add_card then
        SMODS.add_card({ key = center_key, area = G and G.jokers })
        return true
    end

    if FB.create_joker then
        return FB.create_joker(FB.clean_joker_key(center_key))
    end

    return false
end

function FB.secret_force_create_joker(key)
    local center_key = FB.center_key_for_joker(key)
    if not center_key or not (G and G.jokers and G.jokers.config and SMODS and SMODS.add_card) then
        return FB.secret_create_joker(key)
    end

    local old_limit = G.jokers.config.card_limit or 0
    local current_count = #(G.jokers.cards or {})
    local bumped = false

    if current_count >= old_limit then
        G.jokers.config.card_limit = current_count + 1
        bumped = true
    end

    SMODS.add_card({ key = center_key, area = G.jokers })

    -- Restore the real capacity after the card is created. The Joker remains,
    -- but the player is now over capacity until they free slots normally.
    if bumped then
        G.jokers.config.card_limit = old_limit
    end

    return true
end

function FB.secret_destroy_card(card, context)
    if not card then return false end

    if FB.is_joker_key and FB.is_joker_key(card, "dijiang") then
        FB.secret_handle_dijiang_destroy(card, context or {})
    end

    if FB.queue_destroy then
        FB.queue_destroy(card)
        if FB.resolve_or_defer_queued_actions then FB.resolve_or_defer_queued_actions(context or {}) end
        return true
    end
    if card.start_dissolve then card:start_dissolve(); return true end
    return false
end

function FB.secret_to_number(value, fallback)
    fallback = fallback or 0

    if type(value) == "number" then
        return value
    end

    if FB.num then
        local ok, result = pcall(FB.num, value, fallback)
        if ok and type(result) == "number" then
            return result
        end
    end

    if type(value) == "table" then
        if value.to_number then
            local ok, result = pcall(function() return value:to_number() end)
            if ok and type(result) == "number" then return result end
        end

        if value.toNumber then
            local ok, result = pcall(function() return value:toNumber() end)
            if ok and type(result) == "number" then return result end
        end

        if value.array and value.sign then
            local s = tostring(value)
            local n = tonumber(s)
            if n then return n end
        end
    end

    local n = tonumber(value)
    if n then return n end

    return fallback
end

function FB.secret_nonnegative_number(value, fallback)
    local n = FB.secret_to_number(value, fallback or 0)
    if n < 0 then return 0 end
    return n
end

function FB.secret_handle_dijiang_destroy(dijiang, context)
    if not dijiang then return false end
    if not FB.is_joker_key(dijiang, "dijiang") then return false end
    if not FB.secret_pair_active("dijiang", "hundun") then return false end

    G.GAME = G.GAME or {}
    if G.GAME.fb_hundun_dijiang_destroyed then return false end
    G.GAME.fb_hundun_dijiang_destroyed = true

    local hundun = FB.find_joker and FB.find_joker("hundun")
    if hundun then
        if hundun.ability then
            hundun.ability.fb_hundun_dijiang_destroyed = true
        end

        if hundun ~= dijiang then
            if FB.queue_destroy then
                FB.queue_destroy(hundun)
            elseif hundun.start_dissolve then
                hundun:start_dissolve()
            end
        end
    end

    FB.secret_force_create_joker("rainbow_mountain_range")

    if FB.resolve_or_defer_queued_actions then
        FB.resolve_or_defer_queued_actions(context or {})
    end

    return true
end

function FB.install_hidden_synergy_destroy_hooks()
    if FB.hidden_synergy.destroy_hooks_installed then return end
    FB.hidden_synergy.destroy_hooks_installed = true

    if FB.queue_self_destroy then
        local old_queue_self_destroy = FB.queue_self_destroy
        FB.queue_self_destroy = function(card, ...)
            if FB.is_joker_key and FB.is_joker_key(card, "dijiang") then
                FB.secret_handle_dijiang_destroy(card, select(1, ...) or {})
            end
            return old_queue_self_destroy(card, ...)
        end
    end

    if FB.queue_destroy then
        local old_queue_destroy = FB.queue_destroy
        FB.queue_destroy = function(card, ...)
            if FB.is_joker_key and FB.is_joker_key(card, "dijiang") then
                FB.secret_handle_dijiang_destroy(card, select(1, ...) or {})
            end
            return old_queue_destroy(card, ...)
        end
    end

    if FB.destroy then
        local old_destroy = FB.destroy
        FB.destroy = function(card, ...)
            if FB.is_joker_key and FB.is_joker_key(card, "dijiang") then
                FB.secret_handle_dijiang_destroy(card, select(1, ...) or {})
            end
            return old_destroy(card, ...)
        end
    end
end

function FB.install_hidden_synergy_card_debuff_hook()
    if not Card or not Card.set_debuff then return end
    if FB.hidden_synergy.card_debuff_hook_installed then return end
    FB.hidden_synergy.card_debuff_hook_installed = true

    local old_set_debuff = Card.set_debuff

    function Card:set_debuff(should_debuff, ...)
        local ret = old_set_debuff(self, should_debuff, ...)

        if should_debuff
        and self
        and self.debuff then
            if self.juice_up then self:juice_up(0.5, 0.5) end

            if FB.is_joker_key and FB.is_joker_key(self, "dijiang")
            and FB.secret_pair_active
            and FB.secret_pair_active("dijiang", "hundun") then
                local hundun = FB.find_joker and FB.find_joker("hundun")
                if hundun and not hundun.debuff then
                    old_set_debuff(hundun, true)
                end
            end
        end

        return ret
    end
end

function FB.secret_on_ante_complete(card, context)
    return context and context.end_of_round and G and G.GAME and G.GAME.blind and G.GAME.blind.boss
end


function FB.secret_sanitize_effect_return(ret, context)
    if type(ret) ~= "table" then return ret end

    local is_retrigger_return = ret.repetitions ~= nil
        or (context and context.retrigger_joker_check)

    if is_retrigger_return then
        local score_keys = {
            "chips", "h_chips", "chip_mod",
            "mult", "h_mult", "mult_mod",
            "x_chips", "xchips", "Xchip_mod", "x_chips_mod",
            "x_mult", "xmult", "Xmult", "x_mult_mod",
            "e_chips", "ee_chips", "e_mult", "ee_mult"
        }

        for _, k in ipairs(score_keys) do
            ret[k] = nil
        end
    end

    return ret
end

function FB.run_hidden_secret_effects(key, self, card, context, normal_return)
    key = FB.clean_joker_key(key)
    if not key or not card or not context then return normal_return end

    FB.sync_secret_synergy_slots(card)

    -- Tianlu + Bixie: Tianlu stops eating money at blind start; Cintamani sales may evolve Tianlu.
    if key == "tianlu" and FB.secret_synergy_active(card, "bixie") then
        card.ability.extra = card.ability.extra or {}

        if context.setting_blind and not context.blueprint then
            local d = FB.secret_nonnegative_number(G.GAME and G.GAME.dollars, 0)
            card.ability.extra.xchips = (card.ability.extra.xchips or 1) + d * 0.1

            return {
                message = "Vision!",
                colour = G.C.CHIPS,
                card = card
            }
        end

        local sold_card = FB.sold_card_from_context(context)
        if sold_card
        and FB.is_joker_key(sold_card, "cintamani")
        and not context.blueprint then
            if pseudorandom("fb_tianlu_cintamani_true_form") < 0.01 then
                FB.secret_try_evolve_card_once(card, "tianlu_true_form", "fb_tianlu_true_form_from_cintamani")

                return {
                    message = "True Form!",
                    colour = G.C.PURPLE,
                    card = card
                }
            end
        end
    end

    -- Bixie + Tianlu / Sibuxiang.
    if key == "bixie" and FB.can_use_secret_synergies() then
        card.ability.extra = card.ability.extra or {}

        if FB.has_joker_key("tianlu") and context.discard and not context.blueprint then
            card.ability.extra.xmult = (card.ability.extra.xmult or 1) + 1
            return { message = "X" .. tostring(card.ability.extra.xmult), colour = G.C.MULT, card = card }
        end

        local sold_card = FB.sold_card_from_context(context)
        if sold_card and FB.is_joker_key(sold_card, "tianlu") and not context.blueprint then
            FB.secret_try_evolve_card_once(card, "bixie_true_form", "fb_bixie_true_form_from_tianlu")

            if FB.secret_synergy_active(card, "sibuxiang") then
                local sibuxiang = FB.find_joker("sibuxiang")
                FB.secret_destroy_card(sibuxiang, context)
            end

            return { message = "True Form!", colour = G.C.PURPLE, card = card }
        end
    end

    -- Finish the ante to obtain Qilin Sibuxiang after the Tianlu/Bixie/Sibuxiang secret.
    if G and G.GAME and G.GAME.fb_make_qilin_sibuxiang_after_ante and FB.secret_on_ante_complete(card, context) and not context.blueprint then
        G.GAME.fb_make_qilin_sibuxiang_after_ante = nil
        FB.secret_create_joker("qilin_sibuxiang")
        return { message = "Qilin!", colour = G.C.PURPLE, card = card }
    end

    -- Jade Bird + Bixie.
    if key == "jade_bird" and FB.secret_synergy_active(card, "bixie") and not context.blueprint then
        local sold_card = FB.sold_card_from_context(context)
        if context.selling_self or sold_card == card then
            local bixie = FB.find_joker("bixie")
            local sibuxiang = FB.find_joker("sibuxiang")
            if sibuxiang then
                sibuxiang.debuff = true
                sibuxiang.ability = sibuxiang.ability or {}
                sibuxiang.ability.fb_jade_bird_debuffed = true
                G.GAME.fb_jade_bird_restore_bixie = true
            end
            FB.secret_destroy_card(bixie, context)
            FB.secret_destroy_card(card, context)
            return { message = "Jade!", colour = G.C.PURPLE, card = card }
        end
        if G and G.GAME and G.GAME.fb_jade_bird_restore_bixie and FB.secret_on_ante_complete(card, context) then
            G.GAME.fb_jade_bird_restore_bixie = nil
            local sibuxiang = FB.find_joker("sibuxiang")
            if sibuxiang then
                sibuxiang.debuff = false
                FB.secret_evolve_card(sibuxiang, "qilin_sibuxiang")
            end
            FB.secret_create_joker("bixie")
            return { message = "Restored!", colour = G.C.PURPLE, card = card }
        end
    end

    -- Dijiang self-destructs when there are no Hearts left anywhere in the deck.
    -- If Hundun is paired with it, the destroy hook below handles Hundun and Rainbow Mountain Range.
    if key == "dijiang" and not context.blueprint then
        card.ability = card.ability or {}
        if not card.ability.fb_dijiang_self_destructing and not FB.secret_deck_has_hearts() then
            card.ability.fb_dijiang_self_destructing = true
            FB.secret_destroy_card(card, context)
            return { message = "No Hearts!", colour = G.C.RED, card = card }
        end
    end

    -- Hundun + Dijiang.
    if key == "hundun" and FB.secret_synergy_active(card, "dijiang") then
        local dijiang = FB.find_joker("dijiang")

        if dijiang and dijiang.debuff and not card.debuff then
            card.debuff = true
        end

        if context and (context.individual or context.joker_main)
        and not context.end_of_round
        and not context.setting_blind then
            local ret = normal_return or {}
            if not ret.repetitions then
                ret.x_mult = (ret.x_mult or 1) * 1.5
                ret.card = ret.card or card
                normal_return = ret
            end
        end

    end

    if key == "dijiang" and FB.secret_synergy_active(card, "hundun") then
        if FB.is_scoring_individual(context) and context.other_card and context.other_card:is_suit("Hearts") then
            local ret = normal_return or {}
            ret.mult = (ret.mult or 0) + FB.secret_nonnegative_number(hand_chips, 0)
            ret.card = ret.card or card
            normal_return = ret
        end
    end

    -- Chugou + Shanque / Shanque + Chugou.
    if key == "chugou" and FB.secret_synergy_active(card, "shanque") then
        local triggered = (FB.is_scoring_individual(context) and context.other_card and context.other_card ~= card) or (context.post_trigger and context.other_card and context.other_card ~= card)
        if triggered and not context.blueprint then
            local payout = math.max(1, math.floor(1.1))
            FB.try_add_dollars(payout)
            return { message = "$" .. payout, colour = G.C.MONEY, card = card }
        end
    end

    if key == "shanque" and FB.secret_synergy_active(card, "chugou") then
        card.ability.extra = card.ability.extra or {}
        if context.before and not context.blueprint then
            card.ability.extra.fb_shanque_chugou_xmult = 1
        end
        if context.post_trigger and context.other_card and FB.is_joker_key(context.other_card, "chugou") and not context.blueprint then
            card.ability.extra.fb_shanque_chugou_xmult = (card.ability.extra.fb_shanque_chugou_xmult or 1) * 1.1
            return { message = "X1.1", colour = G.C.MULT, card = card }
        end
        if FB.is_scoring_joker_main(context) then
            local x = card.ability.extra.fb_shanque_chugou_xmult or 1
            if x ~= 1 then
                return { x_mult = x, card = card }
            end
        end
    end

    -- Diting + Kulou.
    if key == "diting" and FB.secret_synergy_active(card, "kulou") and FB.main_end_of_round_once and FB.main_end_of_round_once(card, context, "fb_diting_kulou_secret") then
        local kulou = FB.find_joker("kulou")
        if kulou and kulou.ability and kulou.ability.extra then
            kulou.ability.extra.xmult = (kulou.ability.extra.xmult or 1) + 1
            return { message = "Kulou X" .. tostring(kulou.ability.extra.xmult), colour = G.C.MULT, card = card }
        end
    end

    -- Fuzai + Hetao food X3; Hetao + Fuzai same effect.
    if (key == "fuku_fuzai" or key == "hetao") and FB.secret_synergy_active(card, key == "fuku_fuzai" and "hetao" or "fuku_fuzai") then
        if context and context.retrigger_joker_check and context.other_card and FB.is_food_joker and FB.is_food_joker(context.other_card) then
            local ret = normal_return or {}
            ret.message = ret.message or "X3 Food"
            ret.colour = ret.colour or G.C.MULT
            ret.card = ret.card or card
            normal_return = ret
        end
    end

    -- Hetao + Dreamscape / Cardboard Box.
    if key == "hetao" and FB.secret_synergy_active(card, "dreamscape") then
        if context and context.retrigger_joker_check and context.other_card and context.other_card.edition then
            local ret = normal_return or {}
            -- Same rule: retrigger returns should stay retrigger-only.
            ret.message = ret.message or "Dreamscape"
            ret.colour = ret.colour or G.C.PURPLE
            ret.card = ret.card or card
            normal_return = ret
        end
    end

    -- Tuye Tony + Sibuxiang / Zhanhu.
    if key == "tuye_tony" and FB.secret_synergy_active(card, "sibuxiang") and FB.is_scoring_joker_main(context) then
        local xchips = 1
        local xmult = 1

        for _, joker in ipairs(FB.joker_cards()) do
            local bonus = FB.secret_rarity_bonus(joker)

            if bonus.x_chips then
                xchips = xchips * bonus.x_chips
            end

            if bonus.x_mult then
                xmult = xmult * bonus.x_mult
            end
        end

        return {
            x_chips = xchips,
            x_mult = xmult,
            card = card
        }
    end
    if key == "tuye_tony" and FB.secret_synergy_active(card, "zhanhu") then
        if context and context.retrigger_joker_check and context.other_card and context.other_card ~= card and FB.secret_is_xchips_joker(context.other_card) and FB.once_joker_retrigger(card, context, "tuye_tony_zhanhu") then
            return { repetitions = 1, card = card }
        end
    end

    -- Bibi / Christina / Lord Phoenix / Jinchi Dapeng cluster.
    if key == "christina" then
        if FB.is_card_repetition
        and FB.is_card_repetition(context)
        and context.cardarea == G.play
        and context.other_card
        and FB.secret_card_has_edition(context.other_card) then
            local ret = normal_return or {}
            ret.repetitions = (ret.repetitions or 0) + 1
            ret.card = ret.card or card
            return ret
        end
    end

    if key == "bibi" and FB.secret_synergy_active(card, "lord_phoenix") then
        if FB.is_scoring_individual(context)
        and context.other_card
        and not FB.secret_card_has_enhancement(context.other_card) then
            return { x_mult = 2, card = card }
        end
    end
    if key == "christina" and FB.secret_synergy_active(card, "jinchi_dapeng") then
        if FB.is_card_repetition and FB.is_card_repetition(context) and context.cardarea == G.play and FB.is_stone and FB.is_stone(context.other_card) then
            return { repetitions = #((G.play and G.play.cards) or {}), card = card }
        end
    end
    if (key == "lord_phoenix" or key == "jinchi_dapeng") and FB.secret_synergy_active(card, key == "lord_phoenix" and "jinchi_dapeng" or "lord_phoenix") then
        local safe = FB.secret_pair_active("bibi", "christina")
        local other = FB.find_joker(key == "lord_phoenix" and "jinchi_dapeng" or "lord_phoenix")
        if other then
            other.debuff = not safe
            card.debuff = not safe
        end
    end

    -- Bajin + Erliang.
    if key == "bajin" and FB.secret_synergy_active(card, "erliang") then
        if context and context.retrigger_joker_check and context.other_card and context.other_card ~= card and FB.is_food_joker and FB.is_food_joker(context.other_card) and FB.once_joker_retrigger(card, context, "bajin_erliang_food") then
            return { repetitions = 1, card = card }
        end
    end
    if key == "erliang" and FB.secret_synergy_active(card, "bajin") and context.setting_blind and not context.blueprint then
        if FB.create_random_food_joker("erliang_bajin_secret") then
            return { message = "Food!", colour = G.C.GREEN, card = card }
        end
    end

    -- Qiongqi protection / eternal pair.
    if key == "qiongqi" then
        if context.setting_blind and not context.blueprint then
            for _, joker in ipairs(FB.joker_cards()) do
                if FB.is_joker_key(joker, "taowu") and FB.secret_pair_active("qiongqi", "taowu") then
                    joker.debuff = false
                    joker.ability.fb_qiongqi_debuffed = nil
                    joker.ability.eternal = true
                    card.ability.eternal = true
                elseif FB.is_joker_key(joker, "taotie") and FB.secret_pair_active("qiongqi", "taotie") then
                    joker.debuff = false
                    joker.ability.fb_qiongqi_debuffed = nil
                end
            end
        end
    end

    -- Jinjiao + Yinjiao.
    if key == "jinjiao" and FB.secret_synergy_active(card, "yinjiao") then
        if FB.is_card_repetition(context) and (FB.secret_is_gold_or_steel(context.other_card) or FB.secret_has_any_seal(context.other_card)) then
            return { repetitions = 2, card = card }
        end
    end
    if key == "yinjiao" and FB.secret_synergy_active(card, "jinjiao") then
        if FB.is_card_repetition(context) and (FB.secret_is_gold_or_steel(context.other_card) or FB.secret_has_any_seal(context.other_card)) then
            return { repetitions = 2, card = card }
        end
        if FB.is_scoring_individual(context) and FB.secret_is_gold_or_steel(context.other_card) then
            return { x_chips = 2, x_mult = 2, card = card }
        end
    end

    return normal_return
end

function FB.install_hidden_synergy_joker_wrapper()
    FB.install_hidden_synergy_card_debuff_hook()
    FB.install_hidden_synergy_destroy_hooks()
    if not (SMODS and SMODS.Joker) then return end
    if FB.hidden_synergy.wrapper_installed then return end
    FB.hidden_synergy.wrapper_installed = true

    local old_joker = SMODS.Joker

    SMODS.Joker = function(def)
        if def and def.key then
            local joker_key = FB.clean_joker_key(def.key)

            local old_loc_vars = def.loc_vars
            def.loc_vars = function(self, info_queue, card)
                local ret
                if old_loc_vars then
                    ret = old_loc_vars(self, info_queue, card)
                end
                FB.add_secret_synergy_info(info_queue, card)
                return ret or { vars = {} }
            end

            local old_calculate = def.calculate
            def.calculate = function(self, card, context)
                local normal_return

                if joker_key == "tianlu"
                and context
                and context.setting_blind
                and not context.blueprint
                and FB.secret_synergy_active(card, "bixie") then
                    return FB.secret_sanitize_effect_return(
                        FB.run_hidden_secret_effects(joker_key, self, card, context, nil),
                        context
                    )
                end

                if old_calculate then
                    normal_return = old_calculate(self, card, context)
                end

                return FB.secret_sanitize_effect_return(FB.run_hidden_secret_effects(joker_key, self, card, context, normal_return), context)
            end

            local old_add = def.add_to_deck
            def.add_to_deck = function(self, card, from_debuff)
                if old_add then old_add(self, card, from_debuff) end
                FB.sync_secret_synergy_slots(card)
            end

            local old_remove = def.remove_from_deck
            def.remove_from_deck = function(self, card, from_debuff)
                if card and card.ability and card.ability.fb_secret_slot_flags then
                    for flag, active in pairs(card.ability.fb_secret_slot_flags) do
                        if active then
                            if flag == "bibi_christina_joker_slot" or flag == "christina_bibi_joker_slot" or flag == "hetao_cardboard_box_joker_slot" then
                                FB.secret_set_slot_flag(card, flag, false, 1, 0, 0)
                            elseif flag == "kulou_diting_slots" then
                                FB.secret_set_slot_flag(card, flag, false, 1, 1, 1)
                            end
                        end
                    end
                end
                if old_remove then old_remove(self, card, from_debuff) end
            end
        end

        return old_joker(def)
    end
end

FB.install_hidden_synergy_joker_wrapper()
FB.install_hidden_synergy_card_debuff_hook()
FB.install_hidden_synergy_destroy_hooks()
