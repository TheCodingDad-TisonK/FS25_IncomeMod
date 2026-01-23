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
---@class SettingsManager
SettingsManager = {}
local SettingsManager_mt = Class(SettingsManager)

SettingsManager.MOD_NAME = g_currentModName
SettingsManager.XMLTAG = "IncomeManager"

SettingsManager.defaultConfig = {
    difficulty = 2,
    
    enabled = true,
    debugMode = false,
    payMode = 1, 
    showNotifications = true,
    customAmount = 0 
}

function SettingsManager.new()
    return setmetatable({}, SettingsManager_mt)
end

function SettingsManager:getSavegameXmlFilePath()
    if g_currentMission.missionInfo and g_currentMission.missionInfo.savegameDirectory then
        return ("%s/%s.xml"):format(g_currentMission.missionInfo.savegameDirectory, SettingsManager.MOD_NAME)
    end
    return nil
end

function SettingsManager:loadSettings(settingsObject)
    local xmlPath = self:getSavegameXmlFilePath()
    if xmlPath and fileExists(xmlPath) then
        local xml = XMLFile.load("im_Config", xmlPath)
        if xml then
            settingsObject.difficulty = xml:getInt(self.XMLTAG..".difficulty", self.defaultConfig.difficulty)
            
            settingsObject.enabled = xml:getBool(self.XMLTAG..".enabled", self.defaultConfig.enabled)
            settingsObject.debugMode = xml:getBool(self.XMLTAG..".debugMode", self.defaultConfig.debugMode)
            settingsObject.payMode = xml:getInt(self.XMLTAG..".payMode", self.defaultConfig.payMode)
            settingsObject.showNotifications = xml:getBool(self.XMLTAG..".showNotifications", self.defaultConfig.showNotifications)
            settingsObject.customAmount = xml:getInt(self.XMLTAG..".customAmount", self.defaultConfig.customAmount)
            
            xml:delete()
            return
        end
    end
    settingsObject.difficulty = self.defaultConfig.difficulty
    settingsObject.enabled = self.defaultConfig.enabled
    settingsObject.debugMode = self.defaultConfig.debugMode
    settingsObject.payMode = self.defaultConfig.payMode
    settingsObject.showNotifications = self.defaultConfig.showNotifications
    settingsObject.customAmount = self.defaultConfig.customAmount
end

function SettingsManager:saveSettings(settingsObject)
    local xmlPath = self:getSavegameXmlFilePath()
    if not xmlPath then return end
    
    local xml = XMLFile.create("im_Config", xmlPath, self.XMLTAG)
    if xml then
        xml:setInt(self.XMLTAG..".difficulty", settingsObject.difficulty)
        
        xml:setBool(self.XMLTAG..".enabled", settingsObject.enabled)
        xml:setBool(self.XMLTAG..".debugMode", settingsObject.debugMode)
        xml:setInt(self.XMLTAG..".payMode", settingsObject.payMode)
        xml:setBool(self.XMLTAG..".showNotifications", settingsObject.showNotifications)
        xml:setInt(self.XMLTAG..".customAmount", settingsObject.customAmount)
        
        xml:save()
        xml:delete()
    end
end
