---@diagnostic disable: undefined-global
SMODS.Challenge({
    key = "eidolon",
    loc_txt = {
        name = "Eidolon Express"
    },

    jokers = {
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" },
        { id = FB.key("one_way_ticket_to_heaven"), edition = "negative" }
    },

    rules = {
        custom = {
            { id = "set_eternal_ante", value = 4 },
            { id = "set_joker_slots_ante", value = 4 },
            FB.challenge_rule("fb_difficulty_3")
        },
        modifiers = {
            { id = "joker_slots", value = 1 },
            { id = "dollars", value = 44 }
        }
    }
})