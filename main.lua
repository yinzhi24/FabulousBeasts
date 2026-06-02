---@diagnostic disable: undefined-global

--- STEAMODDED HEADER
--- MOD_NAME: Fabulous Beasts
--- MOD_ID: fabulousbeasts
--- MOD_AUTHOR: Zinaida
--- MOD_DESCRIPTION: Chinese mythology and RPG-inspired Balatro expansion.
--- PREFIX: fb
----------------------------------------------

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

assert(SMODS.load_file("util/helpers.lua"))()

assert(SMODS.load_file("jokers/common.lua"))()
assert(SMODS.load_file("jokers/uncommon.lua"))()
assert(SMODS.load_file("jokers/rare.lua"))()
assert(SMODS.load_file("jokers/legendary.lua"))()
assert(SMODS.load_file("jokers/higher.lua"))()

assert(SMODS.load_file("blinds/blinds.lua"))()

assert(SMODS.load_file("vouchers/vouchers.lua"))()
assert(SMODS.load_file("boosters/boosters.lua"))()

assert(SMODS.load_file("challenges/unlucky.lua"))()
assert(SMODS.load_file("challenges/growing_up_together.lua"))()
assert(SMODS.load_file("challenges/eidolon.lua"))()
assert(SMODS.load_file("challenges/nsfw.lua"))()
assert(SMODS.load_file("challenges/picnic_day.lua"))()