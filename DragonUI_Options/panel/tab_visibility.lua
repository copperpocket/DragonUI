--[[
================================================================================
DragonUI Options Panel - Visibility Tab
================================================================================
Centralized master control for frame visibility across all modules.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local L = addon.L
local LO = addon.LO
local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- Shared "Hidden + Show When" section for snake_case modules.
local function BuildVisibilitySection(scroll, opts)
    local section = C:AddSection(scroll, opts.label)
    C:AddDescription(section, opts.desc)

    C:AddToggle(section, {
        label = LO["Hidden"],
        desc = "Hide this frame by default. The conditions below reveal it when met.",
        dbPath = opts.base .. ".hidden",
        callback = function()
            opts.refresh()
            Panel:SelectTab("visibility")
        end,
    })

    local function visDisabled()
        return not C:GetDBValue(opts.base .. ".hidden")
    end

    C:AddHeading(section, LO["Show When"])

    C:AddToggle(section, { label = LO["Show on Hover"], dbPath = opts.base .. ".show_on_hover", disabled = visDisabled, callback = opts.refresh })
    C:AddToggle(section, { label = LO["Show in Combat"], dbPath = opts.base .. ".show_in_combat", disabled = visDisabled, callback = opts.refresh })
    C:AddToggle(section, { label = LO["Show with Target"], dbPath = opts.base .. ".show_with_target", disabled = visDisabled, callback = opts.refresh })
    C:AddToggle(section, { label = LO["Show When Health Is Not Full"], dbPath = opts.base .. ".show_on_health", disabled = visDisabled, callback = opts.refresh })
    C:AddToggle(section, { label = LO["Show When Power Is Not Full"], dbPath = opts.base .. ".show_on_power", disabled = visDisabled, callback = opts.refresh })

    if opts.extra then
        opts.extra(section, visDisabled)
    end

    C:AddSlider(section, {
        label = LO["Fade Delay"],
        desc = "Seconds to wait after the condition ends before the frame begins to fade out. 0 = fade immediately.",
        dbPath = opts.base .. ".fade_delay",
        min = 0, max = 20, step = 0.5, width = 200,
        disabled = visDisabled, callback = opts.refresh,
    })

    C:AddSlider(section, {
        label = LO["Fade Duration"],
        desc = "Time in seconds used to fade this frame in or out. Set to 0 for instant visibility changes.",
        dbPath = opts.base .. ".fade_duration",
        min = 0, max = 5, step = 0.1, width = 200,
        disabled = visDisabled, callback = opts.refresh,
    })

    C:AddSpacer(scroll)
    return section
end

-- Player frame: camelCase keys + advanced macro field, so bespoke section.
local function BuildPlayerVisibilitySection(scroll)
    local refreshPlayer = function()
        if addon.PlayerFrame and addon.PlayerFrame.RefreshPlayerFrame then
            addon.PlayerFrame.RefreshPlayerFrame()
        end
    end

    local section = C:AddSection(scroll, LO["Player Frame"])
    C:AddDescription(section,
        "The player frame is always visible by default, like the standard UI. Check Hidden to hide it and reveal it only under the conditions below. Uses alpha fading so it is safe in combat.")

    C:AddToggle(section, {
        label = LO["Hidden"],
        desc = "Hide the player frame by default. The conditions below reveal it when met.",
        dbPath = "unitframe.player.visibility.hideByDefault",
        callback = function()
            refreshPlayer()
            Panel:SelectTab("visibility")
        end,
    })

    local function visDisabled()
        return not C:GetDBValue("unitframe.player.visibility.hideByDefault")
    end

    C:AddHeading(section, LO["Show When"])

    C:AddToggle(section, { label = LO["In Combat"], dbPath = "unitframe.player.visibility.showInCombat", disabled = visDisabled, callback = refreshPlayer })
    C:AddToggle(section, { label = LO["Target Selected"], dbPath = "unitframe.player.visibility.showWithTarget", disabled = visDisabled, callback = refreshPlayer })
    C:AddToggle(section, { label = LO["Health Not Full"], desc = "Reveal the frame whenever current health is below maximum.", dbPath = "unitframe.player.visibility.showOnHealth", disabled = visDisabled, callback = refreshPlayer })
    C:AddToggle(section, { label = LO["Power Not Full"], desc = "Reveal the frame whenever current mana/power is below maximum.", dbPath = "unitframe.player.visibility.showOnMana", disabled = visDisabled, callback = refreshPlayer })
    C:AddToggle(section, { label = LO["Mouse Over"], desc = "Reveal the player frame while the mouse is over its position.", dbPath = "unitframe.player.visibility.showOnHover", disabled = visDisabled, callback = refreshPlayer })

    C:AddSlider(section, {
        label = LO["Fade Delay"],
        desc = "Seconds to wait after the condition ends before the frame begins to fade out. 0 = fade immediately.",
        dbPath = "unitframe.player.visibility.fadeDelay",
        min = 0, max = 20, step = 0.5, width = 200,
        disabled = visDisabled, callback = refreshPlayer,
    })

    C:AddSlider(section, {
        label = LO["Fade Duration"],
        desc = "Time in seconds used to fade the player frame in or out. Set to 0 for instant visibility changes.",
        dbPath = "unitframe.player.visibility.fadeDuration",
        min = 0, max = 5, step = 0.1, width = 200,     -- max 10 -> 5
        disabled = visDisabled, callback = refreshPlayer,
    })

    C:AddHeading(section, LO["Advanced"])

    C:AddEditBox(section, {
        label = LO["Custom Macro Condition"],
        desc = "Optional. Native macro conditional syntax, e.g. [combat][@target,exists][mod:shift]. If it resolves, the frame is shown. Leave blank to ignore.",
        dbPath = "unitframe.player.visibility.advanced",
        disabled = visDisabled, callback = refreshPlayer,
    })

    C:AddSpacer(scroll)
end

-- Action bars use flat <bar>_* keys with a shared fade duration.
local function BuildActionBarSection(scroll, barKey, label)
    local refreshBars = function()
        if addon.RefreshActionBarVisibility then addon.RefreshActionBarVisibility() end
    end

    local section = C:AddSection(scroll, label)

    C:AddToggle(section, {
        label = LO["Hidden"],
        desc = "Hide this bar by default. The conditions below reveal it when met.",
        dbPath = "actionbars." .. barKey .. "_hidden",
        callback = function()
            refreshBars()
            Panel:SelectTab("visibility")
        end,
    })

    local function visDisabled()
        return not C:GetDBValue("actionbars." .. barKey .. "_hidden")
    end

    C:AddHeading(section, LO["Show When"])

    C:AddToggle(section, { label = LO["Show on Hover"],  dbPath = "actionbars."..barKey.."_show_on_hover",   disabled = visDisabled, callback = refreshBars })
    C:AddToggle(section, { label = LO["Show in Combat"], dbPath = "actionbars."..barKey.."_show_in_combat",  disabled = visDisabled, callback = refreshBars })
    C:AddToggle(section, { label = LO["Show with Target"], dbPath = "actionbars."..barKey.."_show_with_target", disabled = visDisabled, callback = refreshBars })
    C:AddToggle(section, { label = LO["Show When Health Is Not Full"], dbPath = "actionbars."..barKey.."_show_on_health", disabled = visDisabled, callback = refreshBars })
    C:AddToggle(section, { label = LO["Show When Power Is Not Full"], dbPath = "actionbars."..barKey.."_show_on_power", disabled = visDisabled, callback = refreshBars })

    C:AddSlider(section, {
        label = LO["Fade Delay"],
        desc = "Seconds to wait after conditions end before the bar begins to fade out. Shared across all bars.",
        dbPath = "actionbars.visibility_fade_delay",
        min = 0, max = 20, step = 0.5, width = 200,
        disabled = visDisabled,
        callback = refreshBars,
    })

    C:AddSlider(section, {
        label = LO["Fade Duration"],
        desc = "Shared fade time for all action bars. Set to 0 for instant visibility changes.",
        dbPath = "actionbars.visibility_fade_duration",
        min = 0, max = 5, step = 0.1, width = 200,     -- max 3 -> 5
        disabled = visDisabled,
        callback = refreshBars,
    })

    C:AddSpacer(scroll)
end

-- Target frame: fades in/out with the target. It only has content when a
-- target exists, so it uses the existing fade system, not Hidden/conditions.
local function BuildTargetVisibilitySection(scroll)
    local refreshTarget = function()
        if addon.TargetFrame and addon.TargetFrame.RefreshTargetFrame then
            addon.TargetFrame.RefreshTargetFrame()
        end
    end

    local section = C:AddSection(scroll, LO["Target Frame"])
    C:AddDescription(section,
        "The target frame appears when you have a target and hides when you clear it. Enable fading to smoothly fade it in and out instead of instantly showing/hiding.")

    C:AddToggle(section, {
        label = LO["Fade In/Out"],
        desc = "Fade the target frame in when you select a target and out when you clear it.",
        dbPath = "unitframe.target.fade.enabled",
        callback = refreshTarget,
    })

    C:AddSlider(section, {
        label = LO["Fade Duration"],
        desc = "Time in seconds for the target frame to fade in or out.",
        dbPath = "unitframe.target.fade.duration",
        min = 0, max = 2, step = 0.05,
        width = 200,
        disabled = function()
            return not C:GetDBValue("unitframe.target.fade.enabled")
        end,
        callback = refreshTarget,
    })

    C:AddSpacer(scroll)
end


-- The ONE tab builder.
local function BuildVisibilityTab(scroll)
    C:AddLabel(scroll, "|cffFFD700Visibility|r", { color = C.Theme.textGold })
    C:AddDescription(scroll, "Master control for frame visibility. Check Hidden to hide a frame and reveal it only under the chosen conditions. Unchecked means the frame behaves like the standard UI.")
    C:AddSpacer(scroll)

    BuildPlayerVisibilitySection(scroll)
    BuildTargetVisibilitySection(scroll)

    -- Buffs
    BuildVisibilitySection(scroll, {
        label = "Buff Visibility",
        base  = "buffs.visibility",
        desc  = "Buffs are always visible by default. The collapse arrow works independently of this.",
        refresh = function()
            if addon.RefreshBuffVisibility then addon.RefreshBuffVisibility() end
        end,
    })

    -- Micro Menu
    BuildVisibilitySection(scroll, {
        label = "Micro Menu Visibility",
        base  = "micromenu.visibility",
        desc  = "The micro menu is always visible by default. Check Hidden to hide it and reveal it only under the conditions below. The bag bar is configured separately.",
        refresh = function()
            if addon.RefreshMicromenuVisibility then addon.RefreshMicromenuVisibility() end
        end,
    })

    -- Bag Bar
    BuildVisibilitySection(scroll, {
        label = "Bag Bar Visibility",
        base  = "bags.visibility",
        desc  = "The bag bar is always visible by default. The inventory and bank windows are not affected.",
        refresh = function()
            if addon.RefreshBagBarVisibility then addon.RefreshBagBarVisibility() end
        end,
    })

    -- Minimap
    BuildVisibilitySection(scroll, {
        label = "Minimap Visibility",
        base  = "minimap.visibility",
        desc  = "The minimap is always visible by default. Check Hidden to hide it and reveal it only under the conditions below.",
        refresh = function()
            if addon.RefreshMinimapVisibility then addon.RefreshMinimapVisibility() end
        end,
        extra = function(section, visDisabled)
            C:AddToggle(section, {
                label = LO["Map Only Fade"],
                desc = "Fade only the buttons, zone text, calendar, clock and tracking. The minimap and its blips stay fully visible.",
                dbPath = "minimap.visibility.map_only",
                disabled = visDisabled,
                callback = function()
                    if addon.RefreshMinimap then addon:RefreshMinimap() end
                end,
            })
        end,
    })

    BuildActionBarSection(scroll, "main",         "Main Action Bar")
    BuildActionBarSection(scroll, "bottom_left",  "Bottom Left Bar")
    BuildActionBarSection(scroll, "bottom_right", "Bottom Right Bar")
    BuildActionBarSection(scroll, "right",        "Right Bar")
    BuildActionBarSection(scroll, "left",         "Left Bar")


end


Panel:RegisterTab("visibility", "Visibility", BuildVisibilityTab, 1.5)
