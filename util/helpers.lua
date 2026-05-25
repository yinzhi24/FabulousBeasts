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
