---@diagnostic disable: duplicate-set-field
---@class AceAddon AceConsole AceEvent
PetSummoner = LibStub("AceAddon-3.0"):NewAddon("PetSummoner", "AceConsole-3.0", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local defaults = {
  profile = {
    ["msgFormat"] = "Help me %s you're my only hope!!!",
    ["channel"] = "SAY",
    ["useCustomName"] = true,
    ["FavoritePets"] = {}
  }
}

local options = {
  name = "PetSummoner",
  handler = PetSummoner,
  type = "group",
  args = {
    msgFormat = {
      type = "input",
      name = "Message Format",
      desc = "Format of the message to display, use %s in place where pet name should be shown.",
      usage = "<Your message>",
      get = "GetMessageFormat",
      set = "SetMessageFormat",
    },
    useCustomName = {
      type = "toggle",
      name = "Custom Name",
      desc = "Use Custom Name if one is set, otherwise Species Name.",
      get = "IsCustomName",
      set = "ToggleCustomName"
    },
    channel = {
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
}

function PetSummoner:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("PetSummonerDB", defaults, true)
  AceConfig:RegisterOptionsTable("PetSummoner", options)
  self.optionsFrame, self.optionsCategoryId = AceConfigDialog:AddToBlizOptions("PetSummoner", "PetSummoner")

  local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

  AceConfig:RegisterOptionsTable("PetSummoner_Profiles", profiles)
  AceConfigDialog:AddToBlizOptions("PetSummoner_Profiles", "Profiles", "PetSummoner")

  self:RegisterChatCommand("petsummon", "SlashCommand")
  self:RegisterChatCommand("ps", "SlashCommand")
  self:RegisterChatCommand("summonhelp", "SlashCommand")
  self:RegisterChatCommand("sh", "SlashCommand")
  -- self:LoadFavoritePets()
  -- self:LoadMounts()
end

function PetSummoner:OnEnable()
end

function PetSummoner:OnDisable()
end