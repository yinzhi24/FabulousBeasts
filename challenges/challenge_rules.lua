---@diagnostic disable: undefined-global
-- Fabulous Beasts: shared challenge helpers/hooks.
-- Built-in SMODS challenge features are used wherever possible.

FB = FB or {}
FB.challenge_rules = FB.challenge_rules or {}

function FB.challenge_rule(id, value, no_ui)
    local t = { id = id }
    if value ~= nil then t.value = value end
    if no_ui ~= nil then t.no_ui = no_ui end
    return t
end

function FB.challenge_modifier(id, value)
    return { id = id, value = value }
end

function FB.challenge_has_rule(id)
    return G
        and G.GAME
        and G.GAME.modifiers
        and G.GAME.modifiers[id] == true
end

function FB.challenge_modifier_value(id, fallback)
    if G and G.GAME and G.GAME.modifiers and G.GAME.modifiers[id] ~= nil then
        return G.GAME.modifiers[id]
    end
    return fallback
end

-- ---------- Custom challenge rule text ----------
-- SMODS custom challenge rules use G.localization.misc.v_text["ch_c_<id>"]

FB.challenge_text = {
    fb_final_trial = {
        "The deification trial awaits you"
    },

    fb_real_trial = {
        "Trying to ascend beyond Heaven, eh? Get ready for eternal suffering!"
    },

    fb_win_ante = {
        "Winning ante is {C:attention}#1#{}"
    },

    fb_gl = {
        "{C:dark_edition}Good luck{}"
    },

    fb_zero_base_score = {
        "Base {C:chips}Chips{} and {C:mult}Mult{} start at {C:attention}0{}"
    },

    fb_start_mult_aces = {
        "Start with all {C:attention}Aces{} as {C:mult}Mult Cards{}"
    },

    fb_start_blue_seal_twos = {
        "Start with all {C:attention}2s{} having {C:attention}Blue Seals{}"
    },

    fb_start_purple_seal_threes = {
        "Start with all {C:attention}3s{} having {C:attention}Purple Seals{}"
    },

    fb_standard_packs_only = {
        "Only {C:attention}Standard Packs{} appear as Booster Packs"
    },

    fb_spectral_shop = {
        "{C:spectral}Spectral{} cards can appear in the shop"
    },

    no_shop_jokers = {
        "{C:attention}Jokers{} do not appear in the shop"
    },

    fb_no_boosters = {
        "{C:red}Booster Packs{} do not appear"
    },

    fb_no_spectral = {
        "{C:spectral}Spectral{} cards do not appear"
    },

    fb_nine_heavens = {
        "Gain a {C:attention}9th Heaven{} after each round for {C:attention}9{} rounds"
    },

    fb_sell_jokers_after_round = {
        "At end of round, sell all non-Eternal Jokers for {C:money}3X{} their sell value"
    },

    fb_base_after_base = {
        "Blind size increases each clear"
    },

    fb_base_after_base_alt = {
        "Skipping increases future clear scaling"
    },

    fb_out_of_spotlight = {
        "Only non-Legendary {C:attention}Fabulous Beasts{} Jokers may appear"
    },

    fb_ascension_positive_decks_sleeves = {
        "All positive Deck and Sleeve effects are active",
        "{C:attention}8{} hands, {C:attention}8{} discards, {C:attention}8{} Joker slots, start with {C:money}$16{}"
    },

    fb_card_selection_plus_1 = {
        "You may play and discard up to {C:attention}6{} cards"
    },

    fb_difficulty_0 = {
        "Difficulty: {X:inactive,C:white}Free{}"
    },

    fb_difficulty_1 = {
        "Difficulty: {X:blue,C:white}Easy{}"
    },

    fb_difficulty_2 = {
        "Difficulty: {X:green,C:white}Normal{}"
    },

    fb_difficulty_3 = {
        "Difficulty: {X:money,C:white}Hard{}"
    },

    fb_difficulty_4 = {
        "Difficulty: {X:attention,C:white}Extreme{}"
    },

    fb_difficulty_5 = {
        "Difficulty: {X:red,C:white}Insane{}"
    },

    fb_difficulty_6 = {
        "Difficulty: {X:legendary,C:white}Absurd{}"
    },

    fb_difficulty_7 = {
        "Difficulty: {X:purple,C:white}Professional{}"
    },

    fb_difficulty_8 = {
        "Difficulty: {X:black,C:white}Masochistic{}"
    },

    fb_difficulty_9 = {
        "Difficulty: {C:dark_edition}HELP ME :({}"
    },

    fb_difficulty_x = {
        "Difficulty: {C:dark_edition}Go see a therapist, and touch grass for real{}"
    }
}

if SMODS and SMODS.current_mod then
    SMODS.current_mod.process_loc_text = function()
        G.localization.misc = G.localization.misc or {}
        G.localization.misc.v_text = G.localization.misc.v_text or {}

        for id, text in pairs(FB.challenge_text or {}) do
            G.localization.misc.v_text["ch_c_" .. id] = text
        end
    end
end

-- ---------- Built-in deck.cards helpers ----------

FB.challenge_vanilla_suits = { "S", "H", "D", "C" }
FB.challenge_vanilla_ranks = { "A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2" }

function FB.challenge_standard_deck(args)
    args = args or {}
    local cards = {}

    for _, suit in ipairs(FB.challenge_vanilla_suits) do
        for _, rank in ipairs(FB.challenge_vanilla_ranks) do
            local card = { s = suit, r = rank }

            if args.mult_aces and rank == "A" then
                card.e = "m_mult"
            end

            if args.blue_seal_twos and rank == "2" then
                card.g = "Blue"
            end

            if args.purple_seal_threes and rank == "3" then
                card.g = "Purple"
            end

            cards[#cards + 1] = card
        end
    end

    return {
        type = "Challenge Deck",
        cards = cards
    }
end

-- ---------- Restriction helpers ----------
-- Reminder: SMODS docs say banned_cards can ban Jokers, consumables, vouchers,
-- and booster packs. banned_other only supports blinds.

FB.challenge_bans = FB.challenge_bans or {}

FB.challenge_bans.vouchers_shop_breakers = {
    id = "v_overstock_norm",
    ids = {
        "v_overstock_norm", "v_overstock_plus",
        "v_reroll_surplus", "v_reroll_glut",
        "v_liquidation", "v_clearance_sale",
        "v_hieroglyph", "v_petroglyph",
        "v_directors_cut", "v_retcon",
        "v_antimatter", "v_blank",
        "v_magic_trick", "v_illusion",
        "v_crystal_ball",
        "v_tarot_merchant", "v_tarot_tycoon",
        "v_planet_merchant", "v_planet_tycoon",
        "v_omen_globe"
    }
}

FB.challenge_bans.vouchers_booster_breakers = {
    id = "v_tarot_merchant",
    ids = {
        "v_tarot_merchant", "v_tarot_tycoon",
        "v_planet_merchant", "v_planet_tycoon",
        "v_overstock_norm", "v_overstock_plus",
        "v_crystal_ball", "v_omen_globe"
    }
}

FB.challenge_bans.vouchers_economy_breakers = {
    id = "v_seed_money",
    ids = {
        "v_seed_money", "v_money_tree",
        "v_clearance_sale", "v_liquidation",
        "v_reroll_surplus", "v_reroll_glut"
    }
}

FB.challenge_bans.vouchers_hand_breakers = {
    id = "v_grabber",
    ids = {
        "v_grabber", "v_nacho_tong",
        "v_wasteful", "v_recyclomancy",
        "v_hieroglyph", "v_petroglyph"
    }
}

FB.challenge_bans.boosters_non_standard = {
    id = "p_arcana_normal_1",
    ids = {
        "p_arcana_normal_1", "p_arcana_normal_2", "p_arcana_normal_3", "p_arcana_normal_4",
        "p_arcana_jumbo_1", "p_arcana_jumbo_2",
        "p_arcana_mega_1", "p_arcana_mega_2",
        "p_celestial_normal_1", "p_celestial_normal_2", "p_celestial_normal_3", "p_celestial_normal_4",
        "p_celestial_jumbo_1", "p_celestial_jumbo_2",
        "p_celestial_mega_1", "p_celestial_mega_2",
        "p_spectral_normal_1", "p_spectral_normal_2",
        "p_spectral_jumbo_1",
        "p_spectral_mega_1",
        "p_buffoon_normal_1", "p_buffoon_normal_2",
        "p_buffoon_jumbo_1",
        "p_buffoon_mega_1"
    }
}

FB.challenge_bans.boosters_all = {
    id = "p_standard_normal_1",
    ids = {
        "p_standard_normal_1", "p_standard_normal_2", "p_standard_normal_3", "p_standard_normal_4",
        "p_standard_jumbo_1", "p_standard_jumbo_2",
        "p_standard_mega_1", "p_standard_mega_2",
        "p_arcana_normal_1", "p_arcana_normal_2", "p_arcana_normal_3", "p_arcana_normal_4",
        "p_arcana_jumbo_1", "p_arcana_jumbo_2",
        "p_arcana_mega_1", "p_arcana_mega_2",
        "p_celestial_normal_1", "p_celestial_normal_2", "p_celestial_normal_3", "p_celestial_normal_4",
        "p_celestial_jumbo_1", "p_celestial_jumbo_2",
        "p_celestial_mega_1", "p_celestial_mega_2",
        "p_spectral_normal_1", "p_spectral_normal_2",
        "p_spectral_jumbo_1",
        "p_spectral_mega_1",
        "p_buffoon_normal_1", "p_buffoon_normal_2",
        "p_buffoon_jumbo_1",
        "p_buffoon_mega_1"
    }
}

FB.challenge_bans.tags_joker_breakers = {
    id = "tag_uncommon",
    ids = {
        "tag_uncommon", "tag_rare", "tag_negative",
        "tag_foil", "tag_holographic", "tag_polychrome",
        "tag_buffoon", "tag_top_up"
    }
}

FB.challenge_bans.tags_booster_breakers = {
    id = "tag_standard",
    ids = {
        "tag_standard", "tag_charm", "tag_meteor",
        "tag_ethereal", "tag_buffoon"
    }
}

FB.challenge_bans.tags_economy_breakers = {
    id = "tag_investment",
    ids = {
        "tag_investment", "tag_coupon",
        "tag_double", "tag_d_six"
    }
}

FB.challenge_bans.joker_creation_breakers = {
    id = "c_judgement",
    ids = {
        "c_judgement", "c_wraith", "c_soul",
        "j_cartomancer", "j_certificate", "j_dna", "j_marble", "j_perkeo",
        "j_fb_qilin_egg", "j_fb_rigged_video_game", "j_fb_shi_qilin"
    }
}

FB.challenge_bans.joker_slot_breakers = {
    id = "j_fb_album_cover",
    ids = {
        "j_fb_album_cover", "j_fb_alternate_album_cover",
        "j_fb_paw_hole_cave", "j_fb_erliang",
        "v_antimatter"
    }
}

FB.challenge_bans.hand_discard_breakers = {
    id = "j_fb_emergency_rations",
    ids = {
        "j_fb_emergency_rations",
        "j_burglar", "j_drunkard", "j_merry_andy", "j_troubadour", "j_burnt",
        "j_fb_diting", "j_fb_oxen_cart", "j_fb_dew_cloud"
    }
}


function FB.challenge_is_legendary_plus_rarity(rarity)
    if type(rarity) == "number" then
        return rarity >= 4
    end

    rarity = tostring(rarity or ""):lower()

    return rarity == "legendary"
        or rarity == "exotic"
        or rarity == "divine"
        or rarity == "fb_exotic"
        or rarity == "fb_divine"
        or rarity == "fb_legendary"
end

function FB.challenge_is_out_of_spotlight_joker_key(key)
    local center = key and G and G.P_CENTERS and G.P_CENTERS[key]
    if not center or center.set ~= "Joker" then return false end

    -- Only normal Fabulous Beasts Jokers are allowed.
    if not tostring(key):find("^j_fb_") then return false end

    -- Legendary, Exotic, Divine, and any future Legendary+ rarity are banned.
    if FB.challenge_is_legendary_plus_rarity(center.rarity) then return false end

    return center.unlocked ~= false and not center.demo and not center.no_doe
end

function FB.challenge_random_out_of_spotlight_joker_key(seed)
    local eligible = {}

    if G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker then
        for _, center in ipairs(G.P_CENTER_POOLS.Joker) do
            if center and center.key and FB.challenge_is_out_of_spotlight_joker_key(center.key) then
                eligible[#eligible + 1] = center.key
            end
        end
    elseif G and G.P_CENTERS then
        for key, center in pairs(G.P_CENTERS) do
            if center and FB.challenge_is_out_of_spotlight_joker_key(key) then
                eligible[#eligible + 1] = key
            end
        end
    end

    if #eligible <= 0 then return nil end
    return pseudorandom_element(eligible, pseudoseed(seed or "fb_out_of_spotlight_shop"))
end

function FB.challenge_out_of_spotlight_replace_shop_joker(_type, area, forced_key)
    if not FB.challenge_has_rule("fb_out_of_spotlight") then
        return forced_key
    end

    -- This rule only affects the shop Joker area. It does not create a giant banned list,
    -- so the challenge menu stays clean instead of showing the custom-deck/bans wall.
    if not FB.challenge_is_shop_joker(_type, area) then
        return forced_key
    end

    if forced_key and FB.challenge_is_out_of_spotlight_joker_key(forced_key) then
        return forced_key
    end

    return FB.challenge_random_out_of_spotlight_joker_key("fb_out_of_spotlight_shop") or forced_key
end

function FB.challenge_restrictions(opts)
    opts = opts or {}
    local banned_cards = {}
    local banned_tags = {}
    local banned_other = {}

    local function add_card(row)
        if row then banned_cards[#banned_cards + 1] = row end
    end

    local function add_tag(row)
        if row then banned_tags[#banned_tags + 1] = row end
    end

    local function add_blind(id)
        if id then banned_other[#banned_other + 1] = { id = id, type = "blind" } end
    end


    if opts.no_non_standard_boosters then add_card(FB.challenge_bans.boosters_non_standard) end
    if opts.no_boosters then add_card(FB.challenge_bans.boosters_all) end

    if opts.no_shop_joker_bypass then
        add_tag(FB.challenge_bans.tags_joker_breakers)
        add_card(FB.challenge_bans.vouchers_shop_breakers)
        add_card(FB.challenge_bans.joker_creation_breakers)
        add_card(FB.challenge_bans.joker_slot_breakers)
    end

    if opts.no_booster_bypass then
        add_tag(FB.challenge_bans.tags_booster_breakers)
        add_card(FB.challenge_bans.vouchers_booster_breakers)
    end

    if opts.no_economy_bypass then
        add_tag(FB.challenge_bans.tags_economy_breakers)
        add_card(FB.challenge_bans.vouchers_economy_breakers)
    end

    if opts.no_hand_discard_bypass then
        add_card(FB.challenge_bans.hand_discard_breakers)
        add_card(FB.challenge_bans.vouchers_hand_breakers)
        add_blind("bl_fb_goat")
        add_blind("bl_fb_cow")
        add_blind("bl_fb_rooster")
        add_blind("bl_needle")
        add_blind("bl_water")
    end

    if opts.ban_ox then add_blind("bl_ox") end

    return {
        banned_cards = banned_cards,
        banned_tags = banned_tags,
        banned_other = banned_other
    }
end

function FB.merge_challenge_restrictions(base, extra)
    base = base or {}
    extra = extra or {}

    base.banned_cards = base.banned_cards or {}
    base.banned_tags = base.banned_tags or {}
    base.banned_other = base.banned_other or {}

    for _, row in ipairs(extra.banned_cards or {}) do
        base.banned_cards[#base.banned_cards + 1] = row
    end

    for _, row in ipairs(extra.banned_tags or {}) do
        base.banned_tags[#base.banned_tags + 1] = row
    end

    for _, row in ipairs(extra.banned_other or {}) do
        base.banned_other[#base.banned_other + 1] = row
    end

    return base
end

-- ---------- Minimal custom hooks ----------

function FB.challenge_create_fb_joker(key, opts)
    opts = opts or {}
    local full_key = tostring(key or "")
    if not full_key:find("^j_") then full_key = "j_fb_" .. full_key end

    if SMODS and SMODS.add_card then
        return SMODS.add_card({
            key = full_key,
            area = opts.area or G.jokers,
            stickers = opts.stickers,
            edition = opts.edition
        })
    end

    return nil
end

function FB.challenge_make_card_eternal_pinned(card)
    if not card then return end
    card.ability = card.ability or {}
    card.ability.eternal = true
    card.pinned = true
    card.ability.fb_challenge_pinned = true
end

function FB.challenge_spawn_pinned_shanque_once()
    if not (G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.fb_start_pinned_shanque) then return end
    if G.GAME.fb_challenge_shanque_spawned then return end
    G.GAME.fb_challenge_shanque_spawned = true

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        func = function()
            local card = FB.challenge_create_fb_joker("shanque")
            FB.challenge_make_card_eternal_pinned(card)
            return true
        end
    }))
end

function FB.challenge_sell_all_jokers_for_triple(context)
    if not (G and G.jokers and G.jokers.cards) then return end

    local cards = {}
    for _, j in ipairs(G.jokers.cards) do
        if j and not (j.ability and j.ability.eternal) then
            cards[#cards + 1] = j
        end
    end

    local total = 0
    for _, j in ipairs(cards) do
        total = total + (j.sell_cost or 0)
        if j.start_dissolve then
            j:start_dissolve()
        elseif FB.queue_destroy then
            FB.queue_destroy(j)
        end
    end

    if total > 0 then ease_dollars(total * 3) end
    if FB.resolve_or_defer_queued_actions then FB.resolve_or_defer_queued_actions(context or {}) end
end

function FB.challenge_give_9th_heaven_once_per_round()
    if not (G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.fb_nine_heavens) then return end

    G.GAME.fb_nine_heavens_given = G.GAME.fb_nine_heavens_given or 0
    if G.GAME.fb_nine_heavens_given >= 9 then return end

    G.GAME.fb_nine_heavens_given = G.GAME.fb_nine_heavens_given + 1
    FB.challenge_create_fb_joker("9th_heaven")
end

function FB.challenge_apply_win_ante()
    if not (G and G.GAME and G.GAME.modifiers) then return end

    local win_ante = G.GAME.modifiers.fb_win_ante
    if type(win_ante) == "number" and win_ante > 0 then
        G.GAME.win_ante = win_ante
    end
end

function FB.challenge_random_spectral_key(seed)
    if not (G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Spectral) then return nil end

    local choices = {}
    for _, center in ipairs(G.P_CENTER_POOLS.Spectral) do
        if center and center.key and center.unlocked ~= false and not center.no_doe and not center.demo then
            choices[#choices + 1] = center.key
        end
    end

    if #choices <= 0 then return nil end
    return pseudorandom_element(choices, pseudoseed(seed or "fb_challenge_spectral"))
end

function FB.challenge_is_shop_booster(_type, area)
    return _type == "Booster"
        or _type == "Booster Pack"
        or _type == "Booster_Pack"
        or (G and G.shop_booster and area == G.shop_booster)
end

function FB.challenge_is_shop_joker(_type, area)
    return _type == "Joker" and G and G.shop_jokers and area == G.shop_jokers
end

function FB.challenge_center_set(key)
    return key and G and G.P_CENTERS and G.P_CENTERS[key] and G.P_CENTERS[key].set
end

function FB.challenge_is_standard_pack_key(key)
    key = tostring(key or "")
    return key:find("p_standard", 1, true) ~= nil
        or key:find("standard", 1, true) ~= nil
end

function FB.challenge_first_standard_pack_key()
    if G and G.P_CENTERS and G.P_CENTERS.p_standard_normal_1 then return "p_standard_normal_1" end

    if G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Booster then
        for _, center in ipairs(G.P_CENTER_POOLS.Booster) do
            if center and center.key and FB.challenge_is_standard_pack_key(center.key) then
                return center.key
            end
        end
    end

    return nil
end

function FB.challenge_patch_card_creation(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, vanilla_create_card)
    forced_key = FB.challenge_out_of_spotlight_replace_shop_joker(_type, area, forced_key)

    if FB.challenge_has_rule("fb_standard_packs_only")
    and forced_key
    and FB.challenge_is_shop_booster(_type, area)
    and not FB.challenge_is_standard_pack_key(forced_key) then
        forced_key = FB.challenge_first_standard_pack_key() or forced_key
    end

    if FB.challenge_has_rule("fb_no_boosters")
    and FB.challenge_is_shop_booster(_type, area) then
        return vanilla_create_card("Tarot", area, legendary, _rarity, skip_materialize, soulable, nil, key_append)
    end

    if FB.challenge_has_rule("fb_no_spectral")
    and (_type == "Spectral" or FB.challenge_center_set(forced_key) == "Spectral") then
        return vanilla_create_card("Tarot", area, legendary, _rarity, skip_materialize, soulable, nil, key_append)
    end

    if FB.challenge_has_rule("no_shop_jokers")
    and FB.challenge_is_shop_joker(_type, area)
    and not forced_key then
        return vanilla_create_card("Tarot", area, legendary, _rarity, skip_materialize, soulable, nil, key_append)
    end

    if FB.challenge_has_rule("fb_spectral_shop")
    and area and G
    and (area == G.shop_jokers or area == G.shop_booster or area == G.shop_vouchers)
    and not forced_key
    and pseudorandom("fb_challenge_spectral_shop") < 0.20 then
        local spectral_key = FB.challenge_random_spectral_key("fb_challenge_spectral_shop_key")
        if spectral_key then
            return vanilla_create_card("Spectral", area, legendary, _rarity, skip_materialize, soulable, spectral_key, key_append)
        end
    end

    return vanilla_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
end

function FB.challenge_current_blind_key()
    if G and G.GAME and G.GAME.blind_on_deck then return G.GAME.blind_on_deck end

    if G and G.GAME and G.GAME.blind and G.GAME.blind.config and G.GAME.blind.config.blind then
        return G.GAME.blind.config.blind.key
    end

    return nil
end

-- ---------- Little trilogy zero-base score helpers ----------
-- Level 1 hands become 0 Chips / 0 Mult, while later planet/upgrades still work.

FB.zero_base_hands = {
    "High Card",
    "Pair",
    "Two Pair",
    "Three of a Kind",
    "Straight",
    "Flush",
    "Full House",
    "Four of a Kind",
    "Straight Flush",
    "Five of a Kind",
    "Flush House",
    "Flush Five"
}

function FB.challenge_zero_base_score_apply()
    if not FB.challenge_has_rule("fb_zero_base_score") then return end
    if not (G and G.GAME and G.GAME.hands) then return end

    for _, hand in ipairs(FB.zero_base_hands or {}) do
        local h = G.GAME.hands[hand]

        if h then
            local level = math.max(1, h.level or 1)
            local levels_gained = level - 1

            h.chips = levels_gained * (h.l_chips or 0)
            h.mult = levels_gained * (h.l_mult or 0)
        end
    end
end

function FB.challenge_init_base_after_base()
    if not (G and G.GAME) then return end

    G.GAME.fb_base_after_base = G.GAME.fb_base_after_base or {
        mult = 1,
        clear_increment = 0.5
    }

    G.GAME.fb_base_after_base.mult = G.GAME.fb_base_after_base.mult or 1
    G.GAME.fb_base_after_base.clear_increment = G.GAME.fb_base_after_base.clear_increment or 0.5
end

function FB.challenge_base_after_base_multiplier(amount)
    if not FB.challenge_has_rule("fb_base_after_base") then return amount end
    if not (G and G.GAME) then return amount end

    FB.challenge_init_base_after_base()

    return amount * (G.GAME.fb_base_after_base.mult or 1)
end

-- Base After Base:
-- Clearing a blind increases blind size by the current clear increment.
-- The clear increment starts at +0.5X.
-- Each skipped blind permanently increases future clear increments by +0.5X.

function FB.challenge_increment_base_after_base_skip()
    if not FB.challenge_has_rule("fb_base_after_base") then return end
    if not (G and G.GAME) then return end

    FB.challenge_init_base_after_base()

    G.GAME.fb_base_after_base.clear_increment =
        (G.GAME.fb_base_after_base.clear_increment or 0.5) + 0.5
end

FB._base_after_base_skip_ref = FB._base_after_base_skip_ref or skip_blind

function skip_blind(e)
    FB.challenge_increment_base_after_base_skip()
    return FB._base_after_base_skip_ref(e)
end

function FB.challenge_increment_base_after_base_clear()
    if not FB.challenge_has_rule("fb_base_after_base") then return end
    if not (G and G.GAME) then return end

    FB.challenge_init_base_after_base()

    G.GAME.fb_base_after_base.mult =
        (G.GAME.fb_base_after_base.mult or 1)
        + (G.GAME.fb_base_after_base.clear_increment or 0.5)
end

-- ---------- Positive Ascension helpers ----------
-- Keeps only positive Deck/Sleeve effects.

function FB.challenge_apply_positive_ascension_starting_state()
    if not FB.challenge_has_rule("fb_ascension_positive_decks_sleeves") then return end
    if not (G and G.GAME) then return end
    if G.GAME.fb_positive_ascension_state_applied then return end

    G.GAME.fb_positive_ascension_state_applied = true

    if SMODS and SMODS.change_play_limit then
    SMODS.change_play_limit(1)
end

if SMODS and SMODS.change_discard_limit then
    SMODS.change_discard_limit(1)
end
end


function FB.challenge_apply_card_selection_bonus()
    if not FB.challenge_has_rule("fb_card_selection_plus_1") then return end
    if not (G and G.hand and G.hand.config) then return end
    if G.GAME and G.GAME.fb_card_selection_bonus_applied then return end

    if G.GAME then
        G.GAME.fb_card_selection_bonus_applied = true
    end

    G.hand.config.highlighted_limit = (G.hand.config.highlighted_limit or 5) + 1
end

function FB.install_challenge_rule_hooks()
    if FB.challenge_rules.hooks_installed then return end
    FB.challenge_rules.hooks_installed = true

    if create_card then
        local vanilla_create_card = create_card

        function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
            return FB.challenge_patch_card_creation(
                _type,
                area,
                legendary,
                _rarity,
                skip_materialize,
                soulable,
                forced_key,
                key_append,
                vanilla_create_card
            )
        end
    end

    if create_UIBox_shop then
        local vanilla_create_UIBox_shop = create_UIBox_shop

        function create_UIBox_shop(...)
            if G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.fb_no_boosters and G.GAME.shop then
                G.GAME.shop.booster_max = 0
            end

            local ret = vanilla_create_UIBox_shop(...)

            if G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.fb_no_boosters and G.GAME.shop then
                G.GAME.shop.booster_max = 0
            end

            return ret
        end
    end

    if get_blind_amount then
        local vanilla_get_blind_amount = get_blind_amount

        function get_blind_amount(ante)
            FB.challenge_apply_win_ante()
            return FB.challenge_base_after_base_multiplier(vanilla_get_blind_amount(ante))
        end
    end

    if end_round then
        local vanilla_end_round = end_round

        function end_round(...)
            local ret = vanilla_end_round(...)

            if G and G.GAME and G.GAME.modifiers then
                FB.challenge_apply_win_ante()
                FB.challenge_increment_base_after_base_clear()

                if G.GAME.modifiers.fb_sell_jokers_after_round then
                    FB.challenge_sell_all_jokers_for_triple({ end_of_round = true })
                end

                if G.GAME.modifiers.fb_nine_heavens then
                    FB.challenge_give_9th_heaven_once_per_round()
                end
            end

            return ret
        end
    end

    if evaluate_play then
        local vanilla_evaluate_play = evaluate_play

        function evaluate_play(...)
            local ret = vanilla_evaluate_play(...)

            FB.challenge_zero_base_score_apply()

            return ret
        end
    end

    if level_up_hand then
        local vanilla_level_up_hand = level_up_hand

        function level_up_hand(card, hand, instant, amount)
            local ret = vanilla_level_up_hand(card, hand, instant, amount)
            FB.challenge_zero_base_score_apply()
            return ret
        end
    end

    if Game and Game.start_run then
        local vanilla_start_run = Game.start_run

        function Game:start_run(args)
            local ret = vanilla_start_run(self, args)

            FB.challenge_apply_win_ante()
            FB.challenge_zero_base_score_apply()
            FB.challenge_apply_card_selection_bonus()

            if G and G.E_MANAGER then
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.1,
                    func = function()
                        FB.challenge_apply_win_ante()
                        FB.challenge_zero_base_score_apply()
                        FB.challenge_apply_positive_ascension_starting_state()
                        FB.challenge_apply_card_selection_bonus()
                        FB.challenge_spawn_pinned_shanque_once()
                        return true
                    end
                }))
            end

            return ret
        end
    end
end

FB.install_challenge_rule_hooks()
