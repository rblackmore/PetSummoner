---@diagnostic disable: duplicate-set-field
---@class AceAddon: AceConsole-3.0, AceEvent-3.0
local addOn = LibStub("AceAddon-3.0"):NewAddon("PetSummoner", "AceConsole-3.0", "AceEvent-3.0")
_G.PetSummoner = addOn

---@class AceModule
local Options = addOn:NewModule("Options")
---@class AceModule: AceConsole-3.0, AceEvent-3.0
local PetModule = addOn:NewModule("PetModule", "AceConsole-3.0", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function addOn:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("PetSummonerDB", Options:GetGlobalOptionsDefaultDatabase(), true)

  Options:ConfigureGlobalOptions()
  Options:ConfigureOptionsProfiles()
end

function addOn:OnEnable()
  self:RegisterChatCommand("petsummon", "ExecuteChatCommand")
  self:RegisterChatCommand("ps", "ExecuteChatCommand")
  self:RegisterChatCommand("summonhelp", "ExecuteChatCommand")
  self:RegisterChatCommand("sh", "ExecuteChatCommand")
end

function addOn:OnDisable()
end

function addOn:ExecuteChatCommand(msg)
  if msg:trim() == "config" then  
    Settings.OpenToCategory(Options.GlobalSettingsDialog["Id"])
    return
  end
  if msg:trim() == "profiles" then
    Settings.OpenToCategory(Options.ProfileSettingsDialog["Id"])
    return
  end

  PetModule:SummonFavoritePet();
end
