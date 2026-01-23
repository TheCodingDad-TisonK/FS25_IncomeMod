-- =========================================================
-- FS25 Income Mod (version 1.1.0.0)
-- =========================================================
-- Hourly or daily income for players
-- =========================================================
-- Author: TisonK
-- =========================================================
-- COPYRIGHT NOTICE:
-- All rights reserved. Unauthorized redistribution, copying,
-- or claiming this code as your own is strictly prohibited.
-- Original author: TisonK
-- =========================================================
---@class SettingsUI
SettingsUI = {}
local SettingsUI_mt = Class(SettingsUI)

function SettingsUI.new(settings)
    local self = setmetatable({}, SettingsUI_mt)
    self.settings = settings
    self.injected = false
    return self
end

function SettingsUI:inject()
    if self.injected then 
        return 
    end
    
    local page = g_gui.screenControllers[InGameMenu].pageSettings
    if not page then
        Logging.error("im: Settings page not found - cannot inject settings!")
        return 
    end
    
    local layout = page.generalSettingsLayout
    if not layout then
        Logging.error("im: Settings layout not found!")
        return 
    end
    
    local section = UIHelper.createSection(layout, "im_section")
    if not section then
        Logging.error("im: Failed to create settings section!")
        return
    end
    
    local enabledOpt = UIHelper.createBinaryOption(
        layout,
        "im_enabled",
        "im_enabled",
        self.settings.enabled,
        function(val)
            self.settings.enabled = val
            self.settings:save()
            print("Income Mod: " .. (val and "Enabled" or "Disabled"))
        end
    )
    
    local debugOpt = UIHelper.createBinaryOption(
        layout,
        "im_debug",
        "im_debug",
        self.settings.debugMode,
        function(val)
            self.settings.debugMode = val
            self.settings:save()
            print("Income Mod: Debug mode " .. (val and "enabled" or "disabled"))
            -- Force update the UI state
            if self.debugOption and self.debugOption.setState then
                self.debugOption:setState(val and 2 or 1)
            end
        end
    )
    
    local payModeOptions = {
        getTextSafe("im_paymode_1"),
        getTextSafe("im_paymode_2")
    }
    
    local payModeOpt = UIHelper.createMultiOption(
        layout,
        "im_paymode",
        "im_paymode",
        payModeOptions,
        self.settings.payMode,
        function(val)
            self.settings.payMode = val
            self.settings:save()
            local modeName = val == 1 and "Hourly" or "Daily"
            print("Income Mod: Pay mode set to " .. modeName)
        end
    )
    
    local diffOptions = {
        getTextSafe("im_diff_1"),
        getTextSafe("im_diff_2"),
        getTextSafe("im_diff_3")
    }
    
    local diffOpt = UIHelper.createMultiOption(
        layout,
        "im_diff",
        "im_difficulty",
        diffOptions,
        self.settings.difficulty,
        function(val)
            self.settings.difficulty = val
            self.settings:save()
            print("Income Mod: Difficulty set to " .. self.settings:getDifficultyName())
        end
    )
    
    local notificationsOpt = UIHelper.createBinaryOption(
        layout,
        "im_notifications",
        "im_notifications",
        self.settings.showNotifications,
        function(val)
            self.settings.showNotifications = val
            self.settings:save()
            print("Income Mod: Notifications " .. (val and "enabled" or "disabled"))
            -- Force update the UI state
            if self.notificationsOption and self.notificationsOption.setState then
                self.notificationsOption:setState(val and 2 or 1)
            end
        end
    )
    
    self.enabledOption = enabledOpt
    self.debugOption = debugOpt
    self.payModeOption = payModeOpt
    self.difficultyOption = diffOpt
    self.notificationsOption = notificationsOpt
    
    self.injected = true
    layout:invalidateLayout()
    
    print("Income Mod: Settings UI injected successfully")
end


function getTextSafe(key)
    local text = g_i18n:getText(key)
    if text == nil or text == "" then
        return key
    end
    return text
end

function SettingsUI:refreshUI()
    if not self.injected then
        return
    end
    
    if self.enabledOption and self.enabledOption.setIsChecked then
        self.enabledOption:setIsChecked(self.settings.enabled)
    elseif self.enabledOption and self.enabledOption.setState then
        self.enabledOption:setState(self.settings.enabled and 2 or 1)
    end
    
    if self.debugOption and self.debugOption.setIsChecked then
        self.debugOption:setIsChecked(self.settings.debugMode)
    elseif self.debugOption and self.debugOption.setState then
        self.debugOption:setState(self.settings.debugMode and 2 or 1)
    end
    
    if self.payModeOption and self.payModeOption.setState then
        self.payModeOption:setState(self.settings.payMode)
    end
    
    if self.difficultyOption and self.difficultyOption.setState then
        self.difficultyOption:setState(self.settings.difficulty)
    end
    
    if self.notificationsOption and self.notificationsOption.setIsChecked then
        self.notificationsOption:setIsChecked(self.settings.showNotifications)
    elseif self.notificationsOption and self.notificationsOption.setState then
        self.notificationsOption:setState(self.settings.showNotifications and 2 or 1)
    end
    
    print("Income Mod: UI refreshed")
end

function SettingsUI:ensureResetButton(settingsFrame)
    if not settingsFrame or not settingsFrame.menuButtonInfo then
        print("im: ensureResetButton - settingsFrame invalid")
        return
    end
    
    if not self._resetButton then
        self._resetButton = {
            inputAction = InputAction.MENU_EXTRA_1, -- X
            text = g_i18n:getText("im_reset") or "Reset Settings",
            callback = function()
                print("im: Reset button clicked!")
                if g_IncomeManager and g_IncomeManager.settings then
                    g_IncomeManager.settings:resetToDefaults()
                    if g_IncomeManager.settingsUI then
                        g_IncomeManager.settingsUI:refreshUI()
                    end
                end
            end,
            showWhenPaused = true
        }
    end
    
    for _, btn in ipairs(settingsFrame.menuButtonInfo) do
        if btn == self._resetButton then
            print("im: Reset button already in menuButtonInfo")
            return
        end
    end
    
    table.insert(settingsFrame.menuButtonInfo, self._resetButton)
    settingsFrame:setMenuButtonInfoDirty()
    print("im: Reset button added to footer! (X key)")
end
