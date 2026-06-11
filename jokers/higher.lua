---@diagnostic disable: undefined-global
-- Fabulous Beasts: custom rarities and higher-tier Jokers
SMODS.Rarity({
    key = "exotic",
    loc_txt = {
        name = "Exotic"
    },
    badge_colour = HEX("4795A6"),
    default_weight = 0,
    pools = {
        Joker = true
    }
})

SMODS.Rarity({
    key = "divine",
    loc_txt = {
        name = "Divine"
    },
    badge_colour = HEX("E0CB1B"),
    default_weight = 0,
    pools = {
        Joker = true
    }
})

-- Divine secret-unlock helpers. These keep Divine Jokers out of normal pools,
-- but allow catastrophic transforms to create/unlock them reliably.
FB.divine_unlock_center = FB.divine_unlock_center or function(key)
    local clean = FB.clean_joker_key and FB.clean_joker_key(key) or tostring(key or "")
    local full = clean:find("^j_") and clean or ("j_fb_" .. clean)
    local center = G and G.P_CENTERS and G.P_CENTERS[full]
    if center then
        center.unlocked = true
        center.discovered = true
        if unlock_card then
            pcall(unlock_card, center)
        end
    end
    if G and G.GAME then
        G.GAME.fb_unlocked_divines = G.GAME.fb_unlocked_divines or {}
        G.GAME.fb_unlocked_divines[clean:gsub("^j_fb_", "")] = true
    end
end

FB.divine_transform_card = FB.divine_transform_card or function(card, target_key, context)
    if not card then return false end
    local clean = FB.clean_joker_key and FB.clean_joker_key(target_key) or tostring(target_key or "")
    local full = clean:find("^j_") and clean or ("j_fb_" .. clean)
    local center = G and G.P_CENTERS and G.P_CENTERS[full]
    if not center then return false end

    if card.ability then
        if card.ability.fb_divine_transforming_to == clean then return true end
        card.ability.fb_divine_transforming_to = clean
    end

    FB.divine_unlock_center(clean)

    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                if card and card.set_ability then
                    card:set_ability(center, nil, true)
                    card.ability = card.ability or {}
                    card.ability.eternal = true
                    card.ability.perishable = false
                    card.ability.rental = false
                    card.debuff = false
                    if card.set_eternal then card:set_eternal(true) end
                    if card.juice_up then card:juice_up(0.8, 0.8) end
                end
                return true
            end
        }))
    else
        card:set_ability(center, nil, true)
    end

    return true
end

FB.divine_count_created = FB.divine_count_created or function(card, counter_key, amount, limit, target_key, context)
    if not (card and card.ability) then return false end
    amount = amount or 1
    limit = limit or 99
    counter_key = counter_key or "fb_divine_capacity"

    -- A setting_blind cycle is the "single round" window for these creation secrets.
    if context and context.setting_blind and not card.ability[counter_key .. "_active"] then
        card.ability[counter_key] = 0
        card.ability[counter_key .. "_active"] = true
    end

    card.ability[counter_key] = (card.ability[counter_key] or 0) + amount

    if card.ability[counter_key] >= limit then
        card.ability[counter_key .. "_active"] = nil
        return FB.divine_transform_card(card, target_key, context)
    end

    return false
end

FB.divine_reset_capacity_counter = FB.divine_reset_capacity_counter or function(card, counter_key)
    if card and card.ability then
        counter_key = counter_key or "fb_divine_capacity"
        card.ability[counter_key] = 0
        card.ability[counter_key .. "_active"] = nil
    end
end

FB.divine_additive_from_return = FB.divine_additive_from_return or function(ret)
    if type(ret) ~= "table" then return 0 end
    local total = 0
    local keys = {"chips", "h_chips", "chip_mod", "mult", "h_mult", "mult_mod"}
    for _, k in ipairs(keys) do
        local v = ret[k]
        if v ~= nil then
            local n = FB.num and FB.num(v, 0) or tonumber(v) or 0
            if n > 0 then total = total + n end
        end
    end
    return total
end

FB.divine_create_food_or_self = FB.divine_create_food_or_self or function(seed, self_odds_num, self_odds_den)
    self_odds_num = self_odds_num or 1
    self_odds_den = self_odds_den or 100

    local make_self = false
    if FB.roll then
        make_self = FB.roll(seed .. '_scp458_self', self_odds_num, self_odds_den)
    elseif pseudorandom then
        make_self = pseudorandom(seed .. '_scp458_self') < (self_odds_num / self_odds_den)
    end

    if make_self then
        if FB.create_joker then return FB.create_joker('scp_458') end
        if SMODS and SMODS.add_card then
            SMODS.add_card({ key = 'j_fb_scp_458', area = G.jokers })
            return true
        end
    end

    if FB.create_lunchbox_food then return FB.create_lunchbox_food(seed) end
    if FB.create_random_food_joker then return FB.create_random_food_joker(seed) end
    if FB.create_joker then return FB.create_joker('food') end
    if SMODS and SMODS.add_card then
        SMODS.add_card({ key = 'j_fb_food', area = G.jokers })
        return true
    end
    return false
end


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
    pos = {
        x = 0,
        y = 17
    },
    rarity = "fb_exotic",
    cost = 50,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            emult = 1,
            gain_round = 0.1,
            gain_boss = 0.15,
            gain_final = 0.2
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.emult,
                card.ability.extra.gain_round,
                card.ability.extra.gain_boss,
                card.ability.extra.gain_final
            }
        }
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                e_mult = card.ability.extra.emult
            }
        end
        if FB.main_end_of_round_once(card, context, 'fb_bixie_true_scaled') then
            -- Only one condition applies.Final boss > boss > normal round.
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
    pos = {
        x = 1,
        y = 17
    },
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
    key = "shi_qilin",
    loc_txt = {
        name = "Shi Qilin",
        text = {
            "At blind start, create a random",
            "{C:attention}Beast{} Joker"
        }
    },
    atlas = "jokers",
    pos = {
        x = 2,
        y = 17
    },
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
    loc_txt = {
        name = "Qilin Form Sibuxiang",
        text = {
            "{C:attention}Retrigger{} {C:blue}Tianlu{} and {C:red}Bixie{}",
            "once for each triggered card"
        }
    },
    atlas = "jokers",
    pos = {
        x = 3,
        y = 17
    },
    rarity = "fb_exotic",
    cost = 50,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
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
    pos = {
        x = 4,
        y = 17
    },
    rarity = "fb_exotic",
    cost = 50,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            echips = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.echips
            }
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local d = G.GAME.dollars or 0
            card.ability.extra.echips =(card.ability.extra.echips or 1) + d * 0.01
            FB.try_add_dollars(- d)
        end
        if FB.is_scoring_joker_main(context) then
            return {
                e_chips = card.ability.extra.echips
            }
        end
    end
})

SMODS.Joker({
    key = "happy_ending",
    loc_txt = {
        name = "Happy Ending",
        text = {
            "{C:dark_edition}You did it!{}",
            "{X:edition,C:chips}^^#3#{} Chips",
            "{X:dark_edition,C:mult}^^#4#{} Mult"
        }
    },
    atlas = "jokers",
    pos = {
        x = 0,
        y = 18
    },
    rarity = "fb_divine",
    cost = 999,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,
    config = {
        extra = {
            fb_loc_vars = {
                "1",
                "1.2",
                "2",
                "2"
            }
        }
    },
    loc_vars = function(self, info_queue, card)
        return FB.static_loc_vars(card)
    end,
    calculate = function(self, card, context)
        if FB.is_scoring_joker_main(context) then
            return {
                ee_chips = 2,
                ee_mult = 2
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
            "{C:chips}+999,999,999{} Chips {C:mult}+999,999,999{} Mult",
            "{X:chips,C:white}X999,999,999{} Chips {X:mult,C:white}X999,999,999{} Mult",
            "{X:purple,C:white}^999,999,999{} Chips {X:consumable,C:white}^999,999,999{} Mult",
            "{X:edition,C:chips}^^999,999,999{} Chips {X:dark_edition,C:mult}^^999,999,999{} Mult",
            "{X:edition,C:dark_edition}^^^999,999,999{} Chips {X:dark_edition,C:edition}^^^999,999,999{} Mult"
        }
    },
    atlas = "jokers",
    pos = {
        x = 1,
        y = 18
    },
    rarity = "fb_divine",
    cost = 999,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    discovered = true,
    unlocked = true,
    config = {
        extra = {
            chips = 999999999,
            mult = 999999999,
            x_chips = 999999999,
            x_mult = 999999999,
            e_chips = 999999999,
            e_mult = 999999999,
            ee_chips = 999999999,
            ee_mult = 999999999,
            eee_chips = 999999999,
            eee_mult = 999999999,
        }
    },
    add_to_deck = function(self, card, from_debuff)
        card.ability.eternal = true
        card.ability.perishable = false
        card.ability.rental = false
        card.debuff = false
        if card.set_eternal then
            card: set_eternal(true)
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
            for k,
            v in pairs(G.GAME.hands) do
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

SMODS.Joker({
    key = "scp_458",
    loc_txt = {
        name = "SCP-458",
        text = {
            "At blind start, create up to",
            "{C:attention}#1#{} random {C:attention}Food{} Jokers",
            "{C:attention}+#2#{} Joker slots",
            "{C:inactive}\"The perfect tool for the perfect party,",
            "{C:inactive}only if you can eat it all that is...\"{}"
        }
    },

    atlas = "jokers",
    pos = {
        x = 2,
        y = 18
    },

    rarity = "fb_divine",
    cost = 999,
    discovered = true,
    unlocked = true,
    blueprint_compat = false,

    config = {
        extra = {
            foods_per_round = 8,
            joker_slots = 99
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.foods_per_round or 8,
                card.ability.extra.joker_slots or 99
            }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        local slots = card.ability.extra.joker_slots or 99

        if FB.safe_change_joker_slots then
            FB.safe_change_joker_slots(slots)
        elseif G and G.jokers and G.jokers.config then
            G.jokers.config.card_limit = G.jokers.config.card_limit + slots
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        local slots = card.ability.extra.joker_slots or 99

        if FB.safe_change_joker_slots then
            FB.safe_change_joker_slots(-slots)
        elseif G and G.jokers and G.jokers.config then
            G.jokers.config.card_limit = G.jokers.config.card_limit - slots
        end
    end,

    calculate = function(self, card, context)
        if context.setting_blind
        and not context.blueprint
        and not card.ability.fb_scp_458_created_this_blind then
            card.ability.fb_scp_458_created_this_blind = true

            local made = 0
            local cap = card.ability.extra.foods_per_round or 8

            for i = 1, cap do
                if G.jokers
                and G.jokers.cards
                and G.jokers.config
                and #G.jokers.cards >= G.jokers.config.card_limit then
                    break
                end

                if FB.create_random_food_joker then
                    if FB.create_random_food_joker("scp_458_food_" .. tostring(i)) then
                        made = made + 1
                    end
                elseif SMODS and SMODS.add_card and G.P_CENTERS and G.P_CENTERS.j_fb_food then
                    SMODS.add_card({
                        key = "j_fb_food",
                        area = G.jokers
                    })
                    made = made + 1
                end
            end

            if made > 0 then
                return {
                    message = "+" .. tostring(made) .. " Food",
                    colour = G.C.GREEN,
                    card = card
                }
            end

            return {
                message = "Empty Box!",
                colour = G.C.RED,
                card = card
            }
        end

        if context.after and not context.blueprint then
            card.ability.fb_scp_458_created_this_blind = nil
        end
    end
})

SMODS.Joker({
    key = "centimoney",
    loc_txt = {
        name = "Centimoney",
        text = {
            "Whenever any card or Joker triggers,",
            "multiply your money by {C:money}#1#{}",
            "{C:inactive}If you have $0, gain $100 instead{}"
        }
    },
    atlas = "jokers",
    pos = { x = 3, y = 18 },
    rarity = "fb_divine",
    cost = 999,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    discovered = true,
    unlocked = true,
    config = {
        extra = {
            money_mult = 100
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money_mult or 100 } }
    end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.eternal = true
        card.ability.perishable = false
        card.ability.rental = false
        card.debuff = false
        if card.set_eternal then card:set_eternal(true) end
    end,
    calculate = function(self, card, context)
        if not context.blueprint and card.debuff then
            card.debuff = false
        end
        local triggered = context
            and not context.blueprint
            and not context.end_of_round
            and not context.setting_blind
            and not context.before
            and not context.after
            and not context.selling_card
            and not context.selling_self
            and not context.destroy_card
            and not context.remove_playing_cards
            and (
                (FB.is_scoring_individual and FB.is_scoring_individual(context) and context.other_card)
                or (context.post_trigger and context.other_card)
                or (FB.is_scoring_joker_main and FB.is_scoring_joker_main(context))
            )

        if triggered then
            local factor = card.ability.extra.money_mult or 100
            local dollars = math.max(0, FB.num(G.GAME and G.GAME.dollars, 0))
            local gain = dollars > 0 and (dollars * (factor - 1)) or factor
            FB.try_add_dollars(gain)
            return { message = "$X" .. factor, colour = G.C.MONEY, card = card }
        end
    end
})

