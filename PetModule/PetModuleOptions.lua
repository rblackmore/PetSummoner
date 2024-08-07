---@diagnostic disable: duplicate-set-field

---@class AceAddon: AceConsole-3.0, AceEvent-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")

---@class AceModule
local Options = addOn:GetModule("Options")
---@class AceModule: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local PetModule = addOn:GetModule("PetModule")
---@class AceModule: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local PetAutomationModule = PetModule:GetModule("PetAutomationModule")
---@class AceModule: AceConsole-3.0, AceEvent-3.0
local PetModuleOptions = PetModule:GetModule("PetModuleOptions")


local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local announcementOptions = {
  ["MessageFormat"] = {
    type = "input",
    name = "Message Format",
    desc = "Format of the message to display, use %s in place where pet name should be shown.",
    usage = "<Your message>",
    get = "GetValue",
    set = "SetValue",
  },
  ["UseCustomName"] = {
    type = "toggle",
    name = "Custom Name",
    desc = "Use Custom Name if one is set, otherwise Species Name.",
    get = "GetValue",
    set = "SetValue",
  },
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
    get = "GetValue",
    set = "SetValue",
  }
}

local companionOptions = {
  ["RefreshFavoritesList"] = {
    type = "execute",
    name = "Refersh",
    desc = "Refreshes list of Favorite Pets by Scanning the Pet Journal and adds them to database",
    handler = PetModule,
    func = "LoadFavoritePets"
  },
  ["EnablePetOfTheDay"] = {
    type = "toggle",
    name = "Enabled Pet of the Day",
    desc = "Saves the first pet summoned for the day, and summons only that one for the rest of the day.",
    handler = PetModule,
    get = function(info) return PetModule.db["profile"].Settings["PetOfTheDay"].Enabled end,
    set = function(info, value) PetModule.db["profile"].Settings["PetOfTheDay"].Enabled = value end,
  }
}

local automationOptions = {
  ["GLOBAL"] = {
    order = 2,
    type = "toggle",
    name = "Global",
    desc = "Auto Summon In the Open World",
    get = function(info) return PetModule.db["profile"].Settings["Automation"]["GLOBAL"] end,
    set = function(info, value) PetModule.db["profile"].Settings["Automation"]["GLOBAL"] = value end
  },
  ["SCENARIO"] = {
    order = 7,
    type = "toggle",
    name = "Scenario",
    desc = "Auto Summon In the Scenarios",
    get = function(info) return PetModule.db["profile"].Settings["Automation"]["SCENARIO"] end,
    set = function(info, value) PetModule.db["profile"].Settings["Automation"]["SCENARIO"] = value end
  },
  ["RAID"] = {
    order = 4,
    type = "toggle",
    name = "Raid",
    desc = "Auto Summon In the Raids",
    get = function(info) return PetModule.db["profile"].Settings["Automation"]["RAID"] end,
    set = function(info, value) PetModule.db["profile"].Settings["Automation"]["RAID"] = value end
  },
  ["DUNGEON"] = {
    order = 3,
    type = "toggle",
    name = "Dungeon",
    desc = "Auto Summon In Dungeons",
    get = function(info) return PetModule.db["profile"].Settings["Automation"]["DUNGEON"] end,
    set = function(info, value) PetModule.db["profile"].Settings["Automation"]["DUNGEON"] = value end
  },
  ["ARENA"] = {
    order = 6,
    type = "toggle",
    name = "Arena",
    desc = "Auto Summon In Arenas",
    get = function(info) return PetModule.db["profile"].Settings["Automation"]["ARENA"] end,
    set = function(info, value) PetModule.db["profile"].Settings["Automation"]["ARENA"] = value end
  },
  ["BATTLEGROUND"] = {
    order = 5,
    type = "toggle",
    name = "Battleground",
    desc = "Auto Summon In Battlegrounds",
    get = function(info) return PetModule.db["profile"].Settings["Automation"]["BATTLEGROUND"] end,
    set = function(info, value) PetModule.db["profile"].Settings["Automation"]["BATTLEGROUND"] = value end
  },
  ["RESTING"] = {
    order = 1,
    type = "toggle",
    name = "Cities",
    desc = "Auto Summon In Cities (Resting)",
    get = function(info) return PetModule.db["profile"].Settings["Automation"]["RESTING"] end,
    set = function(info, value) PetModule.db["profile"].Settings["Automation"]["RESTING"] = value end
  },
}

local slashCommands = {
  "petconfig",
  "companionconfig",
}

local function combine_optionsTables(...)
  local result = {}
  for _, t in ipairs { ... } do
    for k, v in pairs(t) do
      result[k] = v
    end
  end
  return result
end

function PetModuleOptions:GetOptionsTable()
  local options = {
    name = "Pets",
    type = "group",
    handler = PetModule,
    args =
    {
      announcementGroup = {
        order = 1,
        inline = true,
        name = "Announcement Options",
        type = "group",
        args = announcementOptions
      },
      companionAutomationGroup = {
        order = 2,
        inline = true,
        name = "Automation",
        type = "group",
        args = automationOptions
      },
      companionManagementGroup = {
        order = 3,
        inline = true,
        name = "Companions",
        type = "group",
        args = companionOptions
      },
    }
  }
  return options
end

function PetModuleOptions:OnInitialize()
  AceConfig:RegisterOptionsTable("PetSummoner_PetModule", self:GetOptionsTable(), slashCommands)
  local frame, id = AceConfigDialog:AddToBlizOptions("PetSummoner_PetModule", "Pets",
    Options.GlobalSettingsDialog["Id"])

  PetModule["PetModuleOptionsDialog"] = {
    ["Frame"] = frame,
    ["Id"] = id
  }
end

function PetModuleOptions:GetValue(info)
  if info.arg then
    return PetModule.db.profile[info.arg][info[#info]]
  else
    return PetModule.db.profile[info[#info]]
  end
end

function PetModuleOptions:SetValue(info, value)
  if info.arg then
    PetModule.db.profile[info.arg][info[#info]] = value
  else
    PetModule.db.profile[info[#info]] = value
  end
end
