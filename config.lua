---@diagnostic disable: undefined-global

FabulousBeasts = FabulousBeasts or {}
FB = FabulousBeasts

FB.config = FB.config or {}

local mod_config = SMODS.current_mod.config or {}
SMODS.current_mod.config = mod_config

if mod_config.og_bilibili_colors == nil then
    mod_config.og_bilibili_colors = false
end

if mod_config.enable_japanese_mahjong_calls == nil then
    mod_config.enable_japanese_mahjong_calls = false
end

FB.config = mod_config

function FB.get_bilibili_pos()
    if FB.config and FB.config.og_bilibili_colors then
        return { x = 0, y = 14 } -- OG blue Bilibili sprite
    end

    return { x = 2, y = 12 } -- Modern pink Bilibili sprite
end

SMODS.current_mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            padding = 0.05,
            colour = G.C.CLEAR
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.15
                },
                nodes = {
                    create_toggle({
                        label = "Use OG Bilibili Colors (restart required)",
                        ref_table = FB.config,
                        ref_value = "og_bilibili_colors"
                    }),
                    create_toggle({
                        label = "Enable Japanese Mahjong Calls",
                        ref_table = FB.config,
                        ref_value = "enable_japanese_mahjong_calls"
                    })
                }
            }
        }
    }
end