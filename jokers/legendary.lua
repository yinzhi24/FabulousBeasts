---@diagnostic disable: undefined-global

-- Fabulous Beasts: Legendary Jokers

SMODS.Joker({
    key = "bajin",

    loc_txt = {
        name = "Bajin",
        text = {
            "Cannot be {C:red}debuffed{} by boss blinds",
            "{X:chips,C:white}X8{} Chips for each food joker. All food jokers",
            "have their negative effects doubled",
            "(if possible).",
            "{C:inactive}Currently {X:chips,C:white}X#1#{} Chips{}"
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind and G.GAME.blind.boss and not context.blueprint and card.debuff then
            card.debuff = false
        end

        if context.joker_main then
            return {x_chips = math.max(1, 8 * FB.count_food_jokers_explicit())}
        end
    end
})

SMODS.Joker({
    key = "bilibili",

    loc_txt = {
        name = "Bilibili",
        text = {
            "It’s Chinese YouTube! (it actually",
            "{C:attention}retrigger{}s non-legendary jokers)."
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card ~= card and context.other_card.config.center.rarity ~= 4 then return {repetitions = 1, card = card} end
    end
})

SMODS.Joker({
    key = "bibi",

    loc_txt = {
        name = "Bibi",
        text = {
            "All formerly {C:red}debuffed{} cards and jokers",
            "each give {X:mult,C:white}X2{} Mult for each joker and",
            "played card.",
            "{C:inactive}Affected: #1#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    loc_vars = function(self, info_queue, card)
        local n = 0; for _, c in ipairs(G.play and G.play.cards or {}) do if c.fb_formerly_debuffed then n = n + 1 end end; for _, j in ipairs(G.jokers and G.jokers.cards or {}) do if j.fb_formerly_debuffed then n = n + 1 end end
        return {vars = {n}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local n = 0; for _, c in ipairs(G.play.cards or {}) do if c.fb_formerly_debuffed then n = n + 1 end end; for _, j in ipairs(G.jokers.cards) do if j.fb_formerly_debuffed then n = n + 1 end end
            if n > 0 then return {x_mult = 2 ^ n} end
        end
    end
})

SMODS.Joker({
    key = "bixie",

    loc_txt = {
        name = "Bixie",
        text = {
            "Gains {X:mult,C:white}X1{} Mult every round, {X:mult,C:white}X1.5{} for boss",
            "blinds and {X:mult,C:white}X2{} for final boss blinds",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    config = {extra = {xmult = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xmult}} end,
    calculate = function(self, card, context)
        if context.joker_main then return {x_mult = card.ability.extra.xmult} end
        if context.end_of_round and not context.blueprint then
            local gain = 1
            if G.GAME.blind and G.GAME.blind.boss then
                gain = FB.is_final_boss() and 2 or 1.5
            end
            card.ability.extra.xmult = card.ability.extra.xmult + gain
        end
    end
})

SMODS.Joker({
    key = "christina",

    loc_txt = {
        name = "Christina",
        text = {
            "{C:attention}Retrigger{} Jinchi Dapeng once for each card",
            "played."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and FB.is_joker_key(context.other_card, 'jinchi_dapeng') then
            return {repetitions = #(G.play.cards or {}), card = card}
        end
    end
})

SMODS.Joker({
    key = "chugou",

    loc_txt = {
        name = "Chugou",
        text = {
            "Each triggered card and Joker gives {C:money}$1{}.",
            "{C:inactive}Fallback this hand: {C:money}$#1#{}{}"
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 7},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    config = {extra = {fallback = 0}},
    loc_vars = function(self, info_queue, card)
        local cards = G.play and G.play.cards and #G.play.cards or 0
        local jokers = G.jokers and G.jokers.cards and math.max(0, #G.jokers.cards - 1) or 0
        card.ability.extra.fallback = cards + jokers
        return {vars = {card.ability.extra.fallback}}
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.fb_post_trigger_seen = false
            card.ability.fb_paid_fallback = false
        end

        if context.individual and context.other_card and context.other_card ~= card then
            FB.try_add_dollars(1)
            return {message = "$1", colour = G.C.MONEY, card = card}
        end

        if context.post_trigger and context.other_card and context.other_card ~= card then
            card.ability.fb_post_trigger_seen = true
            FB.try_add_dollars(1)
            return {message = "$1", colour = G.C.MONEY, card = card}
        end

        if context.joker_main and not context.blueprint and not card.ability.fb_post_trigger_seen and not card.ability.fb_paid_fallback then
            card.ability.fb_paid_fallback = true
            local cards = G.play and G.play.cards and #G.play.cards or 0
            local jokers = G.jokers and G.jokers.cards and math.max(0, #G.jokers.cards - 1) or 0
            local payout = cards + jokers
            if payout > 0 then
                FB.try_add_dollars(payout)
                return {message = "$" .. payout, colour = G.C.MONEY, card = card}
            end
        end
    end
})

SMODS.Joker({
    key = "dijiang",

    loc_txt = {
        name = "Dijiang",
        text = {
            "{C:attention}Retrigger{} all {C:heart}Heart{} suit cards 6 times",
            "{C:green}1 in 6 chance{} of being permanently {C:red}debuffed{}",
            "every round. After being {C:red}debuffed{} for",
            "{C:attention}2 antes{}, {C:red}destroy{} this joker."
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card and context.other_card:is_suit('Hearts') then return {repetitions = 6, card = card} end
        if context.end_of_round and pseudorandom('dijiang') < (1/6) then card.debuff = true; card.ability.fb_debuff_rounds = (card.ability.fb_debuff_rounds or 0) + 1; if card.ability.fb_debuff_rounds >= 3 then FB.destroy(card) end end
    end
})

SMODS.Joker({
    key = "diting",

    loc_txt = {
        name = "Diting",
        text = {
            "{X:attention,C:white}X2{} hand size, {C:red}-1{} Hand, {C:red}-1{} Discard.",
            "Inherits the most recently sold/{C:red}destroyed{}",
            "joker's effects."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    add_to_deck = function(self, card, from_debuff)
        card.ability.fb_hand_delta = G.hand and G.hand.config and G.hand.config.card_limit or 8
        FB.safe_change_hand_size(card.ability.fb_hand_delta)
        ease_hands_played(-1)
        ease_discard(-1)
    end,
    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(-(card.ability.fb_hand_delta or 0))
    end
})

SMODS.Joker({
    key = "erliang",

    loc_txt = {
        name = "Erliang",
        text = {
            "Cannot be {C:red}debuffed{} by boss blinds (but can",
            "be via other jokers). {C:attention}+2{} joker slot."
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(2) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-2) end
})

SMODS.Joker({
    key = "fenz",

    loc_txt = {
        name = "Fenz",
        text = {
            "Meet the creators! (it actually {C:attention}retrigger{}s",
            "all jokers in this mod you have in hand)."
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card ~= card and FB.has_mod_key(context.other_card) then
            return {repetitions = 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "fresh_seed",

    loc_txt = {
        name = "Fresh Seed",
        text = {
            "After 1 round turns into Chugou."
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.end_of_round and not context.blueprint then FB.create_joker('chugou'); FB.destroy(card) end end
})

SMODS.Joker({
    key = "fuku_fuzai",

    loc_txt = {
        name = "Fuku Fuzai",
        text = {
            "All food jokers have their negative",
            "effects removed and their effect tripled",
            "(if possible)."
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card and FB.is_food_joker(context.other_card) then return {repetitions = 2, card = card} end
    end
})

SMODS.Joker({
    key = "hetao",

    loc_txt = {
        name = "Hetao",
        text = {
            "{C:attention}Retrigger{} all Beast jokers once."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card and context.other_card ~= card and FB.is_beast_joker(context.other_card) then return {repetitions = 1, card = card} end
    end
})

SMODS.Joker({
    key = "hundun",

    loc_txt = {
        name = "Hundun",
        text = {
            "All boss blinds become final boss blinds,",
            "but all score requirements scaling is",
            "halved while {C:attention}retrigger{}ing all played",
            "cards."
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then return {repetitions = 1, card = card} end
        if context.joker_main then return {x_mult = 2} end
    end
})

SMODS.Joker({
    key = "jinchi_dapeng",

    loc_txt = {
        name = "Jinchi Dapeng",
        text = {
            "All stone cards give {X:chips,C:white}X50{} Chips instead",
            "when played."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.individual and context.cardarea == G.play and FB.is_stone(context.other_card) then return {x_chips = 50} end end
})

SMODS.Joker({
    key = "jinjiao",

    loc_txt = {
        name = "Jinjiao",
        text = {
            "{C:attention}Retrigger{} all Gold cards and Gold Seal",
            "cards twice. Effect stacks."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 8},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.repetition and (FB.is_gold(context.other_card) or (context.other_card and context.other_card.seal == 'Gold')) then return {repetitions = 2, card = card} end end
})

SMODS.Joker({
    key = "kulou",

    loc_txt = {
        name = "Kulou",
        text = {
            "At start of round, {C:red}destroy{} a random",
            "consumable. Whatever consumable is",
            "{C:red}destroyed{} Kulou will gain the effects",
            "after the round ends, removing any limits.",
            "The effects trigger after each Discard."
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.setting_blind and G.consumeables and #G.consumeables.cards > 0 and not context.blueprint then local c = pseudorandom_element(G.consumeables.cards, pseudoseed('kulou')); card.ability.fb_kulou_bonus = (card.ability.fb_kulou_bonus or 0) + 1; FB.destroy(c) end
        if context.pre_discard and card.ability.fb_kulou_bonus then return {mult = 10 * card.ability.fb_kulou_bonus} end
    end
})

SMODS.Joker({
    key = "luo_tianyi",

    loc_txt = {
        name = "Luo Tianyi",
        text = {
            "{X:chips,C:white}X631{} Chips if you have Album Cover. +6100",
            "chips and mult if you have Alternate Album",
            "Cover."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.joker_main then
            if FB.has_joker('alternate_album_cover') then return {chips = 6100, mult = 6100} end
            if FB.has_joker('album_cover') then return {x_chips = 631} end
        end
    end
})

SMODS.Joker({
    key = "lord_phoenix",

    loc_txt = {
        name = "Lord Phoenix",
        text = {
            "Removes the {C:red}debuffed{} effect from all cards",
            "and jokers."
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.setting_blind and not context.blueprint then FB.clear_card_debuffs(G.hand); FB.clear_joker_debuffs(); return {message = "Purified"} end end
})

SMODS.Joker({
    key = "qiongqi",

    loc_txt = {
        name = "Qiongqi",
        text = {
            "All blinds are boss blinds, all original",
            "boss blinds become final boss blinds.",
            "{C:red}Debuffs{} all other jokers. Sell 1 joker to",
            "enable them for the round. Gain {X:mult,C:white}^1{} Mult",
            "for each sold joker (starts with {X:mult,C:white}^1{} Mult).",
            "{C:inactive}Currently {X:mult,C:white}^#1#{} Mult{}"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    config = {extra = {emult = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.emult}} end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then for _, j in ipairs(G.jokers.cards) do if j ~= card then j.debuff = true end end end
        if context.selling_card and not context.blueprint then card.ability.extra.emult = card.ability.extra.emult + 1 end
        if context.joker_main then return {e_mult = card.ability.extra.emult} end
    end
})

SMODS.Joker({
    key = "shanque",

    loc_txt = {
        name = "Shanque",
        text = {
            "Scales all scalable jokers every hand",
            "played (doubles charging rate for charging",
            "jokers if possible).",
            "{C:inactive}Scaling each hand{}"
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then for _, j in ipairs(G.jokers.cards) do if j.ability and j.ability.extra and j.ability.extra.xmult then j.ability.extra.xmult = j.ability.extra.xmult * 2 end end; return {message = "Scaled"} end
    end
})

SMODS.Joker({
    key = "sibuxiang",

    loc_txt = {
        name = "Sibuxiang",
        text = {
            "Guaranteed to have a {C:red}Rare{}+ and an {C:green}Uncommon{}+",
            "joker in the shop. For boss blinds",
            "contains a guaranteed Legendary. All",
            "shop costs are doubled and Legendaries",
            "have tripled prices."
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        local function has_shop_rarity(target_rarity)
            if not G.shop_jokers or not G.shop_jokers.cards then
                return false
            end

            for _, shop_card in ipairs(G.shop_jokers.cards) do
                if shop_card and shop_card.config and shop_card.config.center and shop_card.config.center.rarity == target_rarity then
                    return true
                end
            end

            return false
        end

        local function create_shop_joker(target_rarity)
            if not G.shop_jokers or not G.shop_jokers.cards then
                return false
            end

            if #G.shop_jokers.cards >= G.shop_jokers.config.card_limit then
                return false
            end

            local candidates = {}
            for key, center in pairs(G.P_CENTERS or {}) do
                if type(key) == 'string'
                    and type(center) == 'table'
                    and center.set == 'Joker'
                    and center.rarity == target_rarity then
                    table.insert(candidates, key)
                end
            end

            if #candidates == 0 then
                return false
            end

            local chosen_key = pseudorandom_element(candidates, pseudoseed('sibuxiang_' .. tostring(target_rarity)))
            if not chosen_key then
                return false
            end

            local created = SMODS.add_card({set = 'Joker', key = chosen_key, area = G.shop_jokers})
            return created ~= nil
        end

        if context.end_of_round and not context.blueprint and G.GAME.blind and G.GAME.blind.boss then
            G.GAME.fb_sibuxiang_pending_legendary = true
        end

        if context.starting_shop and not context.blueprint then
            if G.GAME.fb_sibuxiang_shop_applied then
                return {message = "Rare+ Stock"}
            end

            G.GAME.fb_sibuxiang_shop_applied = false

            if not has_shop_rarity(3) then
                create_shop_joker(3)
            end

            if not has_shop_rarity(2) then
                create_shop_joker(2)
            end

            if G.GAME.fb_sibuxiang_pending_legendary and not has_shop_rarity(4) then
                create_shop_joker(4)
                G.GAME.fb_sibuxiang_pending_legendary = false
            end

            G.GAME.fb_sibuxiang_shop_applied = true
            return {message = "Rare+ Stock"}
        end
    end
})

SMODS.Joker({
    key = "taotie",

    loc_txt = {
        name = "Taotie",
        text = {
            "All played cards are {C:red}destroyed{}, then gain",
            "{X:mult,C:white}X1{} Mult for each card {C:red}destroyed{} (starts",
            "with {X:mult,C:white}X0{} Mult)."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    config = {extra = {xmult = 0}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xmult}} end,
    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play then card.ability.extra.xmult = card.ability.extra.xmult + 1; return {remove = true} end
        if context.joker_main then return {x_mult = card.ability.extra.xmult} end
    end
})

SMODS.Joker({
    key = "taowu",

    loc_txt = {
        name = "Taowu",
        text = {
            "Always {C:eternal}Eternal{}. Buffs all negative and",
            "boss blind effects but in return you get",
            "triple blind payout and all shops are",
            "initially free."
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    eternal_compat = true,
    add_to_deck = function(self, card, from_debuff) card.ability.eternal = true end,
    calculate = function(self, card, context) if context.end_of_round then ease_dollars((G.GAME.blind and G.GAME.blind.dollars or 0) * 2) end end
})

SMODS.Joker({
    key = "tianlu",

    loc_txt = {
        name = "Tianlu",
        text = {
            "Sets your money to {C:money}$0{} and for each dollar",
            "consumed he gets {X:chips,C:white}X0.1{} Chips.",
            "{C:inactive}Currently: #1#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    config = {extra = {xchips = 1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xchips}} end,
    add_to_deck = function(self, card, from_debuff)
        local d = G.GAME.dollars or 0
        card.ability.extra.xchips = 1 + d * 0.1
        FB.try_add_dollars(-d)
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local d = G.GAME.dollars or 0
            card.ability.extra.xchips = (card.ability.extra.xchips or 1) + d * 0.1
            FB.try_add_dollars(-d)
        end

        if context.joker_main then
            return {x_chips = card.ability.extra.xchips}
        end
    end
})

SMODS.Joker({
    key = "tubaoshu",

    loc_txt = {
        name = "Tubaoshu",
        text = {
            "Fill all your joker slots with Cintamanis",
            "every round. {C:attention}+2{} joker slot.",
            "{C:inactive}Compatible with Showman{}"
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 9},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(2) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-2) end,
    calculate = function(self, card, context) if context.setting_blind and not context.blueprint then while #G.jokers.cards < G.jokers.config.card_limit do if not FB.create_joker('cintamani') then break end end end end
})

SMODS.Joker({
    key = "tuye_tony",

    loc_txt = {
        name = "Tuye",
        text = {
            "All Mooncakes and Laurel Branches give +1",
            "joker slot. Spawns 2 Mooncakes with a 1 in",
            "5 chance of getting a Laurel Branch on top",
            "every round.",
            "{C:inactive}Compatible with Showman{}"
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 10},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.setting_blind and not context.blueprint then FB.create_joker('mooncake'); FB.create_joker('mooncake'); if pseudorandom('tuye_laurel') < 0.2 then FB.create_joker('laurel_branch') end end end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.fb_tony_slots = FB.count_joker('mooncake') + FB.count_joker('laurel_branch')
        FB.safe_change_joker_slots(card.ability.fb_tony_slots)
    end,
    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_joker_slots(-(card.ability.fb_tony_slots or 0))
    end
})

SMODS.Joker({
    key = "xiaolizhi",

    loc_txt = {
        name = "Xiaolizhi",
        text = {
            "Each joker gives {X:mult,C:white}^0.25{} Mult (starts with",
            "{X:mult,C:white}^1{} Mult). All positive luck based events",
            "are guaranteed. Removes all negative",
            "effects from jokers, cards, and",
            "consumables, but in return gets {C:red}debuffed{}",
            "for 1 round for each removed negative",
            "effect. Those cards, jokers, and current",
            "consumables won't have a negative effect",
            "anymore PERMANENTLY."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 10},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.joker_main then return {e_mult = 1 + 0.25 * #G.jokers.cards} end
        if context.mod_probability then return {numerator = context.denominator} end
    end
})

SMODS.Joker({
    key = "xiezhi",

    loc_txt = {
        name = "Xiezhi",
        text = {
            "Disables boss blind effects after they are",
            "triggered and gives you {X:mult,C:white}^2{} Mult for the",
            "rest of the round."
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 10},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.debuffed_hand then return {e_mult = 2} end end
})

SMODS.Joker({
    key = "yinjiao",

    loc_txt = {
        name = "Yinjiao",
        text = {
            "{C:attention}Retrigger{} all Steel cards twice and all",
            "Steel cards have their values doubled."
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 10},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context) if context.repetition and FB.is_steel(context.other_card) then return {repetitions = 2, card = card} end; if context.individual and FB.is_steel(context.other_card) then return {x_chips = 2, x_mult = 2} end end
})

SMODS.Joker({
    key = "zhanhu",

    loc_txt = {
        name = "Zhanhu",
        text = {
            "{C:attention}Retrigger{} all {X:mult,C:white}XMult{} jokers."
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 10},

    rarity = 4,
    cost = 25,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card ~= card then return {repetitions = 1, card = card} end
    end
})

