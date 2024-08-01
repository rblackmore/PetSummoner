---@diagnostic disable: duplicate-set-field
---@class AceAddon
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")
---@class AceModule
local Options = addOn:GetModule("Options")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function Options:GetDefaultDatabase()
  local defaults = {
    ["profile"] = {
      ["Channel"] = "SAY",
    }
  }
  return defaults
end

local globalOptions =
{
  ["Channel"] = {
    type = "select",
    name = "Channel",
    desc = "The Channel to Announce your Summon to",
    values = {
      ["SAY"] = "SAY",
      ["EMOTE"] = "EMOTE",
      ["YELL"] = "YELL",
      ["PARTY"] = "PARTY",
      ["RAID"] = "RAID",
      ["INSTANCE_CHAT"] = "INSTANCE_CHAT",
      ["GUILD"] = "GUILD",
    },
    get = "GetGlobalValue",
    set = "SetGlobalValue",
  }
}

function Options:GetOptionsTable()
  local options = {
    name = "Pet Summoner",
    handler = Options,
    type = "group",
    args = globalOptions
  }
  return options
end

function Options:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("PetSummonerDB", Options:GetDefaultDatabase(), true)
  self:ConfigureGlobalOptions()
  self:ConfigureOptionsProfiles()
end

function Options:ConfigureGlobalOptions()
  AceConfig:RegisterOptionsTable("PetSummoner", self:GetOptionsTable(), "psconfig")
  local configFrame, configId = AceConfigDialog:AddToBlizOptions("PetSummoner", "Pet Summoner")

  self.GlobalSettingsDialog =
  {
    ["Frame"] = configFrame,
    ["Id"] = configId
  }
end

function Options:ConfigureOptionsProfiles()
  local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

  AceConfig:RegisterOptionsTable("PetSummoner_Profiles", profileOptions, "psprofile")
  local profileFrame, profileId =
      AceConfigDialog:AddToBlizOptions("PetSummoner_Profiles", "Profiles", Options.GlobalSettingsDialog["Id"])

  self.ProfileSettingsDialog =
  {
    ["Frame"] = profileFrame,
    ["Id"] = profileId,
  }
end

function Options:GetGlobalValue(info)
  if info.arg then
    return self.db.profile[info.arg][info[#info]]
  else
    return self.db.profile[info[#info]]
  end
end

function Options:SetGlobalValue(info, value)
  if info.arg then
    self.db.profile[info.arg][info[#info]] = value
  else
    self.db.profile[info[#info]] = value
  end
end
