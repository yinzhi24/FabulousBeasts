local nsfw_cards = {}

for _, suit in ipairs({ "S", "H", "C", "D" }) do
    for _, rank in ipairs({ "A", "A", "K", "K", "Q", "J", "9", "7", "6", "6", "4", "2", "A" }) do
        nsfw_cards[#nsfw_cards + 1] = {
            s = suit,
            r = rank
        }
    end
end

SMODS.Challenge({
    key = "nsfw",
    loc_txt = {
        name = "Not Safe For Work"
    },

    jokers = {
        {
            id = FB.key("questionable_fanart"),
            eternal = true
        }
    },

    deck = {
        type = "Challenge Deck",
        cards = nsfw_cards
    },

    rules = {
        custom = {
            { id = "none" }
        },
        modifiers = {}
    }
})