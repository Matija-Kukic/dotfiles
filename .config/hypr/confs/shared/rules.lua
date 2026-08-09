-- rules.conf translation: window + layer rules

-- Window rules
-- suppress-maximize-events: suppress_event = "maximize" is a legacy
-- hyprlang-only property with no Lua equivalent in Hyprland 0.57+. Kept as reference.
-- hl.window_rule({
--     name = "suppress-maximize-events",
--     match = { class = ".*" },
-- })

-- Caelestia shell layers (R4): no open/close animations on the static surfaces.
-- (blur + ignore_alpha on caelestia-drawers are applied dynamically by the
-- shell itself — services/Colours.qml reloadHyprRules)
hl.layer_rule({
    match = { namespace = "caelestia-background" },
    no_anim = true
})
hl.layer_rule({
    match = { namespace = "caelestia-border-exclusion" },
    no_anim = true
})
