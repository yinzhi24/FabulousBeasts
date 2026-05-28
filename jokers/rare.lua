---@diagnostic disable: undefined-global

-- Fabulous Beasts: Rare Jokers

SMODS.Joker({
    key = "9th_heaven",

    loc_txt = {
        name = "9th Heaven",
        text = {
            "Every {C:attention}#2#{} rounds {C:attention}retrigger{} all played cards",
            "{C:attention}#3#{} times.",
            "{C:inactive}Rounds: #1#/#2#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 5},

    rarity = 3,
    cost = 13,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {rounds = 0, needed = 9, repetitions = 9}},
    loc_vars = function(self, info_queue, card)
        local needed = FB.extra(card, 'needed', 9)
        return {vars = {FB.extra(card, 'rounds', 0) % needed, needed, FB.extra(card, 'repetitions', 9)}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            FB.clear_round_once(card, 'fb_9th_heaven_incremented')
        end

        if FB.is_card_repetition(context)
            and context.cardarea == G.play
            and FB.extra(card, 'rounds', 0) >= FB.extra(card, 'needed', 9) then
            return {repetitions = FB.extra(card, 'repetitions', 9), card = card}
        end

        if context.after and not context.blueprint and FB.extra(card, 'rounds', 0) >= FB.extra(card, 'needed', 9) then
            card.ability.extra.rounds = 0
        end

        -- This is intentionally the only place the counter increases.
        -- The guard prevents duplicate end_of_round callbacks from adding more than 1.
        if FB.main_end_of_round_once(card, context, 'fb_9th_heaven_incremented') then
            card.ability.extra.rounds = FB.extra(card, 'rounds', 0) + 1
        end
    end
})


SMODS.Joker({
    key = "body_swap_mushroom",

    loc_txt = {
        name = "Body Swap Mushroom",
        text = {
            "Once, add current {C:chips}Chips{}",
            "to {C:mult}Mult{}, then {C:red}destroy{} itself"
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 5},

    rarity = 3,
    cost = 10,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) and not context.blueprint then
            local gain = math.max(0, FB.num(hand_chips, 0))
            FB.queue_self_destroy(card)
            FB.resolve_or_defer_queued_actions(context)
            return {mult = gain, colour = G.C.MULT, card = card}
        end
    end
})

SMODS.Joker({
    key = "bone_mask",
    loc_txt = {name = "Bone Mask", text = {"{C:red}Debuff{} played face cards", "{C:attention}Retrigger{} scored cards once per", "{C:red}debuffed{} face card"}},
    atlas = "jokers", pos = {x = 7, y = 5}, rarity = 3, cost = 11,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {repetitions = 1}},
    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.play and G.play.cards then
            for _, c in ipairs(G.play.cards) do
                if FB.is_face(c) then
                    c.debuff = true
                end
            end
        end
        if FB.is_card_repetition(context) and context.cardarea == G.play then
            local n = 0
            for _, c in ipairs((G.play and G.play.cards) or {}) do
                if FB.is_face(c) and c.debuff then
                    n = n + 1
                end
            end
            if n > 0 then return {repetitions = n * (card.ability.extra.repetitions or 1), card = card} end
        end
    end
})

SMODS.Joker({
    key = "cintamani",

    loc_txt = {
        name = "Cintamani",
        text = {
            "At end of round, increase the sell value",
            "of all Jokers and consumables by {C:money}$#1#{}.",
            "Does not affect playing cards.",
            "Stacks per copy."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 5},

    rarity = 3,
    cost = 12,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {sell_gain = 1}},

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.sell_gain or 1}}
    end,

    calculate = function(self, card, context)
        if FB.main_end_of_round_once(card, context, 'fb_cintamani_value_gain') then
            local gain = card.ability.extra.sell_gain or 1
            for _, area in ipairs({G.jokers, G.consumeables}) do
                if area and area.cards then
                    for _, c in ipairs(area.cards) do
                        if c ~= card then
                            c.sell_cost = (c.sell_cost or 0) + gain
                        end
                    end
                end
            end
            return {message = "+$" .. gain .. " Value", colour = G.C.MONEY, card = card}
        end
    end
})

SMODS.Joker({
    key = "divine_garment",
    loc_txt = {
        name = "Divine Garment",
        text = {
            "{C:attention}Retrigger{} the Joker to the left once",
            "{C:inactive}#1#{}"
        }
    },
    atlas = "jokers", pos = {x = 9, y = 5}, rarity = 3, cost = 12,
    discovered = true, unlocked = true, blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local idx = FB.find_joker_index(card)
        local left = idx and G.jokers and G.jokers.cards and G.jokers.cards[idx - 1]
        local ok = left and left.config and left.config.center and left.config.center.blueprint_compat == true
        return {vars = {ok and "Compatible" or "Incompatible"}}
    end,
    calculate = function(self, card, context)
        if FB.is_safe_joker_retrigger_context(context)
            and context.other_card
            and G.jokers
            and G.jokers.cards
            and FB.once_joker_retrigger(card, context, 'divine_garment') then
            local idx = FB.find_joker_index(card)
            local left = idx and G.jokers.cards[idx - 1]
            if left and context.other_card == left and left.config and left.config.center and left.config.center.blueprint_compat == true then
                return {repetitions = 1, card = card}
            end
        end
    end
})

SMODS.Joker({
    key = "divine_hair_growth_elixir",
    loc_txt = {name = "Divine Hair Growth Elixir", text = {"Scored cards permanently gain their", "current {C:chips}Chip{} value as bonus {C:chips}Chips{}", "{C:inactive}Limit once per card per hand{}"}},
    atlas = "jokers", pos = {x = 0, y = 6}, rarity = 3, cost = 14,
    discovered = true, unlocked = true, blueprint_compat = false,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            for _, c in ipairs((G.play and G.play.cards) or {}) do
                c.fb_elixir_used = nil
            end
        end
        if FB.is_scoring_individual(context) and context.other_card and not context.other_card.fb_elixir_used then
            context.other_card.fb_elixir_used = true
            local gain = math.max(1, FB.num(context.other_card:get_chip_bonus(), 0))
            context.other_card.ability = context.other_card.ability or {}
            context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + gain
            return {message = "+" .. gain, colour = G.C.CHIPS, card = context.other_card}
        end
    end
})

SMODS.Joker({
    key = "divine_light",
    loc_txt = {name = "Divine Light", text = {"Gain {X:consumable,C:white}^#2#{} Mult per", "{C:dark_edition}Negative{} Joker", "{C:inactive}Currently {X:consumable,C:white}^#1#{} Mult{}"}},
    atlas = "jokers", pos = {x = 1, y = 6}, rarity = 3, cost = 15,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {base = 1, gain = 0.2}},
    loc_vars = function(self, info_queue, card) return {vars = {(card.ability.extra.base or 1) + (card.ability.extra.gain or 0.2) * FB.count_negative_jokers(), card.ability.extra.gain}} end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then return {e_mult = (card.ability.extra.base or 1) + (card.ability.extra.gain or 0.2) * FB.count_negative_jokers(), card = card} end
    end
})

SMODS.Joker({
    key = "divine_warsword",
    loc_txt = {name = "Divine Warsword", text = {"If played hand is {C:attention}#1#{},", "gain {X:mult,C:white}X#2#{} Mult", "and balance score", "{C:inactive}Current hand: {C:attention}#1#{}{}"}},
    atlas = "jokers", pos = {x = 2, y = 6}, rarity = 3, cost = 13,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {hand = "Pair", xmult = 3}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand, card.ability.extra.xmult}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand = FB.random_hand_type('divine_warsword')
            return {message = card.ability.extra.hand, colour = G.C.ATTENTION, card = card}
        end
        if FB.is_scoring_joker_main(context) and context.scoring_name == card.ability.extra.hand then return FB.balance_score_return(card, {mult_multiplier = card.ability.extra.xmult or 3}) end
    end
})

SMODS.Joker({
    key = "dreamscape",

    loc_txt = {
        name = "Dreamscape",
        text = {
            "Edition cards give {X:chips,C:white}X2{} Chips",
            "and {X:mult,C:white}X2{} Mult",
            "{C:attention}Retrigger{} edition Jokers",
            "{C:attention}+#1#{} hand size"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 6},

    rarity = 3,
    cost = 14,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    add_to_deck = function(self, card, from_debuff) FB.safe_change_hand_size(1) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_hand_size(-1) end,
    calculate = function(self, card, context)
        if FB.is_scoring_individual(context) and context.other_card and context.other_card.edition then return {x_chips = 2, x_mult = 2} end
        if FB.is_safe_joker_retrigger_context(context) and context.other_card and context.other_card.edition and FB.once_joker_retrigger(card, context, 'dreamscape') then return {repetitions = 1, card = card} end
    end
})

SMODS.Joker({
    key = "giant_kun_fish",
    loc_txt = {name = "Giant Kun Fish", text = {"{X:chips,C:white}X#2#{} Chips per Joker you have", "{C:inactive}Currently {X:chips,C:white}X#1#{} Chips{}"}},
    atlas = "jokers", pos = {x = 4, y = 6}, rarity = 3, cost = 13,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {base = 1, gain = 0.5}},
    loc_vars = function(self, info_queue, card) local n=#(FB.joker_cards()); return {vars = {(card.ability.extra.base or 1) + n*(card.ability.extra.gain or 0.5), card.ability.extra.gain}} end,
    calculate = function(self, card, context) if FB.is_scoring_joker_main(context) then local n=#(FB.joker_cards()); return {x_chips = (card.ability.extra.base or 1) + n*(card.ability.extra.gain or 0.5), card = card} end end
})

SMODS.Joker({
    key = "interdimensional_cave",

    loc_txt = {
        name = "Interdimensional Cave",
        text = {
            "Gives random {C:chips}Chips{} and {C:mult}Mult{}",
            "Higher values are significantly rarer"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 6},

    rarity = 3,
    cost = 11,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                chips = FB.normal_scaled_value('interdimensional_cave_chips', 500, 250),
                mult = FB.normal_scaled_value('interdimensional_cave_mult', 20, 10),
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "jade_bird",

    loc_txt = {
        name = "Jade Bird",
        text = {
            "{C:chips}+#1#{} Chips."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 6},

    rarity = 3,
    cost = 6,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {extra = {fb_loc_vars = {"5"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context) if FB.is_scoring_joker_main(context) then return {chips = 5} end end
})

SMODS.Joker({
    key = "laurel_tree",
    loc_txt = {name = "Laurel Tree", text = {"Creates {C:attention}#1#{}-{C:attention}#2#{} Laurel Branches", "every round"}},
    atlas = "jokers", pos = {x = 8, y = 6}, rarity = 3, cost = 12,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {min = 1, max = 3}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.min, card.ability.extra.max}} end,
    calculate = function(self, card, context)
        if FB.main_end_of_round_once(card, context, 'fb_laurel_tree_create') then
            local n = math.floor((card.ability.extra.min or 1) + FB.num(pseudorandom('laurel_tree'),0)*((card.ability.extra.max or 3)-(card.ability.extra.min or 1)+1))
            local made = 0; for i=1,n do if FB.create_joker('laurel_branch') then made=made+1 end end
            if made>0 then return {message = "+" .. made .. " Branch", colour = G.C.GREEN, card = card} end
        end
    end
})

SMODS.Joker({
    key = "lurendian_deermans",
    loc_txt = {
        name = "Lurendian Deerman's",
        text = {
            "{C:attention}+#1#{} Joker slots",
            "{X:mult,C:white}X#3#{} Mult per {C:attention}Beast{} Joker",
            "{C:inactive}Currently {X:mult,C:white}X#2#{} Mult{}"
        }
    },
    atlas = "jokers", pos = {x = 6, y = 6}, rarity = 3, cost = 13,
    discovered = true, unlocked = true, blueprint_compat = true,
    config = {extra = {slots = 2, gain = 1}},
    loc_vars = function(self, info_queue, card)
        local count = FB.count_beast_jokers and FB.count_beast_jokers() or 0
        return {vars = {card.ability.extra.slots or 2, math.max(1, count * (card.ability.extra.gain or 1)), card.ability.extra.gain or 1}}
    end,
    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(card.ability.extra.slots or 2) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-(card.ability.extra.slots or 2)) end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local count = FB.count_beast_jokers and FB.count_beast_jokers() or 0
            return {x_mult = math.max(1, count * (card.ability.extra.gain or 1)), card = card}
        end
    end
})

SMODS.Joker({
    key = "magpie_bridge",

    loc_txt = {
        name = "Magpie Bridge",
        text = {
            "Sell this joker to make the jokers on the",
            "left and right {C:eternal}eternal{}."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 6},

    rarity = 3,
    cost = 14,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            if G.jokers and G.jokers.cards then
                local idx
                for i, j in ipairs(G.jokers.cards) do if j == card then idx = i end end
                if idx then
                    local left = G.jokers.cards[idx - 1]
                    local right = G.jokers.cards[idx + 1]
                    if left then left.ability = left.ability or {}; left.ability.eternal = true end
                    if right then right.ability = right.ability or {}; right.ability.eternal = true end
                end
            end

            return {message = "Forever together!", colour = G.C.ETERNAL, card = card}
        end
    end
})

SMODS.Joker({
    key = "one_way_ticket_to_heaven",

    loc_txt = {
        name = "One-Way Ticket to Heaven",
        text = {
            "Sell any joker and then sell this joker to",
            "get a Negative edition of that sold joker",
            "{C:inactive}Ticket reserved for{} {C:attention}#1#{}"
        }
    },

    config = {
        extra = {
            stored_key = nil,
            stored_name = "nothing"
        }
    },

    loc_vars = function(self, info_queue, card)
        local name = card.ability.extra.stored_name == "nothing"
            and "{C:red}nothing{}"
            or "{C:attention}" .. card.ability.extra.stored_name .. "{}"

        return {
            vars = {name}
        }
    end,

    atlas = "jokers",
    pos = {x = 0, y = 7},

    rarity = 3,
    cost = 16,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,


    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            local sold = context.card or context.other_card

            if sold and sold ~= card then
                local key = FB.get_center_key(sold)
                local center = key and G.P_CENTERS[key]

                if key and center and center.set == "Joker" then
                    local raw_key = key:gsub("^j_fb_", "")
                    card.ability.extra.stored_key = raw_key
                    card.ability.extra.stored_name = center.loc_txt and center.loc_txt.name or raw_key
                else
                    card.ability.extra.stored_key = nil
                    card.ability.extra.stored_name = "nothing"
                end
            end
        end

        if context.selling_self and card.ability.extra.stored_key then
            local created = SMODS.add_card({
                set = "Joker",
                key = FB.key(card.ability.extra.stored_key),
                area = G.jokers
            })

            if created then
                created:set_edition({negative = true}, true)
                return {
                    message = "Ascend safe!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
})

SMODS.Joker({
    key = "pixiu_horn",

    loc_txt = {
        name = "Pixiu Horn",
        text = {
            "Randomly gives {X:money,C:white}X2{} money,",
            "{X:chips,C:white}X5{} Chips, {C:mult}+#1#{} Mult,",
            "or {X:money,C:white}X0.#2#{} money",
            "{C:green}#3# in #4#{} chance to {C:red}destroy{} itself",
            "and lose {C:money}$#5#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 7},

    rarity = 3,
    cost = 15,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"888", "5", "1", "233", "444"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local roll = pseudorandom('pixiu_horn')
            if roll < (1/233) then
                local ret = {message = "Broke!", colour = G.C.RED, card = card}
                if not context.blueprint then
                    FB.try_add_dollars(-444)
                    FB.queue_self_destroy(card)
                    FB.resolve_or_defer_queued_actions(context)
                end
                return ret
            end

            if roll < 0.25 then
                return {x_chips = 5}
            elseif roll < 0.5 then
                return {mult = 888}
            elseif roll < 0.75 then
                if not context.blueprint then FB.try_add_dollars(G.GAME.dollars or 0) end
                return {message = "Money x2"}
            else
                if not context.blueprint then FB.try_add_dollars(-math.floor((G.GAME.dollars or 0)/2)) end
                return {message = "Money x0.5"}
            end
        end
    end
})

SMODS.Joker({
    key = "underworld",
    loc_txt = {name = "Underworld", text = {"Each {C:dark_edition}Negative{} Joker gives", "{C:attention}+#1#{} hand size"}},
    atlas = "jokers", pos = {x = 2, y = 7}, rarity = 3, cost = 15,
    discovered = true, unlocked = true, blueprint_compat = false,
    config = {extra = {hand_per_negative = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand_per_negative}} end,
    update = function(self, card, dt)
        local target = FB.count_negative_jokers() * (card.ability.extra.hand_per_negative or 1)
        local old = card.ability.fb_underworld_hand_bonus or 0
        if target ~= old then FB.safe_change_hand_size(target - old); card.ability.fb_underworld_hand_bonus = target end
    end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_hand_size(-(card.ability.fb_underworld_hand_bonus or 0)) end
})

