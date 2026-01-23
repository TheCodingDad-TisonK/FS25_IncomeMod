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
---@class SettingsGUI

SettingsGUI = {}
local SettingsGUI_mt = Class(SettingsGUI)

function SettingsGUI.new()
    local self = setmetatable({}, SettingsGUI_mt)
    return self
end

function SettingsGUI:registerConsoleCommands()
    addConsoleCommand("IncomeSetDifficulty", "Set difficulty (1=Easy, 2=Normal, 3=Hard)", "consoleCommandSetDifficulty", self)
    
    addConsoleCommand("IncomeEnable", "Enable Income Mod", "consoleCommandIncomeEnable", self)
    addConsoleCommand("IncomeDisable", "Disable Income Mod", "consoleCommandIncomeDisable", self)
    addConsoleCommand("IncomeSetPayMode", "Set pay mode (1=Hourly, 2=Daily)", "consoleCommandSetPayMode", self)
    addConsoleCommand("IncomeSetNotifications", "Enable/disable notifications (true/false)", "consoleCommandSetNotifications", self)
    addConsoleCommand("IncomeSetCustomAmount", "Set custom payment amount (0 = use difficulty)", "consoleCommandSetCustomAmount", self)
    addConsoleCommand("IncomeTestPayment", "Test payment system", "consoleCommandTestPayment", self)
    
    addConsoleCommand("IncomeShowSettings", "Show current settings", "consoleCommandShowSettings", self)
    
    addConsoleCommand("IncomeResetSettings", "Reset all settings to defaults", "consoleCommandResetSettings", self)
    
    addConsoleCommand("income", "Show all income commands", "consoleCommandHelp", self)
    
    Logging.info("Income Mod console commands registered")
end

function SettingsGUI:consoleCommandHelp()
    print("=== Income Mod Console Commands ===")
    print("income - Show this help")
    print("IncomeEnable/Disable - Toggle mod")
    print("IncomeSetDifficulty 1|2|3 - Set difficulty")
    print("IncomeSetPayMode 1|2 - Set payment frequency")
    print("IncomeSetNotifications true|false - Toggle notifications")
    print("IncomeSetCustomAmount <amount> - Set custom amount (0 for default)")
    print("IncomeTestPayment - Test payment system")
    print("IncomeShowSettings - Show current settings")
    print("IncomeResetSettings - Reset to defaults")
    print("===================================")
    return "Type 'help' for more info"
end

function SettingsGUI:consoleCommandSetDifficulty(difficulty)
    local diff = tonumber(difficulty)
    if not diff or diff < 1 or diff > 3 then
        Logging.warning("Invalid difficulty. Use 1 (Easy), 2 (Normal), or 3 (Hard)")
        return "Invalid difficulty"
    end
    
    if g_IncomeManager and g_IncomeManager.settings then
        g_IncomeManager.settings:setDifficulty(diff)
        g_IncomeManager.settings:save()
        return string.format("Difficulty set to: %s ($%d)", 
            g_IncomeManager.settings:getDifficultyName(),
            g_IncomeManager.settings:getDifficultyAmount())
    end
    
    return "Error: Income Mod not initialized"
end

function SettingsGUI:consoleCommandIncomeEnable()
    if g_IncomeManager and g_IncomeManager.settings then
        g_IncomeManager.settings.enabled = true
        g_IncomeManager.settings:save()
        
        if g_IncomeManager.incomeSystem then
            g_IncomeManager.incomeSystem:initialize()
        end
        
        return "Income Mod enabled"
    end
    return "Error: Income Mod not initialized"
end

function SettingsGUI:consoleCommandIncomeDisable()
    if g_IncomeManager and g_IncomeManager.settings then
        g_IncomeManager.settings.enabled = false
        g_IncomeManager.settings:save()
        return "Income Mod disabled"
    end
    return "Error: Income Mod not initialized"
end

function SettingsGUI:consoleCommandSetPayMode(mode)
    local payMode = tonumber(mode)
    if not payMode or (payMode ~= 1 and payMode ~= 2) then
        return "Invalid pay mode. Use 1 (Hourly) or 2 (Daily)"
    end
    
    if g_IncomeManager and g_IncomeManager.settings then
        g_IncomeManager.settings:setPayMode(payMode)
        g_IncomeManager.settings:save()
        return string.format("Pay mode set to: %s", g_IncomeManager.settings:getPayModeName())
    end
    
    return "Error: Income Mod not initialized"
end

function SettingsGUI:consoleCommandSetNotifications(enabled)
    if enabled == nil then
        return "Usage: IncomeSetNotifications true|false"
    end
    
    local enable = enabled:lower()
    if enable ~= "true" and enable ~= "false" then
        return "Invalid value. Use 'true' or 'false'"
    end
    
    if g_IncomeManager and g_IncomeManager.settings then
        g_IncomeManager.settings.showNotifications = (enable == "true")
        g_IncomeManager.settings:save()
        return string.format("Notifications %s", g_IncomeManager.settings.showNotifications and "enabled" or "disabled")
    end
    
    return "Error: Income Mod not initialized"
end

function SettingsGUI:consoleCommandSetCustomAmount(amount)
    local customAmount = tonumber(amount)
    if not customAmount or customAmount < 0 then
        return "Invalid amount. Use a positive number or 0 to use difficulty setting"
    end
    
    if g_IncomeManager and g_IncomeManager.settings then
        g_IncomeManager.settings.customAmount = customAmount
        g_IncomeManager.settings:save()
        if customAmount > 0 then
            return string.format("Custom amount set to: $%d", customAmount)
        else
            return "Custom amount disabled, using difficulty setting"
        end
    end
    
    return "Error: Income Mod not initialized"
end

function SettingsGUI:consoleCommandTestPayment()
    if g_IncomeManager and g_IncomeManager.settings then
        if g_IncomeManager.incomeSystem then
            local success = g_IncomeManager.incomeSystem:giveMoney("test")
            if success then
                return "Test payment executed ($1)"
            else
                return "Test payment failed"
            end
        end
    end
    return "Error: Income Mod not initialized"
end

function SettingsGUI:consoleCommandShowSettings()
    if g_IncomeManager and g_IncomeManager.settings then
        local settings = g_IncomeManager.settings
        local info = string.format(
            "=== Income Mod Settings ===\n" ..
            "Enabled: %s\n" ..
            "Debug Mode: %s\n" ..
            "Pay Mode: %s\n" ..
            "Difficulty: %s\n" ..
            "Payment Amount: $%d\n" ..
            "Notifications: %s\n" ..
            "Custom Amount: $%d\n" ..
            "==========================",
            tostring(settings.enabled),
            tostring(settings.debugMode),
            settings:getPayModeName(),
            settings:getDifficultyName(),
            settings:getPaymentAmount(),
            tostring(settings.showNotifications),
            settings.customAmount
        )
        print(info)
        return info
    end
    
    return "Error: Income Mod not initialized"
end

function SettingsGUI:consoleCommandResetSettings()
    if g_IncomeManager and g_IncomeManager.settings then
        g_IncomeManager.settings:resetToDefaults()
        
        -- Reinitialize the income system
        if g_IncomeManager.incomeSystem then
            g_IncomeManager.incomeSystem:initialize()
        end
        
        if g_IncomeManager.settingsUI then
            g_IncomeManager.settingsUI:refreshUI()
        end
        
        return "Income Mod settings reset to default!"
    end
    
    return "Error: Income Mod not initialized"
end
