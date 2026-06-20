---@diagnostic disable: undefined-global

-- Fabulous Beasts - Talismans, clean trigger framework
-- Core idea:
--   Playing cards: Talismans are stored as a real custom Seal so Steamodded can
--   call Seal:calculate during card modifier scoring.
--
-- Important Steamodded contexts used:
--   context.main_scoring + context.cardarea == G.play  -> played card modifier effects
--   context.main_scoring + context.cardarea == G.hand  -> held card modifier effects
--   context.repetition + context.cardarea == G.play    -> played card retriggers
--   context.repetition + context.cardarea == G.hand    -> held card retriggers

FabulousBeasts = FabulousBeasts or {}
FB = FabulousBeasts
_G.FabulousBeasts = FB
_G.FB = FB

FB.TALISMAN_FIELD = FB.TALISMAN_FIELD or "fb_talisman"
FB.TALISMAN_SET = FB.TALISMAN_SET or "Talisman"
FB.TALISMAN_ATLAS_KEY = FB.TALISMAN_ATLAS_KEY or "talismans"
FB.TALISMAN_ATLAS_PATH = FB.TALISMAN_ATLAS_PATH or "talismans.png"
FB.TALISMAN_ATLAS_PX = FB.TALISMAN_ATLAS_PX or 71
FB.TALISMAN_ATLAS_PY = FB.TALISMAN_ATLAS_PY or 95

local function get_center(card) return card and card.config and card.config.center end
local function center_key(card) local c = get_center(card); return c and c.key end
local function center_set(card) local c = get_center(card); return c and c.set end
local function ensure_ability(card) if not card then return nil end; card.ability = card.ability or {}; return card.ability end

local function is_joker(card)
    local k = center_key(card)
    return center_set(card) == "Joker" or (card and card.ability and card.ability.set == "Joker") or (type(k) == "string" and k:sub(1, 2) == "j_")
end

local function is_playing_card(card)
    if not card or is_joker(card) then return false end
    local k = center_key(card)
    if type(k) == "string" and k:match("^c_fb_talisman_") then return false end
    if card.base or (card.config and card.config.card) then return true end
    return k == "c_base" or (type(k) == "string" and k:sub(1, 2) == "m_")
end

local function highlighted_target()
    local h = G and G.hand and G.hand.highlighted or nil
    if h and #h == 1 then return h[1] end
    return nil
end
FB.highlighted_talisman_target = highlighted_target

local function prob_normal()
    return (G and G.GAME and G.GAME.probabilities and G.GAME.probabilities.normal) or 1
end

local function roll(seed, odds)
    odds = math.max(1, tonumber(odds) or 1)
    if pseudorandom then return pseudorandom(seed or "fb_talisman_roll") < prob_normal() / odds end
    return math.random() < 1 / odds
end

local function add_status(card, text, colour)
    if card and card_eval_status_text then
        card_eval_status_text(card, "extra", nil, nil, nil, { message = text, colour = colour })
    end
end

-- Simple, readable descriptions: effect + stacked effect only.
FB.TALISMANS = {
    bonus = { name = "Bonus Talisman", pos = {x=0,y=0}, vanilla = "m_bonus", text = {
        "{C:chips}+30{} Chips when scored",
        "Stacked effects:",
        "{X:chips,C:white}X2{} Chips",
    }},
    mult = { name = "Mult Talisman", pos = {x=1,y=0}, vanilla = "m_mult", text = {
        "{C:mult}+4{} Mult when scored",
        "Stacked effects:",
        "{X:mult,C:white}X1.5{} Mult",
    }},
    wild = { name = "Wild Talisman", pos = {x=2,y=0}, vanilla = "m_wild", text = {
        "Counts as any {C:attention}suit{}",
        "Stacked effects:",
        "None?",
    }},
    glass = { name = "Glass Talisman", pos = {x=3,y=0}, vanilla = "m_glass", text = {
        "{X:mult,C:white}X2{} Mult when scored",
        "{C:green}1 in 4{} chance to burn away",
        "Stacked effects:",
        "{X:mult,C:white}X5{} Mult instead",
        "{C:green}1 in 3{} chance to burn away",
    }},
    steel = { name = "Steel Talisman", pos = {x=4,y=0}, vanilla = "m_steel", text = {
        "{X:mult,C:white}X1.5{} Mult while held",
        "Stacked effects:",
        "{X:mult,C:white}X1.5{} Mult when scored",
    }},
    stone = { name = "Stone Talisman", pos = {x=0,y=1}, vanilla = "m_stone", text = {
        "{C:chips}+50{} Chips when scored",
        "Stacked effects:",
        "{C:mult}+50{} Mult",
    }},
    gold = { name = "Gold Talisman", pos = {x=1,y=1}, vanilla = "m_gold", text = {
        "Earn {C:money}$3{} while held",
        "Stacked effects:",
        "Earn {C:money}$3{} when scored",
    }},
    lucky = { name = "Lucky Talisman", pos = {x=2,y=1}, vanilla = "m_lucky", text = {
        "{C:green}1 in 5{} chance for {C:mult}+20{} Mult",
        "{C:green}1 in 15{} chance for {C:money}$20{}",
        " ",
        "Stacked effects:",
        "{C:green}1 in 2{} chance for {C:mult}+20{} Mult",
        "{C:green}1 in 5{} chance for {C:money}$20{}",
        "{C:green}1 in 10{} chance for {C:attention}1{} retrigger {C:inactive}(limit 1){}",
    }},
}
FB.TALISMAN_ORDER = {"bonus","mult","wild","glass","steel","stone","gold","lucky"}

FB.TALISMAN_SEALS = FB.TALISMAN_SEALS or {
    red = { name = "Red", text = "Retriggers once" },
    blue = { name = "Blue", text = "Blue-seal style effect" },
    purple = { name = "Purple", text = "Purple-seal style effect" },
    gold = { name = "Gold", text = "Earns {C:money}$3{}" },
}
FB.TALISMAN_EDITIONS = FB.TALISMAN_EDITIONS or {
    foil = { name = "Foil", text = "{C:chips}X2{} Chips" },
    holo = { name = "Holographic", text = "{X:mult,C:white}X2.25{} Mult" },
    polychrome = { name = "Polychrome", text = "{X:dark_edition,C:white}^1.25{} Mult" },
    negative = { name = "Negative", text = "{C:dark_edition}+1{} slot" },
    refined = { name = "Refined", text = "Does nothing" },
}

function FB.talisman_plain_key(key)
    if not key then return nil end
    key = tostring(key)
    key = key:gsub("^c_fb_talisman_", "")
    key = key:gsub("^fb_talisman_", "")
    key = key:gsub("^talisman_", "")
    key = key:gsub("^c_", "")
    return FB.TALISMANS[key] and key or nil
end

function FB.talisman_center_key(key)
    key = FB.talisman_plain_key(key)
    return key and ("c_fb_talisman_" .. key) or nil
end

function FB.talisman_key_from_seal(seal)
    if type(seal) ~= "string" then return nil end
    return FB.talisman_plain_key(seal:match("^fb_talisman_(.+)$") or seal:match("^talisman_(.+)$"))
end

function FB.registered_talisman_seal_key(key)
    key = FB.talisman_plain_key(key)
    if not key then return nil end
    if G and G.P_SEALS then
        if G.P_SEALS["fb_talisman_" .. key] then return "fb_talisman_" .. key end
        if G.P_SEALS["talisman_" .. key] then return "talisman_" .. key end
    end
    -- Steamodded usually prefixes the object key with the mod id, so this is the
    -- most common runtime seal key for SMODS.Seal({ key = "talisman_x" }).
    return "fb_talisman_" .. key
end

function FB.get_talisman(card)
    if not card then return nil end
    local ab = ensure_ability(card)
    if ab and ab[FB.TALISMAN_FIELD] then return ab[FB.TALISMAN_FIELD] end
    -- Playing-card compatibility: if an old save only has the seal, rebuild ability data.
    local key = FB.talisman_key_from_seal(card.seal)
    if key and not is_joker(card) then
        ab[FB.TALISMAN_FIELD] = { key = key }
        return ab[FB.TALISMAN_FIELD]
    end
    return nil
end

function FB.has_talisman(card, key)
    local t = FB.get_talisman(card)
    if not t then return false end
    key = key and FB.talisman_plain_key(key) or nil
    return not key or t.key == key
end

function FB.is_talisman_consumable(card)
    local key = center_key(card)
    return (type(key) == "string" and key:match("^c_fb_talisman_"))
        or (card and card.ability and card.ability.set == FB.TALISMAN_SET)
        or center_set(card) == FB.TALISMAN_SET
end

function FB.attach_talisman_seal(card, key)
    key = FB.talisman_plain_key(key)
    if not (card and key) then return false end
    if is_joker(card) then return false end

    local seal = FB.registered_talisman_seal_key(key)
    if card.set_seal and seal then
        local ok = pcall(function() card:set_seal(seal, true, true) end)
        if ok and card.seal == seal then return true end
    end
    if G and G.P_SEALS and G.P_SEALS[seal] then card.seal = seal else card.seal = nil end
    return true
end

function FB.detach_talisman_seal(card)
    if card and FB.talisman_key_from_seal(card.seal) then card.seal = nil end
end

function FB.apply_talisman(card, key, args)
    key = FB.talisman_plain_key(key)
    if not (card and key and FB.TALISMANS[key]) then return false end
    if not is_playing_card(card) then return false end

    local ab = ensure_ability(card)
    if not ab then return false end

    card.seal = nil
    ab[FB.TALISMAN_FIELD] = {
        key = key,
        seal = args and args.seal or nil,
        edition = args and args.edition or nil,
        created_by = args and args.created_by or nil,
    }
    FB.attach_talisman_seal(card, key)
    add_status(card, FB.TALISMANS[key].name, G and G.C and G.C.ATTENTION or nil)
    return true
end

function FB.remove_talisman(card)
    if card and card.ability then card.ability[FB.TALISMAN_FIELD] = nil end
    FB.detach_talisman_seal(card)
end

function FB.get_consumable_talisman_data(card)
    if not card then return nil end
    local cfg = card.config and card.config.center and card.config.center.config or {}
    local ab = card.ability or {}
    return { key = ab.talisman_key or cfg.talisman_key, seal = ab.talisman_seal or cfg.talisman_seal, edition = ab.talisman_edition or cfg.talisman_edition }
end

function FB.apply_talisman_from_consumable(target, consumable)
    local data = FB.get_consumable_talisman_data(consumable)
    if not (target and data and data.key) then return false end
    return FB.apply_talisman(target, data.key, { seal = data.seal, edition = data.edition, created_by = center_key(consumable) })
end

function FB.set_talisman_seal(card, seal_key)
    if not (card and FB.TALISMAN_SEALS[seal_key]) then return false end
    local t = FB.get_talisman(card)
    if not t then return false end
    t.seal = seal_key
    return true
end

function FB.set_talisman_edition(card, edition_key)
    if not (card and FB.TALISMAN_EDITIONS[edition_key]) then return false end
    local t = FB.get_talisman(card)
    if not t then return false end
    t.edition = edition_key
    return true
end

function FB.set_consumable_talisman_seal(card, seal_key)
    if not (FB.is_talisman_consumable(card) and FB.TALISMAN_SEALS[seal_key]) then return false end
    card.ability = card.ability or {}
    card.ability.talisman_seal = seal_key
    return true
end

function FB.set_consumable_talisman_edition(card, edition_key)
    if not (FB.is_talisman_consumable(card) and FB.TALISMAN_EDITIONS[edition_key]) then return false end
    card.ability = card.ability or {}
    card.ability.talisman_edition = edition_key
    return true
end

function FB.is_bonus_card(card) return center_key(card) == "m_bonus" end
function FB.is_mult_card(card) return center_key(card) == "m_mult" end
function FB.is_glass_card(card) return center_key(card) == "m_glass" end
function FB.is_gold_card(card) return center_key(card) == "m_gold" end
function FB.is_steel_card(card) return center_key(card) == "m_steel" end
function FB.is_wild_card(card) return center_key(card) == "m_wild" end
function FB.is_stone_card(card) return center_key(card) == "m_stone" end
function FB.is_lucky_card(card) return center_key(card) == "m_lucky" end
function FB.has_wild_talisman(card) return FB.has_talisman(card, "wild") end
function FB.card_has_wild_talisman(card) return FB.has_wild_talisman(card) end
function FB.card_can_be_any_suit(card) return FB.has_wild_talisman(card) or FB.is_wild_card(card) end
function FB.card_can_be_any_rank(card) return FB.has_wild_talisman(card) and FB.is_wild_card(card) end


-- Stacked Talismans trigger when the card's real enhancement matches the
-- Talisman's vanilla enhancement. This was accidentally removed during the
-- Forced/Protection cleanup, but scored_effect()/held_effect() still need it.
function FB.is_stacked_talisman(card, key)
    key = FB.talisman_plain_key(key)
    local def = key and FB.TALISMANS and FB.TALISMANS[key]
    return def
        and def.vanilla
        and FB.has_talisman(card, key)
        and center_key(card) == def.vanilla
        or false
end
function FB.is_forced_card(card) return false end
function FB.is_protection_card(card) return false end
function FB.is_enslaved(card) return false end
function FB.is_wild_wild(card) return FB.card_can_be_any_rank(card) end
function FB.is_overprotected(card) return false end
function FB.can_modify_card(card) return true end
function FB.force_score_card(card) return false end
function FB.joker_slave_bypass(joker) return false end
function FB.card_can_be_any_suit_and_rank(card) return FB.card_can_be_any_rank(card) end
function FB.should_joker_force_trigger(joker) return false end

function FB.block_if_overprotected(card, message)
    return false
end

function FB.try_modify_card(card, fn, denied_message)
    if FB.block_if_overprotected(card, denied_message or "Access denied") then return false end
    if fn then fn(card) end
    return true
end

function FB.include_forced_scoring_cards(scoring_cards, played_cards)
    return scoring_cards or {}
end

function FB.extra_slots_from_talismans(area)
    local total = 0
    if not (area and area.cards) then return total end
    for _, c in ipairs(area.cards) do
        local t = FB.get_talisman(c)
        if t and t.edition == "negative" then total = total + 1 end
    end
    return total
end

local function add_modifiers(ret, t)
    if not (ret and t) then return ret end
    if t.edition == "foil" then ret.x_chips = (ret.x_chips or 1) * 2 end
    if t.edition == "holo" then ret.x_mult = (ret.x_mult or 1) * 2.25 end
    if t.edition == "polychrome" then ret.e_mult = (ret.e_mult or 1) * 1.25 end
    if t.seal == "red" then ret.repetitions = (ret.repetitions or 0) + 1 end
    if t.seal == "gold" then ret.dollars = (ret.dollars or 0) + 3 end
    return ret
end

local function strip_non_repetition(ret)
    if not ret then return nil end
    local reps = ret.repetitions
    if not reps then return nil end
    return { repetitions = reps }
end

local function scored_effect(card, context, mode)
    local t = FB.get_talisman(card)
    if not t then return nil end
    local key = t.key
    local stacked = FB.is_stacked_talisman(card, key)
    local ret = {}

    if key == "bonus" then
        if stacked then ret.x_chips = 2 else ret.chips = 30 end
    elseif key == "mult" then
        if stacked then ret.x_mult = 1.5 else ret.mult = 4 end
    elseif key == "glass" then
        ret.x_mult = stacked and 5 or 2
        if roll("fb_glass_talisman_burn", stacked and 3 or 4) then ret.fb_destroy_talisman = true end
    elseif key == "stone" then
        if stacked then ret.mult = 50 else ret.chips = 50 end
    elseif key == "lucky" then
        if roll("fb_lucky_talisman_mult", stacked and 2 or 5) then ret.mult = (ret.mult or 0) + 20 end
        if roll("fb_lucky_talisman_money", stacked and 5 or 15) then ret.dollars = (ret.dollars or 0) + 20 end
        if stacked and roll("fb_lucky_talisman_retrigger", 10) then ret.repetitions = 1 end
    elseif key == "gold" then
        -- Gold's normal effect is held-only; stacked Gold also pays when scored.
        if stacked then ret.dollars = 3 end
    elseif key == "steel" then
        -- Steel's normal effect is held-only; stacked Steel also gives scored XMult.
        if stacked then ret.x_mult = 1.5 end
    end

    add_modifiers(ret, t)
    return next(ret) and ret or nil
end

local function held_effect(card, context)
    local t = FB.get_talisman(card)
    if not t then return nil end
    local key = t.key
    local stacked = FB.is_stacked_talisman(card, key)
    local ret = {}

    if key == "steel" then
        if stacked then ret.repetitions = 1 else ret.x_mult = 1.5 end
    elseif key == "gold" then
        if stacked then ret.repetitions = 1 else ret.dollars = 3 end
    end

    -- Only repetition context should return repetitions. Main held scoring can
    -- return XMult/dollars. This avoids weird UI/selection retrigger leaks.
    if context and context.repetition then return strip_non_repetition(ret) end
    return next(ret) and ret or nil
end

function FB.schedule_talisman_burn(card)
    if not card then return end
    local ab = ensure_ability(card)
    if not ab or ab.fb_talisman_burn_queued then return end
    ab.fb_talisman_burn_queued = true
    local function burn_now()
        if card and card.ability then
            card.ability.fb_talisman_burn_queued = nil
            if FB.has_talisman(card) then
                FB.remove_talisman(card)
                add_status(card, "Talisman burned", G and G.C and G.C.RED or nil)
            end
        end
        return true
    end
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({ trigger = "after", delay = 0.15, func = burn_now }))
    else
        burn_now()
    end
end

function FB.card_calculate_talisman(card, context)
    if not (card and context and FB.has_talisman(card)) then return nil end
    local ab = ensure_ability(card)
    if ab.fb_talisman_calculating then return nil end
    ab.fb_talisman_calculating = true

    local ret = nil

    -- Playing-card modifier path only.
    if is_playing_card(card) then
        if context.main_scoring and context.cardarea == G.play then
            ret = scored_effect(card, context, "played")
        elseif context.main_scoring and context.cardarea == G.hand then
            ret = held_effect(card, context)
        elseif context.repetition and (context.cardarea == G.play or context.cardarea == G.hand) then
            local source = scored_effect(card, context, "repetition") or held_effect(card, context)
            ret = strip_non_repetition(source)
        end
    end

    if ret and ret.fb_destroy_talisman then
        ret.fb_destroy_talisman = nil
        FB.schedule_talisman_burn(card)
    end

    ab.fb_talisman_calculating = nil
    return ret
end

function FB.merge_talisman_calc(base, extra)
    if not extra then return base end
    if not base then return extra end
    for _, k in ipairs({"chips", "mult", "dollars", "repetitions"}) do
        if extra[k] ~= nil then base[k] = (base[k] or 0) + extra[k] end
    end
    for _, k in ipairs({"x_chips", "x_mult", "e_mult"}) do
        if extra[k] ~= nil then base[k] = (base[k] or 1) * extra[k] end
    end
    for k, v in pairs(extra) do if base[k] == nil then base[k] = v end end
    return base
end

function FB.install_talisman_joker_hook()
    -- Talismans are playing-card-only. Kept as a no-op for old load orders.
    FB.talisman_joker_hook_installed = true
end

function FB.install_talisman_playing_card_hooks()
    -- Intentional no-op. Playing cards use SMODS.Seal:calculate.
    -- Keeping this function avoids crashes from old files that call it.
    FB.talisman_playing_card_hooks_installed = true
end

function FB.apply_red_to_target(target)
    if FB.is_talisman_consumable(target) then return FB.set_consumable_talisman_seal(target, "red") end
    if FB.has_talisman(target) then return FB.set_talisman_seal(target, "red") end
    if target and target.set_seal then target:set_seal("Red", nil, true); return true end
    if target then target.seal = "Red"; return true end
    return false
end
function FB.apply_blue_to_target(target)
    if FB.is_talisman_consumable(target) then return FB.set_consumable_talisman_seal(target, "blue") end
    if FB.has_talisman(target) then return FB.set_talisman_seal(target, "blue") end
    if target and target.set_seal then target:set_seal("Blue", nil, true); return true end
    if target then target.seal = "Blue"; return true end
    return false
end
function FB.apply_purple_to_target(target)
    if FB.is_talisman_consumable(target) then return FB.set_consumable_talisman_seal(target, "purple") end
    if FB.has_talisman(target) then return FB.set_talisman_seal(target, "purple") end
    if target and target.set_seal then target:set_seal("Purple", nil, true); return true end
    if target then target.seal = "Purple"; return true end
    return false
end
function FB.apply_gold_to_target(target)
    if FB.is_talisman_consumable(target) then return FB.set_consumable_talisman_seal(target, "gold") end
    if FB.has_talisman(target) then return FB.set_talisman_seal(target, "gold") end
    if target and target.set_seal then target:set_seal("Gold", nil, true); return true end
    if target then target.seal = "Gold"; return true end
    return false
end

local function edition_table(edition_key)
    if edition_key == "foil" then return {foil = true} end
    if edition_key == "holo" or edition_key == "holographic" then return {holo = true} end
    if edition_key == "polychrome" then return {polychrome = true} end
    if edition_key == "negative" then return {negative = true} end
    if edition_key == "refined" then return {fb_refined = true} end
    return nil
end

function FB.apply_edition_to_target(target, edition_key)
    if FB.is_talisman_consumable(target) then return FB.set_consumable_talisman_edition(target, edition_key) end
    if FB.has_talisman(target) then return FB.set_talisman_edition(target, edition_key) end
    local ed = edition_table(edition_key)
    if target and ed and target.set_edition then target:set_edition(ed, true); return true end
    if target and ed then target.edition = ed; return true end
    return false
end

function FB.random_talisman_base_key(seed)
    local pool = {}
    for _, key in ipairs(FB.TALISMAN_ORDER or {}) do
        if FB.TALISMANS[key] then pool[#pool + 1] = key end
    end
    if #pool == 0 then return "bonus" end
    local safe_seed = (type(seed) == "string" or type(seed) == "number") and tostring(seed) or "fb_random_talisman"
    if pseudorandom_element and pseudoseed then return pseudorandom_element(pool, pseudoseed(safe_seed)) end
    return pool[math.random(#pool)]
end
function FB.random_talisman_key(seed) return FB.talisman_center_key(FB.random_talisman_base_key(seed)) end

local function talisman_loc_text(def)
    local out = {"Apply to {C:attention}1{} selected", "playing card"}
    for _, line in ipairs(def.text or {}) do out[#out + 1] = line end
    return out
end

function FB.talisman_display_name(talisman)
    if not talisman then return "Talisman" end
    local def = FB.TALISMANS[talisman.key]
    local name = def and def.name or "Talisman"
    if talisman.seal and FB.TALISMAN_SEALS[talisman.seal] then name = FB.TALISMAN_SEALS[talisman.seal].name .. " " .. name end
    if talisman.edition and FB.TALISMAN_EDITIONS[talisman.edition] then name = FB.TALISMAN_EDITIONS[talisman.edition].name .. " " .. name end
    return name
end

function FB.register_talisman_type()
    if SMODS and SMODS.Atlas and not FB.talisman_atlas_registered then
        FB.talisman_atlas_registered = true
        SMODS.Atlas({ key = FB.TALISMAN_ATLAS_KEY, path = FB.TALISMAN_ATLAS_PATH, px = FB.TALISMAN_ATLAS_PX, py = FB.TALISMAN_ATLAS_PY })
    end

    if SMODS and SMODS.Seal and not FB.talisman_seals_registered then
        FB.talisman_seals_registered = true
        for _, key in ipairs(FB.TALISMAN_ORDER or {}) do
            local def = FB.TALISMANS[key]
            if def and not def.framework_only then
                SMODS.Seal({
                    key = "talisman_" .. key,
                    atlas = FB.TALISMAN_ATLAS_KEY,
                    pos = def.pos or {x=0, y=0},
                    badge_colour = G and G.C and (G.C.IMPORTANT or G.C.ORANGE) or HEX("F2C14E"),
                    loc_txt = { name = def.name, label = def.name, text = def.text },
                    calculate = function(self, card, context)
                        return FB.card_calculate_talisman(card, context)
                    end,
                })
            end
        end
    end

    if SMODS and SMODS.ConsumableType and not FB.talisman_type_registered then
        FB.talisman_type_registered = true
        SMODS.ConsumableType({
            key = FB.TALISMAN_SET,
            primary_colour = G and G.C and (G.C.IMPORTANT or G.C.ORANGE) or HEX("F2C14E"),
            secondary_colour = G and G.C and (G.C.MONEY or G.C.YELLOW) or HEX("D89B2B"),
            collection_rows = {4, 4},
            shop_rate = FB.TALISMAN_SHOP_RATE or 0,
            loc_txt = { name = "Talismans", collection = "Talismans" },
        })
    end
end

local function register_one_talisman(key, def)
    if not (SMODS and SMODS.Consumable and key and def) then return end
    SMODS.Consumable({
        key = "fb_talisman_" .. key,
        set = FB.TALISMAN_SET,
        atlas = FB.TALISMAN_ATLAS_KEY,
        pos = def.pos or {x=0, y=0},
        discovered = true,
        unlocked = true,
        cost = def.cost or 3,
        config = { max_highlighted = 1, talisman_key = key },
        loc_txt = { name = def.name, label = def.name, text = talisman_loc_text(def) },
        loc_vars = function(self, info_queue, card) return { vars = {} } end,
        can_use = function(self, card)
            local target = highlighted_target()
            return target and is_playing_card(target) and not FB.is_talisman_consumable(target)
        end,
        use = function(self, card, area, copier)
            local target = highlighted_target()
            if target and is_playing_card(target) and not FB.is_talisman_consumable(target) then
                FB.apply_talisman(target, key, {
                    seal = card and card.ability and card.ability.talisman_seal or nil,
                    edition = card and card.ability and card.ability.talisman_edition or nil,
                })
            end
        end,
    })
end

function FB.register_talismans()
    FB.register_talisman_type()
    if not FB.talisman_consumables_registered then
        FB.talisman_consumables_registered = true
        for _, key in ipairs(FB.TALISMAN_ORDER or {}) do
            register_one_talisman(key, FB.TALISMANS[key])
        end
    end
    FB.install_talisman_joker_hook()
end

FB.install_talisman_joker_hook()

-- Wild Talisman needs to participate in suit checks, not scoring calculation.
-- Vanilla Wild is handled by Card:is_suit; the talisman version shadows that
-- behavior here so flush/suit checks can see it.
function FB.install_talisman_wild_suit_hook()
    if FB.talisman_wild_suit_hook_installed then return end
    if not (Card and Card.is_suit) then return end
    FB.talisman_wild_suit_hook_installed = true

    local vanilla_is_suit = Card.is_suit
    function Card:is_suit(suit, bypass_debuff, flush_calc, ...)
        local ret = vanilla_is_suit(self, suit, bypass_debuff, flush_calc, ...)
        if ret then return ret end

        if FB
            and FB.card_can_be_any_suit
            and FB.card_can_be_any_suit(self)
            and (bypass_debuff or not self.debuff) then
            return true
        end

        return false
    end
end

FB.install_talisman_wild_suit_hook()

return FB
