---@diagnostic disable: undefined-global

FB.joker_keys = {
    "album_cover",
    "alternate_album_cover",
    "beijing_license_plate",
    "bullet_comment",
    "cardboard_box",
    "dew_cloud",
    "divine_herb",
    "dog_food",
    "emergency_rations",
    "food",
    "food_reserve",
    "foraged_mushrooms",
    "health_insurance",
    "heart_lock",
    "heavenly_cumin",
    "hellspice_hotpot",
    "knockout",
    "lakeside_pond",
    "laurel_branch",
    "mini_theater",
    "mooncake",
    "mortal_realm",
    "pay_stub",
    "rat_poison",
    "shunshui_express",
    "skewered_kebab",
    "teacup",
    "temporal_confinement",
    "tile_cat",
    "tulou",
    "underworld_cash",
    "bestiary",
    "chicken_mushroom_stew",
    "demolition_notice",
    "do_not_imitate",
    "eating_melons",
    "feirenzai_manga",
    "followers_request",
    "gold_sculpture",
    "heavenly_elixirs",
    "hellish_delicacies",
    "lunchbox_medkit",
    "mapo_tofu",
    "moon_palace",
    "mooncake_cannon",
    "open_for_business",
    "oxen_cart",
    "paw_hole_cave",
    "pixiu_fur",
    "qilin_egg",
    "questionable_fanart",
    "rigged_video_game",
    "teapot",
    "underworlds_blacklist",
    "9th_heaven",
    "body_swap_mushroom",
    "bone_mask",
    "cintamani",
    "divine_garment",
    "divine_hair_growth_elixir",
    "divine_light",
    "divine_warsword",
    "dreamscape",
    "giant_kun_fish",
    "interdimensional_cave",
    "jade_bird",
    "laurel_tree",
    "lurendian_deermans",
    "magpie_bridge",
    "one_way_ticket_to_heaven",
    "pixiu_horn",
    "underworld",
    "bajin",
    "bilibili",
    "bibi",
    "bixie",
    "christina",
    "chugou",
    "dijiang",
    "diting",
    "erliang",
    "fenz",
    "fresh_seed",
    "fuku_fuzai",
    "hetao",
    "hundun",
    "jinchi_dapeng",
    "jinjiao",
    "kulou",
    "luo_tianyi",
    "lord_phoenix",
    "qiongqi",
    "shanque",
    "sibuxiang",
    "taotie",
    "taowu",
    "tianlu",
    "tubaoshu",
    "tuye_tony",
    "xiaolizhi",
    "xiezhi",
    "yinjiao",
    "zhanhu",
    "bixie_true_form",
    "rainbow_mountain_range",
    "qishiqi",
    "shi_qilin",
    "qilin_sibuxiang",
    "tianlu_true_form",
    "happy_ending",
}


-- Sprite atlas note: each Joker sprite is 71x95 pixels.
-- SMODS `pos` uses zero-based grid coordinates, not pixel coordinates.
-- This sheet is assumed to have 10 columns; if your PNG has a different column count,
-- change the generated x/y mapping accordingly.

FB.food_joker_keys = FB.food_joker_keys or {
    divine_herb = true,
    dog_food = true,
    emergency_rations = true,
    food = true,
    food_reserve = true,
    foraged_mushrooms = true,
    heavenly_cumin = true,
    hellspice_hotpot = true,
    mooncake = true,
    skewered_kebab = true,
    teacup = true,
    chicken_mushroom_stew = true,
    heavenly_elixirs = true,
    hellish_delicacies = true,
    lunchbox_medkit = true,
    mapo_tofu = true,
    moon_palace = true,
    mooncake_cannon = true,
}

FB.beast_joker_keys = FB.beast_joker_keys or {
    bajin = true,
    bibi = true,
    bixie = true,
    chugou = true,
    dijiang = true,
    diting = true,
    erliang = true,
    fenz = true,
    fuku_fuzai = true,
    hetao = true,
    hundun = true,
    jinchi_dapeng = true,
    jinjiao = true,
    kulou = true,
    lord_phoenix = true,
    qiongqi = true,
    shanque = true,
    sibuxiang = true,
    taotie = true,
    taowu = true,
    tianlu = true,
    tubaoshu = true,
    tuye_tony = true,
    xiaolizhi = true,
    xiezhi = true,
    yinjiao = true,
    zhanhu = true,
    bixie_true_form = true,
    shi_qilin = true,
    qilin_sibuxiang = true,
    tianlu_true_form = true,
}

FB.is_food_joker = FB.is_food_joker or function(card)
    local key = FB.get_center_key(card)
    if not key then return false end
    key = key:gsub('^j_fb_', '')
    return FB.food_joker_keys[key] == true
end

FB.is_beast_joker = FB.is_beast_joker or function(card)
    local key = FB.get_center_key(card)
    if not key then return false end
    key = key:gsub('^j_fb_', '')
    return FB.beast_joker_keys[key] == true
end

FB.count_food_jokers_explicit = FB.count_food_jokers_explicit or function()
    local n = 0

    for _, j in ipairs(FB.joker_cards()) do
        if FB.is_food_joker(j) then n = n + 1 end
    end

    return n
end


-- Fabulous Beasts: Common Jokers

SMODS.Joker({
    key = "album_cover",

    loc_txt = {
        name = "Album Cover",
        text = {
            "Plays the theme song. {C:attention}+1{} joker slot",
            "{C:inactive}WARNING: COPYRIGHTED CONTENT{}"
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 0},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(1) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-1) end
})

SMODS.Joker({
    key = "alternate_album_cover",

    loc_txt = {
        name = "Alternate Album Cover",
        text = {
            "Plays the Feirenzai intro song on repeat",
            "{C:inactive}WARNING: COPYRIGHTED CONTENT{}"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 0},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    add_to_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(1) end,
    remove_from_deck = function(self, card, from_debuff) FB.safe_change_joker_slots(-1) end
})

SMODS.Joker({
    key = "beijing_license_plate",

    loc_txt = {
        name = "Beijing License Plate",
        text = {
            "Before scoring, each held card triggers",
            "its own {C:chips}Chip{} value and shows the",
            "contribution to the total.",
            "{C:inactive}This resolves before Joker scoring.{}"
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 0},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,

    calculate = function(self, card, context)
        -- This must happen BEFORE scoring/Joker main. Returning chips from G.hand individual
        -- evaluates too late, so this directly modifies hand_chips at the before phase.
        if context.before and not context.blueprint and G.hand and G.hand.cards then
            local total_bonus = 0

            for _, held_card in ipairs(G.hand.cards) do
                if held_card and not held_card.debuff then
                    local bonus = held_card:get_chip_bonus() or 0
                    total_bonus = total_bonus + bonus

                    if bonus ~= 0 and type(card_eval_status_text) == 'function' then
                        card_eval_status_text(held_card, 'chips', bonus)
                    end
                end
            end

            if total_bonus ~= 0 then
                hand_chips = mod_chips((hand_chips or 0) + total_bonus)
                update_hand_text({delay = 0}, {chips = hand_chips})
            end
        end
    end
})

SMODS.Joker({
    key = "bullet_comment",

    loc_txt = {
        name = "Bullet Comment",
        text = {
            "{C:green}1 in 5{} chance to retrigger anything."
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 0},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.repetition and (context.cardarea == G.play or context.cardarea == G.hand) then
            if pseudorandom('bulletcomment_card') < 0.2 then
                return {message = localize('k_again_ex'), repetitions = 1, card = card}
            end
        end
        if context.retrigger_joker_check and context.other_card ~= card then
            if pseudorandom('bulletcomment_joker') < 0.2 then
                return {message = localize('k_again_ex'), repetitions = 1, card = card}
            end
        end
    end
})

SMODS.Joker({
    key = "cardboard_box",

    loc_txt = {
        name = "Cardboard Box",
        text = {
            "{C:purple}+1{} consumable slot"
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 0},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,

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
            "{C:red}-1{} hand size",
            "Gain {C:attention}+1{} hand size for",
            "each consecutive hand type played",
            "Resets if you play a different hand",
            "Currently {C:attention}#1#{}",
            "{C:inactive}Streak: #2#{}"
        }
    },

    config = {
        extra = {
            hand_type = "High Card",
            streak = 0
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 0},

    rarity = 1,
    cost = 5,

    discovered = true,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.hand_type,
                card.ability.extra.streak
            }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(-1)
    end,

    remove_from_deck = function(self, card, from_debuff)
        FB.safe_change_hand_size(-card.ability.extra.streak)
    end,

    calculate = function(self, card, context)

        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand_type = FB.random_hand_type and FB.random_hand_type("dewcloud_hand") or FB.random_poker_hand("dewcloud_hand")

            return {
                message = card.ability.extra.hand_type,
                colour = G.C.ATTENTION
            }
        end

        if context.before and context.main_eval and not context.blueprint then
            local played_hand = context.scoring_name

            if played_hand == card.ability.extra.hand_type then
                card.ability.extra.streak = card.ability.extra.streak + 1
                FB.safe_change_hand_size(1)

                return {
                    message = "+" .. card.ability.extra.streak .. " Streak",
                    colour = G.C.GREEN
                }
            else
                if card.ability.extra.streak > 0 then
                    FB.safe_change_hand_size(-card.ability.extra.streak)
                end

                card.ability.extra.streak = 0

                return {
                    message = "Reset!",
                    colour = G.C.RED
                }
            end
        end
    end
})

SMODS.Joker({
    key = "divine_herb",

    loc_txt = {
        name = "Divine Herb",
        text = {
            "When sold during a boss blind, disables",
            "that blind's effects for the current hand.",
            "{C:inactive}Current hand only{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 0},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.selling_self and G.GAME.blind and G.GAME.blind.boss then
            local count = FB.clear_card_debuffs(G.hand)
            return {message = "Blessed!", colour = G.C.GREEN}
        end
    end
})

SMODS.Joker({
    key = "dog_food",

    loc_txt = {
        name = "Dog Food",
        text = {
            "First scored card has tripled values for",
            "each hand."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 0},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.scoring_hand and context.other_card == context.scoring_hand[1] then
            return {x_chips = 3, x_mult = 3}
        end
    end
})

SMODS.Joker({
    key = "emergency_rations",

    loc_txt = {
        name = "Emergency Rations",
        text = {
            "Gain +1 hand and discard when you run out",
            "of hands, {C:red}destroyed{} after you run out of",
            "hands."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 0},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.after and G.GAME.current_round.hands_left <= 0 and not card.ability.fb_used then
            card.ability.fb_used = true
            ease_hands_played(1)
            ease_discard(1)
            FB.destroy(card)
            return {message = "Rations!", colour = G.C.GREEN}
        end
    end
})

SMODS.Joker({
    key = "food",

    loc_txt = {
        name = "Food",
        text = {
            "{C:chips}+20{} Chips. Doesn't take up a joker slot."
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 1},

    rarity = 1,
    cost = 2,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.joker_main then return {chips = 20} end
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
    cost = 3,

    discovered = true,
    unlocked = true,
    config = {extra = {stored = 0, current = 0}},

    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.stored}} end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.current = 0
        end

        if context.individual and context.cardarea == G.play and context.other_card then
            card.ability.extra.current = (card.ability.extra.current or 0) + (context.other_card:get_chip_bonus() or 0)
        end

        if context.joker_main then
            card.ability.extra.stored = card.ability.extra.stored + (card.ability.extra.current or 0)
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
            "{C:green}1 in 2{} chance that the hand does not score.",
            "{C:inactive}Hands remaining: #1#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 1},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    config = {extra = {hands = 8, failed = false}},

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.hands}}
    end,

    calculate = function(self, card, context)
        -- FIRST: roll before the hand starts scoring so the player sees the failure immediately.
        if context.before and not context.blueprint and card.ability.extra.hands > 0 then
            local fail_chance = 0.5
            if FB.has_joker('bajin') then
                fail_chance = math.min(1, fail_chance * 2)
            end
            if FB.has_joker('fuku_fuzai') then
                fail_chance = 0
            end

            card.ability.extra.failed = pseudorandom('foraged_mushrooms_fail') < fail_chance
            if card.ability.extra.failed then
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
        if context.repetition and (context.cardarea == G.play or context.cardarea == G.hand) and card.ability.extra.hands > 0 then
            return {
                message = localize('k_again_ex'),
                repetitions = FB.has_joker('fuku_fuzai') and 3 or 1,
                card = card
            }
        end

        -- LAST SCORING MODIFIER: cancel the hand score after all normal scoring math is known.
        if context.joker_main and card.ability.extra.hands > 0 and card.ability.extra.failed then
            return {
                chips = -math.max(0, hand_chips or 0),
                mult = -math.max(0, mult or 0),
                message = "No Score!",
                colour = G.C.RED,
                card = card
            }
        end

        -- AFTER HAND: count down exactly once per played hand.
        if context.after and not context.blueprint and card.ability.extra.hands > 0 then
            card.ability.extra.hands = card.ability.extra.hands - 1
            card.ability.extra.failed = false
            if card.ability.extra.hands <= 0 then
                FB.destroy(card)
            else
                return {
                    message = card.ability.extra.hands .. " left",
                    colour = G.C.ATTENTION,
                    card = card
                }
            end
        end
    end
})

SMODS.Joker({
    key = "health_insurance",

    loc_txt = {
        name = "Health Insurance",
        text = {
            "{C:attention}Retrigger{}s Medkit until you can't hold",
            "more jokers."
        }
    },

    atlas = "jokers",
    pos = {x = 3, y = 1},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and FB.is_joker_key(context.other_card, 'lunchbox_medkit') then
            return {message = localize('k_again_ex'), repetitions = 1, card = card}
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
    cost = 3,

    discovered = true,
    unlocked = true,
    eternal_compat = true,
    add_to_deck = function(self, card, from_debuff) card.ability.eternal = true end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local choices = {}
            for _, j in ipairs(G.jokers.cards) do if j ~= card then choices[#choices + 1] = j end end
            if #choices > 0 then pseudorandom_element(choices, pseudoseed('heartlock')).debuff = true end
            return {message = "Locked!", colour = G.C.RED}
        end
    end
})

SMODS.Joker({
    key = "heavenly_cumin",

    loc_txt = {
        name = "Heavenly Cumin",
        text = {
            "{C:attention}Retrigger{} all food jokers."
        }
    },

    atlas = "jokers",
    pos = {x = 5, y = 1},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card and FB.is_food_joker(context.other_card) then
            return {message = localize('k_again_ex'), repetitions = 1, card = card}
        end
    end
})

SMODS.Joker({
    key = "hellspice_hotpot",

    loc_txt = {
        name = "Hellspice Hotpot",
        text = {
            "If you score more than the required amount",
            "to clear the ante in one hand, {X:mult,C:white}^4{} Mult."
        }
    },

    atlas = "jokers",
    pos = {x = 6, y = 1},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.joker_main and G.GAME.chips + hand_chips >= G.GAME.blind.chips then
            return {e_mult = 4, message = "^4 Mult"}
        end
    end
})

SMODS.Joker({
    key = "knockout",

    loc_txt = {
        name = "Knockout!",
        text = {
            "Gain {X:mult,C:white}X0.1{} Mult every round. Skipping a",
            "blind resets this joker. Increases",
            "increment by {X:mult,C:white}X0.1{} every round.",
            "{C:inactive}Currently {X:mult,C:white}X#1#{} Mult, gain X#2#{}"
        }
    },

    atlas = "jokers",
    pos = {x = 7, y = 1},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    config = {extra = {xmult = 1, gain = 0.1}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.xmult, card.ability.extra.gain}} end,
    calculate = function(self, card, context)
        if context.joker_main then return {x_mult = card.ability.extra.xmult} end
        if context.end_of_round and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain
            card.ability.extra.gain = card.ability.extra.gain + 0.1
        end
        if context.skip_blind and not context.blueprint then card.ability.extra.xmult = 1; card.ability.extra.gain = 0.1 end
    end
})

SMODS.Joker({
    key = "lakeside_pond",

    loc_txt = {
        name = "Lakeside Pond",
        text = {
            "All scored {C:mult}+Mult{} also gives {C:chips}+Chips{} of the",
            "same amount."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 1},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.joker_main and mult and mult > 0 then return {chips = mult} end
    end
})

SMODS.Joker({
    key = "laurel_branch",

    loc_txt = {
        name = "Laurel Branch",
        text = {
            "{C:attention}Retrigger{} all cards and jokers but",
            "{X:chips,C:white}X0.5{} Chips and {X:mult,C:white}X0.5{} Mult."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 1},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.repetition and (context.cardarea == G.play or context.cardarea == G.hand) then return {repetitions = 1, card = card} end
        if context.retrigger_joker_check and context.other_card ~= card then return {repetitions = 1, card = card} end
        if context.joker_main then return {x_chips = 0.5, x_mult = 0.5} end
    end
})

SMODS.Joker({
    key = "mini_theater",

    loc_txt = {
        name = "Mini Theater",
        text = {
            "Applies a random {C:attention}enhancement{},",
            "{C:green}seal{}, or {C:edition}edition{} if you only have",
            "{C:attention}1{} played card."
        }
    },

    atlas = "jokers",
    pos = {x = 0, y = 2},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.before and #G.play.cards == 1 and not context.blueprint then
            local c = G.play.cards[1]
            local roll = pseudorandom('mini_theater_effect')

            if roll < 1 / 3 then
                local enh = pseudorandom_element({'m_bonus', 'm_mult', 'm_wild', 'm_glass', 'm_steel', 'm_stone', 'm_gold', 'm_lucky'}, pseudoseed('minitheater'))
                c:set_ability(G.P_CENTERS[enh], nil, true)
            elseif roll < 2 / 3 then
                c:set_seal(pseudorandom_element({'Gold', 'Blue', 'Red', 'Purple'}, pseudoseed('mini_theater_seal')), true)
            else
                c:set_edition(pseudorandom_element({{foil = true}, {holo = true}, {polychrome = true}}, pseudoseed('mini_theater_edition_choice')), true)
            end

            return {message = "Enhanced!", colour = G.C.GREEN}
        end
    end
})

SMODS.Joker({
    key = "mooncake",

    loc_txt = {
        name = "Mooncake",
        text = {
            "Every played hand or discard gives {C:money}$1{}."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 2},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.after or context.pre_discard then FB.try_add_dollars(1); return {message = "$1"} end
    end
})

SMODS.Joker({
    key = "mortal_realm",

    loc_txt = {
        name = "Mortal Realm",
        text = {
            "{C:eternal}Eternal{} and takes up space",
            ""
        }
    },

    atlas = "jokers",
    pos = {x = 2, y = 2},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    eternal_compat = true,
    add_to_deck = function(self, card, from_debuff) card.ability.eternal = true end
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
    config = {extra = {chips = -100, hand = "Pair"}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.chips, card.ability.extra.hand}} end,
    calculate = function(self, card, context)
        if context.joker_main then return {chips = card.ability.extra.chips} end
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + (context.other_card:get_chip_bonus() or 0)
        end
        if context.repetition and context.cardarea == G.play and context.scoring_name == card.ability.extra.hand then return {repetitions = 1, card = card} end
        if (context.after or context.pre_discard) and not context.blueprint then card.ability.extra.hand = FB.random_poker_hand('paystub') end
    end
})

SMODS.Joker({
    key = "rat_poison",

    loc_txt = {
        name = "Rat Poison",
        text = {
            "All played number cards (not aces) are",
            "{C:red}destroyed{}. After 10 cards are {C:red}destroyed{},",
            "{C:red}self destructs{}."
        }
    },

    atlas = "jokers",
    pos = {x = 4, y = 2},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    config = {extra = {destroyed = 0}},
    loc_vars = function(self, info_queue, card) return {vars = {card.ability.extra.destroyed}} end,
    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play and FB.is_number(context.destroy_card) then
            card.ability.extra.destroyed = card.ability.extra.destroyed + 1
            if card.ability.extra.destroyed >= 10 then FB.destroy(card) end
            return {remove = true}
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
    cost = 3,

    discovered = true,
    unlocked = true,
    blueprint_compat = true,
    calculate = function(self, card, context) if context.joker_main then return {x_chips = 2} end end
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
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.scoring_name == 'Straight' then return {repetitions = 1, card = card} end
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
    config = {extra = {xmult = 1}},
    loc_vars = function(self, info_queue, card)
        card.ability.extra.xmult = 1 + 0.1 * FB.count_joker('teacup')
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if FB.has_joker('teapot') then
                card.ability.extra.xmult = 1 + 0.1 * FB.count_joker('teacup')
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
            "-2 antes sell everything instantly",
            "(including {C:eternal}eternal{}s) for 3x their sell",
            "price at end of round, and {C:red}self destructs{}."
        }
    },

    atlas = "jokers",
    pos = {x = 8, y = 2},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            G.GAME.fb_temporal_confinement_triggered = false
        end

        if context.end_of_round and not context.blueprint then
            if not G.GAME.fb_temporal_confinement_triggered then
                G.GAME.fb_temporal_confinement_triggered = true
                ease_ante(-2)
                for _, area in ipairs({G.jokers, G.consumeables}) do
                    if area and area.cards then
                        for i = #area.cards, 1, -1 do
                            local c = area.cards[i]
                            if c ~= card then
                                FB.try_add_dollars((c.sell_cost or 0) * 3)
                                FB.destroy(c)
                            end
                        end
                    end
                end
                return {message = "Confined!", colour = G.C.RED}
            end

            FB.destroy(card)
        end
    end
})

SMODS.Joker({
    key = "tile_cat",

    loc_txt = {
        name = "Tile Cat",
        text = {
            "{C:red}Debuffs{} a random played card, {C:chips}+233{} Chips.",
            "Has a {C:green}1 in 4{} chance of {C:red}debuffing{} itself",
            "every round."
        }
    },

    atlas = "jokers",
    pos = {x = 9, y = 2},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.before and G.play and #G.play.cards > 0 and not context.blueprint then pseudorandom_element(G.play.cards, pseudoseed('tilecat')).debuff = true end
        if context.joker_main then return {chips = 233} end
        if context.setting_blind and not context.blueprint and pseudorandom('tilecat_self') < 0.25 then card.debuff = true; return {message = "Debuffed!"} end
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
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.play and G.play.cards and #G.play.cards > 0 then
            card.ability.fb_target_card = pseudorandom_element(G.play.cards, pseudoseed('tulou'))
            return {message = "Marked", colour = G.C.RED, card = card}
        end
        if context.destroy_card and context.cardarea == G.play and context.destroy_card == card.ability.fb_target_card then
            card.ability.fb_target_card = nil
            return {remove = true}
        end
    end
})

SMODS.Joker({
    key = "underworld_cash",

    loc_txt = {
        name = "Underworld Cash",
        text = {
            "Gives you a random {C:money}$5{}-{C:money}$30{} when sold, and",
            "it costs {C:money}$5{} to buy in the shop."
        }
    },

    atlas = "jokers",
    pos = {x = 1, y = 3},

    rarity = 1,
    cost = 3,

    discovered = true,
    unlocked = true,
    calculate = function(self, card, context)
        if context.selling_self then local money = pseudorandom('underworld_cash', 5, 30); FB.try_add_dollars(money); return {message = "$" .. money} end
    end
})

