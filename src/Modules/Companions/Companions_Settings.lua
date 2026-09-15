local addonName, _ = ...
---@class AceAddon: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon(addonName)
---@class AceAddon: AceTimer-3.0, GMM_Companion
local companionModule = addOn:GetModule("CompanionModule")

local Settings = companionModule.Settings
local Data = addOn.Data

--------------------------------------------------------------------------------
--- Local priviat functions
--------------------------------------------------------------------------------

local function getPodSettings()
  return Settings:GetCompanionSettings().profile.Automation.petoftheday
end

--------------------------------------------------------------------------------
--- Public API
--------------------------------------------------------------------------------

function Settings:Init()
  addOn:Print("Initializing Companion Settings")
  Data["CompanionSettings"] = Data.AceDatabase:RegisterNamespace("CompanionModuleSettings", {
    profile = {
      MessageFormat = "Help me %s you're my only hope!!!",
      Channel = "SAY",
      UseCustomName = true,
      UseFavoritesFallback = true,
      Automation = {
        delay = 5,
        forcesummon = false,
        GLOBAL = true,
        SCENARIO = true,
        RAID = true,
        DUNGEON = true,
        ARENA = true,
        BATTLEGROUND = true,
        RESTING = true,
        petoftheday = {
          Enabled = false,
          Date = {
            ["year"] = 2004,
            ["month"] = 11,
            ["day"] = 23,
          },
          Pet = nil,
        },
      },
      meta = { schemaVersion = 1, createdAt = time(), lastUpdated = time() },
    }
  })
end

function Settings:GetCompanionSettings()
  return Data["CompanionSettings"].profile
end

function Settings:GetAutomationSettings()
  return Data["CompanionSettings"].profile.Automation
end

function Settings:GetPetOfTheDaySettings()
  return Data["CompanionSettings"].profile.Automation.petoftheday
end

function Settings:SetPetOfTheDay(petID)
  local podsettings = Settings:GetPetOfTheDaySettings()
  podsettings.petID = petID
  podsettings.Date = date("*t")
end

function Settings:SetActivePetAsPetOfTheDay()
  local currentPetGUID = C_PetJournal.GetSummonedPetGUID()
  if not currentPetGUID then return end
  Settings:SetPetOfTheDay(currentPetGUID)
end

function Settings:GetPetOfTheDay()
  local podsettings = Settings:GetPetOfTheDaySettings();
  local today = date("*t")
  local summonedOn = podsettings.Date

  if not summonedOn or summonedOn.day ~= today.day or summonedOn.month ~= today.month or summonedOn.year ~= today.year then
    return false, podsettings.PetId
  end

  return true, podsettings.PetId
end

function Settings:ClearPetOfTheDay()
  local podsettings = Settings:GetPetOfTheDaySettings()
  podsettings.PetId = nil
  podsettings.Date = nil
end

function Settings:IsPetOfTheDayEnabled()
  return Settings:GetPetOfTheDaySettings().Enabled
end
