---@diagnostic disable: undefined-global

FabulousBeasts = FabulousBeasts or {}
FB = FabulousBeasts

-- Compatibility wrapper for older load orders.
-- Main Talisman behavior lives in talismans.lua. Do not redefine calculate hooks here.

function FB.include_forced_scoring_cards(scoring_cards, played_cards)
    return scoring_cards or {}
end

function FB.card_can_be_any_suit_and_rank(card)
    return FB.is_wild_wild and FB.is_wild_wild(card) or false
end

function FB.should_joker_force_trigger(joker)
    return false
end

function FB.extra_slots_from_talismans(area)
    local total = 0
    if not area or not area.cards then return total end
    for _, c in ipairs(area.cards) do
        local t = FB.get_talisman and FB.get_talisman(c) or nil
        if t and t.edition == "negative" then total = total + 1 end
    end
    return total
end

function FB.try_modify_card(card, fn, denied_message)
    if fn then fn(card) end
    return true
end

return FB
