---@diagnostic disable: undefined-global
-- Fabulous Beasts: Uncommon Jokers
SMODS.Joker({
    key = "bestiary",
    loc_txt = {
        name = "Bestiary",
        text = {
            "{X:mult,C:white}X#2#{} Mult per exact unique",
            "playing card in your deck",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 0,
        y = 4
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            xmult = 0,
            gain = 0.1
        }
    },
    loc_vars = function(self, info_queue, card)
        local seen = {}
        for _,
        c in ipairs((G and G.playing_cards) or {}) do
            seen [FB.card_unique_signature(c)] = true
        end
        local count = 0;
        for _ in pairs(seen) do
            count = count + 1
        end
        card.ability.extra.xmult = count *(card.ability.extra.gain or 0.1)
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.gain or 0.1
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local seen = {}
            for _,
            c in ipairs((G and G.playing_cards) or {}) do
                seen [FB.card_unique_signature(c)] = true
            end
            local count = 0
            for _ in pairs(seen) do
                count = count + 1
            end
            local xmult = count *(card.ability.extra.gain or 0.1)
            if not context.blueprint then
                card.ability.extra.xmult = xmult
            end
            return {
                x_mult = xmult,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "chicken_mushroom_stew",
    loc_txt = {
        name = "Chicken Mushroom Stew",
        text = {
            "Played cards give {X:mult,C:white}X#2#{} Mult",
            "and remove {C:attention}#3#{} serving per trigger",
            "{C:inactive}Servings left: #1#{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 1,
        y = 4
    },
    rarity = 2,
    cost = 7,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            servings = 15,
            xmult = 2,
            serving_loss = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.servings,
                card.ability.extra.xmult,
                card.ability.extra.serving_loss
            }
        }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra
        if FB.is_scoring_individual(context) and not context.blueprint then
            extra.servings =(extra.servings or 0) -(extra.serving_loss or 1)
            return {
                x_mult = extra.xmult or 2,
                card = card
            }
        end
        if context.after and not context.blueprint and(extra.servings or 0) <= 0 then
            G.E_MANAGER: add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = - 0.2
                    card: juice_up(0.3, 0.4)
                    card: start_dissolve()
                    return true
                end
            }))
            return {
                message = "Out!",
                colour = G.C.RED,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "demolition_notice",
    loc_txt = {
        name = "Demolition Notice",
        text = {
            "If you would lose the blind and have",
            "no other lifesaving Joker, clear it instantly,",
            "lose {C:money}$#1#{}, then {C:red}self destructs{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 2,
        y = 4
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            cost = 10
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.cost
            }
        }
    end,
    calculate = function(self, card, context)
        if context.game_over and not context.blueprint and G and G.GAME and G.GAME.blind and not FB.has_life_saving_joker(card) then
            G.GAME.chips = G.GAME.blind.chips
            FB.try_add_dollars(-(card.ability.extra.cost or 10))
            FB.queue_self_destroy(card);
            FB.resolve_or_defer_queued_actions(context)
            return {
                message = "-$"..(card.ability.extra.cost or 10),
                saved = true,
                colour = G.C.MONEY,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "do_not_imitate",
    loc_txt = {
        name = "Do Not Imitate",
        text = {
            "Gain {X:mult,C:white}X#2#{} Mult",
            "every time any card or Joker",
            "is triggered",
            "{C:inactive}Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 3,
        y = 4
    },
    rarity = 2,
    cost = 9,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            xmult = 1,
            gain = 0.01
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult or 1,
                card.ability.extra.gain or 0.01
            }
        }
    end,
    calculate = function(self, card, context)
        local is_trigger = context
        and(context.individual or context.joker_main or context.repetition or context.retrigger_joker)
        and not context.end_of_round
        and not context.before
        and not context.after
        and not context.setting_blind
        if is_trigger and not context.blueprint then
            card.ability.extra.xmult =
            (card.ability.extra.xmult or 1)
            +(card.ability.extra.gain or 0.01)
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
    key = "feirenzai_manga",
    loc_txt = {
        name = "Feirenzai Manga",
        text = {
            "If played hand is {C:attention}#1#{},",
            "gain {X:mult,C:white}X#2#{} Mult",
            "{C:inactive}Hand changes every round{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 4,
        y = 4
    },
    rarity = 2,
    cost = 7,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            hand = "Pair",
            xmult = 3
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.hand,
                card.ability.extra.xmult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand = FB.random_poker_hand('feirenzai_manga')
        end
        if FB.is_scoring_joker_main(context) and context.scoring_name == card.ability.extra.hand then
            return {
                x_mult = card.ability.extra.xmult or 3,
                card = card
            }
        end
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
    pos = {
        x = 5,
        y = 4
    },
    rarity = 2,
    cost = 9,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            fb_loc_vars = {
                "3"
            }
        }
    },
    loc_vars = function(self, info_queue, card)
        return FB.static_loc_vars(card)
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.jokers and G.jokers.cards then
            local choices = {}
            for i,
            j in ipairs(G.jokers.cards) do
                if j ~= card then
                    choices [#choices + 1] = i
                end
            end
            card.ability.fb_target_joker_index =
            #choices > 0 and pseudorandom_element(choices, pseudoseed('followers_request')) or nil
        end
        if context and context.retrigger_joker_check
        and context.other_card
        and G.jokers
        and G.jokers.cards
        and card.ability.fb_target_joker_index
        and context.other_card ~= card
        and context.other_card == G.jokers.cards [card.ability.fb_target_joker_index]
        and FB.once_joker_retrigger(card, context, 'followers_request') then
            return {
                message = localize('k_again_ex'),
                repetitions = 3,
                card = card
            }
        end
        if context.after and not context.blueprint then
            card.ability.fb_target_joker_index = nil
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
    pos = {
        x = 6,
        y = 4
    },
    rarity = 2,
    cost = 6,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if FB.is_card_repetition(context) and(FB.is_gold(context.other_card) or(context.other_card and context.other_card.seal == 'Gold')) then
            return {
                repetitions = 1,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "heavenly_elixirs",
    loc_txt = {
        name = "Heavenly Elixirs",
        text = {
            "If {C:chips}Chips{} are at most",
            "{C:chips}#2#{} per ante, balance score",
            "Otherwise, hand does not score",
            "{C:inactive}Limit: {C:chips}#1#{}{}"
        }
    },
    atlas = "jokers",
    pos = { x = 7, y = 4 },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            limit = 1000,
            per_ante = 1000,
            minimum = 1000
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.limit or 1000,
                card.ability.extra.per_ante or 1000
            }
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.limit = math.max(
                card.ability.extra.minimum or 1000,
                ((G.GAME.round_resets and G.GAME.round_resets.ante) or 1) * (card.ability.extra.per_ante or 1000)
            )
            return
        end

        if FB.is_scoring_joker_main(context) then
            if FB.num(hand_chips, 0) <= FB.num(card.ability.extra.limit, 1000) then
                return {
                    balance = true,
                    card = card
                }
            end

            return {
                x_mult = 0,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "hellish_delicacies",
    loc_txt = {
        name = "Hellish Delicacies",
        text = {
            "{C:attention}Retrigger{} the first scored card",
            "once per scored card",
            "{C:red}Debuffs{} all but the first played card"
        }
    },
    atlas = "jokers",
    pos = {
        x = 8,
        y = 4
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            repetitions_per_card = 1
        }
    },
    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.play and G.play.cards then
            for i,
            c in ipairs(G.play.cards) do
                if i > 1 then
                    c.debuff = true
                end
            end
        end
        if FB.is_card_repetition(context)
        and context.cardarea == G.play
        and context.other_card
        and G.play
        and G.play.cards
        and context.other_card == G.play.cards [1] then
            return {
                repetitions = math.max(0, (#G.play.cards - 1) *(card.ability.extra.repetitions_per_card or 1)),
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "knockout",
    loc_txt = {
        name = "Knockout!",
        text = {
            "Gain {X:mult,C:white}X#3#{} Mult at end of round.",
            "The gain increases by {X:mult,C:white}X#3#{}",
            "at end of round.",
            "Skipping a blind resets this Joker.",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult, gain X#2#{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 9,
        y = 4
    },
    rarity = 2,
    cost = 4,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            xmult = 1,
            gain = 0.1,
            gain_increment = 0.1,
            reset_xmult = 1,
            reset_gain = 0.1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult or 1,
                card.ability.extra.gain or 0.1,
                card.ability.extra.gain_increment or 0.1
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                x_mult = card.ability.extra.xmult or 1,
                card = card
            }
        end
        -- Only increments at true end of round, once and once only.
        if FB.main_end_of_round_once(card, context, 'fb_knockout_incremented') then
            card.ability.extra.xmult =(card.ability.extra.xmult or 1) +(card.ability.extra.gain or 0.1)
            card.ability.extra.gain =(card.ability.extra.gain or 0.1) +(card.ability.extra.gain_increment or 0.1)
        end
        if context.skip_blind and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.reset_xmult or 1
            card.ability.extra.gain = card.ability.extra.reset_gain or 0.1
            card.ability.fb_knockout_incremented = false
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
    atlas = "jokers",
    pos = {
        x = 10,
        y = 4
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and FB.available_joker_slots() > 0 then
            local created = FB.create_lunchbox_food('lunchbox_medkit')
            if created then
                return {
                    message = "Lunch!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

SMODS.Joker({
    key = "mapo_tofu",
    loc_txt = {
        name = "Mapo Tofu",
        text = {
            "{X:mult,C:white}X#3#{} Mult",
            "{C:green}#1# in #2#{} chance",
            "played hand does not score"
        }
    },
    atlas = "jokers",
    pos = {
        x = 11,
        y = 4
    },
    rarity = 2,
    cost = 7,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            odds_num = 1,
            odds_den = 4,
            failed = false,
            xmult = 4
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.odds_num,
                card.ability.extra.odds_den,
                card.ability.extra.xmult
            }
        }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra
        if context.before and not context.blueprint then
            extra.failed = FB.roll(
            'mapo_tofu_fail',
            extra.odds_num or 1,
            extra.odds_den or 4
           )
            if extra.failed then
                return {
                    message = "Too Spicy!",
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if FB.is_scoring_joker_main(context) then
            if extra.failed then
                return {
                    chips = - math.max(0, FB.num(hand_chips, 0)),
                    mult = - math.max(0, FB.num(mult, 0)),
                    message = "No Score!",
                    colour = G.C.RED,
                    card = card
                }
            end
            return {
                x_mult = extra.xmult or 4,
                card = card
            }
        end
        if context.after and not context.blueprint then
            extra.failed = false
        end
    end
})

SMODS.Joker({
    key = "moon_palace",
    loc_txt = {
        name = "Moon Palace",
        text = {
            "Gains {X:mult,C:white}X#1#{} Mult",
            "for each {C:attention}Mooncake{} or",
            "{C:attention}Laurel Branch{} owned",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)"
        }
    },
    atlas = "jokers",
    pos = {
        x = 12,
        y = 4
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            xmult_per = 0.5
        }
    },
    loc_vars = function(self, info_queue, card)
        local count = 0
        if G.jokers and G.jokers.cards then
            for _,
            j in ipairs(G.jokers.cards) do
                if FB.is_joker_key(j, 'mooncake') or FB.is_joker_key(j, 'laurel_branch') then
                    count = count + 1
                end
            end
        end
        return {
            vars = {
                card.ability.extra.xmult_per,
                1 + count * card.ability.extra.xmult_per
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local count = 0
            for _,
            j in ipairs(FB.joker_cards()) do
                if FB.is_joker_key(j, 'mooncake') or FB.is_joker_key(j, 'laurel_branch') then
                    count = count + 1
                end
            end
            local xmult = 1 + count *(card.ability.extra.xmult_per or 0.5)
            if xmult > 1 then
                return {
                    x_mult = xmult,
                    message = "X"..xmult,
                    colour = G.C.MULT,
                    card = card
                }
            end
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
    pos = {
        x = 13,
        y = 4
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards
        and FB.is_joker_key(context.other_card, 'mooncake')
        and FB.once_joker_retrigger(card, context, 'mooncake_cannon') then
            return {
                repetitions = FB.count_joker('mooncake'),
                card = card
            }
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
    pos = {
        x = 14,
        y = 4
    },
    rarity = 2,
    cost = 7,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            odds_num = 1,
            odds_den = 8,
            dollars = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.odds_num,
                card.ability.extra.odds_den,
                card.ability.extra.dollars
            }
        }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra
        if(FB.is_scoring_individual(context)
        or FB.is_scoring_joker_main(context)
        or(context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards)
        or FB.is_card_repetition(context))
        and not context.blueprint
        and FB.roll('open_for_business', extra.odds_num or 1, extra.odds_den or 8) then
            FB.try_add_dollars(extra.dollars or 1)
            return {
                message = "$"..(extra.dollars or 1)
            }
        end
    end
})

SMODS.Joker({
    key = "oxen_cart",
    loc_txt = {
        name = "Oxen Cart",
        text = {
            "Playing {C:attention}#1#{} gives",
            "{C:attention}+#3#{} hand size, up to {C:attention}+#4#{}",
            "{C:inactive}Gained #2#{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 15,
        y = 4
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            hand = "Pair",
            gained = 0,
            gain = 1,
            cap = 3
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.hand,
                card.ability.extra.gained,
                card.ability.extra.gain,
                card.ability.extra.cap
            }
        }
    end,
    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(-(card.ability.extra.gained or 0))
    end,
    calculate = function(self, card, context)
        if context.after and context.scoring_name == card.ability.extra.hand and not context.blueprint and(card.ability.extra.gained or 0) <(card.ability.extra.cap or 3) then
            local add = math.min(card.ability.extra.gain or 1, (card.ability.extra.cap or 3) -(card.ability.extra.gained or 0))
            card.ability.extra.gained =(card.ability.extra.gained or 0) + add
            FB.safe_change_hand_size(add)
            return {
                message = "+"..add.." Hand Size",
                card = card
            }
        end
        if FB.main_end_of_round_once(card, context, 'fb_oxen_cart_hand') then
            card.ability.extra.hand = FB.random_poker_hand('oxen_cart')
        end
    end
})

SMODS.Joker({
    key = "paw_hole_cave",
    loc_txt = {
        name = "Paw Hole Cave",
        text = {
            "{C:attention}+#1#{} joker slots"
        }
    },
    atlas = "jokers",
    pos = {
        x = 16,
        y = 4
    },
    rarity = 2,
    cost = 7,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            fb_loc_vars = {
                "2"
            }
        }
    },
    loc_vars = function(self, info_queue, card)
        return FB.static_loc_vars(card)
    end,
    add_to_deck = function(self, card, from_debuff)
        FB.safe_change_joker_slots(2)
    end,
    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_joker_slots(- 2)
    end
})

SMODS.Joker({
    key = "qilin_egg",
    loc_txt = {
        name = "Qilin Egg",
        text = {
            "After {C:attention}#1#{} rounds, hatch into",
            "a random Joker",
            "{C:inactive}Rounds remaining: #2#{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 17,
        y = 4
    },
    rarity = 2,
    cost = 9,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            start_rounds = 3,
            rounds = 3
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.start_rounds,
                card.ability.extra.rounds
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.main_end_of_round_once(card, context, 'fb_qilin_egg_tick') then
            local extra = card.ability.extra
            extra.rounds =(extra.rounds or extra.start_rounds or 3) - 1
            if extra.rounds <= 0 then
                local eligible = {}
                for _,
                center in pairs(G.P_CENTERS) do
                    if center.set == "Joker"
                    and center.unlocked ~= false
                    and center.key ~= "j_fb_qilin_egg"
                    and center.key ~= "qilin_egg"
                    and center.rarity ~= "Exotic"
                    and center.rarity ~= "exotic"
                    and center.rarity ~= "fb_exotic"
                    and center.rarity ~= "Divine"
                    and center.rarity ~= "divine"
                    and center.rarity ~= "fb_divine"
                    then
                        eligible [#eligible + 1] = center
                    end
                end
                if #eligible > 0 then
                    local chosen = pseudorandom_element(eligible, pseudoseed("qilin_egg"))
                    G.E_MANAGER: add_event(Event({
                        func = function()
                            local new_card = create_card(
                            "Joker",
                            G.jokers,
                            nil,
                            nil,
                            nil,
                            nil,
                            chosen.key,
                            "qilin_egg"
                           )
                            new_card: add_to_deck()
                            G.jokers: emplace(new_card)
                            return true
                        end
                    }))
                end
                FB.queue_self_destroy(card)
                FB.resolve_or_defer_queued_actions(context)
                return {
                    message = "Hatched!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
            return {
                message = extra.rounds.." left",
                colour = G.C.ATTENTION,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "questionable_fanart",
    loc_txt = {
        name = "Questionable Fanart",
        text = {
            "If played hand contains {C:attention}6{} and {C:attention}9{},",
            "gives {C:mult}+#1#{} Mult",
            "If played hand contains {C:attention}6{}, {C:attention}2{}, and {C:attention}Ace{},",
            "gives {C:chips}+#2#{} Chips"
        }
    },
    atlas = "jokers",
    pos = {
        x = 18,
        y = 4
    },
    rarity = 2,
    cost = 6,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            mult = 69,
            chips = 621
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult,
                card.ability.extra.chips
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local ret = {
                card = card
            }
            if FB.hand_contains_number(6) and FB.hand_contains_number(9) then
                ret.mult = card.ability.extra.mult or 69
            end
            if FB.hand_contains_number(6) and FB.hand_contains_number(2) and FB.hand_contains_rank('Ace') then
                ret.chips = card.ability.extra.chips or 621
            end
            if ret.mult or ret.chips then
                return ret
            end
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
    pos = {
        x = 19,
        y = 4
    },
    rarity = 2,
    cost = 6,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            xchips = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        card.ability.extra.xchips = math.max(1, FB.count_joker('teacup'))
        return {
            vars = {
                card.ability.extra.xchips
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            card.ability.extra.xchips = math.max(1, FB.count_joker('teacup'))
            return {
                x_chips = card.ability.extra.xchips
            }
        end
    end
})

SMODS.Joker({
    key = "underworlds_blacklist",
    loc_txt = {
        name = "Underworld's Blacklist",
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "Loses {X:mult,C:white}X#2#{} Mult per sold,",
            "destroyed, or discarded card/Joker/consumable",
            "{C:red}Self destructs{} below {X:mult,C:white}X#3#{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 0,
        y = 5
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            xmult = 4,
            loss = 0.1,
            minimum = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult,
                card.ability.extra.loss,
                card.ability.extra.minimum
            }
        }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra
        local function blacklist_loss(amount)
            amount = amount or 1
            extra.xmult =(extra.xmult or 4) -((extra.loss or 0.1) * amount)
            if extra.xmult <(extra.minimum or 1) then
                G.E_MANAGER: add_event(Event({
                    func = function()
                        if card and not card.removed then
                            play_sound('tarot1')
                            card: start_dissolve()
                        end
                        return true
                    end
                }))
                return {
                    message = "Blacklisted!",
                    colour = G.C.RED,
                    card = card
                }
            end
            return {
                message = "X"..extra.xmult,
                colour = G.C.RED,
                card = card
            }
        end
        -- Sold or individually destroyed card/Joker/consumable
        if(context.selling_card or context.destroy_card) and not context.blueprint then
            return blacklist_loss(1)
        end
        -- Multiple removed playing cards
        if context.remove_playing_cards and not context.blueprint then
            local count = context.removed and #context.removed or 1
            return blacklist_loss(count)
        end
        -- Manual discard: usually fires once per discarded card
        if context.discard and context.other_card and not context.blueprint then
            return blacklist_loss(1)
        end
        -- Played cards going to discard after hand resolves
        if context.after and context.full_hand and not context.blueprint then
            return blacklist_loss(#context.full_hand)
        end
        if FB.is_scoring_joker_main(context) then
            return {
                x_mult = math.max(0, extra.xmult or 4),
                card = card
            }
        end
    end
})
