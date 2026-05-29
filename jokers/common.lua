---@diagnostic disable: undefined-global

-- Fabulous Beasts: Common Jokers
-- Shared helpers/registries live in helpers.lua.

SMODS.Joker({
    key = "album_cover",

    loc_txt = {
        name = "Album Cover",
        text = {
            "Plays the theme song",
            "{C:attention}+#1#{} Joker slot",
            "{C:inactive}WARNING: COPYRIGHTED CONTENT{}"
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 0},

    rarity = 1,
    cost = 5,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(1) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-1) end
})

SMODS.Joker({
    key = "alternate_album_cover",

    loc_txt = {
        name = "Alternate Album Cover",
        text = {
            "Plays the Feirenzai intro song on repeat",
            "{C:attention}+#1#{} Joker slot",
            "{C:inactive}WARNING: COPYRIGHTED CONTENT{}"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 0},

    rarity = 1,
    cost = 4,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(1) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-1) end
})

SMODS.Joker({
    key = "beijing_license_plate",

    loc_txt = {
        name = "Beijing License Plate",
        text = {
            "Held cards trigger and add",
            "their {C:chips}Chip{} values"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 0},

    rarity = 1,
    cost = 4,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.hand
            and not context.end_of_round
            and not context.before
            and not context.after
            and not context.setting_blind
            and context.other_card
            and not context.other_card.debuff then
            local bonus = FB.num(context.other_card:get_chip_bonus(), 0)
            if bonus ~= 0 then
                return {
                    chips = bonus,
                    colour = G.C.CHIPS,
                    card = context.other_card
                }
            end
        end
    end
})

SMODS.Joker({
    key = "bullet_comment",

    loc_txt = {
        name = "Bullet Comment",
        text = {
            "{C:green}#1# in #2#{} chance to {C:attention}retrigger{}",
            "cards or Jokers"
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 0},

    rarity = 1,
    cost = 6,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    config = {
        extra = {
            odds_num = 1,
            odds_den = 5,
            repetitions = 1
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.odds_num,
                card.ability.extra.odds_den
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if FB.is_card_repetition(context)
            and (context.cardarea == G.play or context.cardarea == G.hand) then

            if FB.roll(
                'bulletcomment_card',
                extra.odds_num or 1,
                extra.odds_den or 5
            ) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = extra.repetitions or 1,
                    card = card
                }
            end
        end

        if context
            and context.retrigger_joker_check
            and context.other_card
            and not context.end_of_round
            and not context.setting_blind
            and not context.before
            and not context.after
            and not context.selling_card
            and not context.selling_self
            and not context.destroy_card
            and not context.remove_playing_cards
            and context.other_card ~= card
            and FB.once_joker_retrigger(card, context, 'bullet_comment') then

            if FB.roll(
                'bulletcomment_joker',
                extra.odds_num or 1,
                extra.odds_den or 5
            ) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = extra.repetitions or 1,
                    card = card
                }
            end
        end
    end
})

SMODS.Joker({
    key = "cardboard_box",

    loc_txt = {
        name = "Cardboard Box",
        text = {
            "{C:attention}+#1#{} consumable slot"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 0},

    rarity = 1,
    cost = 4,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,



    add_to_deck = function(self, card, from_debuff)
        if G.consumeables and G.consumeables.config then
            G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if G.consumeables and G.consumeables.config then
            G.consumeables.config.card_limit = G.consumeables.config.card_limit - 1
        end
    end
})

SMODS.Joker({
    key = "dew_cloud",

    loc_txt = {
        name = "Dew Cloud",
        text = {
            "{C:red}-#3#{} hand size",
            "Gain {C:attention}+#4#{} hand size for",
            "each consecutive {C:attention}#1#{} played",
            "Resets if you play a different hand",
            "{C:inactive}Streak: #2#{}"
        }
    },

    config = {
        extra = {
            hand_type = "High Card",
            streak = 0,
            hand_size_loss = 1,
            hand_size_gain = 1
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 0},

    rarity = 1,
    cost = 6,
    blueprint_compat = false,

    discovered = true,

    loc_vars = function(self, info_queue, card)
        card.ability.extra.hand_type = card.ability.extra.hand_type
            or (FB.random_hand_type and FB.random_hand_type("dewcloud_hover") or FB.random_poker_hand("dewcloud_hover"))

        return {vars = {
            card.ability.extra.hand_type,
            card.ability.extra.streak or 0,
            card.ability.extra.hand_size_loss or 1,
            card.ability.extra.hand_size_gain or 1
        }}
    end,

    add_to_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(-(card.ability.extra.hand_size_loss or 1))
    end,

    remove_from_deck = function(self, card, from_debuff)
        local loss = card.ability.extra.hand_size_loss or 1
        local gain = card.ability.extra.hand_size_gain or 1
        FB.safe_change_hand_size(loss - ((card.ability.extra.streak or 0) * gain))
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand_type = FB.random_hand_type and FB.random_hand_type("dewcloud_hand") or FB.random_poker_hand("dewcloud_hand")
            return {message = card.ability.extra.hand_type, colour = G.C.ATTENTION, card = card}
        end

        if context.before and context.main_eval and not context.blueprint then
            local played_hand = context.scoring_name
            local gain = card.ability.extra.hand_size_gain or 1

            if played_hand == card.ability.extra.hand_type then
                card.ability.extra.streak = (card.ability.extra.streak or 0) + 1
                FB.safe_change_hand_size(gain)
                return {message = "+" .. card.ability.extra.streak .. " Streak", colour = G.C.GREEN, card = card}
            else
                if (card.ability.extra.streak or 0) > 0 then
                    FB.safe_change_hand_size(-(card.ability.extra.streak or 0) * gain)
                end
                card.ability.extra.streak = 0
                return {message = "Dissolved!", colour = G.C.RED, card = card}
            end
        end
    end
})

SMODS.Joker({
    key = "divine_herb",
    loc_txt = {name = "Divine Herb", text = {"{X:chips,C:white}X#1#{} Chips and", "{X:mult,C:white}X#2#{} Mult", "{C:red}Destroyed{} at end of round"}},
    atlas = "jokers", pos = {x = 7, y = 0}, rarity = 1, cost = 3,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {xchips = 2, xmult = 2}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xchips, card.ability.extra.xmult}} end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                x_chips = card.ability.extra.xchips or 2,
                x_mult = card.ability.extra.xmult or 2,
                card = card
            }
        end
        if FB.main_end_of_round_once(card, context, 'fb_divine_herb_destroy') and not context.blueprint then
            FB.queue_self_destroy(card); FB.resolve_or_defer_queued_actions(context)
            return {message = "Withered!", colour = G.C.RED, card = card}
        end
    end
})

SMODS.Joker({
    key = "dog_food",
    loc_txt = {name = "Dog Food", text = {"First scored card adds", "{C:chips}+#1#X{} its current", "{C:chips}Chip{} value this hand"}},
    atlas = "jokers", pos = {x = 8, y = 0}, rarity = 1, cost = 5,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {chip_mult = 2}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.chip_mult}} end,
    calculate = function(self, card, context)
        if FB.is_scoring_individual(context)
            and context.scoring_hand
            and context.other_card == context.scoring_hand[1]
            and not context.other_card.debuff then
            local bonus = FB.num(context.other_card:get_chip_bonus(), 0) * (card.ability.extra.chip_mult or 2)
            if bonus ~= 0 then
                return {chips = bonus, card = context.other_card}
            end
        end
    end
})


SMODS.Joker({
    key = "emergency_rations",

    loc_txt = {
        name = "Emergency Rations",
        text = {
            "Gain +#1# hand and discard when you run out",
            "of hands, {C:red}destroyed{} after you run out of",
            "hands."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 0},

    rarity = 1,
    cost = 4,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if context.after and G.GAME.current_round and G.GAME.current_round.hands_left <= 0 and not card.ability.fb_used then
            card.ability.fb_used = true
            ease_hands_played(1)
            ease_discard(1)
            FB.queue_self_destroy(card)
            FB.resolve_or_defer_queued_actions(context)
            return {message = "Rations!", colour = G.C.GREEN, card = card}
        end
    end
})

SMODS.Joker({
    key = "food",

    loc_txt = {
        name = "Food",
        text = {
            "{C:chips}+#1#{} Chips. Doesn't take up a joker slot."
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 1},

    rarity = 1,
    cost = 2,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"20"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then return {chips = 20} end
    end,

    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(1) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-1) end
})

SMODS.Joker({
    key = "food_reserve",

    loc_txt = {
        name = "Food Reserve",
        text = {
            "Stores all scored {C:chips}Chips{}.",
            "Doubles stored {C:chips}Chips{} on the final hand.",
            "{C:inactive}Stored: {C:chips}#1#{} Chips{}"
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 1},

    rarity = 1,
    cost = 5,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {stored = 0, current = 0}},

    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.stored}} end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.current = 0
        end

        if FB.is_scoring_individual(context) and context.other_card and not context.blueprint then
            card.ability.extra.current = (card.ability.extra.current or 0) + (context.other_card:get_chip_bonus() or 0)
        end

        if FB.is_scoring_joker_main(context) then
            if not context.blueprint then
                card.ability.extra.stored = card.ability.extra.stored + (card.ability.extra.current or 0)
            end
            if FB.is_final_hand() then return {chips = card.ability.extra.stored * 2} end
        end
    end
})

SMODS.Joker({
    key = "foraged_mushrooms",

    loc_txt = {
        name = "Foraged Mushrooms",
        text = {
            "For the next {C:attention}#1#{} hands, {C:attention}retrigger{} all cards",
            "played and held in hand.",
            "{C:green}#2# in #3#{} chance that the hand does not score.",
            "{C:inactive}Hands remaining: #1#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 1},

    rarity = 1,
    cost = 5,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {
        extra = {
            hands = 8,
            failed = false,
            odds_num = 1,
            odds_den = 2,
            repetitions = 1,
            fuzai_repetitions = 3
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.hands,
                card.ability.extra.odds_num,
                card.ability.extra.odds_den
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        -- FIRST: roll before the hand starts scoring so the player sees the failure immediately.
        if context.before and not context.blueprint and (extra.hands or 0) > 0 then
            local odds_num = extra.odds_num or 1
            local odds_den = extra.odds_den or 2

            if FB.has_joker('bajin') then
                odds_num = odds_num * 2
            end

            if FB.has_joker('fuku_fuzai') then
                odds_num = 0
            end

            extra.failed = FB.roll(
                'foraged_mushrooms_fail',
                odds_num,
                odds_den
            )

            if extra.failed then
                return {
                    message = "Spoiled!",
                    colour = G.C.RED,
                    card = card
                }
            else
                return {
                    message = "Safe!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end

        -- DURING CARD SCORING: retrigger played/held cards while active.
        if FB.is_card_repetition(context)
            and (context.cardarea == G.play or context.cardarea == G.hand)
            and (extra.hands or 0) > 0 then
            return {
                message = localize('k_again_ex'),
                repetitions = FB.has_joker('fuku_fuzai')
                    and (extra.fuzai_repetitions or 3)
                    or (extra.repetitions or 1),
                card = card
            }
        end

        -- LAST SCORING MODIFIER: cancel the hand score after all normal scoring math is known.
        if FB.is_scoring_joker_main(context)
            and (extra.hands or 0) > 0
            and extra.failed then
            return FB.no_score_return(card, "No Score!")
        end

        -- AFTER HAND: count down exactly once per played hand.
        if context.after and not context.blueprint and (extra.hands or 0) > 0 then
            extra.hands = extra.hands - 1
            extra.failed = false

            if extra.hands <= 0 then
                FB.queue_self_destroy(card)
                FB.resolve_or_defer_queued_actions(context)
                return {message = "Gone!", colour = G.C.RED, card = card}
            else
                return {
                    message = extra.hands .. " left",
                    colour = G.C.ATTENTION,
                    card = card
                }
            end
        end
    end
})

SMODS.Joker({
    key = "health_insurance",
    loc_txt = {name = "Health Insurance", text = {"At blind start, trigger {C:attention}Lunchbox Medkit{}", "once for each open Joker slot"}},
    atlas = "jokers", pos = {x = 3, y = 1}, rarity = 1, cost = 5,
    discovered = true, unlocked = true, blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local slots = FB.available_joker_slots()
            local made = 0
            for _, j in ipairs(FB.joker_cards()) do
                if FB.is_joker_key(j, 'lunchbox_medkit') then
                    for i = 1, slots do
                        if FB.create_lunchbox_food('health_insurance_' .. i) then
                            made = made + 1
                        end
                    end
                    break
                end
            end

            if made > 0 then
                return {message = "+" .. made .. " Food", colour = G.C.GREEN, card = card}
            end
        end
    end
})

SMODS.Joker({
    key = "heart_lock",

    loc_txt = {
        name = "Heart Lock",
        text = {
            "Always {C:eternal}Eternal{}, {C:red}debuffs{} a random joker",
            "every round."
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 1},

    rarity = 1,
    cost = 5,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    eternal_compat = true,
    add_to_deck = function(self, card, from_debuff) card.ability.eternal = true end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and G.jokers and G.jokers.cards then
            local choices = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then
                    choices[#choices + 1] = j
                end
            end

            if #choices > 0 then
                FB.set_permanent_debuff(pseudorandom_element(choices, pseudoseed('heartlock')))
            end
            return {message = "Locked!", colour = G.C.RED}
        end
    end
})

SMODS.Joker({
    key = "heavenly_cumin",
    loc_txt = {
        name = "Heavenly Cumin",
        text = {
            "{C:attention}Retrigger{} all {C:attention}Food{} Jokers",
            "once per hand for {C:attention}#1#{} hands",
            "{C:inactive}Uses left: #1#{}"
        }
    },
    atlas = "jokers", pos = {x = 5, y = 1}, rarity = 1, cost = 5,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {uses = 3, repetitions = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.uses, card.ability.extra.repetitions}} end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.fb_cumin_seen = {}
        end

        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards
            and context.other_card ~= card
            and FB.is_food_joker(context.other_card)
            and (card.ability.extra.uses or 0) > 0 then

            local seen_key = nil
            if context.other_card.config and context.other_card.config.center and context.other_card.config.center.key then
                seen_key = context.other_card.config.center.key
            elseif context.other_card.ability and context.other_card.ability.name then
                seen_key = tostring(context.other_card.ability.name)
            else
                seen_key = 'unknown_food_joker'
            end

            card.ability.fb_cumin_seen = card.ability.fb_cumin_seen or {}

            local key = context.other_card.config
                and context.other_card.config.center
                and context.other_card.config.center.key
                or "unknown_food_joker"

            if not card.ability.fb_cumin_seen[key] then
                card.ability.fb_cumin_seen[key] = true
                return {repetitions = card.ability.extra.repetitions or 1, card = card}
            end
        end
        if context.after and not context.blueprint and (card.ability.extra.uses or 0) > 0 then
            card.ability.extra.uses = card.ability.extra.uses - 1
            if card.ability.extra.uses <= 0 then FB.queue_self_destroy(card); FB.resolve_or_defer_queued_actions(context) end
            return {message = tostring(card.ability.extra.uses) .. " left", colour = G.C.ATTENTION, card = card}
        end
    end
})


SMODS.Joker({
    key = "immortality_elixir",

    loc_txt = {
        name = "Immortality Elixir?",
        text = {
            "Joker to the right becomes",
            "{C:eternal}Eternal{}?",
            "{C:red}Self destructs{} after use"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 3},

    rarity = 1,
    cost = 6,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    eternal_compat = true,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and not card.ability.fb_used then
            local target = FB.get_joker_to_right(card)

            if target then
                card.ability.fb_used = true
                local was_eternal, destroyed = FB.queue_destroy_after_removing_eternal(target)
                FB.queue_self_destroy(card)
                FB.resolve_or_defer_queued_actions(context)

                return {
                    message = was_eternal and "Mortal!" or "Immortal?",
                    colour = was_eternal and G.C.ETERNAL or G.C.RED,
                    card = card
                }
            end

            return {
                message = "No target",
                colour = G.C.INACTIVE,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "hellspice_hotpot",
    loc_txt = {name = "Hellspice Hotpot", text = {"If {C:chips}Chips{} or {C:mult}Mult{} is greater", "than the blind requirement, give", "{X:consumable,C:white}^#1#{} Mult"}},
    atlas = "jokers", pos = {x = 6, y = 1}, rarity = 1, cost = 6,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {emult = 4}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.emult}} end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) and G.GAME and G.GAME.blind and (FB.num(hand_chips,0) > FB.num(G.GAME.blind.chips,0) or FB.num(mult,0) > FB.num(G.GAME.blind.chips,0)) then
            return {e_mult = card.ability.extra.emult or 4, card = card}
        end
    end
})



SMODS.Joker {
    key = 'lakeside_pond',
    loc_txt = {
        name = 'Lakeside Pond',
        text = {
            'Played cards that do not score',
            'add {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult each'
        }
    },
    config = {
        extra = {
            chips = 10,
            mult = 2
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'jokers',
    pos = { x = 0, y = 0 },

    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return {
            vars = {
                extra.chips,
                extra.mult
            }
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local played = context.full_hand and #context.full_hand or 0
            local scored = context.scoring_hand and #context.scoring_hand or 0
            local unscored = math.max(played - scored, 0)

            local extra = card.ability.extra
            local bonus_chips = extra.chips * unscored
            local bonus_mult = extra.mult * unscored

            if unscored > 0 then
                return {
                    chips = bonus_chips,
                    mult = bonus_mult
                }
            end
        end
    end
}

SMODS.Joker({
    key = "laurel_branch",

    loc_txt = {
        name = "Laurel Branch",
        text = {
            "{C:attention}Retrigger{} all cards and jokers but",
            "{X:chips,C:white}X0.#1#{} Chips and {X:mult,C:white}X0.#2#{} Mult."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 1},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {extra = {fb_loc_vars = {"5", "5"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if FB.is_card_repetition(context) and (context.cardarea == G.play or context.cardarea == G.hand) then
            return {repetitions = 1, card = card}
        end

        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards
            and context.other_card ~= card
            and FB.once_joker_retrigger(card, context, 'laurel_branch') then
            return {repetitions = 1, card = card}
        end

        if FB.is_scoring_joker_main(context) then
            return {x_chips = 0.5, x_mult = 0.5}
        end
    end
})

SMODS.Joker({
    key = "mini_theater",
    loc_txt = {
        name = "Mini Theater",
        text = {
            "If your first hand has {C:attention}#1#{} played card,",
            "apply a random enhancement, seal, or edition"
        }
    },
    atlas = "jokers", pos = {x = 9, y = 1}, rarity = 1, cost = 5,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {required_cards = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.required_cards or 1}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.fb_theater_used = false
        end

        if context.before
            and not context.blueprint
            and not card.ability.fb_theater_used
            and G.play and G.play.cards
            and #G.play.cards == (card.ability.extra.required_cards or 1) then

            card.ability.fb_theater_used = true

            local target = G.play.cards[1]
            FB.apply_random_card_modifier(target, 'mini_theater')

            return {
                message = "Scene!",
                colour = G.C.ATTENTION,
                card = target
            }
        end
    end
})

SMODS.Joker({
    key = "mooncake",

    loc_txt = {
        name = "Mooncake",
        text = {
            "Every played hand or discard gives {C:money}$#1#{}."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 2},

    rarity = 1,
    cost = 4,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if (context.after or context.pre_discard) and not context.blueprint then
            FB.try_add_dollars(1)
            return {message = "$1"}
        end
    end
})

SMODS.Joker({
    key = "mortal_realm",

    loc_txt = {
        name = "Mortal Realm",
        text = {
            "#1#",
            "#2#",
            "{C:consumable}#3#{}",
            "{C:attention}#4#{}",
            "{C:attention}#5#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 0},

    rarity = 3,
    cost = 8,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {
        extra = {
            sold_joker_name = nil,
            realm_state = "shop",
            joker_slots = -1,
            consumable_slots = -1,
            hand_size = -1
        }
    },

    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra

        if extra.realm_state == "no_target" then
            return {
                vars = {
                    "This motherfucker sold your...",
                    "oh wait, nevermind",
                    "-1 consumable slot",
                    "-1 Joker slot",
                    "-1 hand size"
                }
            }
        end

        if extra.realm_state == "sold_mortal_realm" then
            return {
                vars = {
                    "This motherfucker sold your Mortal Realm!?",
                    "HOW???",
                    "+1 consumable slot",
                    "+1 Joker slot",
                    "+1 hand size"
                }
            }
        end

        if extra.sold_joker_name then
            return {
                vars = {
                    "This motherfucker sold your " .. extra.sold_joker_name,
                    "just so it can be a permanent pain in your ass",
                    "-1 consumable slot",
                    "-1 Joker slot",
                    "-1 hand size"
                }
            }
        end

        return {
            vars = {
                "A place where everyone lives",
                "It's a beautiful day outside,",
                "birds are singing, flowers are blooming,",
                "on days like these,",
                "you should be taking your time enjoying it"
            }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        local extra = card.ability.extra

        -- Apply default curse first.
        G.jokers.config.card_limit = G.jokers.config.card_limit + (extra.joker_slots or -1)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + (extra.consumable_slots or -1)
        G.hand:change_size(extra.hand_size or -1)

        card_eval_status_text(card, 'extra', nil, nil, nil, {
            message = "Whoops!",
            colour = G.C.RED
        })

        local target = nil

        if G.jokers and G.jokers.cards then
            for _, other_joker in ipairs(G.jokers.cards) do
                if other_joker ~= card then
                    target = other_joker
                    break
                end
            end
        end

        if not target then
            extra.realm_state = "no_target"
            extra.sold_joker_name = nil
            return
        end

        local sold_key = target.config
            and target.config.center
            and target.config.center.key

        local sold_name = "Joker"

        if sold_key then
            sold_name = localize({
                type = "name_text",
                set = "Joker",
                key = sold_key
            }) or sold_key
        elseif target.ability and target.ability.name then
            sold_name = target.ability.name
        end

        extra.sold_joker_name = sold_name

        if sold_key == "mortal_realm" or sold_key == "j_fb_mortal_realm" then
            extra.realm_state = "sold_mortal_realm"
            extra.sold_joker_name = "Mortal Realm"

            -- It already applied -1/-1/-1 above.
            -- Add +2 to each so the final owned effect becomes +1/+1/+1.
            G.jokers.config.card_limit = G.jokers.config.card_limit + 2
            G.consumeables.config.card_limit = G.consumeables.config.card_limit + 2
            G.hand:change_size(2)

            extra.joker_slots = 1
            extra.consumable_slots = 1
            extra.hand_size = 1
        else
            extra.realm_state = "sold_normal"

            if card.set_eternal then
                card:set_eternal(true)
            else
                card.ability.eternal = true
            end
        end

        G.E_MANAGER:add_event(Event({
            func = function()
                if target and not target.removed then
                    target:start_dissolve()
                end
                return true
            end
        }))
    end,

    remove_from_deck = function(self, card, from_debuff)
        local extra = card.ability.extra

        G.jokers.config.card_limit = G.jokers.config.card_limit - (extra.joker_slots or -1)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - (extra.consumable_slots or -1)
        G.hand:change_size(-(extra.hand_size or -1))
    end
})

SMODS.Joker({
    key = "pay_stub",

    loc_txt = {
        name = "Pay Stub",
        text = {
            "{C:chips}-100{} Chips. All scored cards add the same",
            "chip value to this joker. {C:attention}Retrigger{} all",
            "played cards if played hand is {C:attention}#2#{}.",
            "{C:inactive}Currently {C:chips}#1#{} Chips{}"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 2},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    config = {extra = {chips = -100, hand = "Pair"}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.chips, card.ability.extra.hand}} end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then return {chips = card.ability.extra.chips} end
        if FB.is_scoring_individual(context) and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + (context.other_card:get_chip_bonus() or 0)
        end
        if FB.is_card_repetition(context) and context.cardarea == G.play and context.scoring_name == card.ability.extra.hand then return {repetitions = 1, card = card} end
        if (context.after or context.pre_discard) and not context.blueprint then card.ability.extra.hand = FB.random_poker_hand('paystub') end
    end
})

SMODS.Joker({
    key = "rat_poison",
    loc_txt = {
        name = "Rat Poison",
        text = {
            "{C:red}Destroy{} up to {C:attention}#3#{} played cards",
            "after scoring",
            "{C:inactive}Uses left: #1#/#2#{}"
        }
    },
    atlas = "jokers", pos = {x = 4, y = 2}, rarity = 1, cost = 4,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {uses = 3, max_uses = 3, destroy_cap = 10}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.uses, card.ability.extra.max_uses, card.ability.extra.destroy_cap}} end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint and (card.ability.extra.uses or 0) > 0 and G.play and G.play.cards and #G.play.cards > 0 then
            local destroy_count = math.min(card.ability.extra.destroy_cap or 10, #G.play.cards)
            local pool = {}
            for _, c in ipairs(G.play.cards) do pool[#pool + 1] = c end
            for i = 1, destroy_count do
                if #pool <= 0 then break end
                local target, index = pseudorandom_element(pool, pseudoseed('rat_poison_' .. tostring(i)))
                if not index then
                    for j, c in ipairs(pool) do if c == target then index = j; break end end
                end
                if target then FB.queue_destroy(target) end
                if index then table.remove(pool, index) end
            end
            card.ability.extra.uses = card.ability.extra.uses - 1
            if card.ability.extra.uses <= 0 then FB.queue_self_destroy(card) end
            FB.resolve_or_defer_queued_actions(context)
            return {message = tostring(card.ability.extra.uses) .. " left", colour = G.C.RED, card = card}
        end
    end
})

SMODS.Joker({
    key = "shunshui_express",

    loc_txt = {
        name = "Shunshui Express",
        text = {
            "{X:chips,C:white}X2{} Chips."
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 2},

    rarity = 1,
    cost = 5,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {x_chips = 2}
        end
    end
})

SMODS.Joker({
    key = "skewered_kebab",

    loc_txt = {
        name = "Skewered Kebab",
        text = {
            "{C:attention}Retrigger{} all cards if played hand is a",
            "Straight (doesn’t trigger if you play",
            "straight flush)."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 2},

    rarity = 1,
    cost = 4,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if FB.is_card_repetition(context) and context.cardarea == G.play and context.scoring_name == 'Straight' then
            return {repetitions = 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "teacup",

    loc_txt = {
        name = "Teacup",
        text = {
            "{C:mult}+3{} Mult.",
            "If you have {C:attention}Teapot{}, gives {X:mult,C:white}XMult{} instead.",
            "Gains {X:mult,C:white}X0.1{} Mult for each Teacup.",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 2},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    config = {extra = {xmult = 1}},
    loc_vars = function(self, info_queue, card)
        local function teacup_xmult()
            return 1 + 0.1 * FB.count_joker('teacup')
        end

        card.ability.extra.xmult = teacup_xmult()
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        local function teacup_xmult()
            return 1 + 0.1 * FB.count_joker('teacup')
        end

        if FB.is_scoring_joker_main(context) then
            if FB.has_joker('teapot') then
                card.ability.extra.xmult = teacup_xmult()
                return {x_mult = card.ability.extra.xmult}
            end
            return {mult = 3}
        end
    end
})

SMODS.Joker({
    key = "temporal_confinement",

    loc_txt = {
        name = "Temporal Confinement",
        text = {
            "When the ante increases, {C:attention}-#1#{} Antes",
            "Sell all other cards for {C:money}3X{}",
            "their sell value, then {C:red}self destructs{}"
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 2},

    rarity = 1,
    cost = 8,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"2"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            FB.maintain_permanent_debuffs()
            G.GAME.fb_temporal_confinement_triggered = false
        end

        -- context.ante_change fires after the ante value has incremented.
        if context.ante_change and not context.blueprint and not G.GAME.fb_temporal_confinement_triggered then
            G.GAME.fb_temporal_confinement_triggered = true
            ease_ante(-2)

            for _, area in ipairs({G.jokers, G.consumeables}) do
                if area and area.cards then
                    for i = #area.cards, 1, -1 do
                        local c = area.cards[i]
                        if c and c ~= card then
                            FB.try_add_dollars(FB.num(c.sell_cost, 0) * 3)
                            FB.queue_destroy(c)
                        end
                    end
                end
            end

            FB.queue_self_destroy(card)
            FB.resolve_or_defer_queued_actions(context)

            return {message = "Confined!", colour = G.C.RED, card = card}
        end
    end
})

SMODS.Joker({
    key = "tile_cat",

    loc_txt = {
        name = "Tile Cat",
        text = {
            "{C:red}Debuffs{} a random played card, {C:chips}+#1#{} Chips.",
            "Has a {C:green}#2# in #3#{} chance of {C:red}debuffing{} itself",
            "every round."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 2},

    rarity = 1,
    cost = 4,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            chips = 233,
            odds_num = 1,
            odds_den = 4
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.chips,
                card.ability.extra.odds_num,
                card.ability.extra.odds_den
            }
        }
    end,

    calculate = function(self, card, context)
        if context.before and G.play and G.play.cards and #G.play.cards > 0 and not context.blueprint then
            FB.set_permanent_debuff(pseudorandom_element(G.play.cards, pseudoseed('tilecat')))
        end

        if FB.is_scoring_joker_main(context) then
            return {chips = card.ability.extra.chips or 233}
        end

        if context.setting_blind
            and not context.blueprint
            and FB.roll('tilecat_self', card.ability.extra.odds_num or 1, card.ability.extra.odds_den or 4) then
            FB.set_permanent_debuff(card)
            return {message = 'Debuffed!'}
        end
    end
})

SMODS.Joker({
    key = "tulou",

    loc_txt = {
        name = "Tulou",
        text = {
            "{C:red}Destroy{}s a random played card."
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 3},

    rarity = 1,
    cost = 4,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.play and G.play.cards and #G.play.cards > 0 then
            card.ability.fb_target_card_index = pseudorandom('tulou', 1, #G.play.cards)
            return {message = "Marked", colour = G.C.RED, card = card}
        end

        if context.destroy_card and context.cardarea == G.play then
            local target = G.play and G.play.cards and G.play.cards[card.ability.fb_target_card_index or -1]

            if context.destroy_card == target then
                card.ability.fb_target_card_index = nil
                return {remove = true}
            end
        end
    end
})

SMODS.Joker({
    key = "underworld_cash",
    loc_txt = {name = "Underworld Cash", text = {"When sold, gain {C:money}$#1#{}-{C:money}$#2#{}"}},
    atlas = "jokers", pos = {x = 1, y = 3}, rarity = 1, cost = 5,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {min = 0, max = 25}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.min, card.ability.extra.max}} end,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            local minv = card.ability.extra.min or 0
            local maxv = card.ability.extra.max or 25
            local amt = math.floor(minv + FB.num(pseudorandom('underworld_cash'), 0) * (maxv - minv + 1))
            FB.try_add_dollars(amt)
            return {message = "$" .. amt, colour = G.C.MONEY, card = card}
        end
    end
})
