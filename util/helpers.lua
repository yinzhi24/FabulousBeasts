---@diagnostic disable: undefined-global

FB = FB or {}

function FB.joker_cards()
    return (G and G.jokers and G.jokers.cards) or {}
end

function FB.key(base_key)
    return 'j_fb_' .. base_key
end

function FB.get_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

function FB.is_joker_key(card, base_key)
    local key = FB.get_center_key(card)
    return key ~= nil and key == FB.key(base_key)
end

function FB.has_mod_key(card)
    local key = FB.get_center_key(card)
    return key ~= nil and string.sub(key, 1, 5) == 'j_fb_'
end

function FB.has_joker(base_key)
    local target = FB.key(base_key)

    for _, joker in ipairs(FB.joker_cards()) do
        if FB.get_center_key(joker) == target then
            return true
        end
    end

    return false
end

function FB.count_joker(base_key)
    local count = 0
    local target = FB.key(base_key)

    for _, joker in ipairs(FB.joker_cards()) do
        if FB.get_center_key(joker) == target then
            count = count + 1
        end
    end

    return count
end

function FB.count_negative_jokers()
    local count = 0

    for _, joker in ipairs(FB.joker_cards()) do
        if joker.edition and joker.edition.negative then
            count = count + 1
        end
    end

    return count
end

function FB.is_face(card)
    return card and card.base and (
        card.base.value == 'Jack'
        or card.base.value == 'Queen'
        or card.base.value == 'King'
    )
end

function FB.is_number(card)
    return card and card.base and card.base.value
        and card.base.value ~= 'Ace'
        and card.base.value ~= 'Jack'
        and card.base.value ~= 'Queen'
        and card.base.value ~= 'King'
end

function FB.is_gold(card)
    return card and card.ability and card.ability.name == 'Gold Card'
end

function FB.is_steel(card)
    return card and card.ability and card.ability.name == 'Steel Card'
end

function FB.is_stone(card)
    return card and card.ability and card.ability.name == 'Stone Card'
end

function FB.safe_change_hand_size(amount)
    if G and G.hand and G.hand.change_size then
        G.hand:change_size(amount)
    end
end

function FB.safe_change_joker_slots(amount)
    if G and G.jokers and G.jokers.config then
        G.jokers.config.card_limit = G.jokers.config.card_limit + amount
    end
end

function FB.destroy(card)
    if card then
        G.E_MANAGER:add_event(Event({
            func = function()
                card:start_dissolve()
                return true
            end
        }))
    end
end

FB.HAND_TYPES = {
    'High Card',
    'Pair',
    'Two Pair',
    'Three of a Kind',
    'Straight',
    'Flush',
    'Full House',
    'Four of a Kind',
    'Straight Flush',
    'Five of a Kind',
    'Flush House',
    'Flush Five'
}

FB.BASE_HAND_TYPES = {
    'High Card',
    'Pair',
    'Two Pair',
    'Three of a Kind',
    'Straight',
    'Flush',
    'Full House',
    'Four of a Kind'
}

function FB.random_hand_type(seed)
    return pseudorandom_element(FB.HAND_TYPES, pseudoseed(seed or 'fb_random_hand'))
end

function FB.random_poker_hand(seed)
    return pseudorandom_element(FB.BASE_HAND_TYPES, pseudoseed(seed or 'fb_hand'))
end

function FB.create_joker(base_key, edition, negative)
    if not G or not G.jokers then return nil end
    if #G.jokers.cards >= G.jokers.config.card_limit then return nil end

    local created = SMODS.add_card({set = 'Joker', key = FB.key(base_key), area = G.jokers})

    if created and (edition or negative) then
        created:set_edition(negative and {negative = true} or edition, true)
    end

    return created
end

function FB.random_registered_key(seed)
    if not FB.joker_keys or #FB.joker_keys == 0 then return nil end
    return pseudorandom_element(FB.joker_keys, pseudoseed(seed or 'fb_random_registered'))
end

function FB.create_random_joker(seed)
    local key = FB.random_registered_key(seed)
    if key then
        return FB.create_joker(key)
    end
end

function FB.clear_card_debuffs(area)
    if not area or not area.cards then return 0 end
    local count = 0

    for _, playing_card in ipairs(area.cards) do
        if playing_card.debuff then
            playing_card.fb_formerly_debuffed = true
            playing_card.debuff = false
            count = count + 1
        end
    end

    return count
end

function FB.clear_joker_debuffs(limit)
    local count = 0

    for _, joker in ipairs(FB.joker_cards()) do
        if joker.debuff then
            joker.fb_formerly_debuffed = true
            joker.debuff = false
            count = count + 1
            if limit and count >= limit then break end
        end
    end

    return count
end

function FB.mark_formerly_debuffed(area)
    if not area or not area.cards then return end

    for _, c in ipairs(area.cards) do
        if c.debuff then
            c.fb_formerly_debuffed = true
        end
    end
end

function FB.try_add_dollars(amount)
    if ease_dollars then
        ease_dollars(amount)
    end
end

function FB.is_final_boss()
    local blind = G and G.GAME and G.GAME.blind
    if not blind then return false end

    local name = blind.name and string.lower(blind.name) or ''
    local key = blind.key and string.lower(blind.key) or ''

    return string.find(name, 'final') ~= nil or string.find(key, 'final') ~= nil
end

function FB.is_final_hand()
    return G and G.GAME and G.GAME.current_round and G.GAME.current_round.hands_left == 0
end


-- =========================================================
-- Fabulous Beasts shared registries and helpers
-- Moved from common.lua so rarity files stay Joker-only.
-- =========================================================

FB.joker_keys = {
    "album_cover",
    "alternate_album_cover",
    "beijing_license_plate",
    "bullet_comment",
    "cardboard_box",
    "dew_cloud",
    "divine_herb",
    "dog_food",
    "emergency_rations",
    "food",
    "food_reserve",
    "foraged_mushrooms",
    "health_insurance",
    "heart_lock",
    "heavenly_cumin",
    "immortality_elixir",
    "hellspice_hotpot",
    "knockout",
    "lakeside_pond",
    "laurel_branch",
    "mini_theater",
    "mooncake",
    "mortal_realm",
    "pay_stub",
    "rat_poison",
    "shunshui_express",
    "skewered_kebab",
    "teacup",
    "temporal_confinement",
    "tile_cat",
    "tulou",
    "underworld_cash",
    "bestiary",
    "chicken_mushroom_stew",
    "demolition_notice",
    "do_not_imitate",
    "feirenzai_manga",
    "followers_request",
    "gold_sculpture",
    "heavenly_elixirs",
    "hellish_delicacies",
    "lunchbox_medkit",
    "mapo_tofu",
    "moon_palace",
    "mooncake_cannon",
    "open_for_business",
    "oxen_cart",
    "paw_hole_cave",
    "pixiu_fur",
    "qilin_egg",
    "questionable_fanart",
    "rigged_video_game",
    "teapot",
    "underworlds_blacklist",
    "9th_heaven",
    "body_swap_mushroom",
    "bone_mask",
    "cintamani",
    "divine_garment",
    "divine_hair_growth_elixir",
    "divine_light",
    "divine_warsword",
    "dreamscape",
    "giant_kun_fish",
    "interdimensional_cave",
    "jade_bird",
    "laurel_tree",
    "lurendian_deermans",
    "magpie_bridge",
    "one_way_ticket_to_heaven",
    "pixiu_horn",
    "underworld",
    "baby_tianlu",
    "baby_bixie",
    "bajin",
    "bilibili",
    "bibi",
    "bixie",
    "christina",
    "chugou",
    "dijiang",
    "diting",
    "erliang",
    "fenz",
    "fresh_seed",
    "fuku_fuzai",
    "hetao",
    "hundun",
    "jinchi_dapeng",
    "jinjiao",
    "kulou",
    "luo_tianyi",
    "lord_phoenix",
    "qiongqi",
    "shanque",
    "sibuxiang",
    "taotie",
    "taowu",
    "tianlu",
    "tubaoshu",
    "tuye_tony",
    "xiaolizhi",
    "xiezhi",
    "yinjiao",
    "zhanhu",
    "bixie_true_form",
    "rainbow_mountain_range",
    "qishiqi",
    "shi_qilin",
    "qilin_sibuxiang",
    "tianlu_true_form",
    "happy_ending",
    "super_lollipop",
}


-- Sprite atlas note: each Joker sprite is 71x95 pixels.
-- SMODS `pos` uses zero-based grid coordinates, not pixel coordinates.
-- This sheet is assumed to have 10 columns; if your PNG has a different column count,
-- change the generated x/y mapping accordingly.

FB.food_joker_keys = FB.food_joker_keys or {
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
}

FB.beast_joker_keys = FB.beast_joker_keys or {
    baby_tianlu = true,
    baby_bixie = true,
    bajin = true,
    bibi = true,
    bixie = true,
    chugou = true,
    dijiang = true,
    diting = true,
    erliang = true,
    fenz = true,
    fuku_fuzai = true,
    hetao = true,
    hundun = true,
    jinchi_dapeng = true,
    jinjiao = true,
    kulou = true,
    lord_phoenix = true,
    qiongqi = true,
    shanque = true,
    sibuxiang = true,
    taotie = true,
    taowu = true,
    tianlu = true,
    tubaoshu = true,
    tuye_tony = true,
    xiaolizhi = true,
    xiezhi = true,
    yinjiao = true,
    zhanhu = true,
    bixie_true_form = true,
    shi_qilin = true,
    qilin_sibuxiang = true,
    tianlu_true_form = true,
}

FB.is_food_joker = FB.is_food_joker or function(card)
    if not (card and FB.get_center_key) then return false end
    local key = FB.get_center_key(card)
    if not key then return false end
    key = tostring(key):gsub('^j_fb_', '')
    return FB.food_joker_keys[key] == true
end

FB.is_beast_joker = FB.is_beast_joker or function(card)
    if not (card and FB.get_center_key) then return false end
    local key = FB.get_center_key(card)
    if not key then return false end
    key = tostring(key):gsub('^j_fb_', '')
    return FB.beast_joker_keys[key] == true
end

FB.count_food_jokers_explicit = FB.count_food_jokers_explicit or function()
    local n = 0
    local cards = FB.joker_cards and FB.joker_cards() or (G.jokers and G.jokers.cards) or {}

    for _, j in ipairs(cards) do
        if FB.is_food_joker(j) then n = n + 1 end
    end

    return n
end

if SMODS and SMODS.current_mod and not FB.fb_optional_features_wrapped then
    FB.fb_optional_features_wrapped = true
    local fb_old_optional_features = SMODS.current_mod.optional_features
    SMODS.current_mod.optional_features = function()
        local features = {}
        if type(fb_old_optional_features) == 'function' then
            local ok, old_features = pcall(fb_old_optional_features)
            if ok and type(old_features) == 'table' then
                for k, v in pairs(old_features) do features[k] = v end
            end
        elseif type(fb_old_optional_features) == 'table' then
            for k, v in pairs(fb_old_optional_features) do features[k] = v end
        end
        features.retrigger_joker = true
        features.post_trigger = true
        return features
    end
end

FB.num = FB.num or function(value, fallback)
    fallback = fallback or 0
    if type(value) == 'number' then return value end
    if type(value) == 'table' then
        if type(value.to_number) == 'function' then
            local ok, n = pcall(function() return value:to_number() end)
            if ok and type(n) == 'number' then return n end
        end
        if type(value.toNumber) == 'function' then
            local ok, n = pcall(function() return value:toNumber() end)
            if ok and type(n) == 'number' then return n end
        end
    end
    return fallback
end

FB.extra = FB.extra or function(card, key, fallback)
    if not (card and card.ability and card.ability.extra) then return fallback end
    local value = card.ability.extra[key]
    if value == nil then return fallback end
    return value
end

FB.round_condition_value = FB.round_condition_value or function(card, normal_key, boss_key, final_key)
    local normal = FB.extra(card, normal_key, 0)
    local boss = FB.extra(card, boss_key, normal)
    local final = FB.extra(card, final_key, boss)

    if FB.is_final_boss and FB.is_final_boss() then return final end
    if G and G.GAME and G.GAME.blind and G.GAME.blind.boss then return boss end
    return normal
end

FB.static_loc_vars = FB.static_loc_vars or function(card)
    local out = {}
    local vars = card and card.ability and card.ability.extra and card.ability.extra.fb_loc_vars or {}
    for i, v in ipairs(vars) do out[i] = v end
    return {vars = out}
end

FB.mark_round_once = FB.mark_round_once or function(card, flag)
    if not (card and card.ability) then return false end
    flag = flag or 'fb_round_once'
    if card.ability[flag] then return false end
    card.ability[flag] = true
    return true
end

FB.clear_round_once = FB.clear_round_once or function(card, flag)
    if card and card.ability then card.ability[flag or 'fb_round_once'] = nil end
end

FB.weighted_choice = FB.weighted_choice or function(seed, entries)
    local total = 0
    for _, entry in ipairs(entries or {}) do
        total = total + math.max(0, FB.num(entry.weight, 0))
    end
    if total <= 0 then return nil end

    local roll = FB.num(pseudorandom(seed), 0) * total
    local acc = 0
    for _, entry in ipairs(entries) do
        acc = acc + math.max(0, FB.num(entry.weight, 0))
        if roll <= acc then return entry.value end
    end
    return entries[#entries] and entries[#entries].value or nil
end

FB.exp_rand_int = FB.exp_rand_int or function(seed, low, high, power)
    low = math.floor(FB.num(low, 0))
    high = math.floor(FB.num(high, low))
    power = math.max(1, FB.num(power, 2))
    if high < low then low, high = high, low end
    local roll = math.max(0, math.min(1, FB.num(pseudorandom(seed), 0)))
    return math.max(low, math.min(high, low + math.floor(((high - low + 1) * (roll ^ power)))))
end

FB.exp_rand_signed_int = FB.exp_rand_signed_int or function(seed, max_abs, power)
    max_abs = math.floor(math.max(0, FB.num(max_abs, 0)))
    power = math.max(1, FB.num(power, 2))
    local sign = FB.num(pseudorandom(seed .. '_sign'), 0) < 0.5 and -1 or 1
    local magnitude = FB.exp_rand_int(seed .. '_mag', 0, max_abs, power)
    return sign * magnitude
end

FB.plasma_balance_return = FB.plasma_balance_return or function(chips_value, mult_value, args)
    args = args or {}
    return FB.balance_score_return(args.card, args)
end

FB.no_score_return = FB.no_score_return or function(card, message)
    return {
        chips = -math.max(0, FB.num(hand_chips, 0)),
        mult = -math.max(0, FB.num(mult, 0)), colour = G.C.RED,
        card = card
    }
end

FB.action_queue = FB.action_queue or {
    balance = {},
    create = {},
    destroy = {},
    self_destroy = {}
}

FB.queue_balance_score = FB.queue_balance_score or function(source_card, args)
    FB.action_queue.balance[#FB.action_queue.balance + 1] = {
        card = source_card,
        args = args or {}
    }
end

FB.queue_create_joker = FB.queue_create_joker or function(key, seed)
    FB.action_queue.create[#FB.action_queue.create + 1] = {
        key = key,
        seed = seed
    }
end

FB.queue_destroy = FB.queue_destroy or function(target_card)
    if target_card then
        FB.action_queue.destroy[#FB.action_queue.destroy + 1] = {card = target_card}
    end
end

FB.queue_self_destroy = FB.queue_self_destroy or function(source_card)
    if source_card then
        FB.action_queue.self_destroy[#FB.action_queue.self_destroy + 1] = {card = source_card}
    end
end

FB.apply_plasma_balance = FB.apply_plasma_balance or function(args)
    args = args or {}
    local original_chips = FB.num(hand_chips, 0)
    local original_mult = FB.num(mult, 0)
    local chips_now = original_chips * FB.num(args.chips_multiplier, 1)
    local mult_now = original_mult * FB.num(args.mult_multiplier, 1)
    local balanced = (chips_now + mult_now) / 2

    hand_chips = mod_chips(balanced)
    mult = mod_mult(balanced)
    update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})

    return balanced, original_chips, original_mult
end

FB.queue_has_actions = FB.queue_has_actions or function()
    return (FB.action_queue.balance and #FB.action_queue.balance > 0)
        or (FB.action_queue.create and #FB.action_queue.create > 0)
        or (FB.action_queue.destroy and #FB.action_queue.destroy > 0)
        or (FB.action_queue.self_destroy and #FB.action_queue.self_destroy > 0)
end

FB.is_round_won = FB.is_round_won or function()
    if not (G and G.GAME and G.GAME.blind) then return false end
    return FB.num(G.GAME.chips, 0) >= FB.num(G.GAME.blind.chips, math.huge)
end

FB.resolve_queued_actions = FB.resolve_queued_actions or function()
    if not FB.queue_has_actions() then return end

    -- 1. Balance score / Plasma-style effect
    if FB.action_queue.balance and #FB.action_queue.balance > 0 then
        local args = FB.action_queue.balance[#FB.action_queue.balance].args or {}
        FB.apply_plasma_balance(args)
    end

    -- 2. Creation
    for _, action in ipairs(FB.action_queue.create or {}) do
        if action.key then
            FB.create_joker(action.key)
        else
            FB.create_random_joker(action.seed or 'fb_queued_create')
        end
    end

    -- 3. Destruction
    for _, action in ipairs(FB.action_queue.destroy or {}) do
        if action.card then FB.destroy(action.card) end
    end

    -- 4. Self-destruction
    for _, action in ipairs(FB.action_queue.self_destroy or {}) do
        if action.card then FB.destroy(action.card) end
    end

    FB.action_queue.balance = {}
    FB.action_queue.create = {}
    FB.action_queue.destroy = {}
    FB.action_queue.self_destroy = {}
end

FB.resolve_or_defer_queued_actions = FB.resolve_or_defer_queued_actions or function(context)
    if not FB.queue_has_actions() then return end

    if context and context.after and FB.is_round_won() and G and G.GAME then
        if not G.GAME.fb_action_queue_deferred then
            G.GAME.fb_action_queue_deferred = true
            if G.E_MANAGER and Event then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.25,
                    func = function()
                        G.GAME.fb_action_queue_deferred = false
                        FB.resolve_queued_actions()
                        return true
                    end
                }))
            else
                -- Fallback for nonstandard contexts: never leave the queue stuck forever.
                G.GAME.fb_action_queue_deferred = false
                FB.resolve_queued_actions()
            end
        end
        return
    end

    if context and context.end_of_round and G and G.GAME then
        G.GAME.fb_action_queue_deferred = false
    end

    FB.resolve_queued_actions()
end

FB.balance_score_return = FB.balance_score_return or function(card, args)
    args = args or {}
    FB.queue_balance_score(card, args)
    local original_chips = FB.num(hand_chips, 0)
    local original_mult = FB.num(mult, 0)
    local chips_now = original_chips * FB.num(args.chips_multiplier, 1)
    local mult_now = original_mult * FB.num(args.mult_multiplier, 1)
    local balanced = (chips_now + mult_now) / 2
    -- Clear queued balance so returning this from Joker scoring does not apply twice later.
    FB.action_queue.balance = {}
    return {
        chips = balanced - original_chips,
        mult = balanced - original_mult, colour = args.colour or G.C.PURPLE,
        card = card
    }
end

FB.set_permanent_debuff = FB.set_permanent_debuff or function(card)
    if not card then return end
    card.debuff = true
    card.fb_permanent_debuff = true
    card.ability = card.ability or {}
    card.ability.fb_permanent_debuff = true
end

FB.maintain_permanent_debuffs = FB.maintain_permanent_debuffs or function()
    for _, area in ipairs({G.jokers, G.hand, G.play, G.deck, G.discard}) do
        if area and area.cards then
            for _, c in ipairs(area.cards) do
                if c and (c.fb_permanent_debuff or (c.ability and c.ability.fb_permanent_debuff)) then
                    c.debuff = true
                end
            end
        end
    end
end

FB.is_copyable_joker = FB.is_copyable_joker or function(other_card)
    if not (other_card and other_card.config and other_card.config.center) then return false end
    if other_card.debuff then return false end
    if other_card.config.center.blueprint_compat ~= true then return false end
    if FB.is_beast_joker and FB.is_beast_joker(other_card) then return false end
    local key = FB.get_center_key and FB.get_center_key(other_card) or ''
    key = tostring(key):gsub('^j_fb_', '')
    if key == 'happy_ending' then return false end
    local rarity = other_card.config.center.rarity
    if rarity == 'fb_exotic' or rarity == 'fb_divine' then return false end
    return true
end

FB.copy_single_joker_effect = FB.copy_single_joker_effect or function(card, other_card, context)
    if not FB.is_copyable_joker(other_card) then return nil end
    if SMODS and SMODS.blueprint_effect then
        return SMODS.blueprint_effect(card, other_card, context)
    end
    return nil
end


FB.find_joker_index = FB.find_joker_index or function(card)
    if not (G.jokers and G.jokers.cards) then return nil end

    for i, joker in ipairs(G.jokers.cards) do
        if joker == card then return i end
    end

    return nil
end

FB.get_joker_to_right = FB.get_joker_to_right or function(card)
    local index = FB.find_joker_index(card)
    if not index or not (G.jokers and G.jokers.cards) then return nil end
    return G.jokers.cards[index + 1]
end

FB.remove_eternal = FB.remove_eternal or function(card)
    if not (card and card.ability) then return false end

    local was_eternal = card.ability.eternal == true
    card.ability.eternal = false

    if card.set_eternal then
        pcall(function() card:set_eternal(false) end)
    end

    return was_eternal
end

FB.destroy_after_removing_eternal = FB.destroy_after_removing_eternal or function(card)
    if not card then return false, false end

    local was_eternal = FB.remove_eternal(card)
    local key = FB.get_center_key and FB.get_center_key(card)

    if key == FB.key('super_lollipop') or key == 'j_fb_super_lollipop' then
        return was_eternal, false
    end

    FB.destroy(card)
    return was_eternal, true
end

FB.queue_destroy_after_removing_eternal = FB.queue_destroy_after_removing_eternal or function(card)
    if not card then return false, false end

    local was_eternal = FB.remove_eternal(card)
    local key = FB.get_center_key and FB.get_center_key(card)

    if key == FB.key('super_lollipop') or key == 'j_fb_super_lollipop' then
        return was_eternal, false
    end

    FB.queue_destroy(card)
    return was_eternal, true
end

FB.normal_random = FB.normal_random or function(seed)
    local u1 = math.max(1e-12, FB.num(pseudorandom(seed .. '_u1'), 0.5))
    local u2 = math.max(1e-12, FB.num(pseudorandom(seed .. '_u2'), 0.5))

    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
end

FB.normal_scaled_value = FB.normal_scaled_value or function(seed, mean, stddev)
    local z = FB.normal_random(seed)
    return math.floor(mean + z * stddev)
end

FB.inverse_weighted_int = FB.inverse_weighted_int or function(seed, low, high)
    low = math.floor(FB.num(low, 1))
    high = math.floor(FB.num(high, low))
    if high < low then low, high = high, low end

    local total = 0
    for i = low, high do
        total = total + (1 / i)
    end

    local roll = FB.num(pseudorandom(seed), 0) * total
    local acc = 0

    for i = low, high do
        acc = acc + (1 / i)
        if roll <= acc then return i end
    end

    return high
end

-- =========================================================
-- Fabulous Beasts pre-alpha configurable odds/value helpers
-- =========================================================
FB.roll = FB.roll or function(seed, numerator, denominator)
    numerator = math.max(0, FB.num(numerator, 0))
    denominator = math.max(1, FB.num(denominator, 1))

    -- Xiaolizhi-style global guarantee hook.
    if FB.has_joker and FB.has_joker('xiaolizhi') then
        return numerator > 0
    end

    return FB.num(pseudorandom(seed or 'fb_roll'), 0) < (numerator / denominator)
end

FB.random_enhancement_key = FB.random_enhancement_key or function(seed)
    return pseudorandom_element({
        'm_bonus',
        'm_mult',
        'm_wild',
        'm_glass',
        'm_steel',
        'm_stone',
        'm_gold',
        'm_lucky'
    }, pseudoseed(seed or 'fb_random_enhancement'))
end

FB.random_seal = FB.random_seal or function(seed)
    return pseudorandom_element({
        'Gold',
        'Blue',
        'Red',
        'Purple'
    }, pseudoseed(seed or 'fb_random_seal'))
end

FB.random_edition = FB.random_edition or function(seed)
    return pseudorandom_element({
        {foil = true},
        {holo = true},
        {polychrome = true}
    }, pseudoseed(seed or 'fb_random_edition'))
end

FB.apply_random_card_modifier = FB.apply_random_card_modifier or function(card, seed)
    if not card then return nil end
    seed = seed or 'fb_random_card_modifier'

    local modifier_type = pseudorandom_element({
        'enhancement',
        'seal',
        'edition'
    }, pseudoseed(seed .. '_type'))

    if modifier_type == 'enhancement' then
        local enhancement_key = FB.random_enhancement_key(seed .. '_enhancement')
        if enhancement_key and G and G.P_CENTERS and G.P_CENTERS[enhancement_key] then
            card:set_ability(G.P_CENTERS[enhancement_key], nil, true)
            return 'enhancement'
        end
    elseif modifier_type == 'seal' then
        local seal = FB.random_seal(seed .. '_seal')
        if seal then
            card:set_seal(seal, true)
            return 'seal'
        end
    elseif modifier_type == 'edition' then
        local edition = FB.random_edition(seed .. '_edition')
        if edition then
            card:set_edition(edition, true)
            return 'edition'
        end
    end

    return nil
end

FB.is_enhanced_card = FB.is_enhanced_card or function(card)
    return card
        and card.ability
        and card.ability.name
        and card.ability.name ~= 'Default Base'
        and card.ability.name ~= 'Stone Card'
end

FB.card_cash_value = FB.card_cash_value or function(card, edition_mult, mod_bonus)
    if not card then return 0 end

    edition_mult = FB.num(edition_mult, 2)
    mod_bonus = FB.num(mod_bonus, 5)

    local value = FB.num(card.get_chip_bonus and card:get_chip_bonus(), 0)

    if card.edition then
        value = value * edition_mult
    end

    if FB.is_enhanced_card(card) then
        value = value + mod_bonus
    end

    if card.seal then
        value = value + mod_bonus
    end

    return math.floor(math.max(0, value))
end



-- =========================================================
-- Fabulous Beasts safety layer: scoring, once-per-round scaling,
-- and non-recursive Joker retriggers.
-- =========================================================

FB.ensure_extra = FB.ensure_extra or function(card)
    if card then
        card.ability = card.ability or {}
        card.ability.extra = card.ability.extra or {}
        return card.ability.extra
    end
    return {}
end

FB.safe_return = FB.safe_return or function(ret)
    if ret == nil then return nil end
    if type(ret) ~= 'table' then return nil end
    return ret
end

FB.current_round_id = FB.current_round_id or function()
    local game = G and G.GAME or {}
    local blind = game.blind or {}
    local resets = game.round_resets or {}
    return table.concat({
        tostring(game.round or 0),
        tostring(resets.ante or 0),
        tostring(blind.name or blind.key or ''),
        tostring(game.hands_played or 0),
        tostring(game.skips or 0)
    }, '|')
end

FB.main_end_of_round_once = FB.main_end_of_round_once or function(card, context, flag)
    if not (card and context and context.end_of_round) then return false end
    if context.blueprint or context.individual or context.repetition or context.before or context.after then return false end
    if context.cardarea and G and G.jokers and context.cardarea ~= G.jokers then return false end

    card.ability = card.ability or {}
    flag = flag or 'fb_end_of_round_once'
    local id = FB.current_round_id()
    if card.ability[flag] == id then return false end
    card.ability[flag] = id
    return true
end

FB.is_scoring_joker_main = FB.is_scoring_joker_main or function(context)
    return context
        and context.joker_main
        and not context.end_of_round
        and not context.setting_blind
        and not context.selling_card
        and not context.selling_self
        and not context.before
        and not context.after
        and not context.repetition
end

FB.is_scoring_individual = FB.is_scoring_individual or function(context)
    return context
        and context.individual
        and context.cardarea
        and G and G.play
        and context.cardarea == G.play
        and context.other_card
        and not context.end_of_round
        and not context.setting_blind
        and not context.before
        and not context.after
        and not context.selling_card
        and not context.selling_self
end

FB.is_card_repetition = FB.is_card_repetition or function(context)
    return context
        and context.repetition
        and context.cardarea
        and not context.end_of_round
        and not context.setting_blind
        and not context.before
        and not context.after
        and not context.selling_card
        and not context.selling_self
end

-- Fast retrigger helpers.
-- Keep the retrigger gate inline to avoid the extra helper call overhead in scoring paths.
FB.has_retrigger_effect = function(card)
    if not card then return false end

    local center = card.config and card.config.center or {}
    local ability = type(card.ability) == 'table' and card.ability or {}
    local extra = type(ability.extra) == 'table' and ability.extra or {}

    -- Explicit mod/custom flags
    if center.retrigger or center.retriggered or center.retrigger_count then return true end
    if ability.retrigger or ability.retriggered or ability.retrigger_count then return true end
    if extra.retrigger or extra.retriggered or extra.retrigger_count then return true end

    -- Steamodded-style retrigger compatibility hints
    if center.calculate and type(center.calculate) == 'function' then
        local key = center.key or ""
        local name = center.name or ""

        -- Fallback name/key scan for external mod jokers
        key = tostring(key):lower()
        name = tostring(name):lower()

        if key:find("retrigger")
            or key:find("repeat")
            or key:find("again")
            or name:find("retrigger")
            or name:find("repeat")
            or name:find("again") then
            return true
        end
    end

    return false
end

FB.current_retrigger_id = function()
    local game = G and G.GAME or {}
    local blind = game.blind or {}
    local resets = game.round_resets or {}
    return table.concat({
        tostring(game.round or 0),
        tostring(resets.ante or 0),
        tostring(blind.name or blind.key or ''),
        tostring(game.hands_played or 0),
        tostring(game.skips or 0)
    }, '|')
end

-- Runtime-only retrigger cache.
-- IMPORTANT: Do not store card objects or retrigger cache tables inside card.ability.
-- Balatro serializes card.ability; storing card objects there can create table cycles.
FB.fb_rt_seen_temp = FB.fb_rt_seen_temp or {}
FB.fb_rt_seen_hand = FB.fb_rt_seen_hand or nil

FB.once_joker_retrigger = function(source, context, tag)
    if not context or not context.retrigger_joker_check then return false end
    if not source or not context.other_card or context.other_card == source then return false end
    if context.end_of_round or context.setting_blind or context.before or context.after then return false end
    if context.selling_card or context.selling_self or context.destroy_card or context.remove_playing_cards then return false end

    -- Purge old bad saved data from earlier helper versions.
    if source.ability then
        source.ability.fb_rt_seen = nil
        source.ability.fb_rt_hand = nil
    end

    if context.other_card.ability then
        context.other_card.ability.fb_rt_seen = nil
        context.other_card.ability.fb_rt_hand = nil
    end

    local hand_id = FB.current_retrigger_id()

    if FB.fb_rt_seen_hand ~= hand_id then
        FB.fb_rt_seen_hand = hand_id
        FB.fb_rt_seen_temp = {}
    end

    local source_id =
        source.sort_id
        or source.ID
        or FB.get_center_key(source)
        or "source"

    local target_id =
        context.other_card.sort_id
        or context.other_card.ID
        or FB.get_center_key(context.other_card)
        or "target"

    local token =
        tostring(tag or "rt") ..
        ":" .. tostring(source_id) ..
        ">" .. tostring(target_id)

    if FB.fb_rt_seen_temp[token] then return false end
    FB.fb_rt_seen_temp[token] = true
    return true
end

-- =========================================================
-- Fabulous Beasts final release-candidate helpers
-- Implements TXT audit rules and hardens nil/no-effect returns.
-- =========================================================

FB.raw_key = FB.raw_key or function(card)
    local key = FB.get_center_key and FB.get_center_key(card) or nil
    if not key then return nil end
    return tostring(key):gsub('^j_fb_', '')
end

FB.get_rarity = FB.get_rarity or function(card)
    return card and card.config and card.config.center and card.config.center.rarity
end

FB.is_exotic_or_divine = FB.is_exotic_or_divine or function(card)
    local r = FB.get_rarity(card)
    return r == 'fb_exotic' or r == 'fb_divine' or r == 'exotic' or r == 'divine'
end

FB.card_unique_signature = function(card)
    if not card then return 'nil' end
    local rank = card.base and card.base.value or '?'
    local suit = card.base and card.base.suit or '?'
    local ability = card.ability and (card.ability.name or card.ability.set or card.ability.effect) or 'Default Base'
    local seal = card.seal or 'None'
    local edition = 'None'
    if card.edition then
        local parts = {}
        for k, v in pairs(card.edition) do if v then parts[#parts + 1] = tostring(k) end end
        table.sort(parts)
        edition = table.concat(parts, '+')
    end
    local perma_bonus = card.ability and card.ability.perma_bonus or 0
    local perma_mult = card.ability and card.ability.perma_mult or 0
    return table.concat({rank, suit, tostring(ability), tostring(seal), tostring(edition), tostring(perma_bonus), tostring(perma_mult)}, '|')
end

FB.card_mod_count = function(card)
    if not card then return 0 end
    local n = 0
    if FB.is_enhanced_card(card) then n = n + 1 end
    if card.seal then n = n + 1 end
    if card.edition then n = n + 1 end
    return n
end

FB.count_deck_mods = function()
    local n = 0
    for _, c in ipairs((G and G.playing_cards) or {}) do n = n + FB.card_mod_count(c) end
    return n
end

FB.available_joker_slots = function()
    if not (G and G.jokers and G.jokers.cards and G.jokers.config) then return 0 end
    return math.max(0, (G.jokers.config.card_limit or 0) - #G.jokers.cards)
end

FB.available_consumable_slots = function()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then return 0 end
    return math.max(0, (G.consumeables.config.card_limit or 0) - #G.consumeables.cards)
end

FB.create_joker_any_key = function(key)
    if not key or FB.available_joker_slots() <= 0 then return nil end
    local actual = tostring(key)
    if not actual:match('^j_') then actual = FB.key(actual) end
    return SMODS.add_card({set='Joker', key=actual, area=G.jokers})
end

FB.food_common_pool = {'divine_herb','dog_food','emergency_rations','food','food_reserve','foraged_mushrooms','heavenly_cumin','hellspice_hotpot','mooncake','skewered_kebab','teacup','j_gros_michel','j_egg','j_ice_cream','j_popcorn','j_ramen','j_seltzer','j_turtle_bean','j_diet_cola'}
FB.food_uncommon_pool = {'chicken_mushroom_stew','heavenly_elixirs','hellish_delicacies','mapo_tofu','moon_palace','mooncake_cannon'}
FB.food_rare_pool = {'body_swap_mushroom'}

FB.lunchbox_weights = function()
    if FB.has_joker and FB.has_joker('xiaolizhi') then return 1, 1, 1 end
    return 88, 22, 2
end

FB.create_lunchbox_food = function(seed)
    if FB.available_joker_slots() <= 0 then return nil end
    local cw, uw, rw = FB.lunchbox_weights()
    local pool = FB.weighted_choice(seed or 'lunchbox_rarity', {
        {weight=cw, value=FB.food_common_pool}, {weight=uw, value=FB.food_uncommon_pool}, {weight=rw, value=FB.food_rare_pool}
    }) or FB.food_common_pool
    local key = pseudorandom_element(pool, pseudoseed((seed or 'lunchbox') .. '_pick'))
    return FB.create_joker_any_key(key)
end

FB.has_life_saving_joker = function(except)
    for _, j in ipairs(FB.joker_cards()) do
        if j ~= except then
            local k = FB.raw_key(j)
            if k == 'emergency_rations' or k == 'demolition_notice' or k == 'mr_bones' or k == 'j_mr_bones' then return true end
        end
    end
    return false
end

FB.edition_rank = function(card)
    if not (card and card.edition) then return 0 end
    if card.edition.polychrome then return 3 end
    if card.edition.holo then return 2 end
    if card.edition.foil then return 1 end
    return 0
end

FB.set_better_edition = function(card, edition)
    if not card then return false end
    local r = 0
    if edition and edition.polychrome then r = 3 elseif edition and edition.holo then r = 2 elseif edition and edition.foil then r = 1 end
    if r > FB.edition_rank(card) then card:set_edition(edition, true); return true end
    return false
end

FB.hand_contains_rank = function(rank)
    for _, c in ipairs((G and G.play and G.play.cards) or {}) do
        if c and c.base and c.base.value == rank then return true end
    end
    return false
end
FB.hand_contains_number = function(num)
    return FB.hand_contains_rank(tostring(num))
end

FB.sold_destroyed_penalty = function(amount)
    if not (G and G.jokers and G.jokers.cards) then return end
    for _, j in ipairs(G.jokers.cards) do
        if j and j.ability and j.ability.fb_blacklist_tracking then
            j.ability.extra.xmult = (j.ability.extra.xmult or 4) - (amount or 0.1)
        end
        if j and j.ability and j.ability.fb_kulou_tracking then
            j.ability.extra.xmult = (j.ability.extra.xmult or 1) + (amount or 0.1)
        end
    end
end

FB.safe_no_effect = function(ret)
    if ret == nil then return {} end
    if type(ret) ~= 'table' then return {} end
    return ret
end

