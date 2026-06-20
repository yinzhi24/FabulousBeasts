---@diagnostic disable: undefined-global

local ATLAS_KEY = "fb_blinds"

local BLIND_FRAME_W = 34
local BLIND_FRAME_H = 34
local BLIND_ANIMATION_FRAMES = 21

SMODS.Atlas({
    key = ATLAS_KEY,
    path = "blinds.png",
    px = BLIND_FRAME_W,
    py = BLIND_FRAME_H,
    atlas_table = "ANIMATION_ATLAS",
    frames = BLIND_ANIMATION_FRAMES
})

local FB_BLIND_COLOURS = {
    -- Zodiacs / Earthly Branches, rows 0-11
    rat     = HEX("7A5C3A"),
    cow     = HEX("5C4635"),
    tiger   = HEX("C97A1F"),
    rabbit  = HEX("D8A7B1"),
    dragon  = HEX("D4A017"),
    snake   = HEX("5A8F3D"),
    horse   = HEX("8B4A2F"),
    goat    = HEX("C2A878"),
    monkey  = HEX("9C9A3A"),
    rooster = HEX("B5332E"),
    dog     = HEX("6A5E52"),
    boar    = HEX("5A2D2D"),

    -- Heavenly Stems + Yin/Yang, rows 12-23
    armor   = HEX("7E8A97"),
    twist   = HEX("8D6BC9"),
    blaze   = HEX("D9482B"),
    focus   = HEX("384A8F"),
    balance = HEX("666666"),
    self    = HEX("EDEDED"),
    force   = HEX("4C4C52"),
    pain    = HEX("701C1C"),
    flood   = HEX("2B7A9B"),
    mist    = HEX("8A8599"),
    shadow  = HEX("351D4C"),
    light   = HEX("F0E4A0")
}

local function get_state()
    G.GAME.fb_blind_state = G.GAME.fb_blind_state or {}
    return G.GAME.fb_blind_state
end

local function reset_fb_blind_state()
    G.GAME.fb_blind_state = nil
end

local function blaze_active()
    return get_state().blaze_active ~= false
end

local function loc_vars(...)
    return { vars = {...} }
end

local function set_hands_delta(delta)
    if ease_hands_played then
        ease_hands_played(delta)
    end
    G.GAME.round_resets.hands = math.max(1, (G.GAME.round_resets.hands or 1) + delta)
end

local function set_discards_delta(delta)
    if ease_discard then
        ease_discard(delta)
    end
    G.GAME.round_resets.discards = math.max(0, (G.GAME.round_resets.discards or 0) + delta)
end

local function is_playing_card(card)
    return card
        and card.base
        and card.base.suit
        and (
            card.base.id ~= nil
            or card.base.value ~= nil
            or card.base.nominal ~= nil
        )
end

local function is_numbered(card)
    if not is_playing_card(card) then
        return false
    end

    if SMODS and SMODS.has_no_rank and SMODS.has_no_rank(card) then
        return false
    end

    local id = card.base.id
    if type(id) == "number" then
        return id >= 2 and id <= 10
    end

    return not card.base.face_nominal
        and type(card.base.nominal) == "number"
        and card.base.nominal >= 2
        and card.base.nominal <= 10
end

local function is_enhanced(card)
    return card and card.config and card.config.center and card.config.center ~= G.P_CENTERS.c_base
end

local function ensure_dragon_threshold()
    local state = get_state()
    if not state.dragon_threshold then
        state.dragon_threshold = math.max(
            200,
            math.floor((G.GAME.blind and G.GAME.blind.chips or 300) * 1)
        )
    end
    return state.dragon_threshold
end

local function create_blind(args)
    SMODS.Blind({
        key = args.key,
        loc_txt = args.loc_txt,
        loc_vars = args.loc_vars,
        discovered = true,
        atlas = ATLAS_KEY,
        atlas_table = "ANIMATION_ATLAS",
        pos = args.pos,
        dollars = args.dollars or 5,
        mult = args.mult or 2,
        boss = args.boss or {min = 1},
        boss_colour = args.boss_colour or FB_BLIND_COLOURS[args.key] or HEX("8f6f4e"),
        discovered = args.discovered,
        no_collection = args.no_collection,
        ignore_showdown_check = args.ignore_showdown_check,
        in_pool = args.in_pool,
        

        set_blind = function(self, reset, silent)
            reset_fb_blind_state()
            if args.set_blind then
                args.set_blind(self, reset, silent)
            end
        end,

        disable = function(self)
            if args.disable then
                args.disable(self)
            end
            reset_fb_blind_state()
        end,

        defeat = function(self)
            if args.defeat then
                args.defeat(self)
            end
            reset_fb_blind_state()
        end,

        debuff_card = args.debuff_card,
        stay_flipped = args.stay_flipped,
        debuff_hand = args.debuff_hand,
        modifies_draw = args.modifies_draw,
        press_play = args.press_play,
        drawn_to_hand = args.drawn_to_hand,
        modify_hand = args.modify_hand,
        calculate = args.calculate
    })
end

local function ensure_goat_values()
    local state = get_state()

    if not state.goat_hands then
        state.goat_hands = pseudorandom_element({2, 3, 4, 5, 6}, pseudoseed("fb_goat_hands"))
    end
    if not state.goat_discards then
        state.goat_discards = pseudorandom_element({0, 1, 2, 3, 4}, pseudoseed("fb_goat_discards"))
    end
    if not state.goat_hand_size then
        state.goat_hand_size = pseudorandom_element({5, 6, 7, 8, 9, 10, 11, 12}, pseudoseed("fb_goat_hand_size"))
    end
    if not state.goat_blind_mult then
        state.goat_blind_mult = pseudorandom_element({1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, pseudoseed("fb_goat_mult"))
    end

    return state
end

-- =========================
-- Zodiac / Earthly Branches
-- =========================

create_blind({
    key = "rat",
    pos = {x = 0, y = 0},
    loc_txt = {
        name = "The Rat",
        text = {
            "First scoring card of the",
            "first hand loses {C:money}$1{} per chip scored"
        }
    },
    set_blind = function()
        get_state().rat_active = true
    end,
    calculate = function(self, blind, context)
        if context.individual and context.cardarea == G.play and get_state().rat_active and not get_state().rat_used then
            get_state().rat_used = true
            local chips = context.other_card and context.other_card.get_chip_bonus and context.other_card:get_chip_bonus() or 0
            if chips > 0 then
                ease_dollars(-chips)
            end
        end
    end
})

create_blind({
    key = "cow",
    pos = {x = 0, y = 1},
    boss = {min = 3},
    mult = 5,
    loc_txt = {
        name = "The Cow",
        text = {
            "{C:attention}+1{} hand, {C:attention}-1{} discard",
            "Blind size is {C:attention}5X{}"
        }
    },
    set_blind = function()
        set_hands_delta(1)
        set_discards_delta(-1)
    end,
    disable = function()
        set_hands_delta(-1)
        set_discards_delta(1)
    end
})

create_blind({
    key = "tiger",
    pos = {x = 0, y = 2},
    boss = {min = 2},

    loc_txt = {
        name = "The Tiger",
        text = {
            "Each played enhanced card",
            "gives {X:mult,C:white}X0.5{} Mult"
        }
    },

    calculate = function(self, blind, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card
            and is_enhanced(context.other_card) then

            return {
                xmult = 0.5,
                card = context.other_card
            }
        end
    end
})

create_blind({
    key = "rabbit",
    pos = {x = 0, y = 3},
    boss = {min = 2},
    loc_txt = {
        name = "The Rabbit",
        text = {
            "After playing, {C:green}1 in 3{} chance",
            "for hand to score {C:attention}0{}",
            "Final hand always scores"
        }
    },
    press_play = function()
        local state = get_state()
        state.rabbit_fail = false

        -- debuff_hand can be called by preview/selection logic, so RNG must happen here instead.
        local hands_left_after_this = G.GAME.current_round and G.GAME.current_round.hands_left or 1
        if hands_left_after_this > 0 then
            state.rabbit_fail = pseudorandom("fb_rabbit_actual_play") < (1 / 3)
        end
    end,
    debuff_hand = function(self, cards, hand, handname, check)
        return get_state().rabbit_fail == true
    end
})

create_blind({
    key = "dragon",
    pos = {x = 0, y = 4},
    boss = {min = 5},
    loc_txt = {
        name = "The Dragon",
        text = {
            "If final Chips are below {C:chips}#1#{}",
            "Mult becomes {C:attention}0{}"
        }
    },
    loc_vars = function()
        return loc_vars(ensure_dragon_threshold())
    end,
    set_blind = function()
        ensure_dragon_threshold()
    end,
    calculate = function(self, blind, context)
        if context.final_scoring_step then
            local threshold = ensure_dragon_threshold()

            if hand_chips < threshold then
                return {
                    mult = 0,
                    message = "Too Low!"
                }
            end
        end
    end
})

create_blind({
    key = "snake",
    pos = {x = 0, y = 5},
    loc_txt = {
        name = "The Snake",
        text = {
            "Each playing card has a",
            "{C:green}1 in 2{} chance",
            "to be debuffed"
        }
    },
    set_blind = function()
        get_state().snake_rolls = {}
    end,
    debuff_card = function(self, card, from_blind)
        if not is_playing_card(card) then
            return false
        end

        local state = get_state()
        state.snake_rolls = state.snake_rolls or {}

        local id = card.sort_id or card.ID or tostring(card)
        if state.snake_rolls[id] == nil then
            state.snake_rolls[id] = pseudorandom("fb_snake") < 0.5
        end

        return state.snake_rolls[id]
    end
})

create_blind({
    key = "horse",
    pos = {x = 0, y = 6},
    boss = {min = 4},
    loc_txt = {
        name = "The Horse",
        text = {
            "Cannot play",
            "{C:attention}5{} or more cards"
        }
    },
    debuff_hand = function(self, cards, hand, handname, check)
        return #cards >= 5
    end
})

create_blind({
    key = "goat",
    pos = {x = 0, y = 7},
    boss = {min = 3},
    mult = 1,

    loc_txt = {
        name = "The Goat",
        text = {
            "Random hands, discards, hand size",
            "and blind size"
        }
    },

    loc_vars = function()
        local state = ensure_goat_values()
        return loc_vars(
            state.goat_hands,
            state.goat_discards,
            state.goat_hand_size,
            state.goat_blind_mult
        )
    end,

    set_blind = function()
        local state = ensure_goat_values()

        if G.GAME.current_round then
            G.GAME.current_round.hands_left = state.goat_hands
            G.GAME.current_round.discards_left = state.goat_discards
        end

        if G.hand then
            state.goat_old_hand_size = G.hand.config.card_limit
            G.hand.config.card_limit = state.goat_hand_size
        end

        if G.GAME.blind and G.GAME.blind.chips and not state.goat_chips_scaled then
            G.GAME.blind.chips = math.floor(G.GAME.blind.chips * state.goat_blind_mult)
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            state.goat_chips_scaled = true
        end
    end,

    disable = function()
        local state = get_state()
        if G.hand and state.goat_old_hand_size then
            G.hand.config.card_limit = state.goat_old_hand_size
        end
    end,

    defeat = function()
        local state = get_state()
        if G.hand and state.goat_old_hand_size then
            G.hand.config.card_limit = state.goat_old_hand_size
        end
    end
})

create_blind({
    key = "monkey",
    pos = {x = 0, y = 8},
    boss = {min = 6},
    loc_txt = {
        name = "The Monkey",
        text = {
            "Jokers trigger",
            "in random order"
        }
    },
    press_play = function()
        if G.jokers and G.jokers.cards then
            pseudoshuffle(G.jokers.cards, pseudoseed("fb_monkey"))
        end
    end
})

create_blind({
    key = "rooster",
    pos = {x = 0, y = 9},
    boss = {min = 5},
    mult = 1,

    loc_txt = {
        name = "The Rooster",
        text = {
            "Blind size is",
            "{C:attention}#1#X{}"
        }
    },

    loc_vars = function()
        local state = get_state()

        if not state.rooster_mult then
            state.rooster_mult = pseudorandom_element({
                1.0,
                1.5,
                2.0,
                2.5,
                3.0,
                3.5,
                4.0,
                4.5,
                5.0,
                5.5,
                6.0,
                6.5,
                7.0,
                7.5,
                8.0,
                8.5,
                9.0,
                9.5,
                10.0
            }, pseudoseed("fb_rooster_mult"))
        end

        return loc_vars(state.rooster_mult)
    end,

    set_blind = function()
        local state = get_state()

        if not state.rooster_mult then
            state.rooster_mult = pseudorandom_element({
                1.0,
                1.5,
                2.0,
                2.5,
                3.0,
                3.5,
                4.0,
                4.5,
                5.0,
                5.5,
                6.0,
                6.5,
                7.0,
                7.5,
                8.0,
                8.5,
                9.0,
                9.5,
                10.0
            }, pseudoseed("fb_rooster_mult"))
        end

        if G.GAME.blind
        and G.GAME.blind.chips
        and not state.rooster_chips_scaled then

            G.GAME.blind.chips =
                math.floor(G.GAME.blind.chips * state.rooster_mult)

            G.GAME.blind.chip_text =
                number_format(G.GAME.blind.chips)

            state.rooster_chips_scaled = true
        end
    end
})

local function fb_is_numbered_card(card)
    if not card or not card.base then
        return false
    end

    local id = card.base.id

    return type(id) == "number" and id >= 2 and id <= 10
end

create_blind({
    key = "dog",
    pos = {x = 0, y = 10},
    boss = {min = 3},
    loc_txt = {
        name = "The Dog",
        text = {
            "All numbered",
            "cards are debuffed"
        }
    },

    debuff_card = function(self, card, from_blind)
        return fb_is_numbered_card(card)
    end
})

create_blind({
    key = "boar",
    pos = {x = 0, y = 11},
    boss = {min = 5},
    loc_txt = {
        name = "The Boar",
        text = {
            "Played enhanced cards",
            "lose their enhancements"
        }
    },

    calculate = function(self, blind, context)
        if context.before and context.full_hand then
            for _, card in ipairs(context.full_hand or {}) do
                if is_enhanced(card) then
                    card:set_ability(G.P_CENTERS.c_base, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card:juice_up()
                            return true
                        end
                    }))
                end
            end
        end
    end
})

-- ================================
-- Heavenly Stems + Yin/Yang Blinds
-- ================================

create_blind({
    key = "armor",
    pos = {x = 0, y = 12},
    boss = {min = 3},
    mult = 3,
    loc_txt = {
        name = "The Armor",
        text = {
            "At start of scoring,",
            "gain {X:mult,C:white}X0.25{} Mult",
            "Blind size is {C:attention}3X{}"
        }
    },
    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        return mult * 0.25, hand_chips, true
    end
})

local function fb_roll_twist_xmult()
    -- Use math.random here on purpose: this should be a fresh per-hand roll,
    -- not a deterministic same-seed result that repeats every hand.
    return math.random(5, 15) / 10
end

create_blind({
    key = "twist",
    pos = {x = 0, y = 13},

    loc_txt = {
        name = "The Twist",
        text = {
            "Each played hand gains",
            "a random {X:mult,C:white}X0.5{} to",
            "{X:mult,C:white}X1.5{} Mult"
        }
    },

    press_play = function()
        get_state().twist_xmult = fb_roll_twist_xmult()
    end,

    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        local state = get_state()
        state.twist_xmult = state.twist_xmult or fb_roll_twist_xmult()

        return mult * state.twist_xmult, hand_chips, true
    end,

    calculate = function(self, blind, context)
        if context.final_scoring_step then
            local state = get_state()
            local xmult = state.twist_xmult or 1
            state.twist_xmult = nil

            return {
                message = "X" .. tostring(xmult),
                colour = G.C.MULT
            }
        end
    end
})

create_blind({
    key = "blaze",
    pos = {x = 0, y = 14},
    boss = {min = 5},

    loc_txt = {
        name = "The Blaze",
        text = {
            "At end of scoring,",
            "gain {X:mult,C:white}X0.1{} Mult",
            "until a Joker is sold"
        }
    },

    loc_vars = function()
        if not blaze_active() then
            return {
                vars = {},
                text = {
                    "{C:green}EXTINGUISHED{}"
                }
            }
        end

        return { vars = {} }
    end,

    set_blind = function()
        get_state().blaze_active = true
    end,

    calculate = function(self, blind, context)

        if context.selling_card
            and context.card
            and context.card.ability
            and context.card.ability.set == "Joker"
        then
            get_state().blaze_active = false

            return {
                message = "Extinguished!"
            }
        end

        -- Apply X0.1 at final scoring
        if context.final_scoring_step and blaze_active() then
            return {
                xmult = 0.1,
                message = "Blaze!"
            }
        end
    end
})

create_blind({
    key = "focus",
    pos = {x = 0, y = 15},
    mult = 6,
    loc_txt = {
        name = "The Focus",
        text = {
            "{C:red}Debuffs{} all but",
            "the first played card",
            "Retrigger first scored card",
            "once per played card"
        }
    },

    calculate = function(self, blind, context)
        if context.before and G.play and G.play.cards then
            for i, c in ipairs(G.play.cards) do
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
            and context.other_card == G.play.cards[1] then

            return {
                repetitions = math.max(0, #G.play.cards - 1),
                card = context.other_card
            }
        end
    end
})

create_blind({
    key = "balance",
    pos = {x = 0, y = 16},
    boss = {min = 5},

    loc_txt = {
        name = "The Balance",
        text = {
            "{C:chips}Chips{} are set to",
            "initial {C:mult}Mult{}"
        }
    },

    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        return mult, mult, true
    end
})

create_blind({
    key = "self",
    pos = {x = 0, y = 17},
    mult = 1,
    boss = {min = 5},
    loc_txt = {
        name = "The Self",
        text = {
            "Must play",
            "exactly {C:attention}1{} card"
        }
    },
    debuff_hand = function(self, cards, hand, handname, check)
        return #cards ~= 1
    end
})

create_blind({
    key = "force",
    pos = {x = 0, y = 18},
    loc_txt = {
        name = "The Force",
        text = {
            "Debuffs one random",
            "played card each hand"
        }
    },

    calculate = function(self, blind, context)
        if context.before and G.play and G.play.cards and #G.play.cards > 0 then
            for _, c in ipairs(G.play.cards) do
                if c.ability then
                    c.ability.fb_force_debuff = nil
                    c:set_debuff(false)
                end
            end

            local target = pseudorandom_element(G.play.cards, pseudoseed("fb_force"))

            if target then
                target.ability = target.ability or {}
                target.ability.fb_force_debuff = true
                target:set_debuff(true)

                return {
                    message = "Forced!",
                    colour = G.C.RED
                }
            end
        end
    end,

    debuff_card = function(self, card, from_blind)
        return card
            and card.ability
            and card.ability.fb_force_debuff
    end,

    disable = function(self)
        if G.play and G.play.cards then
            for _, c in ipairs(G.play.cards) do
                if c.ability then
                    c.ability.fb_force_debuff = nil
                    c:set_debuff(false)
                end
            end
        end

        if G.hand and G.hand.cards then
            for _, c in ipairs(G.hand.cards) do
                if c.ability then
                    c.ability.fb_force_debuff = nil
                    c:set_debuff(false)
                end
            end
        end
    end
})

create_blind({
    key = "pain",
    pos = {x = 0, y = 19},
    boss = {min = 2},
    loc_txt = {
        name = "The Pain",
        text = {
            "Played cards give",
            "negative Chips and Mult"
        }
    },
    calculate = function(self, blind, context)
        if context.individual and context.cardarea == G.play and context.other_card then
            return {
                chips = -math.abs(context.other_card.get_chip_bonus and context.other_card:get_chip_bonus() or 0),
                mult = -1,
                card = context.other_card
            }
        end
    end
})

create_blind({
    key = "flood",
    pos = {x = 0, y = 20},
    boss = {min = 4},
    loc_txt = {
        name = "The Flood",
        text = {
            "Each card trigger loses {C:money}$1{}"
        }
    },
    calculate = function(self, blind, context)
    if context.individual
    and context.cardarea == G.play
    and context.other_card then
        ease_dollars(-1)
        return {
            message = "-$1",
            colour = G.C.MONEY
        }
    end
end
})

local function fb_is_mist_active()
    return G.GAME
        and G.GAME.blind
        and G.GAME.blind.config
        and G.GAME.blind.config.blind
        and G.GAME.blind.config.blind.key == "mist"
end

local function flip_hand_cards_matching_face_down(predicate)
    if not (G.hand and G.hand.cards) then
        return
    end

    for _, card in ipairs(G.hand.cards) do
        if is_playing_card(card)
            and card.facing == "front"
            and (not predicate or predicate(card)) then
            -- card:flip() toggles. Guarding on facing == "front" prevents
            -- The Shadow from accidentally flipping already-hidden cards back up.
            card:flip()
        end
    end
end

local function flip_all_hand_cards_face_down()
    flip_hand_cards_matching_face_down()
end

local function flip_numbered_hand_cards_face_down()
    flip_hand_cards_matching_face_down(is_numbered)
end

local function mist_activate_and_flip()
    local state = get_state()
    state.mist_has_acted = true

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.15,
        func = function()
            flip_all_hand_cards_face_down()
            return true
        end
    }))
end

create_blind({
    key = "mist",
    modifies_draw = true,
    pos = {x = 0, y = 21},
    boss = {min = 3},
    loc_txt = {
        name = "The Mist",
        text = {
            "After playing a hand,",
            "all cards are flipped face down"
        }
    },

    set_blind = function()
        get_state().mist_has_acted = false
    end,

    press_play = function()
        mist_activate_and_flip()
    end,

    drawn_to_hand = function()
        if get_state().mist_has_acted then
            mist_activate_and_flip()
        end
    end,

    stay_flipped = function(self, area, card)
        return get_state().mist_has_acted
            and area == G.hand
            and is_playing_card(card)
    end

})

create_blind({
    key = "shadow",
    pos = {x = 0, y = 22},
    boss = {min = 6},
    modifies_draw = true,
    loc_txt = {
        name = "The Shadow",
        text = {
            "All numbered",
            "cards are flipped"
        }
    },
    set_blind = function()
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.15,
            func = function()
                flip_numbered_hand_cards_face_down()
                return true
            end
        }))
    end,
    drawn_to_hand = function()
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.05,
            func = function()
                flip_numbered_hand_cards_face_down()
                return true
            end
        }))
    end,
    stay_flipped = function(self, area, card)
        return area == G.hand and is_numbered(card)
    end
})

create_blind({
    key = "light",
    pos = {x = 0, y = 23},
    boss = {min = 7},
    loc_txt = {
        name = "The Light",
        text = {
            "Cards without",
            "enhancements are debuffed"
        }
    },
    debuff_card = function(self, card, from_blind)
        return is_playing_card(card) and not is_enhanced(card)
    end
})

local FINAL_BOSS_MULT = {
    metal_tiger = 2,
    fire_bird = 2,
    water_deer = 2,
    wood_ape = 2,
    earth_bear = 2,
    air_dragon = 2
}

local FINAL_BOSS_COLOURS = {
    -- Final boss rows in blinds.png, rows 24-29, using the image order.
    -- primary = colored outer rim sections / boss background color
    -- secondary = central object/symbol color for reference
    air_dragon  = {primary = HEX("D4E3E5"), secondary = HEX("B1BEBF")},
    earth_bear  = {primary = HEX("8B5A3C"), secondary = HEX("C7A36B")},
    fire_bird   = {primary = HEX("D83A2E"), secondary = HEX("F58A1F")},
    water_deer  = {primary = HEX("5CCEF5"), secondary = HEX("A8E7FF")},
    wood_ape    = {primary = HEX("3F9E4D"), secondary = HEX("2B7A3F")},
    metal_tiger = {primary = HEX("E6B800"), secondary = HEX("E87A1A")}
}

local function final_boss_colour(key)
    return FINAL_BOSS_COLOURS[key] and FINAL_BOSS_COLOURS[key].primary or HEX("8f6f4e")
end

local function final_boss_in_pool()
    local ante = G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 0
    return ante > 0 and ante % 8 == 0
end

local function has_special_card_parts(card)
    if not card then
        return false
    end
    if card.edition or card.seal then
        return true
    end
    return is_enhanced(card)
end

local function has_special_joker_parts(card)
    if not card then
        return false
    end
    if card.edition then
        return true
    end
    if card.ability and (
        card.ability.eternal or
        card.ability.perishable or
        card.ability.rental
    ) then return true end
    return false
end

local function destroy_card_safely(card)
    if not card then
        return
    end
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.1,
        func = function()
            card:start_dissolve()
            return true
        end
    }))
end

local function pick_weighted_fire_bird_joker()
    if not (G.jokers and G.jokers.cards and #G.jokers.cards > 0) then
        return nil
    end

    local pool = {}

    for _, joker in ipairs(G.jokers.cards) do
        local weight = 1
        local rarity = joker.config and joker.config.center and joker.config.center.rarity

        if rarity == 2 then
            weight = weight + 1
        end
        if rarity == 3 then
            weight = weight + 2
        end
        if rarity == 4 then
            weight = weight + 4
        end
        if joker.edition then
            weight = weight + 3
        end

        for i = 1, weight do
            pool[#pool + 1] = joker
        end
    end

    return pseudorandom_element(pool, pseudoseed("fb_fire_bird_joker"))
end

-- Metal Tiger
create_blind({
    key = "metal_tiger",
    pos = {x = 0, y = 29},
    boss = {showdown = true},
    mult = FINAL_BOSS_MULT.metal_tiger,
    boss_colour = final_boss_colour("metal_tiger"),
    loc_txt = {
        name = "Metal Tiger",
        text = {
            "Cards and Jokers with",
            "{C:attention}Enhancements{}, {C:attention}Seals{}, or {C:attention}Editions{}",
            "are debuffed"
        }
    },
    debuff_card = function(self, card, from_blind)
        if is_playing_card(card) then
            return has_special_card_parts(card)
        end

        return has_special_joker_parts(card)
    end
})

-- Fire Bird
create_blind({
    key = "fire_bird",
    pos = {x = 0, y = 26},
    boss = {showdown = true},
    mult = FINAL_BOSS_MULT.fire_bird,
    boss_colour = final_boss_colour("fire_bird"),
    loc_txt = {
        name = "Fire Bird",
        text = {
            "Played cards are destroyed",
            "after scoring",
            "When beaten, destroy",
            "a random Joker"
        }
    },

    calculate = function(self, blind, context)
        if context.after and context.full_hand then
            for _, card in ipairs(context.full_hand or {}) do
                if card and not card.destroyed then
                    card.destroyed = true
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.1,
                        func = function()
                            card:start_dissolve()
                            return true
                        end
                    }))
                end
            end
        end
    end,

    defeat = function()
        local joker = pick_weighted_fire_bird_joker()
        if joker then
            destroy_card_safely(joker)
        end
    end
})

-- Water Deer
local function clear_water_deer_joker_debuffs()
    for _, joker in ipairs((G.jokers and G.jokers.cards) or {}) do
        if joker.ability then
            joker.ability.fb_water_deer_debuff = nil
        end

        joker.debuff = false
    end
end

local function water_deer_scale_blind()
    local state = get_state()

    if not (G.GAME and G.GAME.blind and G.GAME.blind.chips) then
        return
    end

    state.water_deer_base_chips = state.water_deer_base_chips or G.GAME.blind.chips

    local disabled = state.water_deer_disabled_count or 0
    local mult = 1 + (0.5 * disabled)

    G.GAME.blind.chips = math.floor(state.water_deer_base_chips * mult)
    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
end

create_blind({
    key = "water_deer",
    pos = {x = 0, y = 27},

    boss = {showdown = true},
    mult = FINAL_BOSS_MULT.water_deer,
    boss_colour = final_boss_colour("water_deer"),

    loc_txt = {
        name = "Water Deer",
        text = {
            "When playing a hand,",
            "{C:red}debuff{} a random Joker",
            "Blind size increases by",
            "{C:attention}0.5X{} each time"
        }
    },

    set_blind = function()
        local state = get_state()

        state.water_deer_disabled_count = 0
        state.water_deer_base_chips = G.GAME.blind and G.GAME.blind.chips or nil

        clear_water_deer_joker_debuffs()
    end,

    press_play = function()
        local choices = {}

        for _, joker in ipairs((G.jokers and G.jokers.cards) or {}) do
            if joker
                and joker.ability
                and not joker.ability.fb_water_deer_debuff then
                choices[#choices + 1] = joker
            end
        end

        local target = pseudorandom_element(choices, pseudoseed("fb_water_deer_joker"))

        if target then
            target.ability.fb_water_deer_debuff = true
            target.debuff = true

            local state = get_state()
            state.water_deer_disabled_count = (state.water_deer_disabled_count or 0) + 1

            water_deer_scale_blind()
        end
    end,

    debuff_card = function(self, card, from_blind)
        return card
            and card.ability
            and card.ability.fb_water_deer_debuff == true
    end,

    disable = function()
        clear_water_deer_joker_debuffs()
    end,

    defeat = function()
        clear_water_deer_joker_debuffs()
    end
})

-- Wood Ape
create_blind({
    key = "wood_ape",
    pos = {x = 0, y = 28},
    boss = {showdown = true},
    mult = FINAL_BOSS_MULT.wood_ape,
    boss_colour = final_boss_colour("wood_ape"),
    loc_txt = {
        name = "Wood Ape",
        text = {
            "Shuffle and pin all Jokers"
        }
    },
    set_blind = function()
        if G.jokers and G.jokers.cards then
            pseudoshuffle(G.jokers.cards, pseudoseed("fb_wood_ape_shuffle"))

            for _, joker in ipairs(G.jokers.cards) do
                joker.pinned = true
            end
        end
    end,
    press_play = function()
        local state = get_state()
        state.wood_ape_removed_cards = {}

        for _, card in ipairs(G.play.cards or {}) do
            if pseudorandom("fb_wood_ape_discard") < 0.5 then
                state.wood_ape_removed_cards[#state.wood_ape_removed_cards + 1] = card
            end
        end
    end,
    calculate = function(self, blind, context)
        if context.before then
            for _, card in ipairs(get_state().wood_ape_removed_cards or {}) do
                draw_card(G.play, G.discard, 1, "down", false, card)
            end
        end
    end
})

-- Earth Bear
create_blind({
    key = "earth_bear",
    pos = {x = 0, y = 25},
    boss = {showdown = true},
    mult = FINAL_BOSS_MULT.earth_bear,
    boss_colour = final_boss_colour("earth_bear"),
    loc_txt = {
        name = "Earth Bear",
        text = {
            "Each card trigger gives",
            "{X:chips,C:white}X0.5{} Chips and {X:mult,C:white}X0.5{} Mult"
        }
    },
    calculate = function(self, blind, context)
        if context.individual and context.cardarea == G.play then
            return {
                xchips = 0.5,
                xmult = 0.5,
                card = context.other_card
            }
        end
    end
})

-- Air Dragon
create_blind({
    key = "air_dragon",
    pos = {x = 0, y = 24},
    boss = {showdown = true},
    mult = FINAL_BOSS_MULT.air_dragon,
    boss_colour = final_boss_colour("air_dragon"),
    loc_txt = {
        name = "Air Dragon",
        text = {
            "All cards are debuffed",
            "At end of scoring, gain",
            "{X:chips,C:white}X2{} Chips and {X:mult,C:white}X2{} Mult"
        }
    },
    debuff_card = function(self, card, from_blind)
        return is_playing_card(card)
    end,
    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        return mult * 2, hand_chips * 2, true
    end
})


-- =========================
-- Secret Blinds
-- =========================

local function fb_current_round_number()
    if not G or not G.GAME then return 0 end
    return tonumber(G.GAME.round)
        or tonumber(G.GAME.round_count)
        or tonumber(G.GAME.round_number)
        or tonumber(G.GAME.round_resets and G.GAME.round_resets.round)
        or tonumber(G.GAME.current_round and G.GAME.current_round.round_number)
        or 0
end

local function fb_hard_to_destroy_unlocked()
    if not (G and G.GAME) then return false end
    if G.GAME.fb_hard_to_destroy_found then return true end

    -- playtest value
    return fb_current_round_number() >= 682

    -- real value later:
    -- return fb_current_round_number() >= 682
end

local function fb_hard_state()
    G.GAME.fb_hard_to_destroy_state = G.GAME.fb_hard_to_destroy_state or {
        ranks = {},
        suits = {},
        enhancements = {},
        seals = {},
        editions = {},
        jokers = {},
        pending_jokers = {},
    }
    return G.GAME.fb_hard_to_destroy_state
end

local function fb_card_edition_key(card)
    if not card or not card.edition then return nil end
    if card.edition.foil then return "foil" end
    if card.edition.holo then return "holo" end
    if card.edition.polychrome then return "polychrome" end
    if card.edition.negative then return "negative" end
    return nil
end

local function fb_reveal_hard_to_destroy_blind()
    if not (G and G.GAME) then return end
    G.GAME.fb_hard_to_destroy_found = true

    local center = G.P_BLINDS and (
        G.P_BLINDS.bl_fb_hard_to_destroy
        or G.P_BLINDS.fb_hard_to_destroy
        or G.P_BLINDS.hard_to_destroy
    )

    if center then
        center.discovered = true
        center.no_collection = false
    end
end

local function fb_square_current_blind_score()
    if not (G and G.GAME and G.GAME.blind and G.GAME.blind.chips) then return end

    local base = G.GAME.blind.chips
    local squared = base * base

    G.GAME.blind.chips = squared
    G.GAME.blind.chip_text = number_format(squared)
end

create_blind({
    key = "hard_to_destroy",
    pos = {x = 0, y = 25},
    dollars = 6,
    discovered = false,
    no_collection = true,
    boss_colour = HEX("4795A6"),
    loc_txt = {
        name = "Hard to Destroy Blind",
        text = {
            "How the hell am I",
            "supposed to kill this thing?"
        }
    },

    in_pool = function(self)
        local unlocked = fb_hard_to_destroy_unlocked()
        if unlocked then fb_reveal_hard_to_destroy_blind() end
        return unlocked
    end,

    set_blind = function()
        fb_reveal_hard_to_destroy_blind()
        G.GAME.fb_hard_to_destroy_state = nil
        fb_hard_state()
        fb_square_current_blind_score()
    end,

    debuff_card = function(self, card, from_blind)
        local state = fb_hard_state()

        if is_playing_card(card) then
            local rank = card.base and card.base.id
            local suit = card.base and card.base.suit
            local enh = card.config and card.config.center and card.config.center.key
            local seal = card.seal
            local edition = fb_card_edition_key(card)

            return (rank and state.ranks[rank])
                or (suit and state.suits[suit])
                or (enh and enh ~= "c_base" and state.enhancements[enh])
                or (seal and state.seals[seal])
                or (edition and state.editions[edition])
        end

        local key = card and card.config and card.config.center and card.config.center.key
        return key and state.jokers[key]
    end,

    calculate = function(self, blind, context)
        local state = fb_hard_state()

        -- Learn played-card traits during scoring, but debuffs matter after.
        if context.individual and context.cardarea == G.play and context.other_card then
            local c = context.other_card

            if c.base and c.base.id then state.ranks[c.base.id] = true end
            if c.base and c.base.suit then state.suits[c.base.suit] = true end

            local enh = c.config and c.config.center and c.config.center.key
            if enh and enh ~= "c_base" then state.enhancements[enh] = true end

            if c.seal then state.seals[c.seal] = true end

            local ed = fb_card_edition_key(c)
            if ed then state.editions[ed] = true end
        end

        -- Mark Jokers that triggered this hand.
        if context.joker_main and context.card then
            local key = context.card.config and context.card.config.center and context.card.config.center.key
            if key then state.pending_jokers[key] = true end
        end

        -- After scoring, commit Joker adaptations and refresh debuffs.
        if context.after then
            for key, _ in pairs(state.pending_jokers or {}) do
                state.jokers[key] = true
            end
            state.pending_jokers = {}

            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c.set_debuff then c:set_debuff(false) end
                end
            end

            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j.set_debuff then j:set_debuff(false) end
                end
            end
        end
    end
})

local fb_discard_ref = G.FUNCS.discard_cards_from_highlighted

G.FUNCS.discard_cards_from_highlighted = function(e, hook)
    local ret = fb_discard_ref(e, hook)

    if fb_is_mist_active() then
        mist_activate_and_flip()
    end

    return ret
end

local fb_blaze_sell_ref = Card.sell_card

function Card:sell_card()
    if self.ability and self.ability.set == "Joker" then
        if G.GAME
            and G.GAME.blind
            and G.GAME.blind.config
            and G.GAME.blind.config.blind
            and G.GAME.blind.config.blind.key == "blaze" then

            get_state().blaze_active = false
        end
    end

    return fb_blaze_sell_ref(self)
end
