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
---@class Settings

Settings = {}
local Settings_mt = Class(Settings)

Settings.DIFFICULTY_EASY = 1
Settings.DIFFICULTY_NORMAL = 2
Settings.DIFFICULTY_HARD = 3

Settings.PAY_MODE_HOURLY = 1
Settings.PAY_MODE_DAILY = 2

function Settings.new(manager)
    local self = setmetatable({}, Settings_mt)
    self.manager = manager
    
    self:resetToDefaults(false) 
    
    Logging.info("Income Mod: Settings initialized")
    
    return self
end

---@param difficulty number 
function Settings:setDifficulty(difficulty)
    if difficulty >= Settings.DIFFICULTY_EASY and difficulty <= Settings.DIFFICULTY_HARD then
        self.difficulty = difficulty
        
        local difficultyName = "Normal"
        if difficulty == Settings.DIFFICULTY_EASY then
            difficultyName = "Easy"
        elseif difficulty == Settings.DIFFICULTY_HARD then
            difficultyName = "Hard"
        end
        
        Logging.info("Income Mod: Difficulty changed to: %s", 
            difficultyName)
    end
end

---@return string 
function Settings:getDifficultyName()
    if self.difficulty == Settings.DIFFICULTY_EASY then
        return "Easy"
    elseif self.difficulty == Settings.DIFFICULTY_HARD then
        return "Hard"
    else
        return "Normal"
    end
end

---@return number
function Settings:getDifficultyAmount()
    if self.difficulty == Settings.DIFFICULTY_EASY then
        return 5000
    elseif self.difficulty == Settings.DIFFICULTY_HARD then
        return 1100
    else
        return 2400
    end
end

---@return number 
function Settings:getPaymentAmount()
    if self.customAmount > 0 then
        return self.customAmount
    end
    return self:getDifficultyAmount()
end

---@param mode number
function Settings:setPayMode(mode)
    if mode == Settings.PAY_MODE_HOURLY or mode == Settings.PAY_MODE_DAILY then
        self.payMode = mode
        local modeName = mode == Settings.PAY_MODE_HOURLY and "Hourly" or "Daily"
        Logging.info("Income Mod: Pay mode changed to: %s", modeName)
    end
end

---@return string
function Settings:getPayModeName()
    if self.payMode == Settings.PAY_MODE_HOURLY then
        return "Hourly"
    else
        return "Daily"
    end
end

function Settings:load()
    if type(self.difficulty) ~= "number" then
        Logging.warning("Income Mod: difficulty is not a number! Type: %s, Value: %s", 
            type(self.difficulty), tostring(self.difficulty))
        self.difficulty = Settings.DIFFICULTY_NORMAL 
    end
    
    self.manager:loadSettings(self)
    
    self:validateSettings()
    
    Logging.info("Income Mod: Settings Loaded. Enabled: %s, Difficulty: %s, Pay Mode: %s", 
        tostring(self.enabled), self:getDifficultyName(), self:getPayModeName())
end

function Settings:validateSettings()
    if self.difficulty < Settings.DIFFICULTY_EASY or self.difficulty > Settings.DIFFICULTY_HARD then
        Logging.warning("Income Mod: Invalid difficulty value %d, resetting to Normal", self.difficulty)
        self.difficulty = Settings.DIFFICULTY_NORMAL
    end
    
    if self.payMode ~= Settings.PAY_MODE_HOURLY and self.payMode ~= Settings.PAY_MODE_DAILY then
        Logging.warning("Income Mod: Invalid pay mode value %d, resetting to Hourly", self.payMode)
        self.payMode = Settings.PAY_MODE_HOURLY
    end
    
    self.enabled = not not self.enabled 
    self.debugMode = not not self.debugMode
    self.showNotifications = not not self.showNotifications
    
    self.customAmount = tonumber(self.customAmount) or 0
    if self.customAmount < 0 then
        self.customAmount = 0
    end
end

function Settings:save()
    if type(self.difficulty) ~= "number" then
        Logging.warning("Income Mod: difficulty is not a number! Type: %s, Value: %s", 
            type(self.difficulty), tostring(self.difficulty))
        self.difficulty = Settings.DIFFICULTY_NORMAL
    end
    
    self.manager:saveSettings(self)
    Logging.info("Income Mod: Settings Saved. Difficulty: %s, Pay Mode: %s", 
        self:getDifficultyName(), self:getPayModeName())
end

---@param saveImmediately boolean Чи потрібно зберігати одразу
function Settings:resetToDefaults(saveImmediately)
    saveImmediately = saveImmediately ~= false -- Default to true
    
    self.difficulty = Settings.DIFFICULTY_NORMAL
    self.enabled = true
    self.debugMode = false
    self.payMode = Settings.PAY_MODE_HOURLY
    self.showNotifications = true
    self.customAmount = 0
    
    if saveImmediately then
        self:save()
        print("Income Mod: Settings reset to defaults")
    end
end
