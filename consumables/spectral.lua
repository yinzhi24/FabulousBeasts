---@diagnostic disable: undefined-global

-- Fabulous Beasts - Spectral cards
-- This file is intentionally self-contained, but it now respects the shared
-- FB/FabulousBeasts namespace used by the Talisman files.

FabulousBeasts = rawget(_G, 'FabulousBeasts') or rawget(_G, 'FB') or {}
FB = FabulousBeasts
_G.FB = FB
_G.FabulousBeasts = FB

local FB_PREFIX = 'fb'

FB.Spectral = FB.Spectral or {}
-- ------------------------------------------------------------
-- Safe one-time registrations
-- ------------------------------------------------------------
-- Keep the asset paths plain: spectral.png, enhancements.png, refined.fs.
-- The guards prevent reload/duplicate-registration issues when another module
-- already registered the same object.

if SMODS and SMODS.Atlas and not FB.Spectral._atlas_registered then
    FB.Spectral._atlas_registered = true
    SMODS.Atlas { key = 'fb_spectral', path = 'spectral.png', px = 71, py = 95 }
    SMODS.Atlas { key = 'fb_enhancements', path = 'enhancements.png', px = 71, py = 95 }
end

if SMODS and SMODS.Shader and not FB.Spectral._refined_shader_registered then
    FB.Spectral._refined_shader_registered = true
    SMODS.Shader { key = 'refined', path = 'refined.fs' }
end

if SMODS and SMODS.Edition and not FB.Spectral._refined_edition_registered then
    FB.Spectral._refined_edition_registered = true
    SMODS.Edition {
        key = 'refined',
        shader = 'refined',
        loc_txt = {
            name = 'Refined',
            label = 'Refined',
            text = {
                'Balances {C:chips}Chips{}',
                'and {C:mult}Mult{}',
            },
        },
        config = { balance = true },
        in_shop = false,
        weight = 0,
        extra_cost = 6,
        apply_to_float = true,
    }
end

-- ------------------------------------------------------------
-- Utility helpers
-- ------------------------------------------------------------

local function pseudoseed_key(key)
    return pseudoseed(FB_PREFIX .. '_' .. key)
end

local function rand_choice(list, seed_key)
    if not list or #list == 0 then return nil end
    return pseudorandom_element(list, pseudoseed_key(seed_key or 'choice'))
end

local function card_area_cards(area)
    return area and area.cards or {}
end

local function held_cards()
    return card_area_cards(G and G.hand)
end

local function joker_cards()
    return card_area_cards(G and G.jokers)
end

local function consumeable_cards()
    return card_area_cards(G and G.consumeables)
end

local function free_joker_slots()
    if not (G and G.jokers) then return 0 end
    return math.max(0, (G.jokers.config.card_limit or 0) - #G.jokers.cards)
end

local function free_consumeable_slots()
    if not (G and G.consumeables) then return 0 end
    return math.max(0, (G.consumeables.config.card_limit or 0) - #G.consumeables.cards)
end

local function dissolve_card(card)
    if not card or card.removed then return end
    if card.start_dissolve then card:start_dissolve(nil, true) end
end

local function destroy_cards(cards)
    if not cards then return end
    for _, card in ipairs(cards) do
        dissolve_card(card)
    end
end

local function is_protected(card)
    return false
end

local function safe_destroy_playing_card(card)
    if not card or is_protected(card) then return false end
    dissolve_card(card)
    return true
end

local function safe_destroy_joker(card)
    if not card or is_protected(card) then return false end
    if card.ability and card.ability.eternal then return false end
    dissolve_card(card)
    return true
end

local function copy_list(list)
    local out = {}
    for i, v in ipairs(list or {}) do out[i] = v end
    return out
end

local function shuffle_in_place(list, seed_key)
    for i = #list, 2, -1 do
        local j = pseudorandom(seed_key or 'shuffle', 1, i)
        list[i], list[j] = list[j], list[i]
    end
    return list
end

local function random_enhancement_key(seed_key)
    local keys = {}
    for k, v in pairs((G and G.P_CENTERS) or {}) do
        if type(k) == 'string' and k:sub(1, 2) == 'm_' and k ~= 'm_stone' then
            keys[#keys + 1] = k
        end
    end
    return rand_choice(keys, seed_key or 'enhancement')
end

local function random_seal(seed_key)
    return rand_choice({'Red', 'Blue', 'Gold', 'Purple'}, seed_key or 'seal')
end

local function random_edition(seed_key, allow_negative)
    local editions = {'foil', 'holo', 'polychrome'}
    if allow_negative then editions[#editions + 1] = 'negative' end
    return rand_choice(editions, seed_key or 'edition')
end

local function flip_card_for_change(card, mutate)
    if not card or type(mutate) ~= 'function' then return end

    -- Avoid creating nested flip storms when one change function calls another.
    if card._fb_changing_card then
        mutate()
        return
    end

    card._fb_changing_card = true

    local function finish_change()
        mutate()
        if card.flip then card:flip() end
        card._fb_changing_card = nil
        return true
    end

    if card.flip then card:flip() end

    -- In-game, use the event manager so the player actually sees the facedown moment.
    -- In collection/unsafe contexts, fall back to immediate mutation instead of crashing.
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = finish_change,
        }))
    else
        finish_change()
    end
end


local function normalize_playing_card_ability(card)
    -- Vanilla Card:set_debuff assumes several numeric fields exist on a playing
    -- card's ability table. Custom enhancements with an empty config can leave
    -- those nil, which crashes on boss debuffs such as The Force.
    -- Do NOT default perma_debuff to 0: in Lua, 0 is truthy, so that can make
    -- every enhanced card behave as permanently debuffed.
    if not card then return card end
    card.ability = card.ability or {}

    local numeric_defaults = {
        bonus = 0,
        mult = 0,
        h_bonus = 0,
        h_mult = 0,
        x_mult = 1,
        h_x_mult = 1,
        perma_bonus = 0,
        perma_mult = 0,
        perma_x_mult = 0,
        perma_h_bonus = 0,
        perma_h_mult = 0,
        perma_h_x_mult = 0,
        perma_x_chips = 0,
        perma_h_x_chips = 0,
        perma_chips = 0,
        perma_h_chips = 0,
        extra_value = 0,
    }

    for k, v in pairs(numeric_defaults) do
        if card.ability[k] == nil then card.ability[k] = v end
    end

    return card
end

local playing_card_enhancement_key
local card_has_seal
local card_has_edition
local card_has_any_edition
local random_enhancement_key_for_card
local card_can_gain_any_enhancement
local joker_can_be_made_eternal
local joker_can_be_debuffed_by_jiangshi

local function set_card_enhancement(card, key)
    if card and key and G.P_CENTERS[key] and playing_card_enhancement_key(card) ~= key then
        flip_card_for_change(card, function()
            card:set_ability(G.P_CENTERS[key], nil, true)
            normalize_playing_card_ability(card)
        end)
        return true
    end
    return false
end

local function set_card_seal(card, seal)
    if not (card and seal) then return false end

    -- If the target carries a Talisman, route seal changes into the Talisman
    -- metadata instead of overwriting card.seal and breaking the attached seal.
    if FB and FB.has_talisman and FB.has_talisman(card) then
        local s_key = ({ Red = 'red', Blue = 'blue', Gold = 'gold', Purple = 'purple' })[seal] or tostring(seal):lower()
        if FB.set_talisman_seal and FB.TALISMAN_SEALS and FB.TALISMAN_SEALS[s_key] then
            return FB.set_talisman_seal(card, s_key)
        end
    end

    if not card_has_seal(card, seal) then
        flip_card_for_change(card, function()
            if card.set_seal then card:set_seal(seal, nil, true) end
        end)
        return true
    end
    return false
end

local function set_card_edition(card, edition, immediate)
    if not card or not edition then return false end

    -- Same idea as set_card_seal: a Talisman edition belongs to the Talisman,
    -- not the physical card/Joker edition slot.
    if FB and FB.has_talisman and FB.has_talisman(card) then
        local e_key = (edition == 'holographic') and 'holo' or edition
        if FB.set_talisman_edition and FB.TALISMAN_EDITIONS and FB.TALISMAN_EDITIONS[e_key] then
            return FB.set_talisman_edition(card, e_key)
        end
    end

    local edition_table = {}
    if edition == 'foil' then edition_table.foil = true
    elseif edition == 'holo' or edition == 'holographic' then edition_table.holo = true
    elseif edition == 'polychrome' then edition_table.polychrome = true
    elseif edition == 'negative' then edition_table.negative = true
    elseif edition == 'refined' then edition_table[FB_PREFIX .. '_refined'] = true
    else return false end
    if card_has_edition(card, edition) then return false end
    flip_card_for_change(card, function()
        if card.set_edition then card:set_edition(edition_table, immediate ~= false) end
    end)
    return true
end

local function clear_card_mods(card)
    if not card then return 0 end
    local n = 0
    local should_change = false
    if card.config and card.config.center and card.config.center.key and card.config.center.key ~= 'c_base' then
        should_change = true
        n = n + 1
    end
    if card.seal then
        should_change = true
        n = n + 1
    end
    if card.edition then
        should_change = true
        n = n + 1
    end
    if should_change then
        flip_card_for_change(card, function()
            if card.config and card.config.center and card.config.center.key and card.config.center.key ~= 'c_base' then
                card:set_ability(G.P_CENTERS.c_base, nil, true)
            end
            if card.seal then card:set_seal(nil, nil, true) end
            if card.edition then card:set_edition(nil, true) end
        end)
    end
    return n
end

local function clear_joker_stickers_and_edition(card)
    if not card then return 0 end
    local n = 0
    if card.edition then
        card:set_edition(nil, true)
        n = n + 1
    end
    if card.ability then
        for _, sticker in ipairs({'eternal', 'perishable', 'rental', 'pinned'}) do
            if card.ability[sticker] then
                card.ability[sticker] = nil
                n = n + 1
            end
        end
    end
    return n
end

local function edition_name(card)
    if not card or not card.edition then return nil end
    if card.edition.negative then return 'negative' end
    if card.edition[FB_PREFIX .. '_refined'] or card.edition.refined then return 'refined' end
    if card.edition.polychrome then return 'polychrome' end
    if card.edition.holo then return 'holo' end
    if card.edition.foil then return 'foil' end
    return nil
end

local function joker_has_edition(card)
    return edition_name(card) ~= nil
end

local function playing_card_destination(area)
    -- Spectral-created playing cards should be drawn into hand, not silently
    -- added to the deck. If hand is unavailable, fall back to the requested
    -- area, then deck, so collection/load contexts do not explode.
    if G and G.hand then return G.hand end
    return area or (G and G.deck)
end

local function add_created_card_to_hand(card)
    if not card or not G or not G.hand then return card end

    -- create_playing_card usually already registers the card in G.playing_cards.
    -- Only move/emplace if some environment created it elsewhere. Do not
    -- re-add to deck here, or the same physical card can get double-counted.
    if card.area ~= G.hand then
        if card.area and card.area.remove_card then card.area:remove_card(card) end
        G.hand:emplace(card)
    end

    return card
end

local function make_playing_card(rank, suit, area, enhancement, seal, edition)
    area = playing_card_destination(area)
    if not area then return nil end

    local front = G.P_CARDS[(suit or 'S') .. '_' .. (rank or 'A')]
    if not front then return nil end

    local card = create_playing_card({front = front, center = G.P_CENTERS.c_base}, area, nil, nil, nil, nil)
    normalize_playing_card_ability(card)
    add_created_card_to_hand(card)
    if enhancement then set_card_enhancement(card, enhancement) end
    if seal then set_card_seal(card, seal) end
    if edition then set_card_edition(card, edition, true) end
    return card
end

local function copy_playing_card_to_hand(source, seed_key, force_random_enhancement)
    if not source or not source.config or not source.config.card then return nil end
    local area = playing_card_destination(G.hand)
    if not area then return nil end

    local card = copy_card(source, nil, nil, G.playing_card)
    normalize_playing_card_ability(card)
    if card.add_to_deck then card:add_to_deck() end
    if G.deck and G.deck.config then G.deck.config.card_limit = (G.deck.config.card_limit or 0) + 1 end
    if G.playing_cards then table.insert(G.playing_cards, card) end
    area:emplace(card)
    if card.start_materialize then card:start_materialize() end

    if force_random_enhancement then
        set_card_enhancement(card, random_enhancement_key((seed_key or 'copy') .. '_enh'))
    end

    return card
end

local function random_rank(seed_key)
    return rand_choice({'2','3','4','5','6','7','8','9','T','J','Q','K','A'}, seed_key or 'rank')
end

local function random_suit(seed_key)
    return rand_choice({'S','H','D','C'}, seed_key or 'suit')
end

local function random_playing_card_to_area(area, seed_key, with_any_mod)
    local rank = random_rank((seed_key or 'card') .. '_rank')
    local suit = random_suit((seed_key or 'card') .. '_suit')
    local enhancement, seal, edition
    if with_any_mod then
        if pseudorandom((seed_key or 'card') .. '_enh', 1, 2) == 1 then enhancement = random_enhancement_key((seed_key or 'card') .. '_enh_key') end
        if pseudorandom((seed_key or 'card') .. '_seal', 1, 2) == 1 then seal = random_seal((seed_key or 'card') .. '_seal_key') end
        if pseudorandom((seed_key or 'card') .. '_edition', 1, 2) == 1 then edition = random_edition((seed_key or 'card') .. '_edition_key', true) end
        if not enhancement and not seal and not edition then enhancement = random_enhancement_key((seed_key or 'card') .. '_fallback') end
    end
    return make_playing_card(rank, suit, area, enhancement, seal, edition)
end

local function randomize_existing_playing_card(card, seed_key, with_any_mod)
    if not card or is_protected(card) then return end
    local rank = random_rank((seed_key or 'mirror') .. '_rank')
    local suit = random_suit((seed_key or 'mirror') .. '_suit')
    if G.P_CARDS[suit .. '_' .. rank] then
        flip_card_for_change(card, function()
            card:set_base(G.P_CARDS[suit .. '_' .. rank])
        end)
    end
    if with_any_mod then
        if pseudorandom((seed_key or 'mirror') .. '_clear', 1, 2) == 1 then clear_card_mods(card) end
        if pseudorandom((seed_key or 'mirror') .. '_enh', 1, 2) == 1 then set_card_enhancement(card, random_enhancement_key((seed_key or 'mirror') .. '_enh_key')) end
        if pseudorandom((seed_key or 'mirror') .. '_seal', 1, 2) == 1 then set_card_seal(card, random_seal((seed_key or 'mirror') .. '_seal_key')) end
        if pseudorandom((seed_key or 'mirror') .. '_edition', 1, 2) == 1 then set_card_edition(card, random_edition((seed_key or 'mirror') .. '_edition_key', true), true) end
    end
end

local function random_center(pool, seed_key, predicate)
    local keys = {}
    for k, v in pairs((G and G.P_CENTERS) or {}) do
        if v and v.set == pool and (not predicate or predicate(v, k)) then
            keys[#keys + 1] = k
        end
    end
    return rand_choice(keys, seed_key or pool)
end

local function random_joker_key(seed_key, rarity)
    return random_center('Joker', seed_key or 'joker', function(center)
        if center.no_collection then return false end
        if rarity and center.rarity ~= rarity then return false end
        return true
    end)
end


local function rare_or_legendary_joker_key(seed_key)
    -- Jiangshi reward: usually Rare, rarely Legendary. This is explicit, unlike
    -- Judgement-style generic Joker creation, because Jiangshi is meant to be a
    -- high-risk spectral payoff after making everything Perishable.
    local roll = pseudorandom(seed_key or 'jiangshi_reward_roll', 1, 10)
    local rarity = (roll == 1) and 4 or 3
    local key = random_joker_key((seed_key or 'jiangshi_reward') .. '_' .. rarity, rarity)
    if key then return key end
    if rarity == 4 then return random_joker_key((seed_key or 'jiangshi_reward') .. '_fallback_rare', 3) end
    return random_joker_key((seed_key or 'jiangshi_reward') .. '_fallback_any')
end

local function random_consumable_key(seed_key, set)
    -- The previous version accidentally searched for centers with v.set == nil
    -- when no set was provided, so every random Tarot/Planet/Spectral creation
    -- returned nil. This is why Destiny, Nirvana, Offering, Possession, Purity,
    -- and similar creation effects looked like they did nothing.
    local keys = {}
    for k, center in pairs(G.P_CENTERS or {}) do
        if center and type(k) == 'string' and center.set then
            local is_consumable = center.set == 'Tarot' or center.set == 'Planet' or center.set == 'Spectral'
            if is_consumable and (not set or center.set == set) and not center.no_collection then
                keys[#keys + 1] = k
            end
        end
    end
    return rand_choice(keys, seed_key or 'consumable')
end

local function edition_table_for(edition)
    if not edition then return nil end
    local edition_table = {}
    if edition == 'foil' then edition_table.foil = true
    elseif edition == 'holo' or edition == 'holographic' then edition_table.holo = true
    elseif edition == 'polychrome' then edition_table.polychrome = true
    elseif edition == 'negative' then edition_table.negative = true
    elseif edition == 'refined' then edition_table[FB_PREFIX .. '_refined'] = true
    else return nil end
    return edition_table
end

local function apply_edition_immediate(card, edition)
    -- Newly-created cards need their edition before add_to_deck/emplace so
    -- Negative can correctly bypass/expand slot limits. Do not animate this path.
    local edition_table = edition_table_for(edition)
    if card and edition_table then card:set_edition(edition_table, true) end
end

local function create_card_to_area(set, area, key, edition, ignore_slots)
    if not (G and G.P_CENTERS and create_card) then return nil end

    local center = key and G.P_CENTERS[key] or nil
    if key and not center then return nil end

    set = set or (center and center.set)
    if not set then return nil end

    if set == 'Joker' then
        area = area or G.jokers
        if not area then return nil end
        if not ignore_slots and free_joker_slots() <= 0 and edition ~= 'negative' then return nil end
    else
        area = area or G.consumeables
        if not area then return nil end
        -- Do not hard-block consumable creation when the consumeable tray is full.
        -- Most Spectral effects create during the use of another consumable, while
        -- that source card is still occupying a slot. A strict pre-use slot check
        -- makes valid effects silently fail. Negative still works as usual.
    end

    local card = create_card(set, area, nil, nil, nil, nil, key, FB_PREFIX .. '_' .. (key or set))
    if not card then return nil end

    -- Edition first, then add_to_deck, then emplace. This order matters for
    -- Negative consumables/Jokers because add_to_deck is what updates limits.
    if edition then apply_edition_immediate(card, edition) end
    if card.add_to_deck then card:add_to_deck() end
    area:emplace(card)
    if card.start_materialize then card:start_materialize() end

    return card
end

local function create_random_joker(seed_key, rarity, edition, ignore_slots)
    if not ignore_slots and free_joker_slots() <= 0 and edition ~= 'negative' then return nil end

    -- No forced rarity: use Balatro/SMODS' normal Joker pool, like Judgement.
    -- This respects shop-pool rules and avoids Legendary+ unless the current game
    -- rules/vouchers/pools actually allow them.
    if not rarity then
        return create_card_to_area('Joker', G.jokers, nil, edition, ignore_slots)
    end

    -- Explicit rarity requests, such as Ascension/Mandate, still use a filtered key.
    -- ignore_slots is for destroy-then-create Spectrals, because dissolve frees the slot later.
    local key = random_joker_key(seed_key or 'random_joker', rarity)
    if not key then return nil end
    return create_card_to_area('Joker', G.jokers, key, edition, ignore_slots)
end

local function create_random_consumable(seed_key, set, edition)
    -- Same reason as create_card_to_area: creation usually happens while the
    -- consumed Spectral still occupies a slot, so do not pre-emptively fail here.
    local key = random_consumable_key(seed_key or 'random_consumable', set)
    if not key then return nil end
    return create_card_to_area(G.P_CENTERS[key].set, G.consumeables, key, edition)
end

local function create_soul_or_black_hole(seed_key)
    local key = rand_choice({'c_soul', 'c_black_hole'}, seed_key or 'soul_black_hole')
    local center = key and G.P_CENTERS and G.P_CENTERS[key]
    return center and create_card_to_area(center.set, G.consumeables, key) or nil
end

local function create_random_tag(seed_key)
    local tag_keys = {}
    for k, v in pairs(G.P_TAGS or {}) do
        tag_keys[#tag_keys + 1] = k
    end
    local key = rand_choice(tag_keys, seed_key or 'tag')
    if key and add_tag then add_tag(Tag(key)) end
end

local function create_specific_tag(key)
    if key and G and G.P_TAGS and G.P_TAGS[key] and add_tag and Tag then
        add_tag(Tag(key))
        return true
    end
    return false
end

local function selected_playing_cards()
    return (G and G.hand and G.hand.highlighted) or {}
end

local function selected_jokers()
    return (G and G.jokers and G.jokers.highlighted) or {}
end

local function exactly_one_selected_card_or_joker()
    local h = selected_playing_cards()
    local j = selected_jokers()
    if (#h + #j) ~= 1 then return nil end
    return h[1] or j[1]
end


local function playing_card_has_modifier(card)
    if not card then return false end
    local center_key = card.config and card.config.center and card.config.center.key
    return (center_key and center_key ~= 'c_base') or card.seal or card.edition
end

playing_card_enhancement_key = function(card)
    local key = card and card.config and card.config.center and card.config.center.key
    if key and key ~= 'c_base' then return key end
    return nil
end

card_has_seal = function(card, seal)
    return card and seal and card.seal == seal
end

card_has_edition = function(card, edition)
    if not card or not edition then return false end
    if edition == 'foil' then return card.edition and card.edition.foil
    elseif edition == 'holo' or edition == 'holographic' then return card.edition and card.edition.holo
    elseif edition == 'polychrome' then return card.edition and card.edition.polychrome
    elseif edition == 'negative' then return card.edition and card.edition.negative
    elseif edition == 'refined' then return card.edition and card.edition[FB_PREFIX .. '_refined']
    end
    return false
end

card_has_any_edition = function(card)
    return card and card.edition ~= nil
end

random_enhancement_key_for_card = function(card, seed_key)
    local current = playing_card_enhancement_key(card)
    local keys = {}
    for k, v in pairs((G and G.P_CENTERS) or {}) do
        if type(k) == 'string' and k:sub(1, 2) == 'm_' and k ~= 'm_stone' and k ~= current then
            keys[#keys + 1] = k
        end
    end
    return rand_choice(keys, seed_key or 'enhancement_for_card')
end

card_can_gain_any_enhancement = function(card)
    return card and random_enhancement_key_for_card(card, 'can_gain_enhancement') ~= nil
end

joker_can_be_made_eternal = function(card)
    return card and card.ability and not card.ability.eternal
end

joker_can_be_debuffed_by_jiangshi = function(card)
    return card and card.ability and not card.ability.fb_jiangshi_permadebuff and not card.ability.eternal
end

local function consumable_copy_candidates(exclude_card)
    local out = {}
    for _, c in ipairs(consumeable_cards()) do
        local center = c.config and c.config.center
        if c ~= exclude_card and center and center.set and center.set ~= 'Booster' then
            out[#out + 1] = c
        end
    end
    return out
end

local function random_non_spectral_consumable_key(seed_key)
    local keys = {}
    for k, center in pairs(G.P_CENTERS or {}) do
        if center and type(k) == 'string' and center.set and not center.no_collection then
            if center.set == 'Tarot' or center.set == 'Planet' then
                keys[#keys + 1] = k
            end
        end
    end
    return rand_choice(keys, seed_key or 'non_spectral_consumable')
end

local function rarity_up(r)
    if r == 1 or r == 'Common' then return 2 end
    if r == 2 or r == 'Uncommon' then return 3 end
    if r == 3 or r == 'Rare' then return 4 end
    return nil
end

local function is_legendary(card)
    return card and card.config and card.config.center and (card.config.center.rarity == 4 or card.config.center.rarity == 'Legendary')
end

local function rarity_value(card)
    local rarity = card and card.config and card.config.center and card.config.center.rarity
    if rarity == 'Common' or rarity == 'common' then return 1 end
    if rarity == 'Uncommon' or rarity == 'uncommon' then return 2 end
    if rarity == 'Rare' or rarity == 'rare' then return 3 end
    if rarity == 'Legendary' or rarity == 'legendary' then return 4 end
    -- Fabulous Beasts / external custom rarity reference:
    -- SMODS.Rarity({ key = 'exotic', ... }) stores center.rarity as 'exotic'.
    if rarity == 'Exotic' or rarity == 'exotic' then return 5 end
    return tonumber(rarity) or 0
end

local function is_legendary_or_higher(card)
    return rarity_value(card) >= 4
end

local function is_exotic(card)
    local rarity = card and card.config and card.config.center and card.config.center.rarity
    return rarity == 'exotic' or rarity == 'Exotic' or rarity_value(card) >= 5
end

local function permanent_gain_run_resource(resource, amount)
    amount = amount or 1
    if not G then return end
    G.GAME = G.GAME or {}
    G.GAME.round_resets = G.GAME.round_resets or {}
    G.GAME.round_resets[resource] = (G.GAME.round_resets[resource] or 0) + amount
    if G.GAME.current_round and G.GAME.current_round[resource .. '_left'] ~= nil then
        G.GAME.current_round[resource .. '_left'] = G.GAME.current_round[resource .. '_left'] + amount
    end
end

local function permanent_gain_consumable_slot(amount)
    amount = amount or 1
    if G and G.consumeables and G.consumeables.config then
        G.consumeables.config.card_limit = (G.consumeables.config.card_limit or 0) + amount
    end
end

local function permanent_gain_joker_slot(amount)
    amount = amount or 1
    if G and G.jokers and G.jokers.config then
        G.jokers.config.card_limit = (G.jokers.config.card_limit or 0) + amount
    end
end

local function not_legendary_jokers()
    local out = {}
    for _, j in ipairs(joker_cards()) do
        if not is_legendary(j) and not (j.ability and j.ability.eternal) then out[#out + 1] = j end
    end
    return out
end

local function legendary_jokers()
    local out = {}
    for _, j in ipairs(joker_cards()) do
        if is_legendary(j) and not (j.ability and j.ability.eternal) then out[#out + 1] = j end
    end
    return out
end

local function random_destroyable_joker(seed_key)
    local candidates = {}
    for _, j in ipairs(joker_cards()) do
        if not (j.ability and j.ability.eternal) then candidates[#candidates + 1] = j end
    end
    return rand_choice(candidates, seed_key or 'destroyable_joker')
end

local function make_jokers_debuffed_until_blind_complete()
    -- Tribulation should last through the current blind/round, not clear from
    -- an early generic update tick. Mark only the Jokers it affected so we do
    -- not accidentally clear other debuffs.
    FB.tribulation_debuff_active = true
    for _, j in ipairs(joker_cards()) do
        j.ability = j.ability or {}
        j.ability.fb_tribulation_debuff = true
        j.debuff = true
    end
end

local function clear_tribulation_debuffs()
    if not FB.tribulation_debuff_active then return end
    FB.tribulation_debuff_active = false
    for _, j in ipairs(joker_cards()) do
        if j.ability and j.ability.fb_tribulation_debuff then
            j.ability.fb_tribulation_debuff = nil
            -- Do not clear Jiangshi's permanent debuff.
            if not j.ability.fb_jiangshi_permadebuff then
                j.debuff = false
            end
        end
    end
end

-- Call this from your end-of-round / blind-complete hook if you already have one.
-- This intentionally clears Tribulation only when the blind/round is completed.
function FB.Spectral.end_round_update()
    clear_tribulation_debuffs()
end

-- Extra safety: if this file is loaded in a context where no external hook calls
-- FB.Spectral.end_round_update(), clear on cash out, which is Balatro's normal
-- post-blind completion flow.
if G and G.FUNCS and G.FUNCS.cash_out and not FB.Spectral._cash_out_hooked then
    FB.Spectral._cash_out_hooked = true
    local fb_cash_out_ref = G.FUNCS.cash_out
    G.FUNCS.cash_out = function(e)
        clear_tribulation_debuffs()
        return fb_cash_out_ref(e)
    end
end

-- Jiangshi's permanent Joker debuff must survive normal set_debuff(false) calls.
-- This wrapper only re-applies our explicit permanent flag after vanilla/modded
-- debuff logic has done its thing.
if Card and Card.set_debuff and not FB.Spectral._set_debuff_hooked then
    FB.Spectral._set_debuff_hooked = true
    local fb_set_debuff_ref = Card.set_debuff
    function Card:set_debuff(should_debuff, ...)
        -- Normalize playing cards before vanilla/modded debuff logic touches them.
        -- This prevents nil numeric comparisons from custom enhancements, without
        -- setting perma_debuff, which would make normal enhanced cards stay debuffed.
        if self and self.config and self.config.center and self.config.center.set ~= 'Joker' then
            normalize_playing_card_ability(self)
        end

        local ret = fb_set_debuff_ref(self, should_debuff, ...)

        -- Re-apply our explicit Joker debuffs after vanilla/other mods recalculate.
        -- Otherwise Tribulation can be wiped immediately by set_debuff(false).
        if self and self.ability and (self.ability.fb_jiangshi_permadebuff or self.ability.fb_tribulation_debuff) then
            self.debuff = true
        end
        return ret
    end
end

local function held_face_cards()
    local out = {}
    for _, c in ipairs(held_cards()) do
        local id = c:get_id()
        if id == 11 or id == 12 or id == 13 then out[#out + 1] = c end
    end
    return out
end


local function selected_single_playing_card()
    local h = selected_playing_cards()
    if h and #h == 1 then return h[1] end
    return nil
end

local function apply_random_talisman_to_card(card, seed_key)
    if not (card and FB and FB.apply_talisman and FB.random_talisman_base_key) then return false end
    local key = FB.random_talisman_base_key(seed_key or 'jiangshi_talisman')
    return key and FB.apply_talisman(card, key) or false
end

local function card_rank_chip_value(card)
    if not card then return 0 end
    if card.get_id then
        local ok, id = pcall(function() return card:get_id() end)
        if ok and type(id) == 'number' then
            if id == 14 then return 11 end
            if id >= 11 and id <= 13 then return 10 end
            if id >= 2 and id <= 10 then return id end
        end
    end
    local id = card.base and card.base.id
    if type(id) == 'number' then
        if id == 14 then return 11 end
        if id >= 11 and id <= 13 then return 10 end
        if id >= 2 and id <= 10 then return id end
    end
    local nominal = card.base and card.base.nominal
    if type(nominal) == 'number' then return math.max(0, math.floor(nominal)) end
    return 0
end

local function card_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

local function card_has_talisman(card)
    return FB and FB.has_talisman and FB.has_talisman(card) or false
end

local function incense_card_value(card)
    if not card then return 0 end
    local key = card_center_key(card)
    local amount = card_rank_chip_value(card)

    -- Base is the chips the card would give before editions/seals/talismans.
    if key == 'm_stone' then
        amount = 50
    elseif key == 'm_bonus' then
        amount = amount + 30
    end

    local enhanced = key and key ~= 'c_base'
    if enhanced then amount = amount + 1 end
    if card.seal or card_has_talisman(card) then amount = amount + 3 end

    if card.edition then
        if card.edition.foil then amount = amount + 5 end
        if card.edition.holo or card.edition.holographic then amount = amount + 10 end
        if card.edition.polychrome then amount = math.floor(amount * 1.5) end
    end

    local suit = card.base and card.base.suit
    if suit == 'Diamonds' or suit == 'D' then amount = amount * 2 end

    return math.max(0, math.floor(amount))
end

local function use_context(card, area, copier)
    return {card = card, area = area, copier = copier}
end

local function register_spectral(def)
    if not (SMODS and SMODS.Consumable and def and def.key) then return end
    FB.Spectral._registered_keys = FB.Spectral._registered_keys or {}
    if FB.Spectral._registered_keys[def.key] then return end
    FB.Spectral._registered_keys[def.key] = true

    SMODS.Consumable {
        key = def.key,
        set = 'Spectral',
        atlas = def.atlas or 'fb_spectral',
        pos = def.pos or {x = 0, y = 0},
        config = def.config or {},
        loc_txt = {
            name = def.name,
            text = def.text,
        },
        can_use = def.can_use or function(self, card) return true end,
        use = function(self, card, area, copier)
            -- Omen intentionally uses the consumable used BEFORE Omen.
            if def.use then def.use(use_context(card, area, copier)) end

            -- Record after use so Omen copies the previous consumable, not itself.
            if def.key ~= 'omen' and card and card.config and card.config.center then
                FB.Spectral.last_used_consumable_key = card.config.center.key
                FB.Spectral.last_used_consumable_set = card.config.center.set or 'Spectral'
            end
        end,
    }
end

-- ------------------------------------------------------------
-- The 36 Spectral Cards
-- ------------------------------------------------------------

local S = {}

S[#S+1] = {
    key='duality', name='Duality', pos={x=0,y=0},
    text={'Destroy a random {C:attention}Joker{}', 'Each held card gains a random', '{C:attention}Enhancement{}, {C:attention}Seal{}, or {C:attention}Edition{}'},
    can_use=function() return #joker_cards() > 0 and #held_cards() > 0 end,
    use=function()
        safe_destroy_joker(random_destroyable_joker('duality_joker'))
        for i,c in ipairs(held_cards()) do
            local roll = pseudorandom('duality_roll_'..i, 1, 3)
            if roll == 1 then set_card_enhancement(c, random_enhancement_key_for_card(c, 'duality_enh_'..i))
            elseif roll == 2 then set_card_seal(c, random_seal('duality_seal_'..i))
            else set_card_edition(c, random_edition('duality_ed_'..i, true), true) end
        end
    end,
}

S[#S+1] = {
    key='infinity', name='Infinity', pos={x=1,y=0},
    text={'Select 1 non-Eternal Joker', 'Make it {C:dark_edition}Eternal{}', 'Gain {X:money,C:white}$2X{} its sell value'},
    can_use=function(self, card)
        local j = G.jokers and G.jokers.highlighted and G.jokers.highlighted[1]
        return G.jokers and G.jokers.highlighted and #G.jokers.highlighted == 1 and joker_can_be_made_eternal(j)
    end,
    use=function()
        local j = G.jokers.highlighted[1]
        if j then
            j.ability.eternal = true
            ease_dollars((j.sell_cost or 0) * 2)
        end
    end,
}

S[#S+1] = {
    key='banishment', name='Banishment', pos={x=2,y=0},
    text={'Destroy all held cards,', 'Consumables, and Jokers', 'Set Ante to {C:red}-1{}', 'Create {C:attention}Mortal Realm{}'},
    use=function()
        destroy_cards(copy_list(held_cards()))
        destroy_cards(copy_list(consumeable_cards()))
        destroy_cards(copy_list(joker_cards()))
        if G.GAME and G.GAME.round_resets then G.GAME.round_resets.ante = -1 end
        create_card_to_area('Joker', G.jokers, 'j_' .. FB_PREFIX .. '_mortal_realm', nil, true)
    end,
}

S[#S+1] = {
    key='karma', name='Karma', pos={x=3,y=0},
    text={'Destroy all held cards', 'or give a random Joker', 'a random {C:dark_edition}Edition{}'},
    can_use=function() return #held_cards() > 0 or #joker_cards() > 0 end,
    use=function()
        if pseudorandom('karma', 1, 2) == 1 then
            for _, c in ipairs(copy_list(held_cards())) do safe_destroy_playing_card(c) end
        else
            local j = rand_choice(joker_cards(), 'karma_joker')
            if j then set_card_edition(j, random_edition('karma_ed', true), true) end
        end
    end,
}

S[#S+1] = {
    key='jiangshi', name='Jiangshi', pos={x=4,y=0},
    text={'Select 1 card', 'Apply a random {C:attention}Talisman{}'},
    can_use=function()
        local c = selected_single_playing_card()
        return c ~= nil and FB and FB.apply_talisman and FB.random_talisman_base_key
    end,
    use=function()
        local c = selected_single_playing_card()
        if c then apply_random_talisman_to_card(c, 'jiangshi_talisman') end
    end,
}

S[#S+1] = {
    key='immortality', name='Immortality', pos={x=5,y=0},
    text={'All non-Eternal Jokers', 'become {C:dark_edition}Eternal{}'},
    can_use=function()
        for _, j in ipairs(joker_cards()) do if joker_can_be_made_eternal(j) then return true end end
        return false
    end,
    use=function() for _, j in ipairs(joker_cards()) do if joker_can_be_made_eternal(j) then j.ability.eternal = true end end end,
}

S[#S+1] = {
    key='fate', name='Fate', pos={x=6,y=0},
    text={'Destroy a {C:legendary}Legendary{} Joker', 'All held cards gain a random', 'Enhancement, Seal, and Edition'},
    can_use=function() return #legendary_jokers() > 0 and #held_cards() > 0 end,
    use=function()
        safe_destroy_joker(rand_choice(legendary_jokers(), 'fate_legendary'))
        for i,c in ipairs(held_cards()) do
            set_card_enhancement(c, random_enhancement_key_for_card(c, 'fate_enh_'..i))
            set_card_seal(c, random_seal('fate_seal_'..i))
            set_card_edition(c, random_edition('fate_ed_'..i, true), true)
        end
    end,
}

S[#S+1] = {
    key='destiny', name='Destiny', pos={x=7,y=0},
    text={'Create a random {C:attention}Joker{},', '{C:attention}Consumable{}, and {C:attention}Tag{}'},
    use=function()
        create_random_joker('destiny_joker')
        create_random_consumable('destiny_consumable')
        create_random_tag('destiny_tag')
    end,
}

S[#S+1] = {
    key='mandate', name='Mandate', pos={x=8,y=0},
    text={'Destroy a random', 'non-Legendary Joker', 'Create a Joker one rarity higher'},
    can_use=function() return #not_legendary_jokers() > 0 end,
    use=function()
        local j = rand_choice(not_legendary_jokers(), 'mandate_joker')
        if not j then return end
        local new_rarity = rarity_up(j.config.center.rarity)
        safe_destroy_joker(j)
        if new_rarity then create_random_joker('mandate_new', new_rarity, nil, true) end
    end,
}

S[#S+1] = {
    key='ascension', name='Ascension', pos={x=9,y=0},
    text={'Destroy all held cards', 'and a random Joker', 'Create a random {C:dark_edition}Edition{}', '{C:legendary}Legendary{} Joker'},
    can_use=function() return random_destroyable_joker('ascension_check') ~= nil end,
    use=function()
        for _, c in ipairs(copy_list(held_cards())) do safe_destroy_playing_card(c) end
        safe_destroy_joker(random_destroyable_joker('ascension_joker'))
        create_random_joker('ascension_legendary', 4, random_edition('ascension_ed', true), true)
    end,
}

S[#S+1] = {
    key='yaoguai', name='Yaoguai', pos={x=0,y=1},
    text={'Destroy all held face cards', 'Draw an equal number of', '{C:attention}sealed Aces{} to hand'},
    can_use=function() return #held_face_cards() > 0 end,
    use=function()
        local faces = held_face_cards()
        local n = #faces
        for _, c in ipairs(faces) do safe_destroy_playing_card(c) end
        for i=1,n do make_playing_card('A', random_suit('yaoguai_suit_'..i), G.hand, nil, random_seal('yaoguai_seal_'..i), nil) end
    end,
}

S[#S+1] = {
    key='tribulation', name='Tribulation', pos={x=1,y=1},
    text={'All held cards gain random', 'Enhancement, Seal, or Edition', 'All Jokers are debuffed', 'until this blind is completed'},
    can_use=function() return #held_cards() > 0 end,
    use=function()
        for i,c in ipairs(held_cards()) do
            local roll = pseudorandom('tribulation_roll_'..i, 1, 3)
            if roll == 1 then set_card_enhancement(c, random_enhancement_key_for_card(c, 'tribulation_enh_'..i))
            elseif roll == 2 then set_card_seal(c, random_seal('tribulation_seal_'..i))
            else set_card_edition(c, random_edition('tribulation_ed_'..i, true), true) end
        end
        make_jokers_debuffed_until_blind_complete()
    end,
}

S[#S+1] = {
    key='enlightenment', name='Enlightenment', pos={x=2,y=1},
    text={'Select 1 card', 'Give it a random Enhancement,', 'Seal, and Edition'},
    can_use=function() return G.hand and G.hand.highlighted and #G.hand.highlighted == 1 end,
    use=function()
        local c = G.hand.highlighted[1]
        set_card_enhancement(c, random_enhancement_key_for_card(c, 'enlightenment_enh'))
        set_card_seal(c, random_seal('enlightenment_seal'))
        set_card_edition(c, random_edition('enlightenment_ed', true), true)
        c.ability = c.ability or {}
    end,
}

S[#S+1] = {
    key='nirvana', name='Nirvana', pos={x=3,y=1},
    text={'Remove all Editions and Stickers', 'from Jokers', 'Create a random {C:dark_edition}Negative{}', 'Consumable for each one removed'},
    can_use=function() return #joker_cards() > 0 end,
    use=function()
        local count = 0
        for _, j in ipairs(joker_cards()) do count = count + clear_joker_stickers_and_edition(j) end
        for i=1,count do create_random_consumable('nirvana_'..i, nil, 'negative') end
    end,
}

S[#S+1] = {
    key='rebirth', name='Rebirth', pos={x=4,y=1},
    text={'Destroy a random Joker with an Edition', 'Apply that Edition to all other', 'unedited Jokers', '{C:dark_edition}Negative{} becomes Polychrome'},
    can_use=function()
        for _, j in ipairs(joker_cards()) do if joker_has_edition(j) and not (j.ability and j.ability.eternal) then return true end end
        return false
    end,
    use=function()
        local candidates = {}
        for _, j in ipairs(joker_cards()) do if joker_has_edition(j) and not (j.ability and j.ability.eternal) then candidates[#candidates+1]=j end end
        local source = rand_choice(candidates, 'rebirth_source')
        if not source then return end
        local ed = edition_name(source)
        if ed == 'negative' then ed = 'polychrome' end
        safe_destroy_joker(source)
        for _, j in ipairs(joker_cards()) do if not joker_has_edition(j) then set_card_edition(j, ed, true) end end
    end,
}

S[#S+1] = {
    key='apotheosis', name='Apotheosis', pos={x=5,y=1},
    text={'Destroy a random {C:attention}other{} Consumable', 'Create {C:spectral}The Soul{} or {C:planet}Black Hole{}'},
    can_use=function(self, card)
        if not G.consumeables or not G.consumeables.cards then return false end
        for _, c in ipairs(G.consumeables.cards) do
            if c ~= card and c.config and c.config.center and c.config.center.set ~= 'Booster' then
                return true
            end
        end
        return false
    end,
    use=function(ctx)
        local candidates = {}
        if G.consumeables and G.consumeables.cards then
            for _, c in ipairs(G.consumeables.cards) do
                if c ~= ctx.card and c.config and c.config.center and c.config.center.set ~= 'Booster' then
                    candidates[#candidates + 1] = c
                end
            end
        end

        local target = rand_choice(candidates, 'apotheosis_target')
        if not target then return end

        dissolve_card(target)
        create_soul_or_black_hole('apotheosis')
    end,
}

S[#S+1] = {
    key='exorcism', name='Exorcism', pos={x=6,y=1},
    text={'Remove all Seals from held cards', 'Create a random {C:attention}Tag{}', 'for each removed Seal'},
    can_use=function() for _,c in ipairs(held_cards()) do if c.seal then return true end end return false end,
    use=function()
        local n = 0
        for _, c in ipairs(held_cards()) do if c.seal then c:set_seal(nil, nil, true); n=n+1 end end
        for i=1,n do create_random_tag('exorcism_'..i) end
    end,
}

S[#S+1] = {
    key='requiem', name='Requiem', pos={x=7,y=1},
    text={'Select 1 card', 'Destroy it and create', 'a random non-{C:spectral}Spectral{}', '{C:attention}Consumable{}'},
    can_use=function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1 and random_non_spectral_consumable_key('requiem_check') ~= nil
    end,
    use=function()
        local c = G.hand and G.hand.highlighted and G.hand.highlighted[1]
        if not c then return end
        local key = random_non_spectral_consumable_key('requiem_consumable')
        if not key then return end
        safe_destroy_playing_card(c)
        local center = G.P_CENTERS[key]
        if center then create_card_to_area(center.set, G.consumeables, key) end
    end,
}

S[#S+1] = {
    key='offering', name='Offering', pos={x=8,y=1},
    text={'Turn all Consumables', 'into random {C:spectral}Spectral{} cards'},
    can_use=function() return #consumeable_cards() > 0 end,
    use=function()
        local count = #consumeable_cards()
        destroy_cards(copy_list(consumeable_cards()))
        for i=1,count do create_random_consumable('offering_'..i, 'Spectral') end
    end,
}

S[#S+1] = {
    key='incense', name='Incense', pos={x=0,y=2},
    text={'Destroy 1 selected card', 'Gain {C:money}money{} based on its', '{C:attention}chips and modifiers{}'},
    can_use=function()
        return selected_single_playing_card() ~= nil
    end,
    use=function()
        local c = selected_single_playing_card()
        if not c then return end
        local dollars = incense_card_value(c)
        safe_destroy_playing_card(c)
        if dollars > 0 and ease_dollars then ease_dollars(dollars) end
    end,
}

S[#S+1] = {
    key='fengshui', name='Fengshui', pos={x=1,y=2},
    text={'Randomly redistribute current', '{C:attention}Enhancements{}', 'among held cards'},
    can_use=function()
        if #held_cards() <= 1 then return false end
        for _, c in ipairs(held_cards()) do
            local key = c.config and c.config.center and c.config.center.key
            if key and key ~= 'c_base' then return true end
        end
        return false
    end,
    use=function()
        local cards = held_cards()
        local enh = {}
        for _, c in ipairs(cards) do
            local key = c.config and c.config.center and c.config.center.key
            enh[#enh + 1] = (key and key ~= 'c_base') and key or nil
            if key and key ~= 'c_base' and not is_protected(c) then
                flip_card_for_change(c, function() c:set_ability(G.P_CENTERS.c_base, nil, true) end)
            end
        end
        shuffle_in_place(enh, 'fengshui_enh')
        for i, c in ipairs(cards) do
            if enh[i] and G.P_CENTERS[enh[i]] and not is_protected(c) then
                set_card_enhancement(c, enh[i])
            end
        end
    end,
}

S[#S+1] = {
    key='mirror', name='Mirror', pos={x=2,y=2},
    text={'Turn all held cards', 'into random cards', 'May gain Enhancements, Seals,', 'and/or Editions'},
    can_use=function() return #held_cards() > 0 end,
    use=function() for i,c in ipairs(held_cards()) do randomize_existing_playing_card(c, 'mirror_'..i, true) end end,
}

S[#S+1] = {
    key='smite', name='Smite', pos={x=3,y=2},
    text={'Destroy 1 selected', '{C:legendary}Legendary{} or higher Joker', 'Permanently gain {C:attention}+1{} Hand,', '{C:attention}+1{} Discard, and', '{C:attention}+1{} Consumable Slot'},
    can_use=function()
        local j = G and G.jokers and G.jokers.highlighted and G.jokers.highlighted[1]
        return G and G.jokers and G.jokers.highlighted and #G.jokers.highlighted == 1
            and is_legendary_or_higher(j)
            and not is_protected(j)
            and not (j.ability and j.ability.eternal)
    end,
    use=function()
        local j = G and G.jokers and G.jokers.highlighted and G.jokers.highlighted[1]
        if not (j and is_legendary_or_higher(j)) then return end

        local exotic = is_exotic(j)
        if not safe_destroy_joker(j) then return end

        permanent_gain_run_resource('hands', 1)
        permanent_gain_run_resource('discards', 1)
        permanent_gain_consumable_slot(1)
        if exotic then permanent_gain_joker_slot(1) end
    end,
}

S[#S+1] = {
    key='balance', name='Balance', pos={x=4,y=2},
    text={'Turn all held cards into', 'a random selected card in hand', '{C:red}-1{} hand size'},
    can_use=function() return #held_cards() > 0 end,
    use=function()
        local source = rand_choice(held_cards(), 'balance_source')
        if not source then return end
        local front = source.config.card
        for _, c in ipairs(held_cards()) do
            if not is_protected(c) then
                flip_card_for_change(c, function() c:set_base(front) end)
            end
        end
        G.hand:change_size(-1)
    end,
}

S[#S+1] = {
    key='essence', name='Essence', pos={x=5,y=2},
    text={'Select 1 modified card', 'Remove its modifiers', 'Create a random Joker for each', '{C:inactive}(must have room)'},
    can_use=function()
        if not (G.hand and G.hand.highlighted and #G.hand.highlighted == 1) then return false end
        local c = G.hand.highlighted[1]
        return (c.seal or c.edition or (c.config and c.config.center and c.config.center.key ~= 'c_base')) and free_joker_slots() > 0
    end,
    use=function()
        local c = G.hand.highlighted[1]
        local n = clear_card_mods(c)
        for i=1,math.min(n, free_joker_slots()) do create_random_joker('essence_'..i) end
    end,
}

S[#S+1] = {
    key='harmony', name='Harmony', pos={x=6,y=2},
    text={'Remove all Joker Editions', 'Randomly apply them', 'to other Jokers'},
    can_use=function()
        for _, j in ipairs(joker_cards()) do
            if joker_has_edition(j) then return true end
        end
        return false
    end,
    use=function()
        local eds = {}

        -- Collect editions and remove them from Jokers
        for _, j in ipairs(joker_cards()) do
            local ed = edition_name(j)

            if ed then
                eds[#eds+1] = ed

                -- Clear edition only; do not touch enhancement/seal/etc.
                j.edition = nil

                if j.ability then
                    j.ability.edition = nil
                end

                -- Some versions cache edition flags directly on ability.
                if j.ability then
                    j.ability.foil = nil
                    j.ability.holo = nil
                    j.ability.polychrome = nil
                    j.ability.negative = nil
                end
            end
        end

        -- Reapply editions to random Jokers without editions
        for i, ed in ipairs(eds) do
            local candidates = {}

            for _, j in ipairs(joker_cards()) do
                if not joker_has_edition(j) then
                    candidates[#candidates+1] = j
                end
            end

            local target = rand_choice(candidates, 'harmony_' .. i)

            if target then
                set_card_edition(target, ed, true)
            end
        end
    end,
}

S[#S+1] = {
    key='insight', name='Insight', pos={x=7,y=2},
    text={'+1 hand size'},
    use=function() G.hand:change_size(1) end,
}

S[#S+1] = {
    key='oblivion', name='Oblivion', pos={x=8,y=2},
    text={'Remove all modifiers from', 'held cards and Jokers', 'Create {C:spectral}The Soul{}', 'or {C:planet}Black Hole{}'},
    use=function()
        for _, c in ipairs(held_cards()) do clear_card_mods(c) end
        for _, j in ipairs(joker_cards()) do clear_joker_stickers_and_edition(j) end
        create_soul_or_black_hole('oblivion')
    end,
}

S[#S+1] = {
    key='omen', name='Omen', pos={x=9,y=2},
    text={'Create 4 {C:dark_edition}Negative{} copies', 'of the most recently used', '{C:attention}Consumable{}'},
    can_use=function(self, card)
        local key = FB.Spectral.last_used_consumable_key
        return key and G and G.P_CENTERS and G.P_CENTERS[key] and key ~= 'c_fb_omen'
    end,
    use=function(ctx)
        local key = FB.Spectral.last_used_consumable_key
        local center = key and G and G.P_CENTERS and G.P_CENTERS[key]
        if not center or not center.set then return end
        for i=1,4 do create_card_to_area(center.set, G.consumeables, key, 'negative') end
    end,
}


S[#S+1] = {
    key='possession', name='Possession', pos={x=0,y=3},
    text={'Fill empty Joker slots', 'with random Jokers', 'Fill empty Consumable slots', 'with random Consumables'},
    use=function()
        local js = free_joker_slots()
        for i=1,js do create_random_joker('possession_joker_'..i) end
        local cs = free_consumeable_slots()
        for i=1,cs do create_random_consumable('possession_cons_'..i) end
    end,
}

S[#S+1] = {
    key='purity', name='Purity', pos={x=1,y=3},
    text={'Select 1 modified card', 'Remove its modifiers', 'Create a random {C:spectral}Spectral{}'},
    can_use=function()
        if not (G.hand and G.hand.highlighted and #G.hand.highlighted == 1) then return false end
        return playing_card_has_modifier(G.hand.highlighted[1])
    end,
    use=function()
        local c = G.hand.highlighted[1]
        if not playing_card_has_modifier(c) then return end
        clear_card_mods(c)
        create_random_consumable('purity_spectral', 'Spectral')
    end,
}

S[#S+1] = {
    key='samsara', name='Samsara', pos={x=2,y=3},
    text={'For each held card:', '1 in 4 destroy, duplicate enhanced,', 'apply Seal, or apply Edition'},
    can_use=function() return #held_cards() > 0 end,
    use=function()
        -- Snapshot first, because this effect can destroy cards or add cards to hand.
        -- Each original held card independently rolls one of the four effects.
        local cards = copy_list(held_cards())
        for i, c in ipairs(cards) do
            if c and not c.removed then
                local roll = pseudorandom('samsara_roll_' .. i, 1, 4)
                if roll == 1 then
                    safe_destroy_playing_card(c)
                elseif roll == 2 then
                    copy_playing_card_to_hand(c, 'samsara_copy_' .. i, true)
                elseif roll == 3 then
                    set_card_seal(c, random_seal('samsara_seal_' .. i))
                else
                    set_card_edition(c, random_edition('samsara_ed_' .. i, true), true)
                end
            end
        end
    end,
}

S[#S+1] = {
    key='limbo', name='Limbo', pos={x=3,y=3},
    text={
        'Select {C:attention}1{} modified card or Joker',
        'Reroll its current modifiers'
    },
    can_use=function()
        local c = exactly_one_selected_card_or_joker()
        if not c then return false end

        local has_enhancement =
            c.config and c.config.center and c.config.center.key
            and c.config.center.key ~= 'c_base'
            and c.config.center.set ~= 'Joker'

        local has_seal = c.seal ~= nil
        local has_talisman = FB and FB.has_talisman and FB.has_talisman(c)
        local has_edition = c.edition ~= nil

        return has_enhancement or has_seal or has_talisman or has_edition
    end,
    use=function()
        local c = exactly_one_selected_card_or_joker()
        if not c then return end

        -- Enhancement reroll, playing cards only
        local has_enhancement =
            c.config and c.config.center and c.config.center.key
            and c.config.center.key ~= 'c_base'
            and c.config.center.set ~= 'Joker'

        if has_enhancement then
            set_card_enhancement(c, random_enhancement_key_for_card(c, 'limbo_enh'))
        end

        -- Normal Seal reroll ONLY if it has a normal seal, not a Talisman seal
        local has_talisman = FB and FB.has_talisman and FB.has_talisman(c)
        if c.seal and not has_talisman then
            local tries = {'Red', 'Blue', 'Gold', 'Purple'}
            local choices = {}
            for _, seal in ipairs(tries) do
                if c.seal ~= seal then choices[#choices + 1] = seal end
            end
            set_card_seal(c, rand_choice(choices, 'limbo_seal'))
        end

        -- Talisman reroll ONLY if it has a Talisman
        if has_talisman and FB.random_talisman_base_key and FB.apply_talisman then
            local old = FB.get_talisman and FB.get_talisman(c)
            local choices = {}

            for _, key in ipairs(FB.TALISMAN_ORDER or {}) do
                if key ~= (old and old.key) then choices[#choices + 1] = key end
            end

            local new_key = rand_choice(choices, 'limbo_talisman')
                or FB.random_talisman_base_key('limbo_talisman_fallback')

            if new_key then
                local old_seal = old and old.seal
                local old_edition = old and old.edition
                FB.apply_talisman(c, new_key, {
                    seal = old_seal,
                    edition = old_edition,
                    created_by = 'limbo',
                })
            end
        end

        -- Edition reroll, card or Joker
        if c.edition then
            local tries = {'foil', 'holo', 'polychrome', 'negative', 'refined'}
            local choices = {}
            for _, ed in ipairs(tries) do
                if not card_has_edition(c, ed) then choices[#choices + 1] = ed end
            end
            set_card_edition(c, rand_choice(choices, 'limbo_ed'), true)
        end
    end,
}

S[#S+1] = {
    key='elixir', name='Elixir', pos={x=4,y=3},
    text={'Select 1 card or Joker', 'Apply the {C:attention}Refined{} Edition'},
    can_use=function()
        local c = exactly_one_selected_card_or_joker()
        return c ~= nil and not card_has_edition(c, 'refined')
    end,
    use=function()
        local c = exactly_one_selected_card_or_joker()
        if c then set_card_edition(c, 'refined', true) end
    end,
}

S[#S+1] = {
    key='order', name='Order', pos={x=5,y=3},
    text={'Select 5 cards', 'Each gains a random', '{C:attention}Enhancement{}'},
    can_use=function()
        if not (G.hand and G.hand.highlighted and #G.hand.highlighted == 5) then return false end
        for _, c in ipairs(G.hand.highlighted) do
            if not card_can_gain_any_enhancement(c) then return false end
        end
        return true
    end,
    use=function()
        local cards = copy_list(G.hand.highlighted or {})
        for i, c in ipairs(cards) do
            set_card_enhancement(c, random_enhancement_key_for_card(c, 'order_enh_' .. i))
        end
    end,
}

S[#S+1] = {
    key='decree', name='Decree', pos={x=6,y=3},
    text={'Create a {C:attention}Negative Tag{}', 'and a {C:attention}Double Tag{}', '{C:red}-1{} hand size'},
    can_use=function()
        return G.hand and G.hand.config and (G.hand.config.card_limit or 0) > 1
    end,
    use=function()
        create_specific_tag('tag_negative')
        create_specific_tag('tag_double')
        if G.hand and G.hand.change_size then G.hand:change_size(-1) end
    end,
}

for _, def in ipairs(S) do register_spectral(def) end

return FB.Spectral
