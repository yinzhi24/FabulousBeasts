---@diagnostic disable: undefined-global

-- Fabulous Beasts: custom rarities and higher-tier Jokers

SMODS.Rarity({
    key = "exotic",
    loc_txt = {name = "Exotic"},
    badge_colour = HEX("4795A6"),
    default_weight = 0,
    pools = {Joker = true}
})

SMODS.Rarity({
    key = "divine",
    loc_txt = {name = "Divine"},
    badge_colour = HEX("E0CB1B"),
    default_weight = 0,
    pools = {Joker = true}
})

SMODS.Joker({
    key = "bixie_true_form",

    loc_txt = {
        name = "Bixie True Form",
        text = {
            "Gains {X:consumable,C:white}^#2#{} Mult every round, {X:consumable,C:white}^#3#{} for",
            "boss and {X:consumable,C:white}^#4#{} for final bosses.",
            "{C:inactive}Currently {X:consumable,C:white}^#1#{C:inactive} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 10},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {emult = 1, gain_round = 0.1, gain_boss = 0.15, gain_final = 0.2}},
    loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.extra.emult,
            card.ability.extra.gain_round,
            card.ability.extra.gain_boss,
            card.ability.extra.gain_final
        }}
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then return {e_mult = card.ability.extra.emult} end
        if FB.main_end_of_round_once(card, context, 'fb_bixie_true_scaled') then
            -- Only one condition applies. Final boss > boss > normal round.
            local gain = FB.round_condition_value(card, 'gain_round', 'gain_boss', 'gain_final')
            card.ability.extra.emult = card.ability.extra.emult + gain
        end
    end
})


SMODS.Joker({
    key = "rainbow_mountain_range",

    loc_txt = {
        name = "Rainbow Mountain Range",
        text = {
            "Gives {X:chips,C:white}XChips{} equal to current",
            "{C:mult}Mult{}, and {X:mult,C:white}XMult{} equal to",
            "current {C:chips}Chips{}"
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 10},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                x_chips = math.max(1, FB.num(mult, 1)),
                x_mult = math.max(1, FB.num(hand_chips, 1))
            }
        end
    end
})

SMODS.Joker({
    key = "qishiqi",

    loc_txt = {
        name = "Qishiqi",
        text = {
            "Every {C:attention}#2#{} played-card triggers,",
            "gain {X:purple,C:white}^#3#{} Chips and",
            "{X:consumable,C:white}^#4#{} Mult",
            "{C:inactive}Triggers: #1#/#2#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 10},

    rarity = "fb_exotic",
    cost = 77,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {triggers = 0, needed = 77, echips = 7, emult = 7}},
    loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.extra.triggers,
            card.ability.extra.needed,
            card.ability.extra.echips,
            card.ability.extra.emult
        }}
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_individual(context) then
            card.ability.extra.triggers = card.ability.extra.triggers + 1
        end
        if FB.is_scoring_joker_main(context) and card.ability.extra.triggers >= card.ability.extra.needed then
            card.ability.extra.triggers = card.ability.extra.triggers - card.ability.extra.needed
            return {e_chips = card.ability.extra.echips, e_mult = card.ability.extra.emult,}
        end
    end
})


SMODS.Joker({
    key = "shi_qilin",

    loc_txt = {
        name = "Shi Qilin",
        text = {
            "At blind start, create a random",
            "{C:attention}Beast{} Joker"
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 10},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            FB.create_random_joker('shi_qilin')
            return {
                message = 'Beast!',
                colour = G.C.GREEN
            }
        end
    end
})

SMODS.Joker({
    key = "qilin_sibuxiang",
    loc_txt = {name = "Qilin Form Sibuxiang", text = {"{C:attention}Retrigger{} {C:blue}Tianlu{} and {C:red}Bixie{}", "once for each triggered card"}},
    atlas = "jokers", pos = {x = 9, y = 10}, rarity = "fb_exotic", cost = 50,
    discovered = true, unlocked = true, blueprint_compat = false,
    calculate = function(self, card, context)
        local key = context.other_card and FB.raw_key(context.other_card)
        local is_target = key == 'tianlu'
            or key == 'tianlu_true_form'
            or key == 'bixie'
            or key == 'bixie_true_form'

        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards
            and is_target
            and FB.once_joker_retrigger(card, context, 'qilin_sibuxiang') then
            return {
                repetitions = #(G.play and G.play.cards or {}),
                card = card
            }
        end
    end
})

SMODS.Joker({
    key = "tianlu_true_form",

    loc_txt = {
        name = "Tianlu True Form",
        text = {
            "Gains {X:purple,C:white}^0.01{} Chips for each dollar",
            "consumed.",
            "{C:inactive}Currently {X:purple,C:white}^#1#{} Chips{}"
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 11},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {extra = {echips = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.echips}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local d = G.GAME.dollars or 0
            card.ability.extra.echips = (card.ability.extra.echips or 1) + d * 0.01
            FB.try_add_dollars(-d)
        end

        if FB.is_scoring_joker_main(context) then
            return {e_chips = card.ability.extra.echips}
        end
    end
})

SMODS.Joker({
    key = "happy_ending",

    loc_txt = {
        name = "Happy Ending",
        text = {
            "{C:edition,E:#1#,s:#2#}You did it!{}",
            "{X:edition,C:chips}^^#3#{} Chips",
            "{X:dark_edition,C:mult}^^#4#{} Mult"
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 11},

    rarity = "fb_divine",
    cost = 999,

    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {extra = {fb_loc_vars = {"1", "1.2", "7", "7"}}},

    loc_vars = function(self, info_queue, card) return FB.static_loc_vars(card) end,


    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                ee_chips = 7,
                ee_mult = 7
            }
        end
    end
})

SMODS.Joker({
    key = "super_lollipop",

    loc_txt = {
        name = "Super Lollipop",
        text = {
            "{C:dark_edition,E:1,s:1.2}Gives me magical powers!{}",
            "{C:inactive}(Cannot be debuffed, destroyed,{}",
            "{C:inactive}or negatively affected){}",
            "{C:attention}Retrigger{} all cards and Jokers",
            "Triggered cards and Jokers give:",
            "{C:chips}+999{} Chips {C:mult}+999{} Mult",
            "{X:chips,C:white}X999{} Chips {X:mult,C:white}X999{} Mult",
            "{X:purple,C:white}^999{} Chips {X:consumable,C:white}^999{} Mult",
            "{X:edition,C:chips}^^999{} Chips {X:dark_edition,C:mult}^^999{} Mult",
            "{X:edition,C:dark_edition}^^^999{} Chips {X:dark_edition,C:edition}^^^999{} Mult"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 11},

    rarity = "fb_divine",
    cost = 999,

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,

    discovered = true,
    unlocked = true,

    config = {
        extra = {
            chips = 999,
            mult = 999,
            x_chips = 999,
            x_mult = 999,
            e_chips = 999,
            e_mult = 999,
            ee_chips = 999,
            ee_mult = 999,
            eee_chips = 999,
            eee_mult = 999,
        }
    },

    add_to_deck = function(self, card, from_debuff)
        card.ability.eternal = true
        card.ability.perishable = false
        card.ability.rental = false
        card.debuff = false

        if card.set_eternal then
            card:set_eternal(true)
        end
    end,

    calculate = function(self, card, context)
        -- Prevent debuffs (do not mutate state during blueprint previews)
        if not context.blueprint and card.debuff then
            card.debuff = false
        end

        -- Retrigger all played cards
        if FB.is_card_repetition(context) and context.cardarea == G.play then
            return {
                repetitions = 1,
                card = card
            }
        end

        -- Retrigger all jokers
        if context and context.retrigger_joker_check and context.other_card and not context.end_of_round and not context.setting_blind and not context.before and not context.after and not context.selling_card and not context.selling_self and not context.destroy_card and not context.remove_playing_cards
        and context.other_card ~= card
        and FB.once_joker_retrigger(card, context, 'super_lollipop') then
            return {
                repetitions = 1,
                card = card
            }
        end

        local function apply_lollipop_bonus()
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult,
                x_chips = card.ability.extra.x_chips,
                x_mult = card.ability.extra.x_mult,
                e_chips = card.ability.extra.e_chips,
                e_mult = card.ability.extra.e_mult,
                ee_chips = card.ability.extra.ee_chips,
                ee_mult = card.ability.extra.ee_mult,
                eee_chips = card.ability.extra.eee_chips,
                eee_mult = card.ability.extra.eee_mult,
                colour = G.C.EDITION,
                card = card
            }
        end

        if FB.is_scoring_individual(context) and context.other_card and context.other_card ~= card then
            return apply_lollipop_bonus()
        end

        if context.post_trigger and context.other_card and context.other_card ~= card then
            return apply_lollipop_bonus()
        end

        -- Upgrade all hands every hand played
        if context.after and not context.blueprint then
            for k, v in pairs(G.GAME.hands) do
                level_up_hand(card, k, true, 1)
            end

            return {
                message = "Level Up!",
                colour = G.C.ATTENTION,
                card = card
            }
        end
    end
})