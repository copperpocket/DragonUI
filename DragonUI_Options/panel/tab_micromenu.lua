--[[
================================================================================
DragonUI Options Panel - Micro Menu Tab
================================================================================
Micro menu, bags, XP/rep bars, additional bars.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local L = addon.L
local LO = addon.LO
local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- MICRO MENU TAB BUILDER
-- ============================================================================

local function BuildMicromenuTab(scroll)
    -- ====================================================================
    -- MICRO MENU
    -- ====================================================================
    local menu = C:AddSection(scroll, LO["Micro Menu"])

    C:AddToggle(menu, {
        label = LO["Grayscale Icons"],
        desc = LO["Use grayscale icons instead of colored icons."],
        dbPath = "micromenu.grayscale_icons",
        requiresReload = true,
    })

    -- Mode-aware scale
    local modeKey = function()
        return (C:GetDBValue("micromenu.grayscale_icons") and "grayscale" or "normal")
    end

    C:AddSlider(menu, {
        label = LO["Menu Scale"],
        getFunc = function()
            return C:GetDBValue("micromenu." .. modeKey() .. ".scale_menu")
        end,
        setFunc = function(val)
            C:SetDBValue("micromenu." .. modeKey() .. ".scale_menu", val)
            if addon.RefreshMicromenu then addon.RefreshMicromenu() end
        end,
        min = 0.5, max = 3.0, step = 0.01,
        width = 200,
    })

    C:AddSlider(menu, {
        label = LO["Icon Spacing"],
        getFunc = function()
            return C:GetDBValue("micromenu." .. modeKey() .. ".icon_spacing")
        end,
        setFunc = function(val)
            C:SetDBValue("micromenu." .. modeKey() .. ".icon_spacing", val)
            if addon.RefreshMicromenu then addon.RefreshMicromenu() end
        end,
        min = 5, max = 40, step = 1,
        width = 200,
    })

    C:AddToggle(menu, {
        label = LO["Hide on Vehicle"],
        desc = LO["Hide micromenu and bags while in a vehicle."],
        dbPath = "micromenu.hide_on_vehicle",
        callback = function()
            if addon.RefreshMicromenuVehicle then addon.RefreshMicromenuVehicle() end
            if addon.RefreshBagsVehicle then addon.RefreshBagsVehicle() end
        end,
    })

    C:AddToggle(menu, {
        label = LO["Show Latency Indicator"],
        desc = LO["Show a colored bar below the Help button indicating connection quality (green/yellow/red). Requires UI reload."],
        dbPath = "micromenu.show_latency_indicator",
        callback = function()
            StaticPopup_Show("DRAGONUI_RELOAD_UI")
        end,
    })

    -- ====================================================================
    -- MICRO MENU VISIBILITY
    -- ====================================================================

    local visibilitySection = C:AddSection(scroll, LO["Micro Menu Visibility"])

    C:AddDescription(
        visibilitySection,
        LO["Show the micro menu only when selected conditions are active. The bag bar is configured separately."]
    )

    local function RefreshMicroMenuVisibility()
        if addon.RefreshMicromenuVisibility then
            addon.RefreshMicromenuVisibility()
        end
    end

    C:AddToggle(visibilitySection, {
        label = LO["Show on Hover"],
        dbPath = "micromenu.visibility.show_on_hover",
        callback = RefreshMicroMenuVisibility,
    })

    C:AddToggle(visibilitySection, {
        label = LO["Show in Combat"],
        dbPath = "micromenu.visibility.show_in_combat",
        callback = RefreshMicroMenuVisibility,
    })

    C:AddToggle(visibilitySection, {
        label = LO["Show with Target"],
        dbPath = "micromenu.visibility.show_with_target",
        callback = RefreshMicroMenuVisibility,
    })

    C:AddToggle(visibilitySection, {
        label = LO["Show When Health Is Not Full"],
        dbPath = "micromenu.visibility.show_on_health",
        callback = RefreshMicroMenuVisibility,
    })

    C:AddToggle(visibilitySection, {
        label = LO["Show When Power Is Not Full"],
        dbPath = "micromenu.visibility.show_on_power",
        callback = RefreshMicroMenuVisibility,
    })

    C:AddSlider(visibilitySection, {
        label = LO["Fade Duration"],
        desc = LO["Time in seconds used to fade the micro menu in or out. Set to 0 for instant visibility changes."],
        dbPath = "micromenu.visibility.fade_duration",
        min = 0,
        max = 3,
        step = 0.05,
        width = 200,
        callback = RefreshMicroMenuVisibility,
    })


end

-- Register the tab
Panel:RegisterTab("micromenu", LO["Micro Menu"], BuildMicromenuTab, 9)
