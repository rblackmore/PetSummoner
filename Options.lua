---@class AceAddon
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")
---@class AceModule
local Options = addOn:GetModule("Options")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local function getGlobalOptions()
  return {
    ["MessageFormat"] = {
      type = "input",
      name = "Message Format",
      desc = "Format of the message to display, use %s in place where pet name should be shown.",
      usage = "<Your message>",
      get = "GetMessageFormat",
      set = "SetMessageFormat",
    },
    ["UseCustomName"] = {
      type = "toggle",
      name = "Custom Name",
      desc = "Use Custom Name if one is set, otherwise Species Name.",
      get = "IsCustomName",
      set = "ToggleCustomName"
    },
    ["Channel"] = {
      type = "select",
      name = "Channel",
      desc = "The Channel to Announce your Pet Summon",
      values = {
        ["SAY"] = "SAY",
        ["EMOTE"] = "EMOTE",
        ["YELL"] = "YELL",
        ["PARTY"] = "PARTY",
        ["RAID"] = "RAID",
        ["INSTANCE_CHAT"] = "INSTANCE_CHAT",
        ["GUILD"] = "GUILD",
      },
      get = "GetAnnounceChannel",
      set = "SetAnnounceChannel",
    }
  }
end

function Options:GetDefaultOptions()
  local defaults = {
    ["profile"] = {
      ["MessageFormat"] = "Help me %s you're my only hope!!!",
      ["Channel"] = "SAY",
      ["UseCustomName"] = true,
      ["FavoritePets"] = {}
    }
  }
  return defaults
end

function Options:GetOptionsTable()
  local options = {
    name = "Pet Summoner",
    handler = Options,
    type = "group",
    args = getGlobalOptions()
  }
  return options
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
  local profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(addOn.db)

  AceConfig:RegisterOptionsTable("PetSummoner_Profiles", profileOptions, "psprofile")
  local profileFrame, profileId =
      AceConfigDialog:AddToBlizOptions("PetSummoner_Profiles", "Profiles", Options.GlobalSettingsDialog["Id"])

  self.ProfileSettingsDialog =
  {
    ["Frame"] = profileFrame,
    ["Id"] = profileId,
  }
end

function Options:GetMessageFormat(info)
  return addOn.db.profile["MessageFormat"]
end

function Options:SetMessageFormat(info, value)
  addOn.db.profile["MessageFormat"] = value
end

function Options:GetAnnounceChannel(info)
  return addOn.db.profile["Channel"]
end

function Options:SetAnnounceChannel(info, value)
  addOn.db.profile["Channel"] = value
end

function Options:IsCustomName(info)
  return addOn.db.profile["UseCustomName"]
end

function Options:ToggleCustomName(info, value)
  addOn.db.profile["UseCustomName"] = value
end
