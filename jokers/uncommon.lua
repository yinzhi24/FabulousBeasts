---@diagnostic disable: undefined-global
-- Fabulous Beasts: Uncommon Jokers

SMODS.Joker({
    key = "ambrosia",
    loc_txt = {
        name = "Ambrosia",
        text = {
            "At end of round, fully {C:attention}recharge{}",
            "all compatible Jokers",
            "then {C:red}self destructs{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 1,
        y = 4
    },
    -- change sprite position
    rarity = 2,
    cost = 12,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if FB.main_end_of_round_once(card, context, "fb_ambrosia_recharge")
        and not context.blueprint then
            local recharged = 0
            for _,
            joker in ipairs(FB.joker_cards()) do
                if joker ~= card and FB.recharge_joker and FB.recharge_joker(joker) then
                    recharged = recharged + 1
                end
            end
            FB.queue_self_destroy(card)
            FB.resolve_or_defer_queued_actions(context)
            return {
                message = recharged > 0 and "Recharged!" or "Nothing!",
                colour = recharged > 0 and G.C.GREEN or G.C.RED,
                card = card
            }
        end
    end
})

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
    key = "coexistence",
    loc_txt = {
        name = "Coexistence",
        text = {
            "If every card in your deck is",
            "{C:attention}unique{}, retrigger all",
            "played cards {C:attention}once{}",
            "{C:inactive}Checks rank, suit, enhancement,",
            "{C:inactive}seal, and edition{}"
        }
    },
    atlas = "jokers",
    pos = { x = 1, y = 4 }, -- change sprite slot
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            repetitions = 1
        }
    },
    calculate = function(self, card, context)
        local function card_signature(c)
            if not c then return "nil" end

            local center = c.config and c.config.center and c.config.center.key or "none"
            local seal = c.seal or "none"

            local edition = "none"
            if c.edition then
                if c.edition.negative then edition = "negative"
                elseif c.edition.foil then edition = "foil"
                elseif c.edition.holo then edition = "holo"
                elseif c.edition.polychrome then edition = "polychrome"
                else edition = "edition"
                end
            end

            return table.concat({
                tostring(c.base and c.base.value or c:get_id() or "rank"),
                tostring(c.base and c.base.suit or "suit"),
                tostring(center),
                tostring(seal),
                tostring(edition)
            }, "|")
        end

        local function deck_is_unique()
            if not G.playing_cards then return false end

            local seen = {}
            for _, c in ipairs(G.playing_cards) do
                local sig = card_signature(c)
                if seen[sig] then
                    return false
                end
                seen[sig] = true
            end

            return true
        end

        if FB.is_card_repetition(context)
        and context.cardarea == G.play
        and deck_is_unique() then
            return {
                repetitions = card.ability.extra.repetitions or 1,
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
    key = "past_experience",
    loc_txt = {
        name = "Past Experience",
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "After each played hand,",
            "lose {X:mult,C:white}X#2#{} Mult"
        }
    },
    atlas = "jokers",
    pos = { x = 2, y = 4 },
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    config = {
        extra = {
            xmult = 2,
            loss = 0.1,
            min_xmult = 1
        }
    },

    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return {
            vars = {
                string.format("%.1f", extra.xmult or 2),
                extra.loss or 0.1
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if FB.is_scoring_joker_main(context) then
            return {
                x_mult = extra.xmult or 2,
                card = card
            }
        end

        if context.after and not context.blueprint then
            extra.xmult = math.max(
                extra.min_xmult or 1,
                (extra.xmult or 2) - (extra.loss or 0.1)
            )

            return {
                message = "-X" .. tostring(extra.loss or 0.1),
                colour = G.C.RED,
                card = card
            }
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
    key = "rubbing_walnuts",
    loc_txt = {
        name = "Rubbing Walnuts",
        text = {
            "{C:attention}Retrigger{} each played card",
            "once for each {C:attention}exact duplicate{}",
            "in played hand",
            "{C:inactive}Exact: rank, suit, enhancement,",
            "{C:inactive}seal, edition, and bonuses{}"
        }
    },
    atlas = "jokers",
    pos = { x = 0, y = 6 }, -- change sprite pos
    rarity = 2,
    cost = 7,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if FB.is_card_repetition(context)
        and context.cardarea == G.play
        and context.other_card
        and G.play
        and G.play.cards then
            local sig = FB.card_unique_signature(context.other_card)
            local duplicates = 0

            for _, played_card in ipairs(G.play.cards) do
                if played_card ~= context.other_card
                and FB.card_unique_signature(played_card) == sig then
                    duplicates = duplicates + 1
                end
            end

            if duplicates > 0 then
                return {
                    message = localize("k_again_ex"),
                    repetitions = duplicates,
                    card = card
                }
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

FB.mahjong_table_calls = FB.mahjong_table_calls or {
    chinese = {
        normal = {
            ["High Card"] = {"Dan Diao!"},
            ["Pair"] = {"Dui Zi!"},
            ["Two Pair"] = {"Liang Dui!"},
            ["Three of a Kind"] = {"Peng!"},
            ["Straight"] = {"Chi!", "Shun Zi!"},
            ["Flush"] = {"Qing Yi Se!"},
            ["Full House"] = {"Peng Peng Hu!"},
            ["Four of a Kind"] = {"Gang!"},
            ["Straight Flush"] = {"Yi Tiao Long!"},
            ["Five of a Kind"] = {"Wu Zhang!"},
            ["Flush House"] = {"Hun Yi Se!"},
            ["Flush Five"] = {"Qing Yi Se Da Dui!"},
            ["Flush Six"] = {"Liu Tong Qing Yi Se!"},
            ["Super Straight Flush"] = {"Chang Yi Tiao Long!"},
            ["Six of a Kind"] = {"Liu Tong!"},
            ["Flush Party"] = {"Qing Yi Se Da Peng Hu!"},
            ["Flush Double Triple"] = {"Qing Yi Se Shuang Peng!"},
            ["Flush Three Pair"] = {"Qing Yi Se San Dui!"},
            ["House Party"] = {"Da Peng Hu!"},
            ["Double Triple"] = {"Shuang Peng!"},
            ["Super Flush"] = {"Chang Qing Yi Se!"},
            ["Super Straight"] = {"Chang Shun Zi!"},
            ["Three Pair"] = {"San Dui!"},
        },

        one_shot_no_discards = {
            "Tian Hu!",
            "Shi San Yao!",
            "Da San Yuan!"
        },

        -- If you discarded at least once, then one-shot the Blind.
        one_shot_with_discards = {
            ["High Card"] = {"Di Hu!"},
            ["Pair"] = {"Di Hu!"},
            ["Two Pair"] = {"Di Hu!"},
            ["Three of a Kind"] = {"Di Hu!"},
            ["Straight"] = {"Di Hu!"},
            ["Flush"] = {"Di Hu!"},
            ["Full House"] = {"Di Hu!"},
            ["Four of a Kind"] = {"Di Hu!"},
            ["Straight Flush"] = {"Di Hu!"},
            ["Five of a Kind"] = {"Di Hu!"},
            ["Flush House"] = {"Di Hu!"},
            ["Flush Five"] = {"Di Hu!"},
            ["Flush Six"] = {"Di Hu!"},
            ["Super Straight Flush"] = {"Di Hu!"},
            ["Six of a Kind"] = {"Di Hu!"},
            ["Flush Party"] = {"Di Hu!"},
            ["Flush Double Triple"] = {"Di Hu!"},
            ["Flush Three Pair"] = {"Di Hu!"},
            ["House Party"] = {"Di Hu!"},
            ["Double Triple"] = {"Di Hu!"},
            ["Super Flush"] = {"Di Hu!"},
            ["Super Straight"] = {"Di Hu!"},
            ["Three Pair"] = {"Di Hu!"},
        }
    },

    japanese = {
        normal = {
            ["High Card"] = {"Tanki!"},
            ["Pair"] = {"Toitsu!"},
            ["Two Pair"] = {"Chiitoi-ish!"},
            ["Three of a Kind"] = {"Pon!"},
            ["Straight"] = {"Chii!", "Shuntsu!"},
            ["Flush"] = {"Chinitsu!"},
            ["Full House"] = {"Toitoi!"},
            ["Four of a Kind"] = {"Kan!"},
            ["Straight Flush"] = {"Ittsuu!"},
            ["Five of a Kind"] = {"Yakuman?!"},
            ["Flush House"] = {"Honitsu!"},
            ["Flush Five"] = {"Double Yakuman?!"},
            ["Flush Six"] = {"Roku Douitsu Chinitsu!"},
            ["Super Straight Flush"] = {"Chou Ittsuu!"},
            ["Six of a Kind"] = {"Rokukoutsu?!"},
            ["Flush Party"] = {"Da Toitoi Chinitsu!"},
            ["Flush Double Triple"] = {"Ryan Koutsu Chinitsu!"},
            ["Flush Three Pair"] = {"San Toitsu Chinitsu!"},
            ["House Party"] = {"Da Toitoi!"},
            ["Double Triple"] = {"Ryan Koutsu!"},
            ["Super Flush"] = {"Naga Chinitsu!"},
            ["Super Straight"] = {"Naga Shuntsu!"},
            ["Three Pair"] = {"San Toitsu!"},
        },

        one_shot_no_discards = {
            "Tenhou!",
            "Kokushi Musou!",
            "Daisangen!",
            "Suuankou!"
        },

        one_shot_with_discards = {
            ["High Card"] = {"Chiihou!"},
            ["Pair"] = {"Chiihou!"},
            ["Two Pair"] = {"Chiihou!"},
            ["Three of a Kind"] = {"Chiihou!"},
            ["Straight"] = {"Chiihou!"},
            ["Flush"] = {"Chiihou!"},
            ["Full House"] = {"Chiihou!"},
            ["Four of a Kind"] = {"Chiihou!"},
            ["Straight Flush"] = {"Chiihou!"},
            ["Five of a Kind"] = {"Chiihou!"},
            ["Flush House"] = {"Chiihou!"},
            ["Flush Five"] = {"Chiihou!"},
            ["Flush Six"] = {"Chiihou!"},
            ["Super Straight Flush"] = {"Chiihou!"},
            ["Six of a Kind"] = {"Chiihou!"},
            ["Flush Party"] = {"Chiihou!"},
            ["Flush Double Triple"] = {"Chiihou!"},
            ["Flush Three Pair"] = {"Chiihou!"},
            ["House Party"] = {"Chiihou!"},
            ["Double Triple"] = {"Chiihou!"},
            ["Super Flush"] = {"Chiihou!"},
            ["Super Straight"] = {"Chiihou!"},
            ["Three Pair"] = {"Chiihou!"},
        }
    }
}

function FB.mahjong_table_current_style()
    return (FB.config and FB.config.enable_japanese_mahjong_calls)
        and "japanese"
        or "chinese"
end

function FB.mahjong_table_style_name()
    return (FB.mahjong_table_current_style() == "japanese")
        and "Japanese"
        or "Chinese"
end

function FB.mahjong_table_pick_call(hand_name, one_shot, used_discards)
    local style = FB.mahjong_table_current_style()
    local data = FB.mahjong_table_calls[style] or FB.mahjong_table_calls.chinese

    local pool = nil

    if one_shot and used_discards then
        pool = data.one_shot_with_discards and data.one_shot_with_discards[hand_name]
    elseif one_shot and not used_discards then
        pool = data.one_shot_no_discards
    end

    pool = pool or (data.normal and data.normal[hand_name]) or {"Mahjong!"}

    return pseudorandom_element(
        pool,
        pseudoseed("fb_mahjong_table_" .. tostring(hand_name or "unknown"))
    )
end

function FB.mahjong_table_hand_name_from_context(context)
    if context and type(context.scoring_name) == "string" then
        return context.scoring_name
    end

    if G and G.GAME and G.GAME.current_round
    and G.GAME.current_round.current_hand
    and type(G.GAME.current_round.current_hand.handname) == "string" then
        return G.GAME.current_round.current_hand.handname
    end

    if context and type(context.poker_hands) == "table" then
        local priority = {
            "Flush Six",
            "Super Straight Flush",
            "Six of a Kind",
            "Flush Party",
            "Flush Double Triple",
            "Flush Three Pair",
            "House Party",
            "Double Triple",
            "Super Flush",
            "Super Straight",
            "Three Pair",
            "Flush Five",
            "Flush House",
            "Five of a Kind",
            "Straight Flush",
            "Four of a Kind",
            "Full House",
            "Flush",
            "Straight",
            "Three of a Kind",
            "Two Pair",
            "Pair",
            "High Card"
        }

        for _, name in ipairs(priority) do
            if context.poker_hands[name] then
                return name
            end
        end

        for name, value in pairs(context.poker_hands) do
            if value then
                return name
            end
        end
    end

    return "High Card"
end

function FB.mahjong_table_pick_call(hand_name, one_shot, used_discards)
    local style = FB.mahjong_table_current_style()
    local data = FB.mahjong_table_calls[style] or FB.mahjong_table_calls.chinese

    local pool

    if one_shot and used_discards then
        pool = data.one_shot_with_discards and data.one_shot_with_discards[hand_name]
    elseif one_shot and not used_discards then
        pool = data.one_shot_no_discards
    end

    pool = pool or (data.normal and data.normal[hand_name])
    pool = pool or (data.normal and data.normal["High Card"])
    pool = pool or {"Mahjong!"}

    return pseudorandom_element(
        pool,
        pseudoseed("fb_mahjong_table_" .. tostring(hand_name))
    )
end

function FB.mahjong_table_apply_bonuses(card)
    if not (G and G.GAME and card and card.ability) then return end
    if card.ability.fb_mahjong_table_applied then return end

    card.ability.fb_mahjong_table_applied = true

    -- +1 card selection limit
    if G.hand and G.hand.config then
        G.hand.config.highlighted_limit = (G.hand.config.highlighted_limit or 5) + 1
    end

    if SMODS and SMODS.change_play_limit then
        SMODS.change_play_limit(1)
    end

    if SMODS and SMODS.change_discard_limit then
        SMODS.change_discard_limit(1)
    end

    -- +1 hand size
    if FB.safe_change_hand_size then
        FB.safe_change_hand_size(1)
    elseif G.hand and G.hand.change_size then
        G.hand:change_size(1)
    end

    -- +1 discard
    if G.GAME.round_resets then
        G.GAME.round_resets.discards = (G.GAME.round_resets.discards or 0) + 1
    end

    if G.GAME.current_round then
        G.GAME.current_round.discards_left = (G.GAME.current_round.discards_left or 0) + 1
    end

    -- -1 hand
    if G.GAME.round_resets then
        G.GAME.round_resets.hands = math.max(0, (G.GAME.round_resets.hands or 1) - 1)
    end

    if G.GAME.current_round then
        G.GAME.current_round.hands_left = math.max(0, (G.GAME.current_round.hands_left or 1) - 1)
    end

    -- -1 Joker slot because Mahjong Table takes up 2 slots total.
    if FB.safe_change_joker_slots then
        FB.safe_change_joker_slots(-1)
    elseif G.jokers and G.jokers.config then
        G.jokers.config.card_limit = math.max(0, (G.jokers.config.card_limit or 1) - 1)
    end
end

function FB.mahjong_table_remove_bonuses(card)
    if not (G and G.GAME and card and card.ability) then return end
    if not card.ability.fb_mahjong_table_applied then return end

    card.ability.fb_mahjong_table_applied = nil

    if G.hand and G.hand.config then
        G.hand.config.highlighted_limit = math.max(5, (G.hand.config.highlighted_limit or 6) - 1)
    end

    if SMODS and SMODS.change_play_limit then
        SMODS.change_play_limit(-1)
    end

    if SMODS and SMODS.change_discard_limit then
        SMODS.change_discard_limit(-1)
    end

    if FB.safe_change_hand_size then
        FB.safe_change_hand_size(-1)
    elseif G.hand and G.hand.change_size then
        G.hand:change_size(-1)
    end

    if G.GAME.round_resets then
        G.GAME.round_resets.discards = math.max(0, (G.GAME.round_resets.discards or 1) - 1)
        G.GAME.round_resets.hands = (G.GAME.round_resets.hands or 0) + 1
    end

    if G.GAME.current_round then
        G.GAME.current_round.discards_left = math.max(0, (G.GAME.current_round.discards_left or 1) - 1)
        G.GAME.current_round.hands_left = (G.GAME.current_round.hands_left or 0) + 1
    end

    if FB.safe_change_joker_slots then
        FB.safe_change_joker_slots(1)
    elseif G.jokers and G.jokers.config then
        G.jokers.config.card_limit = (G.jokers.config.card_limit or 0) + 1
    end
end

SMODS.Joker({
    key = "mahjong_table",
    loc_txt = {
        name = "Mahjong Table",
        text = {
            "{C:attention}+1{} card selection limit",
            "{C:attention}+1{} hand size, {C:attention}+1{} discard",
            "{C:red}-1{} hand, {C:red}-1{} Joker slot",
            "{C:inactive}Call style: #1# Mahjong{}"
        }
    },
    atlas = "jokers",
    pos = { x = 3, y = 6 }, -- change sprite pos
    rarity = 2,
    cost = 7,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {
        extra = {}
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                FB.mahjong_table_style_name()
            }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        FB.mahjong_table_apply_bonuses(card)
    end,

    remove_from_deck = function(self, card, from_debuff)
        FB.mahjong_table_remove_bonuses(card)
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.fb_mahjong_last_hand =
                FB.mahjong_table_hand_name_from_context(context)

            card.ability.extra.fb_mahjong_discards_used =
                G.GAME
                and G.GAME.current_round
                and (G.GAME.current_round.discards_used or 0)
                or 0
        end

        if context.after and not context.blueprint then
            local hand_name =
                card.ability.extra.fb_mahjong_last_hand
                or FB.mahjong_table_hand_name_from_context(context)

            local blind_chips = G.GAME and G.GAME.blind and G.GAME.blind.chips or math.huge
            local current_chips = G.GAME and G.GAME.chips or 0

            local one_shot

            if to_big then
                one_shot = to_big(current_chips) >= to_big(blind_chips)
            else
                one_shot = current_chips >= blind_chips
            end

            local used_discards =
                (card.ability.extra.fb_mahjong_discards_used or 0) > 0

            return {
                message = FB.mahjong_table_pick_call(hand_name, one_shot, used_discards),
                colour = G.C.PURPLE,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "tea_table",
    loc_txt = {
        name = "Tea Table",
        text = {
            "{C:attention}Retrigger{} {C:attention}Teapot{}",
            "and {C:attention}Teacup{} once"
        }
    },
    atlas = "jokers",
    pos = { x = 1, y = 6 }, -- change sprite pos
    rarity = 2,
    cost = 7,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if context
        and context.retrigger_joker_check
        and context.other_card
        and context.other_card ~= card
        and not context.end_of_round
        and not context.setting_blind
        and not context.before
        and not context.after
        and not context.selling_card
        and not context.selling_self
        and not context.destroy_card
        and not context.remove_playing_cards
        and (
            FB.is_joker_key(context.other_card, "teapot")
            or FB.is_joker_key(context.other_card, "teacup")
        )
        and FB.once_joker_retrigger(card, context, "tea_table") then
            return {
                message = localize("k_again_ex"),
                repetitions = 1,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "vending_machine",
    loc_txt = {
        name = "Vending Machine",
        text = {
            "At blind start, pay {C:money}$#1#{}",
            "to create a random {C:attention}Food{} Joker",
            "{C:red}Self destructs{} if you have less than {C:money}$#1#{}",
            "{C:green}#2# in #3#{} chance to {C:red}explode{} after use"
        }
    },
    atlas = "jokers",
    pos = { x = 2, y = 6 }, -- change sprite pos
    rarity = 2,
    cost = 8,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {
        extra = {
            cost = 5,
            odds_num = 1,
            odds_den = 12
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.cost or 5,
                card.ability.extra.odds_num or 1,
                card.ability.extra.odds_den or 12
            }
        }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local extra = card.ability.extra
            local price = extra.cost or 5

            -- Talisman-safe money comparison
            local dollars = G.GAME and G.GAME.dollars or 0
            local can_pay = false

            if to_big then
                can_pay = to_big(dollars) >= to_big(price)
            else
                can_pay = dollars >= price
            end

            if not can_pay then
                FB.queue_self_destroy(card)
                FB.resolve_or_defer_queued_actions(context)

                return {
                    message = "Out of order!",
                    colour = G.C.RED,
                    card = card
                }
            end

            FB.try_add_dollars(-price)

            local created = nil

            if FB.create_random_food_joker then
                created = FB.create_random_food_joker("vending_machine")
            elseif FB.random_food_joker_key and SMODS and SMODS.add_card then
                local food_key = FB.random_food_joker_key()

                if food_key then
                    created = SMODS.add_card({
                        set = "Joker",
                        key = food_key,
                        area = G.jokers
                    })
                end
            elseif FB.create_joker then
                created = FB.create_joker("food")
            end

            local explode = false

            if FB.roll then
                explode = FB.roll(
                    "vending_machine_explode",
                    extra.odds_num or 1,
                    extra.odds_den or 12
                )
            else
                explode = pseudorandom("vending_machine_explode") < ((extra.odds_num or 1) / (extra.odds_den or 12))
            end

            if explode then
                FB.queue_self_destroy(card)
                FB.resolve_or_defer_queued_actions(context)

                return {
                    message = "BOOM!",
                    colour = G.C.RED,
                    card = card
                }
            end

            return {
                message = created and "Snack!" or "Nothing!",
                colour = created and G.C.GREEN or G.C.RED,
                card = card
            }
        end
    end
})