---@diagnostic disable: undefined-global

--- STEAMODDED HEADER
--- MOD_NAME: Fabulous Beasts
--- MOD_ID: fabulousbeasts
--- MOD_AUTHOR: Zinaida
--- MOD_DESCRIPTION: Chinese mythology and RPG-inspired Balatro expansion.
--- PREFIX: fb
----------------------------------------------

FB = FB or {}

SMODS.Atlas({
    key = "modicon",
    path = "modicon.png",
    px = 34,
    py = 34
})

SMODS.Atlas({
    key = "jokers",
    path = "Jokers.png",
    px = 71,
    py = 95
})

assert(SMODS.load_file("config.lua"))()

assert(SMODS.load_file("util/helpers.lua"))()
assert(SMODS.load_file("util/hidden_synergies.lua"))()
assert(SMODS.load_file("util/baize.lua"))()
assert(SMODS.load_file("challenges/challenge_rules.lua"))()

assert(SMODS.load_file("jokers/common.lua"))()
assert(SMODS.load_file("jokers/uncommon.lua"))()
assert(SMODS.load_file("jokers/rare.lua"))()
assert(SMODS.load_file("jokers/legendary.lua"))()
assert(SMODS.load_file("jokers/higher.lua"))()

assert(SMODS.load_file("decks_sleeves/decks_sleeves.lua"))()

assert(SMODS.load_file("blinds/blinds.lua"))()

assert(SMODS.load_file("vouchers/vouchers.lua"))()
assert(SMODS.load_file("boosters/boosters.lua"))()

assert(SMODS.load_file("challenges/unlucky.lua"))()
assert(SMODS.load_file("challenges/growing_up_together.lua"))()
assert(SMODS.load_file("challenges/eidolon.lua"))()
assert(SMODS.load_file("challenges/nsfw.lua"))()
assert(SMODS.load_file("challenges/picnic_day.lua"))()
assert(SMODS.load_file("challenges/cycles.lua"))()
assert(SMODS.load_file("challenges/cant_let_go.lua"))()
assert(SMODS.load_file("challenges/keeping_spirits_high.lua"))()
assert(SMODS.load_file("challenges/aleph_0.lua"))()
assert(SMODS.load_file("challenges/angels.lua"))()
assert(SMODS.load_file("challenges/base_after_base.lua"))()
assert(SMODS.load_file("challenges/little_one.lua"))()
assert(SMODS.load_file("challenges/little_two.lua"))()
assert(SMODS.load_file("challenges/little_three.lua"))()
assert(SMODS.load_file("challenges/out_of_the_spotlight.lua"))()
assert(SMODS.load_file("challenges/ascension_to_heaven.lua"))()



-- dev username for dev mode: Zinaidev0.2.0-alpha-06BCF5-FF6565-1B