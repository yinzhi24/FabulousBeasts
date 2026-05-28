---@diagnostic disable: undefined-global

-- Fabulous Beasts: Uncommon Jokers

SMODS.Joker({
    key = "bestiary",
    loc_txt = {name = "Bestiary", text = {"{X:mult,C:white}X#2#{} Mult per exact unique", "playing card in your deck", "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"}},
    atlas = "jokers", pos = {x = 2, y = 3}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {xmult = 0, gain = 0.1}},
    loc_vars = function(self, info_queue, card)
        local seen = {}
        for _, c in ipairs((G and G.playing_cards) or {}) do seen[FB.card_unique_signature(c)] = true end
        local count = 0; for _ in pairs(seen) do count = count + 1 end
        card.ability.extra.xmult = count * (card.ability.extra.gain or 0.1)
        return {vars = {card.ability.extra.xmult, card.ability.extra.gain or 0.1}}
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local seen = {}
            for _, c in ipairs((G and G.playing_cards) or {}) do seen[FB.card_unique_signature(c)] = true end
            local count = 0
            for _ in pairs(seen) do
                count = count + 1
            end
            local xmult = count * (card.ability.extra.gain or 0.1)
            if not context.blueprint then
                card.ability.extra.xmult = xmult
            end
            return {x_mult = xmult, card = card}
        end
    end
})

SMODS.Joker({
    key = "chicken_mushroom_stew",
    loc_txt = {name = "Chicken Mushroom Stew", text = {"Played cards give {X:mult,C:white}X#2#{} Mult", "and remove {C:attention}#3#{} serving per trigger", "{C:inactive}Servings left: #1#{}"}},
    atlas = "jokers", pos = {x = 3, y = 3}, rarity = 2, cost = 7,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {servings = 15, xmult = 2, serving_loss = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.servings, card.ability.extra.xmult, card.ability.extra.serving_loss}} end,
    calculate = function(self, card, context)
        if FB.is_scoring_individual(context) and not context.blueprint then
            card.ability.extra.servings = (card.ability.extra.servings or 0) - (card.ability.extra.serving_loss or 1)
            return {x_mult = card.ability.extra.xmult or 2, card = card}
        end
    end
})

SMODS.Joker({
    key = "demolition_notice",
    loc_txt = {name = "Demolition Notice", text = {"If you would lose the blind and have", "no other lifesaving Joker, clear it instantly,", "lose {C:money}$#1#{}, then {C:red}self destructs{}"}},
    atlas = "jokers", pos = {x = 4, y = 3}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {cost = 10}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.cost}} end,
    calculate = function(self, card, context)
        if context.game_over and not context.blueprint and G and G.GAME and G.GAME.blind and not FB.has_life_saving_joker(card) then
            G.GAME.chips = G.GAME.blind.chips
            FB.try_add_dollars(-(card.ability.extra.cost or 10))
            FB.queue_self_destroy(card); FB.resolve_or_defer_queued_actions(context)
            return {message = "-$" .. (card.ability.extra.cost or 10), saved = true, colour = G.C.MONEY, card = card}
        end
    end
})

SMODS.Joker({
    key = "do_not_imitate",

    loc_txt = {
        name = "Do Not Imitate",
        text = {
            "Gain {X:mult,C:white}X#2#{} Mult",
            "for every {C:attention}retrigger{}",
            "on any card or Joker",
            "{C:inactive}Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 3},

    rarity = 2,
    cost = 9,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    config = {
        extra = {
            xmult = 1,
            gain = 0.1
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult or 1,
                card.ability.extra.gain or 0.1
            }
        }
    end,

    calculate = function(self, card, context)

        -- Detect actual retriggers only
        if (context.repetition or context.retrigger_joker)
            and not context.blueprint then

            card.ability.extra.xmult =
                (card.ability.extra.xmult or 1)
                + (card.ability.extra.gain or 0.1)
        end

        if FB.is_scoring_joker_main(context) then
            return {
                x_mult = card.ability.extra.xmult or 1,
                card = card
            }
        end

        return {}
    end
})

SMODS.Joker({
    key = "eating_melons",
    loc_txt = {
        name = "Eating Melons",
        text = {
            "{C:attention}Retrigger{} Jokers with",
            "{C:attention}retrigger{} effects"
        }
    },
    atlas = "jokers", pos = {x = 6, y = 3}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = true,
    calculate = function(self, card, context)
        if FB.is_safe_joker_retrigger_context(context)
            and context.other_card ~= card
            and FB.has_retrigger_effect(context.other_card)
            and FB.once_joker_retrigger(card, context, 'eating_melons') then
            return {repetitions = 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "feirenzai_manga",
    loc_txt = {name = "Feirenzai Manga", text = {"If played hand is {C:attention}#1#{},", "gain {X:mult,C:white}X#2#{} Mult", "{C:inactive}Hand changes every round{}"}},
    atlas = "jokers", pos = {x = 7, y = 3}, rarity = 2, cost = 7,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {hand = "Pair", xmult = 3}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand, card.ability.extra.xmult}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then card.ability.extra.hand = FB.random_poker_hand('feirenzai_manga') end
        if FB.is_scoring_joker_main(context) and context.scoring_name == card.ability.extra.hand then return {x_mult = card.ability.extra.xmult or 3, card = card} end
    end
})

SMODS.Joker({
    key = "followers_request",

    loc_txt = {
        name = "Follower's Request",
        text = {
            "At start of scoring, choose",
            "a random Joker",
            "{C:attention}Retrigger{} it {C:attention}#1#{} times",
            "{C:inactive}Target changes every hand.{}"
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 3},

    rarity = 2,
    cost = 9,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"3"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.jokers and G.jokers.cards then
            local choices = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then choices[#choices + 1] = j end
            end
            card.ability.fb_target_joker = #choices > 0 and pseudorandom_element(choices, pseudoseed('followers_request')) or nil
        end

        if FB.is_safe_joker_retrigger_context(context) and context.other_card ~= card and context.other_card == card.ability.fb_target_joker and FB.once_joker_retrigger(card, context, 'followers_request') then
            return {message = localize('k_again_ex'), repetitions = 3, card = card}
        end

        if context.after and not context.blueprint then
            card.ability.fb_target_joker = nil
        end
    end
})

SMODS.Joker({
    key = "gold_sculpture",

    loc_txt = {
        name = "Gold Sculpture",
        text = {
            "{C:attention}Retrigger{} all {C:money}Gold{} cards"
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 3},

    rarity = 2,
    cost = 6,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if FB.is_card_repetition(context) and (FB.is_gold(context.other_card) or (context.other_card and context.other_card.seal == 'Gold')) then return {repetitions = 1, card = card} end
    end
})

SMODS.Joker({
    key = "heavenly_elixirs",
    loc_txt = {name = "Heavenly Elixirs", text = {"If {C:chips}Chips{} are at most", "{C:chips}#2#{} per ante, balance score", "Otherwise, hand does not score", "{C:inactive}Limit: {C:chips}#1#{}{}"}},
    atlas = "jokers", pos = {x = 0, y = 4}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {limit = 1000, per_ante = 1000, minimum = 1000}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.limit or 1000, card.ability.extra.per_ante or 1000}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.limit = math.max(card.ability.extra.minimum or 1000, ((G.GAME.round_resets and G.GAME.round_resets.ante) or 1) * (card.ability.extra.per_ante or 1000))
        end
        if FB.is_scoring_joker_main(context) then
            if FB.num(hand_chips, 0) <= FB.num(card.ability.extra.limit, 1000) then return FB.balance_score_return(card) end
            return FB.no_score_return(card)
        end
    end
})

SMODS.Joker({
    key = "hellish_delicacies",
    loc_txt = {name = "Hellish Delicacies", text = {"{C:attention}Retrigger{} the first scored card", "once per scored card", "{C:red}Debuffs{} all but the first played card"}},
    atlas = "jokers", pos = {x = 1, y = 4}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {repetitions_per_card = 1}},
    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.play and G.play.cards then
            for i, c in ipairs(G.play.cards) do if i > 1 then c.debuff = true end end
        end
        if FB.is_card_repetition(context)
            and context.cardarea == G.play
            and context.other_card
            and G.play
            and G.play.cards
            and context.other_card == G.play.cards[1] then
            return {
                repetitions = math.max(0, (#G.play.cards - 1) * (card.ability.extra.repetitions_per_card or 1)),
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "lunchbox_medkit",
    loc_txt = {
        name = "Lunchbox Medkit",
        text = {
            "At blind start, create a random",
            "{C:attention}Food{} Joker"
        }
    },
    atlas = "jokers", pos = {x = 2, y = 4}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and FB.available_joker_slots() > 0 then
            local created = FB.create_lunchbox_food('lunchbox_medkit')
            if created then return {message = "Lunch!", colour = G.C.GREEN, card = card} end
        end
    end
})

SMODS.Joker({
    key = "mapo_tofu",
    loc_txt = {
        name = "Mapo Tofu",
        text = {
            "{C:green}#1# in #2#{} chance",
            "played hand does not score"
        }
    },
    atlas = "jokers", pos = {x = 3, y = 4}, rarity = 2, cost = 7,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {odds_num = 1, odds_den = 4, failed = false}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.odds_num, card.ability.extra.odds_den}} end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.failed = FB.roll('mapo_tofu_fail', card.ability.extra.odds_num or 1, card.ability.extra.odds_den or 4)
            if card.ability.extra.failed then return {message = "Too Spicy!", colour = G.C.RED, card = card} end
        end
        if FB.is_scoring_joker_main(context) and card.ability.extra.failed then
            card.ability.extra.failed = false
            return FB.no_score_return(card)
        end
        if context.after and not context.blueprint then card.ability.extra.failed = false end
    end
})

SMODS.Joker({
    key = "moon_palace",
    loc_txt = {name = "Moon Palace", text = {"{C:attention}Retrigger{} Mooncakes", "and Laurel Branches"}},
    atlas = "jokers", pos = {x = 4, y = 4}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = true,
    calculate = function(self, card, context)
        if FB.is_safe_joker_retrigger_context(context)
            and context.other_card ~= card
            and (FB.is_joker_key(context.other_card, 'mooncake') or FB.is_joker_key(context.other_card, 'laurel_branch'))
            and FB.once_joker_retrigger(card, context, 'moon_palace') then
            return {repetitions = 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "mooncake_cannon",

    loc_txt = {
        name = "Mooncake Cannon",
        text = {
            "{C:attention}Retrigger{} all Mooncakes once for every",
            "{C:attention}Mooncake{} you have."
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 4},

    rarity = 2,
    cost = 8,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if FB.is_safe_joker_retrigger_context(context)
            and FB.is_joker_key(context.other_card, 'mooncake')
            and FB.once_joker_retrigger(card, context, 'mooncake_cannon') then
            return {repetitions = FB.count_joker('mooncake'), card = card}
        end
    end
})

SMODS.Joker({
    key = "open_for_business",

    loc_txt = {
        name = "Open For Business",
        text = {
            "{C:green}#1# in #2#{} chance of getting {C:money}$#3#{} when anything",
            "is triggered or {C:attention}retriggered{}."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 4},

    rarity = 2,
    cost = 7,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1", "8", "1"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if (FB.is_scoring_individual(context)
            or FB.is_scoring_joker_main(context)
            or FB.is_safe_joker_retrigger_context(context)
            or FB.is_card_repetition(context))
            and not context.blueprint
            and FB.num(pseudorandom('open_for_business'), 0) < 0.125 then
            FB.try_add_dollars(1)
            return {message = "$1"}
        end
    end
})

SMODS.Joker({
    key = "oxen_cart",
    loc_txt = {name = "Oxen Cart", text = {"Playing {C:attention}#1#{} gives", "{C:attention}+#3#{} hand size, up to {C:attention}+#4#{}", "{C:inactive}Gained #2#{}"}},
    atlas = "jokers", pos = {x = 7, y = 4}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {hand = "Pair", gained = 0, gain = 1, cap = 3}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand, card.ability.extra.gained, card.ability.extra.gain, card.ability.extra.cap}} end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_hand_size(-(card.ability.extra.gained or 0)) end,
    calculate = function(self, card, context)
        if context.after and context.scoring_name == card.ability.extra.hand and not context.blueprint and (card.ability.extra.gained or 0) < (card.ability.extra.cap or 3) then
            local add = math.min(card.ability.extra.gain or 1, (card.ability.extra.cap or 3) - (card.ability.extra.gained or 0))
            card.ability.extra.gained = (card.ability.extra.gained or 0) + add
            FB.safe_change_hand_size(add)
            return {message = "+" .. add .. " Hand Size", card = card}
        end
        if FB.main_end_of_round_once(card, context, 'fb_oxen_cart_hand') then card.ability.extra.hand = FB.random_poker_hand('oxen_cart') end
    end
})

SMODS.Joker({
    key = "paw_hole_cave",

    loc_txt = {
        name = "Paw Hole Cave",
        text = {
            "{C:attention}+#1#{} joker slot."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 4},

    rarity = 2,
    cost = 7,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"2"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(2) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-2) end
})

SMODS.Joker({
    key = "pixiu_fur",
    loc_txt = {name = "Pixiu Fur", text = {"If your next hand is {C:attention}#1#{},", "apply a random {C:attention}enhancement{},", "{C:green}seal{}, and {C:edition}edition{}", "to all scored cards, then {C:red}self destructs{}"}},
    atlas = "jokers", pos = {x = 9, y = 4}, rarity = 2, cost = 10,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {hand = "Pair"}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then card.ability.extra.hand = FB.random_hand_type('pixiu_fur') end
        if context.before and context.scoring_name == card.ability.extra.hand and not context.blueprint then
            for _, c in ipairs(context.scoring_hand or {}) do
                c:set_ability(G.P_CENTERS[pseudorandom_element({'m_bonus','m_mult','m_wild','m_glass','m_steel','m_stone','m_gold','m_lucky'}, pseudoseed('pixiu_fur_enhance'))], nil, true)
                c:set_seal(pseudorandom_element({'Gold','Blue','Red','Purple'}, pseudoseed('pixiu_fur_seal')), true)
                c:set_edition(pseudorandom_element({{foil=true},{holo=true},{polychrome=true}}, pseudoseed('pixiu_fur_edition')), true)
            end
            FB.queue_self_destroy(card); FB.resolve_or_defer_queued_actions(context)
            return {message = "Blessed!", colour = G.C.GREEN, card = card}
        end
    end
})

SMODS.Joker({
    key = "qilin_egg",

    loc_txt = {
        name = "Qilin Egg",
        text = {
            "After {C:attention}3{} rounds, hatch into",
            "a random Joker",
            "{C:inactive}Rounds remaining: #1#{}",
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 5},

    rarity = 2,
    cost = 9,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {rounds = 3}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.rounds}} end,
    calculate = function(self, card, context)
        if FB.main_end_of_round_once(card, context, 'fb_qilin_egg_tick') then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds <= 0 then FB.queue_create_joker(nil, 'qilin_egg'); FB.queue_self_destroy(card); FB.resolve_or_defer_queued_actions(context) end
        end
    end
})

SMODS.Joker({
    key = "questionable_fanart",
    loc_txt = {name = "Questionable Fanart", text = {"If played hand contains {C:attention}6{} and {C:attention}9{},", "gives {C:mult}+#1#{} Mult", "If played hand contains {C:attention}6{}, {C:attention}2{}, and {C:attention}Ace{},", "gives {C:chips}+#2#{} Chips"}},
    atlas = "jokers", pos = {x = 0, y = 5}, rarity = 2, cost = 6,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {mult = 69, chips = 621}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.mult, card.ability.extra.chips}} end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local ret = {card = card}
            if FB.hand_contains_number(6) and FB.hand_contains_number(9) then ret.mult = card.ability.extra.mult or 69 end
            if FB.hand_contains_number(6) and FB.hand_contains_number(2) and FB.hand_contains_rank('Ace') then ret.chips = card.ability.extra.chips or 621 end
            if ret.mult or ret.chips then return ret end
        end
    end
})

SMODS.Joker({
    key = "rigged_video_game",

    loc_txt = {
        name = "Rigged Video Game",
        text = {
            "At end of round, create a",
            "random Joker and lose between",
            "{C:money}$#1#{} and {C:money}$#2#{}",
            "Higher losses are {C:attention}rarer{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 4},

    rarity = 2,
    cost = 8,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    config = {
        extra = {
            min_loss = 1,
            max_loss = 99
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.min_loss,
                card.ability.extra.max_loss
            }
        }
    end,

    calculate = function(self, card, context)
        if FB.main_end_of_round_once(card, context, 'fb_rigged_video_game_round') then

            local extra = (card.ability and card.ability.extra) or {}
            local min_loss = extra.min_loss or 1
            local max_loss = extra.max_loss or 99
            local loss = FB.inverse_weighted_int and FB.inverse_weighted_int('rigged_video_game_loss', min_loss, max_loss) or min_loss

            FB.create_random_joker('rigged_video_game')
            if FB.try_add_dollars then FB.try_add_dollars(-loss) end

            return {
                message = "-$" .. loss,
                colour = G.C.MONEY,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "teapot",

    loc_txt = {
        name = "Teapot",
        text = {
            "Gains {X:chips,C:white}X1{} Chips per Teacup.",
            "{C:inactive}Currently {X:chips,C:white}X#1#{} Chips{}"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 5},

    rarity = 2,
    cost = 6,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    config = {extra = {xchips = 1}},
    loc_vars = function(self, info_queue, card)
        card.ability.extra.xchips = math.max(1, FB.count_joker('teacup'))
        return {vars = {card.ability.extra.xchips}}
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            card.ability.extra.xchips = math.max(1, FB.count_joker('teacup'))
            return {x_chips = card.ability.extra.xchips}
        end
    end
})

SMODS.Joker({
    key = "underworlds_blacklist",
    loc_txt = {name = "Underworld's Blacklist", text = {"{X:mult,C:white}X#1#{} Mult", "Loses {X:mult,C:white}X#2#{} Mult per", "sold or destroyed Joker, card, or consumable", "{C:red}Self destructs{} below {X:mult,C:white}X#3#{}"}},
    atlas = "jokers", pos = {x = 2, y = 5}, rarity = 2, cost = 8,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {xmult = 4, loss = 0.1, minimum = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xmult, card.ability.extra.loss, card.ability.extra.minimum}} end,
    add_to_deck = function(self, card, from_debuff) card.ability.fb_blacklist_tracking = true end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then return {x_mult = math.max(0, card.ability.extra.xmult or 4), card = card} end
        if (context.selling_card or context.remove_playing_cards or context.destroy_card) and not context.blueprint then
            card.ability.extra.xmult = (card.ability.extra.xmult or 4) - (card.ability.extra.loss or 0.1)
        end
        if (card.ability.extra.xmult or 4) < (card.ability.extra.minimum or 1) and not context.blueprint then
            FB.queue_self_destroy(card); FB.resolve_or_defer_queued_actions(context)
            return {message = "Blacklisted!", colour = G.C.RED, card = card}
        end
    end
})
