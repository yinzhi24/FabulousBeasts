---@diagnostic disable: undefined-global

-- Fabulous Beasts: Rare Jokers

SMODS.Joker({
    key = "9th_heaven",

    loc_txt = {
        name = "9th Heaven",
        text = {
            "Every {C:attention}9{} rounds {C:attention}retrigger{} all played cards",
            "{C:attention}9{} times.",
            "{C:inactive}Rounds: #1#/9{}"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 5},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    config = {extra = {rounds = 0}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.rounds % 9}} end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint then card.ability.extra.rounds = card.ability.extra.rounds + 1 end
        if context.repetition and context.cardarea == G.play and card.ability.extra.rounds >= 9 then return {repetitions = 9, card = card} end
        if context.after and not context.blueprint and card.ability.extra.rounds >= 9 then card.ability.extra.rounds = 0 end
    end
})

SMODS.Joker({
    key = "body_swap_mushroom",

    loc_txt = {
        name = "Body Swap Mushroom",
        text = {
            "All chips and mult are swapped (chips >",
            "mult and mult > chips, same with {X:mult,C:white}XMult{} and",
            "{X:chips,C:white}XChips{})."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 5},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.joker_main then return {chips = mult, mult = hand_chips, message = "Swapped"} end
    end
})

SMODS.Joker({
    key = "bone_mask",

    loc_txt = {
        name = "Bone Mask",
        text = {
            "All face cards are {C:red}debuffed{}. {C:attention}Retrigger{} all",
            "jokers for each played {C:red}debuffed{} face card."
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 5},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then for _, c in ipairs(G.play.cards) do if FB.is_face(c) then c.debuff = true end end end
        if context.retrigger_joker_check and context.other_card ~= card then
            local n = 0; for _, c in ipairs(G.play.cards or {}) do if FB.is_face(c) and c.debuff then n = n + 1 end end
            if n > 0 then return {repetitions = n, card = card} end
        end
    end
})

SMODS.Joker({
    key = "cintamani",

    loc_txt = {
        name = "Cintamani",
        text = {
            "For each one your are holding doubles the",
            "sell value of all jokers and consumables,",
            "and it stacks."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 5},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local multv = 2 ^ FB.count_joker('cintamani')
            for _, area in ipairs({G.jokers, G.consumeables}) do
                if area and area.cards then
                    for _, c in ipairs(area.cards) do
                        c.sell_cost = (c.sell_cost or 0) * multv
                    end
                end
            end
            return {message = "Value x" .. multv}
        end
    end
})

SMODS.Joker({
    key = "divine_garment",

    loc_txt = {
        name = "Divine Garment",
        text = {
            "{C:attention}Retrigger{} the left beast's effects once."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 5},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card and G.jokers.cards then
            local index = nil; for i, j in ipairs(G.jokers.cards) do if j == card then index = i end end
            if index and context.other_card == G.jokers.cards[index - 1] then return {repetitions = 1, card = card} end
        end
    end
})

SMODS.Joker({
    key = "divine_hair_growth_elixir",

    loc_txt = {
        name = "Divine Hair Growth Elixir",
        text = {
            "Scored cards permanently double their current",
            "{C:chips}Chip{} value as bonus {C:chips}Chips{}.",
            "{C:inactive}Limit once per card per hand{}"
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            for _, c in ipairs(G.play.cards or {}) do
                c.fb_elixir_used = nil
            end
        end

        if context.individual and context.cardarea == G.play and context.other_card and not context.other_card.fb_elixir_used then
            context.other_card.fb_elixir_used = true
            local gain = math.max(1, context.other_card:get_chip_bonus())
            context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + gain
            return {
                message = "+" .. gain,
                colour = G.C.CHIPS,
                card = context.other_card
            }
        end
    end
})

SMODS.Joker({
    key = "divine_light",

    loc_txt = {
        name = "Divine Light",
        text = {
            "{X:mult,C:white}^1.2{} Mult for each negative joker.",
            "{C:inactive}Currently {X:mult,C:white}^#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    loc_vars = function(self, info_queue, card) return {vars = {math.max(1, 1.2 ^ FB.count_negative_jokers())}} end,
    calculate = function(self, card, context) if context.joker_main then return {e_mult = math.max(1, 1.2 ^ FB.count_negative_jokers())} end end
})

SMODS.Joker({
    key = "divine_warsword",

    loc_txt = {
        name = "Divine Warsword",
        text = {
            "When your played card is [poker hand], X3",
            "mult and balance score (Plasma deck",
            "effect, hand type changes at the end of",
            "every round).",
            "{C:inactive}Current hand: {C:attention}#1#{}{}"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    config = {extra = {hand = "Pair"}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand = FB.random_hand_type and FB.random_hand_type('divine_warsword') or FB.random_poker_hand('divine_warsword')
            return {message = card.ability.extra.hand, colour = G.C.ATTENTION, card = card}
        end
        if context.joker_main and context.scoring_name == card.ability.extra.hand then
            return {x_mult = 3, chips = mult, mult = hand_chips}
        end
    end
})

SMODS.Joker({
    key = "dreamscape",

    loc_txt = {
        name = "Dreamscape",
        text = {
            "All jokers and cards with editions have",
            "doubled values. {C:attention}+1{} hand size."
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    add_to_deck = function(self, card, from_debuff) FB.safe_change_hand_size(1) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_hand_size(-1) end,
    calculate = function(self, card, context)
        if context.individual and context.other_card and context.other_card.edition then return {x_chips = 2, x_mult = 2} end
        if context.retrigger_joker_check and context.other_card and context.other_card.edition then return {repetitions = 1, card = card} end
    end
})

SMODS.Joker({
    key = "giant_kun_fish",

    loc_txt = {
        name = "Giant Kun Fish",
        text = {
            "{X:chips,C:white}X1.5{} Chips for each joker triggered.",
            "{C:inactive}Currently {X:chips,C:white}X#1#{} Chips{}"
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    loc_vars = function(self, info_queue, card) return {vars = {math.max(1, 1.5 ^ #G.jokers.cards)}} end,
    calculate = function(self, card, context) if context.joker_main then return {x_chips = math.max(1, 1.5 ^ #G.jokers.cards)} end end
})

SMODS.Joker({
    key = "interdimensional_cave",

    loc_txt = {
        name = "Interdimensional Cave",
        text = {
            "Randomizes all values if possible."
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.joker_main then return {chips = pseudorandom('interdimensional_cave_chips', -500, 500), mult = pseudorandom('interdimensional_cave_mult', -50, 50)} end
    end
})

SMODS.Joker({
    key = "jade_bird",

    loc_txt = {
        name = "Jade Bird",
        text = {
            "{C:chips}+5{} Chips."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.joker_main then return {chips = 5} end end
})

SMODS.Joker({
    key = "laurel_tree",

    loc_txt = {
        name = "Laurel Tree",
        text = {
            "Creates a Laurel Branch every round."
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.setting_blind and not context.blueprint then FB.create_joker('laurel_branch'); return {message = "Branched"} end end
})

SMODS.Joker({
    key = "lurendian_deermans",

    loc_txt = {
        name = "Deerman's",
        text = {
            "Doubles the reroll cost but gains +4 shop",
            "slots, {C:attention}+1{} voucher slot, and {C:attention}+1{} booster",
            "pack slot."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 6},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    add_to_deck = function(self, card, from_debuff)
        if G.shop_jokers then G.shop_jokers.config.card_limit = G.shop_jokers.config.card_limit + 4 end
        if G.shop_vouchers then G.shop_vouchers.config.card_limit = G.shop_vouchers.config.card_limit + 1 end
        if G.shop_booster then G.shop_booster.config.card_limit = G.shop_booster.config.card_limit + 1 end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if G.shop_jokers then G.shop_jokers.config.card_limit = G.shop_jokers.config.card_limit - 4 end
        if G.shop_vouchers then G.shop_vouchers.config.card_limit = G.shop_vouchers.config.card_limit - 1 end
        if G.shop_booster then G.shop_booster.config.card_limit = G.shop_booster.config.card_limit - 1 end
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
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.selling_self then
            local idx; for i,j in ipairs(G.jokers.cards) do if j == card then idx = i end end
            if idx then if G.jokers.cards[idx - 1] then G.jokers.cards[idx - 1].ability.eternal = true end; if G.jokers.cards[idx + 1] then G.jokers.cards[idx + 1].ability.eternal = true end end
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
            "{C:inactive}Ticket reserved for {C:attention}#1#{}",
            "{C:inactive}Not affected by Showman{}"
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
    cost = 7,

    discovered = true,
    unlocked = true,

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
            "Does one of these randomly: {X:money,C:white}X2{} money, X5",
            "chips, {C:mult}+888{} Mult, {X:money,C:white}X0.5{} money, with a 1 in",
            "233 chance to {C:red}destroy{} itself and lose",
            "{C:money}$444{}."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 7},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.joker_main then
            local roll = pseudorandom('pixiu_horn')
            if roll < (1/233) then FB.try_add_dollars(-444); FB.destroy(card); return {message = "Broke!"} end
            if roll < 0.25 then return {x_chips = 5} elseif roll < 0.5 then return {mult = 888} elseif roll < 0.75 then FB.try_add_dollars(G.GAME.dollars or 0); return {message = "Money x2"} else FB.try_add_dollars(-math.floor((G.GAME.dollars or 0)/2)); return {message = "Money x0.5"} end
        end
    end
})

SMODS.Joker({
    key = "underworld",

    loc_txt = {
        name = "Underworld",
        text = {
            "Chance to spawn any sold joker (non",
            "duplicate only, will allow dupes if you",
            "have Showman) every round ({C:green}1 in 4{})."
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 7},

    rarity = 3,
    cost = 7,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            local sold = context.card or context.other_card
            local key = FB.get_center_key(sold)

            if key and key:sub(1, 5) == 'j_fb_' then
                FB.sold_joker_keys = FB.sold_joker_keys or {}
                local raw_key = key:gsub('^j_fb_', '')
                local seen = false

                for _, existing in ipairs(FB.sold_joker_keys) do
                    if existing == raw_key then
                        seen = true
                        break
                    end
                end

                if not seen then
                    table.insert(FB.sold_joker_keys, raw_key)
                end
            end
        end

        if context.setting_blind and pseudorandom('underworld') < 0.25 and not context.blueprint then
            if FB.sold_joker_keys and #FB.sold_joker_keys > 0 then
                local key = pseudorandom_element(FB.sold_joker_keys, pseudoseed('underworld_spawn'))
                FB.create_joker(key)
            end
            return {message = "Returned"}
        end
    end
})

