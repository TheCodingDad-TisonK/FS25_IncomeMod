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
---@class IncomeManager
IncomeManager = {}
local IncomeManager_mt = Class(IncomeManager)

function IncomeManager.new(mission, modDirectory, modName)
    local self = setmetatable({}, IncomeManager_mt)
    
    self.mission = mission
    self.modDirectory = modDirectory
    self.modName = modName
    
    self.settingsManager = SettingsManager.new()
    self.settings = Settings.new(self.settingsManager)
    
    self.incomeSystem = IncomeSystem.new(self.settings)
    
    if mission:getIsClient() and g_gui then
        self.settingsUI = SettingsUI.new(self.settings)
        
        InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameOpen, function()
            self.settingsUI:inject()
        end)
        
        InGameMenuSettingsFrame.updateButtons = Utils.appendedFunction(InGameMenuSettingsFrame.updateButtons, function(frame)
            if self.settingsUI then
                self.settingsUI:ensureResetButton(frame)
            end
        end)
    end
    
    self.settingsGUI = SettingsGUI.new()
    self.settingsGUI:registerConsoleCommands()
    
    self.settings:load()
    
    return self
end

function IncomeManager:onMissionLoaded()
    if self.incomeSystem then
        self.incomeSystem:initialize()
    end
    
    if self.settings.enabled and self.settings.showNotifications then
        if g_currentMission and g_currentMission.hud then
            g_currentMission.hud:showBlinkingWarning(
                "Income Mod Active - Type 'help' for commands",
                4000
            )
        end
    end
end

function IncomeManager:update(dt)
    if self.incomeSystem then
        self.incomeSystem:update(dt)
    end
end

function IncomeManager:delete()
    if self.settings then
        self.settings:save()
    end
    
    print("Income Mod: Shutting down")
end
