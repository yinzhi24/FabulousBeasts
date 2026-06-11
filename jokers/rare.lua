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
    pos = {
        x = 0,
        y = 8
    },
    rarity = 3,
    cost = 13,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            rounds = 0,
            needed = 9,
            repetitions = 9
        }
    },
    loc_vars = function(self, info_queue, card)
        local needed = FB.extra(card, 'needed', 9)
        return {
            vars = {
                FB.extra(card, 'rounds', 0) % needed,
                needed,
                FB.extra(card, 'repetitions', 9)
            }
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            FB.clear_round_once(card, 'fb_9th_heaven_incremented')
        end
        if FB.is_card_repetition(context)
        and context.cardarea == G.play
        and FB.extra(card, 'rounds', 0) >= FB.extra(card, 'needed', 9) then
            return {
                repetitions = FB.extra(card, 'repetitions', 9),
                card = card
            }
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
    key = "ambrosia_blender",
    loc_txt = {
        name = "Ambrosia Blender",
        text = {
            "Stores added {C:chips}Chips{} and {C:mult}Mult{}",
            "At blind start, every {C:attention}#2#{}",
            "progress creates {C:attention}Ambrosia{}"
        }
    },
    atlas = "jokers",
    pos = { x = 2, y = 9 },
    rarity = 3,
    cost = 9,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {
        extra = {
            progress = 0,
            threshold = 10000,
            max_progress = 999999
        }
    },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return {
            vars = {
                math.floor(e.progress or 0),
                e.threshold or 10000,
                e.max_progress or 999999
            }
        }
    end,

    calculate = function(self, card, context)
        local e = card.ability.extra

        -- Safety: do not let this fire multiple times from repeated contexts.
        local function blender_explode()
            if card.ability.fb_ambrosia_blender_exploded then
                return nil
            end

            card.ability.fb_ambrosia_blender_exploded = true

            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.1,
                func = function()
                    play_sound("tarot1")
                    card:juice_up(1.0, 1.0)

                    -- Mechanically transform instead of destroy + create.
                    -- This avoids full Joker-slot failures and stale-card weirdness.
                    if G.P_CENTERS and G.P_CENTERS.j_fb_super_lollipop then
                        card:set_ability(G.P_CENTERS.j_fb_super_lollipop, nil, true)
                    else
                        -- Fallback: if Super Lollipop somehow is not loaded,
                        -- destroy the Blender so the failure is obvious.
                        if FB.queue_self_destroy then
                            FB.queue_self_destroy(card)
                            if FB.resolve_or_defer_queued_actions then
                                FB.resolve_or_defer_queued_actions(context or {})
                            end
                        elseif card.start_dissolve then
                            card:start_dissolve()
                        end
                    end

                    return true
                end
            }))

            return {
                message = "BOOM!",
                colour = G.C.RED,
                card = card
            }
        end

        -- Check the breaking point FIRST.
        -- Otherwise 999,999 progress gets converted into Ambrosia at blind start
        -- and never reaches the Divine transformation.
        if not context.blueprint
        and FB.num(e.progress, 0) >= FB.num(e.max_progress, 999999) then
            return blender_explode()
        end

        -- Normal Ambrosia production.
        if context.setting_blind and not context.blueprint then
            local made = 0

            -- Check again before spending progress.
            if FB.num(e.progress, 0) >= FB.num(e.max_progress, 999999) then
                return blender_explode()
            end

            while FB.num(e.progress, 0) >= FB.num(e.threshold, 10000)
            and G.jokers
            and G.jokers.cards
            and G.jokers.config
            and #G.jokers.cards < G.jokers.config.card_limit do

                -- Do not let the normal Ambrosia loop consume the breaking point.
                if FB.num(e.progress, 0) >= FB.num(e.max_progress, 999999) then
                    return blender_explode()
                end

                e.progress = FB.num(e.progress, 0) - FB.num(e.threshold, 10000)

                SMODS.add_card({
                    key = "j_fb_ambrosia",
                    area = G.jokers
                })

                made = made + 1
            end

            if made > 0 then
                return {
                    message = "+" .. tostring(made) .. " Ambrosia",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

SMODS.Joker({
    key = "baby_bixie",
    loc_txt = {
        name = "Baby Bixie",
        text = {
            "Gains {C:mult}+#2#{} Mult every round",
            "Evolves into {C:attention}Bixie{} at {C:mult}+#3#{} Mult",
            "{C:inactive}Currently {C:mult}+#1#{} Mult{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 2,
        y = 8
    },
    rarity = 3,
    cost = 13,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            mult = 0,
            mult_gain = 10,
            evolve_mult = 150
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return {
            vars = {
                FB.num(extra.mult, 0),
                FB.num(extra.mult_gain, 10),
                FB.num(extra.evolve_mult, 150)
            }
        }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra
        if FB.main_end_of_round_once(card, context, 'fb_baby_bixie_growth') then
            extra.mult = FB.num(extra.mult, 0) + FB.num(extra.mult_gain, 10)
            if FB.num(extra.mult, 0) >= FB.num(extra.evolve_mult, 150) then
                G.E_MANAGER: add_event(Event({
                    func = function()
                        if G.P_CENTERS.j_fb_bixie then
                            card: set_ability(G.P_CENTERS.j_fb_bixie, nil, true)
                            card: juice_up(0.5, 0.5)
                        end
                        return true
                    end
                }))
                return {
                    message = "Evolved!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
            return {
                message = "+"..tostring(FB.num(extra.mult_gain, 10)),
                colour = G.C.MULT,
                card = card
            }
        end
        if FB.is_scoring_joker_main(context) then
            return {
                mult = FB.num(extra.mult, 0),
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "baby_tianlu",
    loc_txt = {
        name = "Baby Tianlu",
        text = {
            "At blind start, consume all money",
            "and gain {C:chips}+#2#{} Chips per {C:money}$1{} consumed",
            "Evolves into {C:attention}Tianlu{} at {C:chips}+#3#{} Chips",
            "{C:inactive}Currently {C:chips}+#1#{} Chips{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 3,
        y = 8
    },
    rarity = 3,
    cost = 13,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            chips = 0,
            chip_gain_per_dollar = 10,
            evolve_chips = 1000
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return {
            vars = {
                FB.num(extra.chips, 0),
                FB.num(extra.chip_gain_per_dollar, 10),
                FB.num(extra.evolve_chips, 1000)
            }
        }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra
        if context.setting_blind and not context.blueprint then
            local dollars = math.max(0, FB.num(G.GAME.dollars, 0))
            if dollars > 0 then
                extra.chips = FB.num(extra.chips, 0)
                + dollars * FB.num(extra.chip_gain_per_dollar, 10)
                FB.try_add_dollars(- dollars)
            end
            if FB.num(extra.chips, 0) >= FB.num(extra.evolve_chips, 1000) then
                G.E_MANAGER: add_event(Event({
                    func = function()
                        if G.P_CENTERS.j_fb_tianlu then
                            card: set_ability(G.P_CENTERS.j_fb_tianlu, nil, true)
                            card: juice_up(0.5, 0.5)
                        end
                        return true
                    end
                }))
                return {
                    message = "Evolved!",
                    colour = G.C.GREEN,
                    card = card
                }
            end
            return {
                message = "+"..tostring(dollars * FB.num(extra.chip_gain_per_dollar, 10)),
                colour = G.C.CHIPS,
                card = card
            }
        end
        if FB.is_scoring_joker_main(context) then
            return {
                chips = FB.num(extra.chips, 0),
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "bone_mask",
    loc_txt = {
        name = "Bone Mask",
        text = {
            "{C:red}Debuff{} played face cards",
            "{C:attention}Retrigger{} scored cards once per",
            "{C:red}debuffed{} face card"
        }
    },
    atlas = "jokers",
    pos = {
        x = 5,
        y = 8
    },
    rarity = 3,
    cost = 11,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            repetitions = 1
        }
    },
    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.play and G.play.cards then
            for _,
            c in ipairs(G.play.cards) do
                if FB.is_face(c) then
                    c.debuff = true
                end
            end
        end
        if FB.is_card_repetition(context) and context.cardarea == G.play then
            local n = 0
            for _,
            c in ipairs((G.play and G.play.cards) or {}) do
                if FB.is_face(c) and c.debuff then
                    n = n + 1
                end
            end
            if n > 0 then
                return {
                    repetitions = n *(card.ability.extra.repetitions or 1),
                    card = card
                }
            end
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
            "Gives {C:mult}+#2#{} Mult, equal to",
            "your current {C:money}money{}."
        }
    },
    atlas = "jokers",
    pos = {
        x = 6,
        y = 8
    },
    rarity = 3,
    cost = 12,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            sell_gain = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.sell_gain or 1,
                math.max(0, G.GAME and G.GAME.dollars or 0)
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                mult = math.max(0, G.GAME.dollars or 0),
                card = card
            }
        end
        if FB.main_end_of_round_once(card, context, 'fb_cintamani_value_gain') then
            local gain = card.ability.extra.sell_gain or 1
            for _,
            area in ipairs({
                G.jokers,
                G.consumeables
            }) do
                if area and area.cards then
                    for _,
                    c in ipairs(area.cards) do
                        if c ~= card then
                            c.sell_cost =(c.sell_cost or 0) + gain
                        end
                    end
                end
            end
            return {
                message = "+$"..gain.." Value",
                colour = G.C.MONEY,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "divine_garment",
    loc_txt = {
        name = "Divine Garment",
        text = {
            "{C:attention}Retrigger{} Legendary Jokers once",
            "{C:inactive}Only affects rarity 4 Jokers{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 7,
        y = 8
    },
    rarity = 3,
    cost = 12,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
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
        and context.other_card.config
        and context.other_card.config.center
        and context.other_card.config.center.rarity == 4
        and FB.once_joker_retrigger(card, context, 'divine_garment') then
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "divine_hair_growth_elixir",
    loc_txt = {
        name = "Divine Hair Growth Elixir",
        text = {
            "Scored cards permanently gain their",
            "current {C:chips}Chip{} value as bonus {C:chips}Chips{}",
            "{C:inactive}Limit once per card per hand{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 8,
        y = 8
    },
    rarity = 3,
    cost = 14,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            for _,
            c in ipairs((G.play and G.play.cards) or {}) do
                c.fb_elixir_used = nil
            end
        end
        if FB.is_scoring_individual(context) and context.other_card and not context.other_card.fb_elixir_used then
            context.other_card.fb_elixir_used = true
            local gain = math.max(1, FB.num(context.other_card:get_chip_bonus(), 0))
            context.other_card.ability = context.other_card.ability or {}
            context.other_card.ability.perma_bonus =(context.other_card.ability.perma_bonus or 0) + gain
            return {
                message = "+"..gain,
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
            "Gain {X:consumable,C:white}^#2#{} Mult per",
            "{C:dark_edition}Negative{} Joker",
            "{C:inactive}Currently {X:consumable,C:white}^#1#{} Mult{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 9,
        y = 8
    },
    rarity = 3,
    cost = 15,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            base = 1,
            gain = 0.2
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                (card.ability.extra.base or 1) +(card.ability.extra.gain or 0.2) * FB.count_negative_jokers(),
                card.ability.extra.gain
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                e_mult =(card.ability.extra.base or 1) +(card.ability.extra.gain or 0.2) * FB.count_negative_jokers(),
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "divine_warsword",
    loc_txt = {
        name = "Divine Warsword",
        text = {
            "If played hand is {C:attention}#1#{},",
            "gain {X:mult,C:white}X#2#{} Mult",
            "and balance score",
            "{C:inactive}Current hand: {C:attention}#1#{}{}"
        }
    },
    atlas = "jokers",
    pos = { x = 10, y = 8 },
    rarity = 3,
    cost = 13,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
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
            card.ability.extra.hand = FB.random_hand_type('divine_warsword')
            return
        end

        if FB.is_scoring_joker_main(context) and context.scoring_name == card.ability.extra.hand then
            return {
                x_mult = card.ability.extra.xmult or 3,
                balance = true,
                card = card
            }
        end
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
    pos = {
        x = 11,
        y = 8
    },
    rarity = 3,
    cost = 14,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            fb_loc_vars = {
                "1"
            }
        }
    },
    loc_vars = function(self, info_queue, card)
        return FB.static_loc_vars(card)
    end,
    add_to_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(1)
    end,
    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(- 1)
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_individual(context) and context.other_card and context.other_card.edition then
            return {
                x_chips = 2,
                x_mult = 2
            }
        end
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards and context.other_card and context.other_card.edition and FB.once_joker_retrigger(card, context, 'dreamscape') then
            return {
                repetitions = 1,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "giant_kun_fish",
    loc_txt = {
        name = "Giant Kun Fish",
        text = {
            "{X:chips,C:white}X#2#{} Chips per Joker you have",
            "{C:inactive}Currently {X:chips,C:white}X#1#{} Chips{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 12,
        y = 8
    },
    rarity = 3,
    cost = 13,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            base = 1,
            gain = 0.5
        }
    },
    loc_vars = function(self, info_queue, card)
        local n = #(FB.joker_cards());
        return {
            vars = {
                (card.ability.extra.base or 1) + n *(card.ability.extra.gain or 0.5),
                card.ability.extra.gain
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local n = #(FB.joker_cards());
            return {
                x_chips =(card.ability.extra.base or 1) + n *(card.ability.extra.gain or 0.5),
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
    pos = {
        x = 2,
        y = 19
    },
    rarity = 3,
    cost = 6,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            fb_loc_vars = {
                "5"
            }
        }
    },
    loc_vars = function(self, info_queue, card)
        return FB.static_loc_vars(card)
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                chips = 5
            }
        end
    end
})

SMODS.Joker({
    key = "laurel_tree",
    loc_txt = {
        name = "Laurel Tree",
        text = {
            "Creates {C:attention}#1#{}-{C:attention}#2#{} Laurel Branches",
            "every round"
        }
    },
    atlas = "jokers",
    pos = {
        x = 15,
        y = 8
    },
    rarity = 3,
    cost = 12,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            min = 1,
            max = 3
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.min,
                card.ability.extra.max
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.main_end_of_round_once(card, context, 'fb_laurel_tree_create') then
            local n = math.floor((card.ability.extra.min or 1) + FB.num(pseudorandom('laurel_tree'), 0) *((card.ability.extra.max or 3) -(card.ability.extra.min or 1) + 1))
            local made = 0;
            for i = 1,
            n do
                if FB.create_joker('laurel_branch') then
                    made = made + 1
                end
            end
            if made > 0 then
                return {
                    message = "+"..made.." Branch",
                    colour = G.C.GREEN,
                    card = card
                }
            end
        end
    end
})

SMODS.Joker({
    key = "deermans",
    loc_txt = {
        name = "Deerman's",
        text = {
            "{C:attention}+#1#{} Joker slots",
            "{X:mult,C:white}X#3#{} Mult per {C:attention}Beast{} Joker",
            "{C:inactive}Currently {X:mult,C:white}X#2#{} Mult{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 16,
        y = 8
    },
    rarity = 3,
    cost = 13,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            slots = 2,
            gain = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        local count = FB.count_beast_jokers and FB.count_beast_jokers() or 0
        return {
            vars = {
                card.ability.extra.slots or 2,
                math.max(1, count *(card.ability.extra.gain or 1)),
                card.ability.extra.gain or 1
            }
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        FB.safe_change_joker_slots(card.ability.extra.slots or 2)
    end,
    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_joker_slots(-(card.ability.extra.slots or 2))
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local count = FB.count_beast_jokers and FB.count_beast_jokers() or 0
            return {
                x_mult = math.max(1, count *(card.ability.extra.gain or 1)),
                card = card
            }
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
    pos = {
        x = 17,
        y = 8
    },
    rarity = 3,
    cost = 14,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            if G.jokers and G.jokers.cards then
                local idx
                for i,
                j in ipairs(G.jokers.cards) do
                    if j == card then
                        idx = i
                    end
                end
                if idx then
                    local left = G.jokers.cards [idx - 1]
                    local right = G.jokers.cards [idx + 1]
                    if left then
                        left.ability = left.ability or {};
                        left.ability.eternal = true
                    end
                    if right then
                        right.ability = right.ability or {};
                        right.ability.eternal = true
                    end
                end
            end
            return {
                message = "Forever together!",
                colour = G.C.ETERNAL,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "one_way_ticket_to_heaven",
    loc_txt = {
        name = "One-Way Ticket to Heaven",
        text = {
            "Sell any other Joker, then sell this Joker",
            "to get a {C:dark_edition}Negative{} copy of it",
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
        return {
            vars = {
                card.ability.extra.stored_name or "nothing"
            }
        }
    end,
    atlas = "jokers",
    pos = {
        x = 18,
        y = 8
    },
    rarity = 3,
    cost = 16,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        -- IMPORTANT: handle selling this Ticket first.
        -- Otherwise context.selling_card may still point to the last sold Joker.
        if context.selling_self then
            local key = card.ability.extra.stored_key
            if not key then
                return
            end
            if key == FB.key("one_way_ticket_to_heaven") then
                return
            end
            if not G.P_CENTERS [key] then
                return
            end
            local created =

            SMODS.add_card({
                set = "Joker",
                key = key,
                area = G.jokers
            })
            if created then
                created: set_edition({
                    negative = true
                }, true)
                return {
                    message = "Ascend safe!",
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
            return
        end
        if context.selling_card and not context.blueprint then
            local sold = context.card or context.other_card
            if not sold or sold == card then
                return
            end
            local key = FB.get_center_key(sold)
            local center = key and G.P_CENTERS [key]
            -- Ignore tickets entirely; do not overwrite reservation.
            if key == FB.key("one_way_ticket_to_heaven") then
                return
            end
            if key and center and center.set == "Joker" then
                card.ability.extra.stored_key = key
                card.ability.extra.stored_name =
                (center.loc_txt and center.loc_txt.name)
                or center.name
                or key
            end
        end
    end
})

SMODS.Joker({
    key = "pixiu_fur",
    loc_txt = {
        name = "Pixiu Fur",
        text = {
            "If your next hand contains {C:attention}#1#{},",
            "apply a random {C:attention}enhancement{},",
            "{C:green}seal{}, and {C:edition}edition{}",
            "to all scored cards, then {C:red}self destructs{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 19,
        y = 8
    },
    rarity = 3,
    cost = 10,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            hand = "Pair"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.hand
            }
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand = FB.random_hand_type('pixiu_fur')
        end
        if context.before
        and not context.blueprint
        and context.poker_hands
        and context.poker_hands [card.ability.extra.hand]
        and next(context.poker_hands [card.ability.extra.hand]) then
            for _,
            c in ipairs(context.scoring_hand or {}) do
                c: set_ability(
                G.P_CENTERS [pseudorandom_element({
                    'm_bonus',
                    'm_mult',
                    'm_wild',
                    'm_glass',
                    'm_steel',
                    'm_stone',
                    'm_gold',
                    'm_lucky'
                }, pseudoseed('pixiu_fur_enhance'))],
                nil,
                true
               )
                c: set_seal(
                pseudorandom_element({
                    'Gold',
                    'Blue',
                    'Red',
                    'Purple'
                }, pseudoseed('pixiu_fur_seal')),
                true
               )
                c: set_edition(
                pseudorandom_element({
                    {
                        foil = true
                    },
                    {
                        holo = true
                    },
                    {
                        polychrome = true
                    }
                }, pseudoseed('pixiu_fur_edition')),
                true
               )
            end
            FB.queue_self_destroy(card)
            FB.resolve_or_defer_queued_actions(context)
            return {
                message = "Blessed!",
                colour = G.C.GREEN,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "pixiu_horn",
    loc_txt = {
        name = "Pixiu Horn",
        text = {
            "Randomly gives {X:money,C:white}X2{} money,",
            "{X:chips,C:white}X#2#{} Chips, {C:mult}+#1#{} Mult,",
            "or {X:money,C:white}X0.#3#{} money",
            "{C:green}#4# in #5#{} chance to {C:red}destroy{} itself",
            "and lose {C:money}$#6#{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 0,
        y = 9
    },
    rarity = 3,
    cost = 15,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            mult = 888,
            xchips = 5,
            money_halve_digit = 5,
            odds_num = 1,
            odds_den = 233,
            break_cost = 444
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult,
                card.ability.extra.xchips,
                card.ability.extra.money_halve_digit,
                card.ability.extra.odds_num,
                card.ability.extra.odds_den,
                card.ability.extra.break_cost
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            local extra = card.ability.extra
            if FB.roll('pixiu_horn_break', extra.odds_num or 1, extra.odds_den or 233) then
                local ret = {
                    message = "Broke!",
                    colour = G.C.RED,
                    card = card
                }
                if not context.blueprint then
                    FB.try_add_dollars(-(extra.break_cost or 444))
                    FB.queue_self_destroy(card)
                    FB.resolve_or_defer_queued_actions(context)
                end
                return ret
            end
            local effect = pseudorandom_element({
                'x_chips',
                'mult',
                'money_double',
                'money_halve'
            }, pseudoseed('pixiu_horn_effect'))
            if effect == 'x_chips' then
                return {
                    x_chips = extra.xchips or 5
                }
            elseif effect == 'mult' then
                return {
                    mult = extra.mult or 888
                }
            elseif effect == 'money_double' then
                if not context.blueprint then
                    FB.try_add_dollars(G.GAME.dollars or 0)
                end
                return {
                    message = "Money x2"
                }
            else
                if not context.blueprint then
                    FB.try_add_dollars(- math.floor((G.GAME.dollars or 0) / 2))
                end
                return {
                    message = "Money x0.5"
                }
            end
        end
    end
})

SMODS.Joker({
    key = "rigged_video_game",
    loc_txt = {
        name = "Rigged Video Game",
        text = {
            "At start of blind, if you have space,",
            "create a random {C:attention}Joker{} with {C:attention}equal odds{}",
            "then lose money based on its rarity",
            "{C:inactive}Exotic and Divine Jokers cannot appear{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 1,
        y = 9
    },
    rarity = 3,
    cost = 10,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            common_min = 1,
            common_max = 5,
            uncommon_min = 5,
            uncommon_max = 15,
            rare_min = 10,
            rare_max = 30,
            legendary_min = 15,
            legendary_max = 50,
            exotic_min = 20,
            exotic_max = 75,
            divine_min = 25,
            divine_max = 99
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {}
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            if not G.jokers or #G.jokers.cards >= G.jokers.config.card_limit then
                return {
                    message = "No Space!",
                    colour = G.C.RED,
                    card = card
                }
            end
            local extra = card.ability.extra
            local function get_cost_range(rarity)
                if rarity == 1 or rarity == "Common" or rarity == "common" then
                    return extra.common_min,
                    extra.common_max
                elseif rarity == 2 or rarity == "Uncommon" or rarity == "uncommon" then
                    return extra.uncommon_min,
                    extra.uncommon_max
                elseif rarity == 3 or rarity == "Rare" or rarity == "rare" then
                    return extra.rare_min,
                    extra.rare_max
                elseif rarity == 4 or rarity == "Legendary" or rarity == "legendary" then
                    return extra.legendary_min,
                    extra.legendary_max
                elseif rarity == "Exotic" or rarity == "exotic" or rarity == "fb_exotic" then
                    return extra.exotic_min,
                    extra.exotic_max
                elseif rarity == "Divine" or rarity == "divine" or rarity == "fb_divine" then
                    return extra.divine_min,
                    extra.divine_max
                end
                return extra.common_min,
                extra.common_max
            end
            local eligible = {}
            for _,
            center in pairs(G.P_CENTERS) do
                if center.set == "Joker"
                and center.unlocked ~= false
                and center.key ~= "j_fb_rigged_video_game"
                and center.key ~= "rigged_video_game"
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
            if #eligible <= 0 then
                return {
                    message = "No Prize!",
                    colour = G.C.RED,
                    card = card
                }
            end
            local chosen = pseudorandom_element(eligible, pseudoseed("rigged_video_game"))
            local min_cost,
            max_cost = get_cost_range(chosen.rarity)
            local money_loss = pseudorandom("rigged_video_game_cost", min_cost, max_cost)
            ease_dollars(- money_loss)
            G.E_MANAGER: add_event(Event({
                func = function()
                    if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                        local new_card = create_card(
                        "Joker",
                        G.jokers,
                        nil,
                        nil,
                        nil,
                        nil,
                        chosen.key,
                        "rigged_video_game"
                       )
                        new_card: add_to_deck()
                        G.jokers: emplace(new_card)
                    end
                    return true
                end
            }))
            return {
                message = "-$"..money_loss,
                colour = G.C.MONEY,
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "underworld",
    loc_txt = {
        name = "Underworld",
        text = {
            "Each {C:dark_edition}Negative{} Joker gives",
            "{C:attention}+#1#{} hand size"
        }
    },
    atlas = "jokers",
    pos = {
        x = 2,
        y = 9
    },
    rarity = 3,
    cost = 15,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            hand_per_negative = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.hand_per_negative
            }
        }
    end,
    update = function(self, card, dt)
        local target = FB.count_negative_jokers() *(card.ability.extra.hand_per_negative or 1)
        local old = card.ability.fb_underworld_hand_bonus or 0
        if target ~= old then
            FB.safe_change_hand_size(target - old);
            card.ability.fb_underworld_hand_bonus = target
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(-(card.ability.fb_underworld_hand_bonus or 0))
    end
})

SMODS.Joker({
    key = "failed_creations",
    loc_txt = {
        name = "Failed Creations",
        text = {
            "This Joker gains {X:mult,C:white}X#2#{} Mult",
            "for this round for each",
            "{C:attention}unscored{} played card",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },
    atlas = "jokers",
    pos = {
        x = 3,
        y = 9
    },
    rarity = 3,
    cost = 9,
    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    config = {
        extra = {
            xmult = 1,
            gain = 0.25
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xmult or 1,
                card.ability.extra.gain or 0.25
            }
        }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra

        -- Reset at the start of each blind/round.
        if context.setting_blind and not context.blueprint then
            extra.xmult = 1
            return {
                message = "Reset",
                colour = G.C.RED,
                card = card
            }
        end

        -- Count played cards that are NOT in the scoring hand.
        -- This intentionally anti-synergizes with Splash because Splash makes played cards score.
        if context.before and not context.blueprint then
            local scored = {}

            for _, scored_card in ipairs(context.scoring_hand or {}) do
                scored[scored_card] = true
            end

            local unscored = 0
            for _, played_card in ipairs(context.full_hand or {}) do
                if not scored[played_card] then
                    unscored = unscored + 1
                end
            end

            if unscored > 0 then
                extra.xmult = (extra.xmult or 1) + unscored * (extra.gain or 0.25)

                return {
                    message = "+" .. tostring(unscored * (extra.gain or 0.25)) .. "X",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        if FB.is_scoring_joker_main(context) then
            return {
                x_mult = extra.xmult or 1,
                card = card
            }
        end
    end
})
