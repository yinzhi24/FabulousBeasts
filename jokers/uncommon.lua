---@diagnostic disable: undefined-global

-- Fabulous Beasts: Uncommon Jokers

SMODS.Joker({
    key = "bestiary",

    loc_txt = {
        name = "Bestiary",
        text = {
            "For each unique playing card in your deck,",
            "gain {X:mult,C:white}X0.1{} Mult (starts at {X:mult,C:white}X1{}).",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 3},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {xmult = 1}},

    loc_vars = function(self, info_queue, card)
        local seen = {}
        if G and G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                local rank = c.base and c.base.value or "?"
                local suit = c.base and c.base.suit or "?"
                seen[rank .. "_" .. suit] = true
            end
        end

        local count = 0
        for _ in pairs(seen) do count = count + 1 end
        card.ability.extra.xmult = 1 + count * 0.1

        return {vars = {card.ability.extra.xmult}}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local seen = {}
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    local rank = c.base and c.base.value or "?"
                    local suit = c.base and c.base.suit or "?"
                    seen[rank .. "_" .. suit] = true
                end
            end

            local count = 0
            for _ in pairs(seen) do count = count + 1 end
            card.ability.extra.xmult = 1 + count * 0.1

            return {
                x_mult = card.ability.extra.xmult,
                message = "X" .. card.ability.extra.xmult,
                colour = G.C.MULT,
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
            "Has {C:attention}#1#{} servings. Each played card removes",
            "1 serving. Turns into Dog Food once all",
            "servings are gone. {X:mult,C:white}X2{} Mult for each card",
            "triggered.",
            "{C:inactive}Servings left: #1#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 3},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {servings = 15}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.servings}} end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then card.ability.extra.servings = card.ability.extra.servings - 1; return {x_mult = 2} end
        if context.after and card.ability.extra.servings <= 0 and not context.blueprint then FB.destroy(card); FB.create_joker('dog_food') end
    end
})

SMODS.Joker({
    key = "demolition_notice",

    loc_txt = {
        name = "Demolition Notice",
        text = {
            "The next blind you play is cleared",
            "instantly without cashing out if you run",
            "out of hands, then {C:red}self destructs{}."
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 3},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.after and G.GAME.current_round.hands_left <= 0 and not card.ability.fb_used then
            card.ability.fb_used = true
            G.GAME.chips = G.GAME.blind.chips
            FB.destroy(card)
            return {message = "Cleared!", colour = G.C.GREEN}
        end
    end
})

SMODS.Joker({
    key = "do_not_imitate",

    loc_txt = {
        name = "Do Not Imitate",
        text = {
            "All {C:attention}retrigger{}s are removed. Instead gain",
            "{X:mult,C:white}X1{} Mult for each {C:attention}retrigger{} (stacks over",
            "time).",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 3},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {xmult = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xmult}} end,
    calculate = function(self, card, context)
        if context.repetition or context.retrigger_joker_check then
            if not context.blueprint then card.ability.extra.xmult = card.ability.extra.xmult + 1 end
            return {repetitions = 0, message = "+X1"}
        end
        if context.joker_main then return {x_mult = card.ability.extra.xmult} end
    end
})

SMODS.Joker({
    key = "eating_melons",

    loc_txt = {
        name = "Eating Melons",
        text = {
            "{C:attention}Retrigger{} all jokers with {C:attention}retrigger{}",
            "effects."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 3},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card ~= card then return {repetitions = 1, card = card} end
    end
})

SMODS.Joker({
    key = "feirenzai_manga",

    loc_txt = {
        name = "Feirenzai Manga",
        text = {
            "Removes the {C:red}debuffed{} status from one",
            "joker. Playing [poker hand] removes",
            "another one. Changes with each hand.",
            "{C:inactive}Current hand: {C:attention}#1#{}{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 3},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {hand = "Pair"}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then FB.clear_joker_debuffs(1) end
        if context.after and context.scoring_name == card.ability.extra.hand and not context.blueprint then FB.clear_joker_debuffs(1); card.ability.extra.hand = FB.random_poker_hand('feirenzai_manga') end
    end
})

SMODS.Joker({
    key = "followers_request",

    loc_txt = {
        name = "Follower's Request",
        text = {
            "At the start of scoring, choose a random Joker.",
            "{C:attention}Retrigger{} that Joker {C:attention}3{} times.",
            "{C:inactive}Target changes every hand.{}"
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 3},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.jokers and G.jokers.cards then
            local choices = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then choices[#choices + 1] = j end
            end
            card.ability.fb_target_joker = #choices > 0 and pseudorandom_element(choices, pseudoseed('followers_request')) or nil
        end

        if context.retrigger_joker_check and context.other_card ~= card and context.other_card == card.ability.fb_target_joker then
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
            "{C:attention}Retriggers{} all {C:money}Gold{} cards"
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 3},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.repetition and (FB.is_gold(context.other_card) or (context.other_card and context.other_card.seal == 'Gold')) then return {repetitions = 1, card = card} end
    end
})

SMODS.Joker({
    key = "heavenly_elixirs",

    loc_txt = {
        name = "Heavenly Elixirs",
        text = {
            "Must score less than or equal to",
            "[chips/mult] in a single hand or the hand",
            "will not score. Balances score if",
            "achieved. Value is based on ante.",
            "{C:inactive}Limit: {C:chips}#1#{}{}"
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {limit = 1000}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.limit}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then card.ability.extra.limit = math.max(100, (G.GAME.round_resets.ante or 1) * 1000) end
        if context.joker_main and (hand_chips or 0) <= card.ability.extra.limit then return {chips = card.ability.extra.limit - hand_chips, mult = 0} end
        if context.joker_main then return {chips = -hand_chips, mult = -mult, message = "Too much!"} end
    end
})

SMODS.Joker({
    key = "hellish_delicacies",

    loc_txt = {
        name = "Hellish Delicacies",
        text = {
            "For each planned played card trigger, only",
            "trigger the first card and {C:attention}retrigger{} it by",
            "the amount of times of total card triggers",
            "in current played hand."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.scoring_hand and context.other_card == context.scoring_hand[1] then return {repetitions = #context.scoring_hand, card = card} end
    end
})

SMODS.Joker({
    key = "lunchbox_medkit",

    loc_txt = {
        name = "Lunchbox Medkit",
        text = {
            "Every round spawns a random food joker",
            "{C:inactive}Compatible with Showman{}"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local pool = {'body_swap_mushroom','divine_herb','heavenly_cumin','emergency_rations','mooncake','dog_food','food','chicken_mushroom_stew'}
            FB.create_joker(pseudorandom_element(pool, pseudoseed('lunchbox_medkit')))
            return {message = "Packed!", colour = G.C.GREEN}
        end
    end
})

SMODS.Joker({
    key = "mapo_tofu",

    loc_txt = {
        name = "Mapo Tofu",
        text = {
            "{X:mult,C:white}X4{} Mult.",
            "{C:green}1 in 4{} chance that the hand does not score."
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local fail_chance = 0.25
            if FB.has_joker('bajin') then
                fail_chance = math.min(1, fail_chance * 2)
            end
            if FB.has_joker('fuku_fuzai') then
                fail_chance = 0
            end

            card.ability.fb_failed = pseudorandom('mapo_tofu') < fail_chance
            if card.ability.fb_failed then
                return {message = "Too spicy!", colour = G.C.RED, card = card}
            end
        end

        if context.joker_main then
            if card.ability.fb_failed then
                return {chips = -math.max(0, hand_chips or 0), mult = -math.max(0, mult or 0), message = "No Score!", colour = G.C.RED, card = card}
            end
            return {x_mult = FB.has_joker('fuku_fuzai') and 12 or 4}
        end

        if context.after and not context.blueprint then
            card.ability.fb_failed = false
        end
    end
})

SMODS.Joker({
    key = "moon_palace",

    loc_txt = {
        name = "Moon Palace",
        text = {
            "Gains {X:mult,C:white}X0.1{} Mult for each Mooncake in hand.",
            "Triggers every played hand.",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {xmult = 1}},

    loc_vars = function(self, info_queue, card)
        card.ability.extra.xmult = 1 + 0.1 * FB.count_joker('mooncake')
        return {vars = {card.ability.extra.xmult}}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.xmult = 1 + 0.1 * FB.count_joker('mooncake')
            return {x_mult = card.ability.extra.xmult, card = card}
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
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and FB.is_joker_key(context.other_card, 'mooncake') then
            return {repetitions = FB.count_joker('mooncake'), card = card}
        end
    end
})

SMODS.Joker({
    key = "open_for_business",

    loc_txt = {
        name = "Open For Business",
        text = {
            "{C:green}1 in 8{} chance of getting {C:money}$1{} when anything",
            "is triggered or {C:attention}retriggered{}."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if (context.individual or context.joker_main or context.retrigger_joker_check or context.repetition) and pseudorandom('open_for_business') < 0.125 then FB.try_add_dollars(1); return {message = "$1"} end
    end
})

SMODS.Joker({
    key = "oxen_cart",

    loc_txt = {
        name = "Oxen Cart",
        text = {
            "For each played [poker hand] (changes at",
            "end of round), {C:attention}+1{} hand size.",
            "{C:inactive}Current: {C:attention}#1#{}, gained #2#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {hand = "Pair", gained = 0}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand, card.ability.extra.gained}} end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_hand_size(-card.ability.extra.gained) end,
    calculate = function(self, card, context)
        if context.after and context.scoring_name == card.ability.extra.hand and not context.blueprint then card.ability.extra.gained = card.ability.extra.gained + 1; FB.safe_change_hand_size(1); return {message = "+1 Hand Size"} end
        if context.end_of_round and not context.blueprint then card.ability.extra.hand = FB.random_poker_hand('oxen_cart') end
    end
})

SMODS.Joker({
    key = "paw_hole_cave",

    loc_txt = {
        name = "Paw Hole Cave",
        text = {
            "{C:attention}+2{} joker slot."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(2) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-2) end
})

SMODS.Joker({
    key = "pixiu_fur",

    loc_txt = {
        name = "Pixiu Fur",
        text = {
            "If your next played hand is [poker hand]",
            "(randomly generated), apply a random",
            "{C:attention}enhancement{}, {C:green}seal{}, and",
            "{C:edition}edition{} to all scored cards, then",
            "{C:red}self destructs{}.",
            "{C:inactive}Current hand: {C:attention}#1#{}{}"
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 4},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {hand = "Pair"}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.hand}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand = FB.random_hand_type and FB.random_hand_type('pixiu_fur') or FB.random_poker_hand('pixiu_fur')
            return {message = card.ability.extra.hand, colour = G.C.ATTENTION, card = card}
        end

        if context.before and context.scoring_name == card.ability.extra.hand and not context.blueprint then
            for _, c in ipairs(context.scoring_hand or {}) do
                local roll = pseudorandom('pixiu_fur_effect')
                if roll < 1 / 3 then
                    c:set_ability(G.P_CENTERS[pseudorandom_element({'m_bonus','m_mult','m_wild','m_glass','m_steel','m_stone','m_gold','m_lucky'}, pseudoseed('pixiu_fur'))], nil, true)
                elseif roll < 2 / 3 then
                    c:set_seal(pseudorandom_element({'Gold', 'Blue', 'Red', 'Purple'}, pseudoseed('pixiu_fur_seal')), true)
                else
                    c:set_edition(pseudorandom_element({{foil = true}, {holo = true}, {polychrome = true}}, pseudoseed('pixiu_fur_edition_choice')), true)
                end
            end
            FB.destroy(card)
            return {message = "Blessed!"}
        end
    end
})

SMODS.Joker({
    key = "qilin_egg",

    loc_txt = {
        name = "Qilin Egg",
        text = {
            "After 3 rounds, this hatches into a random",
            "joker",
            "{C:inactive}Rounds remaining: #1#{}",
            "{C:inactive}Compatible with Showman{}"
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 5},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {rounds = 3}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.rounds}} end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds <= 0 then FB.create_random_joker('qilin_egg'); FB.destroy(card) end
        end
    end
})

SMODS.Joker({
    key = "questionable_fanart",

    loc_txt = {
        name = "Questionable Fanart",
        text = {
            "Each {C:red}debuffed{} card and joker gives +69",
            "chips when scored."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 5},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.individual and context.other_card and context.other_card.debuff then return {chips = 69} end
        if context.retrigger_joker_check and context.other_card and context.other_card.debuff then return {chips = 69} end
    end
})

SMODS.Joker({
    key = "rigged_video_game",

    loc_txt = {
        name = "Rigged Video Game",
        text = {
            "Gives a random joker every round and",
            "-{C:money}$1{}-99 every round. Higher numbers have an",
            "exponentially lower chance of occurring.",
            "{C:inactive}Compatible with Showman{}"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 5},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint then
            FB.create_random_joker('rigged_video_game')
            local loss = math.min(99, math.ceil(1 / math.max(0.01, pseudorandom('rigged_video_game'))))
            FB.try_add_dollars(-loss)
            return {message = "-$" .. loss}
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
    cost = 5,

    discovered = true,
    unlocked = true,
    config = {extra = {xchips = 1}},
    loc_vars = function(self, info_queue, card)
        card.ability.extra.xchips = math.max(1, FB.count_joker('teacup'))
        return {vars = {card.ability.extra.xchips}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.xchips = math.max(1, FB.count_joker('teacup'))
            return {x_chips = card.ability.extra.xchips}
        end
    end
})

SMODS.Joker({
    key = "underworlds_blacklist",

    loc_txt = {
        name = "Underworld's Blacklist",
        text = {
            "All cards, jokers, and consumables can't",
            "be {C:red}destroyed{} via any means."
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 5},

    rarity = 2,
    cost = 5,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.destroy_card then return {remove = false, message = "Blocked"} end
    end
})
