--[[
================================================================================
DragonUI Options Panel - Chat Tab
================================================================================
Chat Mods options: editbox position, tab opacity, URL detection, chat copy.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local L = addon.L
local LO = addon.LO
local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- CHAT TAB BUILDER
-- ============================================================================

local function BuildChatTab(scroll)
    C:AddLabel(scroll, "|cffFFD700" .. LO["Chat Mods"] .. "|r", { color = C.Theme.textGold })
    C:AddDescription(scroll, LO["Enables or disables Chat Mods."])

    C:AddSpacer(scroll)

    -- ====================================================================
    -- ENABLE / DISABLE
    -- ====================================================================
    local generalSection = C:AddSection(scroll, LO["Chat Mods"])

    C:AddToggle(generalSection, {
        label = LO["Enable Chat Mods"],
        desc  = LO["Enables or disables Chat Mods."],
        getFunc  = function()
            return addon.db.profile.modules and addon.db.profile.modules.chatmods and addon.db.profile.modules.chatmods.enabled
        end,
        setFunc  = function(val)
            if not addon.db.profile.modules then addon.db.profile.modules = {} end
            if not addon.db.profile.modules.chatmods then addon.db.profile.modules.chatmods = {} end
            addon.db.profile.modules.chatmods.enabled = val
        end,
        requiresReload = true,
    })

    -- ====================================================================
    -- EDITBOX POSITION
    -- ====================================================================
    local editboxSection = C:AddSection(scroll, LO["Editbox Position"])

    C:AddDropdown(editboxSection, {
        label  = LO["Editbox Position"],
        desc   = LO["Choose where the chat editbox is positioned."],
        values = {
            top    = LO["Top"],
            bottom = LO["Bottom"],
            middle = LO["Middle"],
        },
        dbPath = "modules.chatmods.editbox",
        callback = function()
            if addon.ApplyEditBoxPosition then
                addon.ApplyEditBoxPosition()
            end
        end,
    })

    -- ====================================================================
    -- APPEARANCE
    -- ====================================================================
    local appearanceSection = C:AddSection(scroll, LO["Appearance"])

    C:AddDropdown(appearanceSection, {
        label  = LO["Chat Style"],
        desc   = LO["Visual style for the chat frame background."],
        values = {
            none     = LO["None"],
            dark     = LO["Dark"],
            dragon   = LO["DragonUI Style"],
            midnight = LO["Midnight"],
        },
        dbPath = "modules.chatmods.chatStyle",
        callback = function()
            if addon.ApplyChatStyle then
                addon.ApplyChatStyle()
            end
        end,
    })

    C:AddDropdown(appearanceSection, {
        label  = LO["Editbox Style"],
        desc   = LO["Visual style for the chat input box background."],
        values = {
            none     = LO["None"],
            dark     = LO["Dark"],
            dragon   = LO["DragonUI Style"],
            midnight = LO["Midnight"],
        },
        dbPath = "modules.chatmods.editboxStyle",
        callback = function()
            if addon.ApplyEditboxStyle then
                addon.ApplyEditboxStyle()
            end
        end,
    })

    C:AddSlider(appearanceSection, {
        label   = LO["Tab & Button Fade"],
        desc    = LO["How visible chat tabs are when not hovered. 0 = fully hidden, 1 = fully visible."],
        min     = 0, max = 1, step = 0.05,
        dbPath  = "modules.chatmods.tabIdleAlpha",
        callback = function()
            if addon.RefreshChatFadeState then
                addon.RefreshChatFadeState()
            else
                local cfg = addon.db.profile.modules and addon.db.profile.modules.chatmods
                local alpha = (cfg and cfg.tabIdleAlpha ~= nil) and cfg.tabIdleAlpha or 0
                for i = 1, 10 do
                    local tab = _G["ChatFrame" .. i .. "Tab"]
                    if tab then tab.noMouseAlpha = alpha end
                end
            end
        end,
    })

    C:AddSlider(appearanceSection, {
        label   = LO["Chat Style Opacity"],
        desc    = LO["Minimum opacity of the custom chat background. At 0 it fades with tabs; above 0 it stays partially visible when idle."],
        min     = 0, max = 1, step = 0.05,
        dbPath  = "modules.chatmods.chatBgIdleAlpha",
        callback = function()
            if addon.RefreshChatFadeState then
                addon.RefreshChatFadeState()
            end
        end,
    })

    C:AddSlider(appearanceSection, {
        label   = LO["Text Box Min Opacity"],
        desc    = LO["Minimum opacity of the text input box when idle. At 0 it fades with tabs; above 0 it stays partially visible."],
        min     = 0, max = 1, step = 0.05,
        dbPath  = "modules.chatmods.editboxIdleAlpha",
        callback = function()
            if addon.RefreshChatFadeState then
                addon.RefreshChatFadeState()
            end
        end,
    })

    -- ====================================================================
    -- CHAT VISIBILITY
    -- ====================================================================

    C:AddSpacer(scroll)

    local visibilitySection = C:AddSection(scroll, LO["Chat Visibility"])

    C:AddDescription(
        visibilitySection,
        LO["Show the complete chat area only when selected conditions are active. Existing tab and button fading remains available."]
    )

    local function RefreshChatVisibility()
        if addon.RefreshChatVisibility then
            addon.RefreshChatVisibility()
        end
    end

    C:AddToggle(visibilitySection, {
        label = LO["Show on Hover"],
        desc = LO["Reveal the chat area while the mouse is over a chat frame, tab, button, or edit box."],
        dbPath = "modules.chatmods.visibility.show_on_hover",
        callback = RefreshChatVisibility,
    })

    C:AddToggle(visibilitySection, {
        label = LO["Show in Combat"],
        desc = LO["Reveal the chat area while in combat."],
        dbPath = "modules.chatmods.visibility.show_in_combat",
        callback = RefreshChatVisibility,
    })

    C:AddToggle(visibilitySection, {
        label = LO["Show with Target"],
        desc = LO["Reveal the chat area while a target exists."],
        dbPath = "modules.chatmods.visibility.show_with_target",
        callback = RefreshChatVisibility,
    })

    C:AddToggle(visibilitySection, {
        label = LO["Show When Health Is Not Full"],
        desc = LO["Reveal the chat area while your health is below maximum."],
        dbPath = "modules.chatmods.visibility.show_on_health",
        callback = RefreshChatVisibility,
    })

    C:AddToggle(visibilitySection, {
        label = LO["Show When Power Is Not Full"],
        desc = LO["Reveal the chat area while your mana or power is below maximum."],
        dbPath = "modules.chatmods.visibility.show_on_power",
        callback = RefreshChatVisibility,
    })

    C:AddSlider(visibilitySection, {
        label = LO["Chat Fade Duration"],
        desc = LO["Time in seconds used to fade the complete chat area in or out. Set to 0 for instant visibility changes."],
        dbPath = "modules.chatmods.visibility.fade_duration",
        min = 0,
        max = 3,
        step = 0.05,
        width = 200,
        callback = RefreshChatVisibility,
    })


end

-- Register the tab (order 14, after Bags)
Panel:RegisterTab("chat", LO["Chat"], BuildChatTab, 14)
