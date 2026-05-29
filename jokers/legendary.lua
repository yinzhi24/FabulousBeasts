---@diagnostic disable: undefined-global

-- Fabulous Beasts: Legendary Jokers

SMODS.Joker({
    key = "bajin",
    loc_txt = {name = "Bajin", text = {"{X:chips,C:white}X#2#{} Chips per {C:attention}Food{} Joker", "Doubles negative Food effects", "{C:inactive}Currently {X:chips,C:white}X#1#{} Chips{}"}},
    atlas = "jokers", pos = {x = 4, y = 7}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {xchips_per_food = 8}},
    loc_vars = function(self, info_queue, card)
        local n = FB.count_food_jokers_explicit()
        return {vars = {math.max(1, (card.ability.extra.xchips_per_food or 8) * n), card.ability.extra.xchips_per_food or 8}}
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {x_chips = math.max(1, (card.ability.extra.xchips_per_food or 8) * FB.count_food_jokers_explicit()), card = card}
        end
    end
})

SMODS.Joker({
    key = "bilibili",
    loc_txt = {name = "Bilibili", text = {"{C:attention}Retrigger{} non-Legendary Jokers", "Does not target {C:attention}Exotic{} or {C:attention}Divine{} Jokers"}},
    atlas = "jokers", pos = {x = 5, y = 7}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = true,
    calculate = function(self, card, context)
        local r = context.other_card and context.other_card.config and context.other_card.config.center and context.other_card.config.center.rarity
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards and context.other_card ~= card and r ~= 4 and not FB.is_exotic_or_divine(context.other_card) and FB.once_joker_retrigger(card, context, 'bilibili') then
            return {repetitions = 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "bibi",
    loc_txt = {
        name = "Bibi",
        text = {
            "Gain {X:mult,C:white}X#2#{} Mult for each",
            "enhancement, seal, and edition",
            "in your entire deck",
            "{C:inactive}Total modifiers: #1#{}",
            "{C:inactive}Currently {X:mult,C:white}X#3#{} Mult{}"
        }
    },
    atlas = "jokers", pos = {x = 6, y = 7}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {base = 1, gain = 1}},
    loc_vars = function(self, info_queue, card)
        local total_mods = FB.count_deck_mods()
        local current_xmult =
            (card.ability.extra.base or 1)
            + total_mods * (card.ability.extra.gain or 1)

        return {
            vars = {
                total_mods,
                card.ability.extra.gain,
                current_xmult
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then return {x_mult = (card.ability.extra.base or 1) + FB.count_deck_mods() * (card.ability.extra.gain or 1), card = card} end
    end
})

SMODS.Joker({
    key = "bixie",

    loc_txt = {
        name = "Bixie",
        text = {
            "Gains {X:mult,C:white}X#2#{} Mult every round.",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {xmult = 1, gain = 1}},

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult or 1, card.ability.extra.gain or 1}}
    end,

    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {x_mult = card.ability.extra.xmult or 1, card = card}
        end

        if FB.main_end_of_round_once(card, context, 'fb_bixie_scaled') then
            card.ability.extra.xmult = (card.ability.extra.xmult or 1) + (card.ability.extra.gain or 1)
        end
    end
})

SMODS.Joker({
    key = "christina",

    loc_txt = {
        name = "Christina",
        text = {
            "{C:attention}Retrigger{} Jinchi Dapeng once for each card",
            "played."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards and FB.is_joker_key(context.other_card, 'jinchi_dapeng') and FB.once_joker_retrigger(card, context, 'christina') then
            return {repetitions = #((G.play and G.play.cards) or {}), card = card}
        end
    end
})

SMODS.Joker({
    key = "chugou",

    loc_txt = {
        name = "Chugou",
        text = {
            "Each triggered card and Joker gives {C:money}$1{}.",
            "{C:inactive}Fallback this hand: {C:money}$#1#{}{}"
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {fallback = 0}},
    loc_vars = function(self, info_queue, card)
        local cards = G.play and G.play.cards and #G.play.cards or 0
        local jokers = G.jokers and G.jokers.cards and math.max(0, #G.jokers.cards - 1) or 0
        card.ability.extra.fallback = cards + jokers
        return {vars = {card.ability.extra.fallback}}
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.fb_post_trigger_seen = false
            card.ability.fb_paid_fallback = false
        end

        if FB.is_scoring_individual(context) and context.other_card and context.other_card ~= card and not context.blueprint then
            FB.try_add_dollars(1)
            return {message = "$1", colour = G.C.MONEY, card = card}
        end

        if context.post_trigger and context.other_card and context.other_card ~= card and not context.blueprint then
            card.ability.fb_post_trigger_seen = true
            FB.try_add_dollars(1)
            return {message = "$1", colour = G.C.MONEY, card = card}
        end

        if FB.is_scoring_joker_main(context) and not context.blueprint and not card.ability.fb_post_trigger_seen and not card.ability.fb_paid_fallback then
            card.ability.fb_paid_fallback = true
            local cards = G.play and G.play.cards and #G.play.cards or 0
            local jokers = G.jokers and G.jokers.cards and math.max(0, #G.jokers.cards - 1) or 0
            local payout = cards + jokers
            if payout > 0 then
                FB.try_add_dollars(payout)
                return {message = "$" .. payout, colour = G.C.MONEY, card = card}
            end
        end
    end
})

SMODS.Joker({
    key = "dijiang",
    loc_txt = {
        name = "Dijiang",
        text = {
            "{C:attention}Retrigger{} Heart cards {C:attention}#1#{} times",
            "Comes with {C:attention}Perishable{}",
            "{C:red}Self destructs{} after {C:attention}#2#{} debuffed rounds"
        }
    },
    atlas = "jokers", pos = {x = 0, y = 8}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {repetitions = 6, debuff_rounds = 0, debuff_limit = 5}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.repetitions, card.ability.extra.debuff_limit}} end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.perishable = true
        card.ability.perish_tally = card.ability.perish_tally or 5
    end,
    calculate = function(self, card, context)
        if FB.is_card_repetition(context) and context.cardarea == G.play and context.other_card and context.other_card:is_suit('Hearts') then
            return {repetitions = card.ability.extra.repetitions or 6, card = card}
        end
        if FB.main_end_of_round_once(card, context, 'fb_dijiang_debuff_counter') and not context.blueprint then
            if card.debuff then
                card.ability.extra.debuff_rounds = (card.ability.extra.debuff_rounds or 0) + 1
                if card.ability.extra.debuff_rounds >= (card.ability.extra.debuff_limit or 5) then
                    FB.queue_self_destroy(card)
                    FB.resolve_or_defer_queued_actions(context)
                    return {message = "Destroyed!", colour = G.C.RED, card = card}
                end
            else
                card.ability.extra.debuff_rounds = 0
            end
        end
    end
})

SMODS.Joker({
    key = "diting",

    loc_txt = {
        name = "Diting",
        text = {
            "{X:attention,C:white}X#1#{} hand size"
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {hand_size_mult = 2}},

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.hand_size_mult or 2}}
    end,

    add_to_deck = function(self, card, from_debuff)
        local mult = card.ability.extra.hand_size_mult or 2
        local current = G.hand and G.hand.config and G.hand.config.card_limit or 8
        card.ability.fb_hand_delta = math.floor(current * (mult - 1))
        FB.safe_change_hand_size(card.ability.fb_hand_delta)
    end,

    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(-(card.ability.fb_hand_delta or 0))
    end
})

SMODS.Joker({
    key = "erliang",
    loc_txt = {name = "Erliang", text = {"{C:attention}Retrigger{} Bajin", "{C:attention}+#1#{} Joker slots", "{C:attention}+#2#{} consumable slot"}},
    atlas = "jokers", pos = {x = 2, y = 8}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {joker_slots = 2, consumable_slots = 1, repetitions = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.joker_slots, card.ability.extra.consumable_slots}} end,
    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(card.ability.extra.joker_slots or 2); if G.consumeables and G.consumeables.config then G.consumeables.config.card_limit = G.consumeables.config.card_limit + (card.ability.extra.consumable_slots or 1) end end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-(card.ability.extra.joker_slots or 2)); if G.consumeables and G.consumeables.config then G.consumeables.config.card_limit = G.consumeables.config.card_limit - (card.ability.extra.consumable_slots or 1) end end,
    calculate = function(self, card, context)
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards
            and FB.is_joker_key(context.other_card, 'bajin')
            and FB.once_joker_retrigger(card, context, 'erliang') then
            return {repetitions = card.ability.extra.repetitions or 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "fenz",

    loc_txt = {
        name = "Fenz",
        text = {
            "{C:attention}Retrigger{} Fabulous Beasts Jokers"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards and context.other_card ~= card and FB.has_mod_key(context.other_card) and FB.once_joker_retrigger(card, context, 'fenz') then
            return {repetitions = 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "fresh_seed",

    loc_txt = {
        name = "Fresh Seed",
        text = {
            "After {C:attention}#1#{} round, turns into {C:attention}Chugou{}"
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if FB.main_end_of_round_once(card, context, 'fb_fresh_seed_transform') then
            FB.queue_create_joker('chugou')
            FB.queue_self_destroy(card)
            FB.resolve_or_defer_queued_actions(context)
        end
    end
})

SMODS.Joker({
    key = "fuku_fuzai",
    loc_txt = {name = "Fuzai", text = {"{C:attention}Retrigger{} all {C:attention}Food{} Jokers", "{C:attention}#1#{} times"}},
    atlas = "jokers", pos = {x = 5, y = 8}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {repetitions = 3}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.repetitions}} end,
    calculate = function(self, card, context)
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards and context.other_card ~= card and FB.is_food_joker(context.other_card) and FB.once_joker_retrigger(card, context, 'fuzai') then
            return {repetitions = card.ability.extra.repetitions or 3, card = card}
        end
    end
})

SMODS.Joker({
    key = "hetao",

    loc_txt = {
        name = "Hetao",
        text = {
            "{C:attention}Retrigger{} all Beast jokers once."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards and context.other_card and context.other_card ~= card and FB.is_beast_joker(context.other_card) and FB.once_joker_retrigger(card, context, 'hetao') then return {repetitions = 1, card = card} end
    end
})

SMODS.Joker({
    key = "hundun",
    loc_txt = {name = "Hundun", text = {"{C:attention}Retrigger{} all played cards", "and all Jokers"}},
    atlas = "jokers", pos = {x = 7, y = 8}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {repetitions = 1}},
    calculate = function(self, card, context)
        if FB.is_card_repetition(context) and context.cardarea == G.play then return {repetitions = card.ability.extra.repetitions or 1, card = card} end
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards and context.other_card ~= card and FB.once_joker_retrigger(card, context, 'hundun') then return {repetitions = card.ability.extra.repetitions or 1, card = card} end
    end
})

SMODS.Joker({
    key = "jinchi_dapeng",

    loc_txt = {
        name = "Jinchi Dapeng",
        text = {
            "All stone cards give {X:chips,C:white}X50{} Chips instead",
            "when played."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if FB.is_scoring_individual(context) and FB.is_stone(context.other_card) then
            return {x_chips = 50}
        end
    end
})

SMODS.Joker({
    key = "jinjiao",

    loc_txt = {
        name = "Jinjiao",
        text = {
            "{C:attention}Retrigger{} all Gold cards and Gold Seal",
            "cards twice. Effect stacks."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if FB.is_card_repetition(context) and (FB.is_gold(context.other_card) or (context.other_card and context.other_card.seal == 'Gold')) then
            return {repetitions = 2, card = card}
        end
    end
})

SMODS.Joker({
    key = "kulou",
    loc_txt = {
        name = "Kulou",
        text = {
            "For each destroyed, sold, or discarded",
            "card/Joker/consumable, gain {X:mult,C:white}X#2#{} Mult",
            "{C:inactive}Currently gives {X:mult,C:white}X#1#{} Mult{}"
        }
    },
    atlas = "jokers",
    pos = {x = 0, y = 9},
    rarity = 4,
    cost = 25,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {
        extra = {
            xmult = 1,
            gain = 0.1
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.gain
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        local function kulou_gain(amount)
            amount = amount or 1
            extra.xmult = (extra.xmult or 1) + ((extra.gain or 0.1) * amount)

            return {
                message = "X" .. extra.xmult,
                colour = G.C.MULT,
                card = card
            }
        end

        -- Destroyed card / sold card
        if context.destroy_card or context.selling_card then
            return kulou_gain(1)
        end

        -- Multiple removed playing cards
        if context.remove_playing_cards then
            local count = context.removed and #context.removed or 1
            return kulou_gain(count)
        end

        -- Normal discard button: usually fires once per discarded card
        if context.discard and context.other_card and not context.blueprint then
            return kulou_gain(1)
        end

        -- After playing a hand, played cards go to discard
        if context.after and context.full_hand and not context.blueprint then
            return kulou_gain(#context.full_hand)
        end

        if FB.is_scoring_joker_main(context) then
            return {
                x_mult = extra.xmult or 1,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "luo_tianyi",
    loc_txt = {
        name = "Luo Tianyi",
        text = {
            "{C:attention}Album Cover{} gives {X:chips,C:white}X#1#{} Chips",
            "{C:attention}Alt Album Cover{} gives",
            "{C:chips}+#2#{} Chips and {C:mult}+#2#{} Mult"
        }
    },
    atlas = "jokers", pos = {x = 1, y = 9}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {album_xchips = 631, alt_bonus = 6100}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.album_xchips or 631, card.ability.extra.alt_bonus or 6100}}
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local albums = FB.count_joker('album_cover')
            local alts = FB.count_joker('alternate_album_cover')
            local ret = {card = card}
            if albums > 0 then ret.x_chips = (card.ability.extra.album_xchips or 631) ^ albums end
            if alts > 0 then
                ret.chips = (card.ability.extra.alt_bonus or 6100) * alts
                ret.mult = (card.ability.extra.alt_bonus or 6100) * alts
            end
            if ret.x_chips or ret.chips or ret.mult then return ret end
        end
    end
})

SMODS.Joker({
    key = "lord_phoenix",

    loc_txt = {
        name = "Lord Phoenix",
        text = {
            "{C:attention}Retrigger{} cards without",
            "any {C:attention}enhancements{} {C:attention}#1#{} times."
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    config = {extra = {repetitions = 3}},

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.repetitions or 3}}
    end,

    calculate = function(self, card, context)
        if FB.is_card_repetition(context)
            and context.cardarea == G.play
            and context.other_card
            and not FB.is_enhanced_card(context.other_card) then
            return {repetitions = card.ability.extra.repetitions or 3, card = card}
        end
    end
})

SMODS.Joker({
    key = "qiongqi",

    loc_txt = {
        name = "Qiongqi",
        text = {
            "{C:red}Debuffs{} all other Jokers",
            "until you sell a Joker.",
            "Whenever a Joker is sold, gain",
            "{X:consumable,C:white}^#2#{} Mult and lift the debuff",
            "for this round.",
            "If Qiongqi is sold, debuffs are lifted.",
            "{C:inactive}Currently {X:consumable,C:white}^#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {emult = 1, gain = 1}},

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.emult or 1, card.ability.extra.gain or 1}}
    end,

    add_to_deck = function(self, card, from_debuff)
        card.ability.fb_qiongqi_released = false
    end,

    remove_from_deck = function(self, card, from_debuff)
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and j.ability and j.ability.fb_qiongqi_debuffed then
                    j.debuff = false
                    j.ability.fb_qiongqi_debuffed = nil
                end
            end
        end
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.fb_qiongqi_released = false
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card then
                        j.ability = j.ability or {}
                        j.debuff = true
                        j.ability.fb_qiongqi_debuffed = true
                    end
                end
            end
            return {message = "Cursed!", colour = G.C.RED, card = card}
        end

        if context.selling_card and not context.blueprint then
            card.ability.extra.emult = (card.ability.extra.emult or 1) + (card.ability.extra.gain or 1)
            card.ability.fb_qiongqi_released = true

            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and j.ability and j.ability.fb_qiongqi_debuffed then
                        j.debuff = false
                        j.ability.fb_qiongqi_debuffed = nil
                    end
                end
            end

            return {colour = G.C.PURPLE, card = card}
        end

        if FB.is_scoring_joker_main(context) then
            return {e_mult = card.ability.extra.emult or 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "shanque",
    loc_txt = {name = "Shanque", text = {"{C:attention}Retrigger{} Chugou"}},
    atlas = "jokers", pos = {x = 4, y = 9}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {repetitions = 1}},
    calculate = function(self, card, context)
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards
            and FB.is_joker_key(context.other_card, 'chugou')
            and FB.once_joker_retrigger(card, context, 'shanque') then
            return {repetitions = card.ability.extra.repetitions or 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "sibuxiang",
    loc_txt = {name = "Sibuxiang", text = {"At shop start, ensure at least one", "{C:attention}Uncommon{} and one {C:attention}Rare{} Joker", "Boss blinds also add a {C:attention}Legendary{} Joker"}},
    atlas = "jokers", pos = {x = 6, y = 9}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = false,
    calculate = function(self, card, context)
        local function has_shop_rarity(r)
            for _, c in ipairs((G.shop_jokers and G.shop_jokers.cards) or {}) do if c.config and c.config.center and c.config.center.rarity == r then return true end end
            return false
        end
        local function add_rarity(r)
            if not (G.shop_jokers and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) then return end
            local choices={}
            for _, center in ipairs(G.P_CENTER_POOLS.Joker) do if center and center.rarity == r and center.key then choices[#choices+1]=center.key end end
            if #choices>0 then SMODS.add_card({set='Joker', key=pseudorandom_element(choices, pseudoseed('sibuxiang_'..r)), area=G.shop_jokers}) end
        end
        if FB.main_end_of_round_once(card, context, 'fb_sibuxiang_boss') and G.GAME.blind and G.GAME.blind.boss then G.GAME.fb_sibuxiang_pending_legendary = true end
        if context.starting_shop and not context.blueprint then
            if not has_shop_rarity(2) then add_rarity(2) end
            if not has_shop_rarity(3) then add_rarity(3) end
            if G.GAME.fb_sibuxiang_pending_legendary and not has_shop_rarity(4) then add_rarity(4); G.GAME.fb_sibuxiang_pending_legendary=false end
            return {message = "Rare+ Stock", card = card}
        end
    end
})

SMODS.Joker({
    key = "taotie",

    loc_txt = {
        name = "Taotie",
        text = {
            "At end of scoring, {C:red}destroy{}",
            "all played cards and gain",
            "{X:mult,C:white}X#2#{} Mult per card destroyed",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {
        extra = {
            xmult = 1,
            gain = 1
        }
    },

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.gain}}
    end,

    calculate = function(self, card, context)
        if context.after and not context.blueprint and G.play and G.play.cards then
            local destroyed = 0

            for _, played_card in ipairs(G.play.cards) do
                if played_card then
                    destroyed = destroyed + 1
                    FB.queue_destroy(played_card)
                end
            end

            if destroyed > 0 then
                card.ability.extra.xmult = card.ability.extra.xmult + destroyed * card.ability.extra.gain
                FB.resolve_or_defer_queued_actions(context)

                return {
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        if FB.is_scoring_joker_main(context) then
            return {
                x_mult = card.ability.extra.xmult,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "taowu",

    loc_txt = {
        name = "Taowu",
        text = {
            "{C:green}#1# in #2#{} chance to {C:red}destroy{}",
            "each scored card.",
            "Earn that card's {C:chips}Chip{} value",
            "as {C:money}money{} when destroyed.",
            "{C:edition}Edition{} multiplies base value by {X:money,C:white}X#3#{}.",
            "{C:attention}Enhancements{} and {C:green}Seals{}",
            "give {C:money}+$#4#{} each."
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {odds_num = 1, odds_den = 2, edition_mult = 2, mod_bonus = 5}},

    loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.extra.odds_num or 1,
            card.ability.extra.odds_den or 2,
            card.ability.extra.edition_mult or 2,
            card.ability.extra.mod_bonus or 5
        }}
    end,

    calculate = function(self, card, context)
        if context.destroy_card
            and context.cardarea == G.play
            and context.destroy_card
            and not context.blueprint then

            if not FB.roll('taowu_destroy', card.ability.extra.odds_num or 1, card.ability.extra.odds_den or 2) then
                return nil
            end

            local value = FB.card_cash_value(context.destroy_card, card.ability.extra.edition_mult or 2, card.ability.extra.mod_bonus or 5)
            FB.try_add_dollars(value)

            return {remove = true, message = "$" .. value, colour = G.C.MONEY, card = card}
        end
    end
})

SMODS.Joker({
    key = "tianlu",

    loc_txt = {
        name = "Tianlu",
        text = {
            "At blind start, lose all money",
            "Gains {X:chips,C:white}X0.1{} Chips per {C:money}$1{}",
            "{C:inactive}Currently: #1#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {xchips = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xchips}} end,
    add_to_deck = function(self, card, from_debuff)
        local d = G.GAME.dollars or 0
        card.ability.extra.xchips = 1 + d * 0.1
        FB.try_add_dollars(-d)
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local d = G.GAME.dollars or 0
            card.ability.extra.xchips = (card.ability.extra.xchips or 1) + d * 0.1
            FB.try_add_dollars(-d)
        end

        if FB.is_scoring_joker_main(context) then
            return {x_chips = card.ability.extra.xchips}
        end
    end
})

SMODS.Joker({
    key = "tubaoshu",

    loc_txt = {
        name = "Tubaoshu",
        text = {
            "Fill all your joker slots with Cintamanis",
            "every round. {C:attention}+#1#{} joker slots",
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"2"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(2) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-2) end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and G.jokers and G.jokers.cards then
            while #G.jokers.cards < G.jokers.config.card_limit do
                if not FB.create_joker('cintamani') then break end
            end
        end
    end
})

SMODS.Joker({
    key = "tuye_tony",
    loc_txt = {name = "Tuye", text = {"Gain {X:mult,C:white}X#2#{} Mult for each", "{C:attention}Laurel Branch{} and {C:attention}Mooncake{}", "you have", "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"}},
    atlas = "jokers", pos = {x = 0, y = 10}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {base = 1, gain = 1}},
    loc_vars = function(self, info_queue, card)
        local function count_support_cards()
            return FB.count_joker('mooncake') + FB.count_joker('laurel_branch')
        end

        local n = count_support_cards()
        return {vars = {(card.ability.extra.base or 1) + n * (card.ability.extra.gain or 1), card.ability.extra.gain}}
    end,
    calculate = function(self, card, context)
        local function count_support_cards()
            return FB.count_joker('mooncake') + FB.count_joker('laurel_branch')
        end

        if FB.is_scoring_joker_main(context) then
            local n = count_support_cards()
            return {x_mult = (card.ability.extra.base or 1) + n * (card.ability.extra.gain or 1), card = card}
        end
    end
})

SMODS.Joker({
    key = "xiaolizhi",

    loc_txt = {
        name = "Xiaolizhi",
        text = {
            "All {C:green}odds{} become",
            "{C:attention}guaranteed{}.",
            "{C:inactive}This also guarantees bad odds.{}"
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 10},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context.mod_probability then
            return {
                numerator = context.denominator
            }
        end
    end
})

SMODS.Joker({
    key = "xiezhi",
    loc_txt = {name = "Xiezhi", text = {"If played hand contains exactly", "one scoring card, give {X:mult,C:white}X#1#{} Mult", "and {X:chips,C:white}X#2#{} Chips"}},
    atlas = "jokers", pos = {x = 2, y = 10}, rarity = 4, cost = 25,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {xmult = 4, xchips = 4}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xmult, card.ability.extra.xchips}} end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) and context.scoring_hand and #context.scoring_hand == 1 then return {x_mult = card.ability.extra.xmult or 4, x_chips = card.ability.extra.xchips or 4, card = card} end
    end
})

SMODS.Joker({
    key = "yinjiao",

    loc_txt = {
        name = "Yinjiao",
        text = {
            "{C:attention}Retrigger{} all Steel cards twice and all",
            "Steel cards have their values doubled."
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 10},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if FB.is_card_repetition(context) and FB.is_steel(context.other_card) then
            return {repetitions = 2, card = card}
        end

        if FB.is_scoring_individual(context) and FB.is_steel(context.other_card) then
            return {x_chips = 2, x_mult = 2}
        end
    end
})

SMODS.Joker({
    key = "zhanhu",

    loc_txt = {
        name = "Zhanhu",
        text = {
            "{C:attention}Retrigger{} all {X:mult,C:white}XMult{} jokers."
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 10},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards and context.other_card ~= card and FB.once_joker_retrigger(card, context, 'zhanhu') then return {repetitions = 1, card = card} end
    end
})

