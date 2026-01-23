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
---@class IncomeSystem
IncomeSystem = {}
local IncomeSystem_mt = Class(IncomeSystem)

function IncomeSystem.new(settings)
    local self = setmetatable({}, IncomeSystem_mt)
    self.settings = settings
    self.lastHour = -1
    self.lastDay = -1
    self.lastMinuteCheck = -1
    self.isInitialized = false
    
    return self
end

function IncomeSystem:initialize()
    if self.isInitialized then
        return
    end
    
    if g_currentMission and g_currentMission.environment then
        local env = g_currentMission.environment
        self.lastHour = env.currentHour
        self.lastDay = env.currentDay
        self.lastMinuteCheck = math.floor(env.dayTime / 60000)
        
        self.isInitialized = true
        self:log("Income System initialized successfully (Day %d, Hour %d)", self.lastDay, self.lastHour)
        self:log("Mode: %s, Amount: $%d", self.settings:getPayModeName(), self.settings:getPaymentAmount())
        
        if self.settings.enabled and self.settings.showNotifications then
            self:showNotification("Income Mod Active", "Type 'help' for commands")
        end
    end
end

function IncomeSystem:log(msg, ...)
    if self.settings.debugMode then
        print(string.format("[Income Mod] " .. msg, ...))
    end
end

function IncomeSystem:showNotification(title, message)
    if not g_currentMission or not self.settings.showNotifications then
        return
    end
    
    if g_currentMission.hud and g_currentMission.hud.showBlinkingWarning then
        g_currentMission.hud:showBlinkingWarning(message, 4000)
    end
    
    self:log("%s: %s", title, message)
end

function IncomeSystem:giveMoney(paymentType)
    if not g_currentMission then
        self:log("Cannot give money: No mission")
        return false
    end
    
    local amount = 1
    local typeText = "Test Payment"
    
    if paymentType ~= "test" then
        amount = self.settings:getPaymentAmount()
        if paymentType == "hourly" then
            typeText = "Hourly Income"
        else
            typeText = "Daily Income"
        end
    end
    
    local farmId = g_currentMission:getFarmId()
    if not farmId then
        self:log("Cannot give money: No farm ID")
        return false
    end
    
    g_currentMission:addMoney(
        amount,
        farmId,
        MoneyType.INCOME,
        false
    )
    
    if self.settings.showNotifications then
        local formattedAmount = g_i18n:formatMoney(amount, 0, true, true)
        local message = string.format("%s: $%s", typeText, formattedAmount)
        
        self:showNotification("Payment Received", message)
        
        self:log("Notification shown: %s", message)
    end
    
    self:log("%s: $%d to farm %d", typeText, amount, farmId)
    return true
end

function IncomeSystem:checkHourly()
    if not g_currentMission or not g_currentMission.environment then
        return false
    end
    
    local env = g_currentMission.environment
    local currentHour = env.currentHour
    
    if currentHour ~= self.lastHour then
        self.lastHour = currentHour
        self:giveMoney("hourly")
        return true
    end
    
    return false
end

function IncomeSystem:checkDaily()
    if not g_currentMission or not g_currentMission.environment then
        return false
    end
    
    local env = g_currentMission.environment
    local currentDay = env.currentDay
    
    if currentDay ~= self.lastDay then
        self.lastDay = currentDay
        self:giveMoney("daily")
        return true
    end
    
    return false
end

function IncomeSystem:update(dt)
    if not self.settings.enabled or not self.isInitialized then
        return
    end
    
    if g_currentMission and g_currentMission.environment then
        local currentMinute = math.floor(g_currentMission.environment.dayTime / 60000)
        
        if currentMinute ~= self.lastMinuteCheck then
            self.lastMinuteCheck = currentMinute
            
            if self.settings.payMode == Settings.PAY_MODE_HOURLY then
                self:checkHourly()
            else
                self:checkDaily()
            end
        end
    end
end

function IncomeSystem:saveState()
    return {
        lastHour = self.lastHour,
        lastDay = self.lastDay,
        lastMinuteCheck = self.lastMinuteCheck
    }
end

function IncomeSystem:loadState(state)
    if state then
        self.lastHour = state.lastHour or -1
        self.lastDay = state.lastDay or -1
        self.lastMinuteCheck = state.lastMinuteCheck or -1
    end
end
