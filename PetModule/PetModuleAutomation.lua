---@diagnostic disable: duplicate-set-field

---@class AceAddon: AceConsole-3.0, AceEvent-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")

---@class AceModule
local Options = addOn:GetModule("Options")

---@class AceModule: AceConsole-3.0, AceEvent-3.0
local PetModule = addOn:GetModule("PetModule")
---@class AceModule: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local PetAutomationModule = PetModule:GetModule("PetAutomationModule")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local eventsToRegister = {
  -- "PET_JOURNAL_LIST_UPDATE",
  "ZONE_CHANGED_NEW_AREA", -- Player changes major Zone, et, Orgrimmar -> Durotar
  "ZONE_CHANGED",          -- Player changes minor zone, eg, Valley of Honor -> The Drag
}

local registeredEvents = {}

function PetAutomationModule:OnInitialize()
  for _, event in ipairs(eventsToRegister) do
    if not registeredEvents[event] then
      self:RegisterEvent(event)
      registeredEvents[event] = true
    end
  end
end

function PetAutomationModule:ZONE_CHANGED_NEW_AREA()
  local automationSettings = PetModule.db["profile"].Settings["AutoSummon"]

  local zoneType = PETSUMMONER_LOCATIONTYPES.GetCurrentZoneType()

  if automationSettings[zoneType] then
    self:ScheduleTimer(function()
      PetModule:SummonCompanion(false)
    end, automationSettings["delay"])
  end
end

function PetAutomationModule:ZONE_CHANGED()
end
