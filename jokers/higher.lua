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
            "Gains {X:consumable,C:white}^0.1{} Mult every round, {X:consumable,C:white}^0.15{} for",
            "boss and {X:consumable,C:white}^0.2{} for final bosses.",
            "{C:inactive}Currently {X:consumable,C:white}^#1#{C:inactive} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 10},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    config = {extra = {emult = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.emult}} end,
    calculate = function(self, card, context)
        if context.joker_main then return {e_mult = card.ability.extra.emult} end
        if context.end_of_round and not context.blueprint then
            local gain = 0.1
            if G.GAME.blind and G.GAME.blind.boss then
                gain = FB.is_final_boss() and 0.2 or 0.15
            end
            card.ability.extra.emult = card.ability.extra.emult + gain
        end
    end
})

SMODS.Joker({
    key = "rainbow_mountain_range",

    loc_txt = {
        name = "Rainbow Mountain Range",
        text = {
            "{X:mult,C:white}XMult{} also give {X:chips,C:white}XChips{} of the same amount,",
            "same with {X:chips,C:white}XChips{} for {X:mult,C:white}XMult{} and also",
            "{X:purple,C:white}^Chips{}/{X:consumable,C:white}^Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 10},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.joker_main then return {x_chips = math.max(1, mult), x_mult = math.max(1, hand_chips)} end end
})

SMODS.Joker({
    key = "qishiqi",

    loc_txt = {
        name = "Qishiqi",
        text = {
            "Every 77 [#1#] card triggers you get {X:purple,C:white}^7{} Chips",
            "and {X:consumable,C:white}^7{} Mult"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 10},

    rarity = "fb_exotic",
    cost = 77,

    discovered = true,
    unlocked = true,
    config = {extra = {triggers = 0}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.triggers}} end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then card.ability.extra.triggers = card.ability.extra.triggers + 1 end
        if context.joker_main and card.ability.extra.triggers >= 77 then
            card.ability.extra.triggers = card.ability.extra.triggers - 77
            return {e_chips = 7, e_mult = 7, message = "^7"}
        end
    end
})

SMODS.Joker({
    key = "shi_qilin",

    loc_txt = {
        name = "Shi Qilin",
        text = {
            "Create a random beast every round."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 10},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.setting_blind and not context.blueprint then FB.create_random_joker('shi_qilin'); return {message = "Beast!", colour = G.C.GREEN} end end
})

SMODS.Joker({
    key = "qilin_sibuxiang",

    loc_txt = {
        name = "Qilin Form Sibuxiang",
        text = {
            "{C:attention}Retrigger{} {C:blue}Tianlu{} AND {C:red}Bixie{}",
            "for every joker triggered"
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 10},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        local function is_qilin_target(other_card)
            if not other_card then
                return false
            end

            local key = FB.get_center_key(other_card)
            return key == FB.key('tianlu')
                or key == FB.key('tianlu_true_form')
                or key == FB.key('baby_tianlu')
                or key == FB.key('bixie')
                --or key == FB.key('bixie_true_form') temporary disabled until definition
                --or key == FB.key('baby_bixie')
        end

        if context.before and not context.blueprint and G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do j.fb_qilin_retriggered = nil end
        end
        if context.retrigger_joker_check and context.other_card and context.other_card ~= card
            and not context.other_card.fb_qilin_retriggered
            and is_qilin_target(context.other_card) then
            context.other_card.fb_qilin_retriggered = true
            return {repetitions = 2, card = card}
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
            "{C:inactive}Currently {X:purple,C:white}^#1# {C:inactive} Chips{}"
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 11},

    rarity = "fb_exotic",
    cost = 50,

    discovered = true,
    unlocked = true,
    config = {extra = {echips = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.echips}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local d = G.GAME.dollars or 0
            card.ability.extra.echips = (card.ability.extra.echips or 1) + d * 0.01
            FB.try_add_dollars(-d)
        end

        if context.joker_main then
            return {e_chips = card.ability.extra.echips}
        end
    end
})

SMODS.Joker({
    key = "happy_ending",

    loc_txt = {
        name = "Happy Ending",
        text = {
            "{C:edition,E:1,s:1.2}You did it!{}",
            "{X:edition}^^7{} Chips and {X:dark_edition,C:white}^^7{} Mult."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 11},

    rarity = "fb_divine",
    cost = 999,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.joker_main then return {ee_chips = 7, ee_mult = 7, message = "^.^"} end end
})

SMODS.Joker({
    key = "super_lollipop",

    loc_txt = {
        name = "Super Lollipop",
        text = {
            "{C:dark_edition,E:1,s:1.2}Gives me magical powers!{}",
            "{C:inactive}(Cannot be debuffed, destroyed,{}",
            "{C:inactive}or negatively affected){}",
            "{C:attention}Retriggers{} all cards",
            "Each time a card or Joker is triggered:",
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

        -- Prevent debuffs
        if card.debuff then
            card.debuff = false
        end

        -- Retrigger all played cards
        if context.repetition and context.cardarea == G.play then
            return {
                repetitions = 1,
                card = card
            }
        end

        -- Retrigger all jokers
        if context.retrigger_joker_check
        and context.other_card ~= card then
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
                message = "Tasty!",
                colour = G.C.EDITION,
                card = card
            }
        end

        if context.individual and context.cardarea == G.play and context.other_card and context.other_card ~= card then
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