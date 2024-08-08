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
  "UNIT_SPELLCAST_SUCCEEDED",
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
  if C_PetJournal.GetSummonedPetGUID() then
    return
  end

  local automationSettings = PetModule.db["profile"].Settings["Automation"]
  self:ScheduleTimer(function()
    local zoneType = PETSUMMONER_LOCATIONTYPES.GetCurrentZoneType()
    if automationSettings[zoneType] then
      PetModule:SummonCompanion(false)
    end
  end, automationSettings["delay"])
end

function PetAutomationModule:UNIT_SPELLCAST_SUCCEEDED(unit, castGUID, spellID)
  --[[
    TODO: Posible Ideas:
    Perhaps on load, I make a list of all pets, including their names, C_Spell.GetSpellInfo(spellID) will give me the name of the pet.
    I can then check the list ofr this name if it existes, then it was a pet that was summoned.
      I should also check the GUID, that it's type is '3' which usually indicates a spell cast by player
  ]]
end

function PetAutomationModule:ZONE_CHANGED()
end
