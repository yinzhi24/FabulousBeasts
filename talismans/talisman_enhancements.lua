---@diagnostic disable: undefined-global

FabulousBeasts = FabulousBeasts or {}
FB = FabulousBeasts

-- Forced/Protection enhancements have been removed.
-- Kept as a compatibility no-op so older load orders that call this function do not crash.
function FB.register_talisman_enhancements()
    return nil
end

return FB
