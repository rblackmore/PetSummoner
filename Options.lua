---@class AceAddon
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")
---@class AceModule
local Options = addOn:GetModule("Options")

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
    name = "PetSummoner",
    handler = Options,
    type = "group",
    args = getGlobalOptions()
  }
  return options
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
