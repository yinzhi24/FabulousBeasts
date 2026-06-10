---@diagnostic disable: undefined-global

FB = FB or {}

SMODS.Atlas {
    key = "backs",
    path = "backs.png",
    px = 71,
    py = 95
}

SMODS.Back {
    key = "mahjong",
    loc_txt = {
        name = "Mahjong Deck",
        text = {
            "Start with",
            "{C:attention}Mahjong Table{}"
        }
    },
    atlas = "backs",
    pos = { x = 5, y = 2 },
    unlocked = true,
    discovered = true,

    apply = function(self)
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.1,
            func = function()
                SMODS.add_card {
                    key = "j_fb_mahjong_table",
                    area = G.jokers
                }
                return true
            end
        }))
    end
}

function FB.mahjong_random_enhance_faces_and_aces()
    if not G.playing_cards then return end

    local enhancements = {
        "m_bonus", "m_mult", "m_wild", "m_glass",
        "m_steel", "m_gold", "m_lucky"
    }

    for _, card in ipairs(G.playing_cards) do
        local id = card:get_id()
        if id == 14 or id == 11 or id == 12 or id == 13 then
            local enhancement = pseudorandom_element(
                enhancements,
                pseudoseed("fb_mahjong_enhance")
            )
            card:set_ability(G.P_CENTERS[enhancement], nil, true)
        end
    end
end

if CardSleeves then
    SMODS.Atlas {
        key = "sleeves",
        path = "sleeves.png",
        px = 73,
        py = 95
    }

    G.localization.descriptions.Sleeve = G.localization.descriptions.Sleeve or {}

    G.localization.descriptions.Sleeve.sleeve_fb_mahjong_alt = {
        name = "Mahjong Sleeve",
        text = {
            "{C:attention}Aces{} and {C:attention}face cards{}",
            "gain random {C:dark_edition}enhancements{}",
            "except {C:attention}stone{}"
        }
    }

    CardSleeves.Sleeve {
        key = "mahjong",
        name = "Mahjong Sleeve",
        pos = { x = 1, y = 3 },
        atlas = "sleeves",
        unlocked = true,
        discovered = true,
        config = {},

        loc_txt = {
            name = "Mahjong Sleeve",
            text = {
                "Start with",
                "{C:attention}Mahjong Table{}"
            }
        },

        loc_vars = function(self)
            if self.get_current_deck_key
            and self.get_current_deck_key() == "b_fb_mahjong" then
                return { key = "sleeve_fb_mahjong_alt" }
            end

            return { key = "sleeve_fb_mahjong" }
        end,

        apply = function(self, sleeve)
            CardSleeves.Sleeve.apply(self)

            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.1,
                func = function()
                    if self.get_current_deck_key
                    and self.get_current_deck_key() == "b_fb_mahjong" then
                        FB.mahjong_random_enhance_faces_and_aces()
                    end

                    return true
                end
            }))
        end
    }
end