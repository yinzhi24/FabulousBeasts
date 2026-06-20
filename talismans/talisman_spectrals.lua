---@diagnostic disable: undefined-global

FabulousBeasts = FabulousBeasts or {}
FB = FabulousBeasts

-- Jiangshi now lives in spectral.lua and applies a random Talisman to one selected playing card.
-- Kept as a compatibility no-op so older load orders that call this function do not double-register Jiangshi.
function FB.register_talisman_spectrals()
    return nil
end

return FB
