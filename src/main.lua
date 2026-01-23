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
local modDirectory = g_currentModDirectory
local modName = g_currentModName

source(modDirectory .. "src/settings/SettingsManager.lua")
source(modDirectory .. "src/settings/Settings.lua")
source(modDirectory .. "src/settings/SettingsGUI.lua") 
source(modDirectory .. "src/utils/UIHelper.lua")
source(modDirectory .. "src/settings/SettingsUI.lua")
source(modDirectory .. "src/IncomeSystem.lua")
source(modDirectory .. "src/IncomeManager.lua")

local im

local function isEnabled()
    return im ~= nil
end

local function loadedMission(mission, node)
    if not isEnabled() then
        return
    end
    
    if mission.cancelLoading then
        return
    end
    
    im:onMissionLoaded()
end

local function load(mission)
    if im == nil then
        print("Income Mod: Initializing...")
        im = IncomeManager.new(mission, modDirectory, modName)
        getfenv(0)["g_IncomeManager"] = im
        print("Income Mod: Initialized successfully")
    end
end

local function unload()
    if im ~= nil then
        im:delete()
        im = nil
        getfenv(0)["g_IncomeManager"] = nil
    end
end

Mission00.load = Utils.prependedFunction(Mission00.load, load)
Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, loadedMission)
FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)

FSBaseMission.update = Utils.appendedFunction(FSBaseMission.update, function(mission, dt)
    if im then
        im:update(dt)
    end
end)

function income()
    if g_IncomeManager and g_IncomeManager.settingsGUI then
        return g_IncomeManager.settingsGUI:consoleCommandHelp()
    else
        print("=== Income Mod Commands ===")
        print("Type these commands in console (~):")
        print("IncomeShowSettings - Show current settings")
        print("IncomeEnable/Disable - Enable/disable mod")
        print("IncomeSetDifficulty 1|2|3 - Set difficulty")
        print("IncomeSetPayMode 1|2 - Set pay mode")
        print("IncomeSetNotifications true|false - Toggle notifications")
        print("IncomeTestPayment - Test payment")
        print("IncomeResetSettings - Reset to defaults")
        print("============================")
        return "Income Mod commands listed above"
    end
end

function incomeStatus()
    if g_IncomeManager and g_IncomeManager.settings then
        local settings = g_IncomeManager.settings
        print(string.format(
            "Enabled: %s\nMode: %s\nDifficulty: %s\nAmount: $%d\nNotifications: %s",
            tostring(settings.enabled),
            settings:getPayModeName(),
            settings:getDifficultyName(),
            settings:getPaymentAmount(),
            tostring(settings.showNotifications)
        ))
    else
        print("Income Mod not initialized")
    end
end

getfenv(0)["income"] = income
getfenv(0)["incomeStatus"] = incomeStatus
getfenv(0)["incomeEnable"] = function() 
    if g_IncomeManager and g_IncomeManager.settingsGUI then
        return g_IncomeManager.settingsGUI:consoleCommandIncomeEnable()
    end
    return "Income Mod not initialized"
end

getfenv(0)["incomeDisable"] = function() 
    if g_IncomeManager and g_IncomeManager.settingsGUI then
        return g_IncomeManager.settingsGUI:consoleCommandIncomeDisable()
    end
    return "Income Mod not initialized"
end

getfenv(0)["incomeTest"] = function() 
    if g_IncomeManager and g_IncomeManager.settingsGUI then
        return g_IncomeManager.settingsGUI:consoleCommandTestPayment()
    end
    return "Income Mod not initialized"
end

print("========================================")
print("     FS25 Income Mod v1.1.0.0 LOADED    ")
print("     Integrated into settings system    ")
print("     Type 'income' in console for help  ")
print("========================================")
