-- Switch Magic / Hyprland 0.56+ (Lua configuration).
-- Global-shortcut events stay ordered on one Wayland connection; no process
-- is spawned per Tab press. QML owns the frozen window list and selection.
local function emit(name)
    hl.dispatch(hl.dsp.global("switch-magic:" .. name))
end

local chords = {
    { "ALT + TAB", "workspace", "Switch Magic: current workspace" },
    { "ALT + SHIFT + TAB", "monitor", "Switch Magic: current monitor" },
    { "CTRL + ALT + TAB", "all", "Switch Magic: all workspaces" },
}
for _, chord in ipairs(chords) do
    hl.unbind(chord[1])
    hl.bind(chord[1], hl.dsp.global("switch-magic:" .. chord[2]), { description = chord[3], repeating = true })
end

-- Modifier-only release binds do not reliably fire after a chord. Observe
-- just Alt releases; defer one event-loop turn so physical key state settles.
-- This hook is owned by Hyprland's config and removed on config reload.
hl.on("input.keyboard.key", function(keycode, _, state)
    if state ~= 0 or (keycode ~= 64 and keycode ~= 108) then return end
    hl.timer(function()
        if not hl.is_key_down("Alt_L") and not hl.is_key_down("Alt_R") then
            emit("commit")
        end
    end, { timeout = 1, type = "oneshot" })
end)
