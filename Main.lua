---@diagnostic disable: duplicate-set-field
---@class AceAddon: AceConsole-3.0, AceEvent-3.0
local addOn = LibStub("AceAddon-3.0"):NewAddon("PetSummoner", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
_G.PetSummoner = addOn

---@class AceModule
local Options = addOn:NewModule("Options")
---@class AceModule: AceConsole-3.0, AceEvent-3.0
local PetModule = addOn:NewModule("PetModule", "AceConsole-3.0", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function addOn:OnInitialize()

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
  local sep = " "
  local args = {}
  local total = 0
  for str in string.gmatch(msg, "([^" .. sep .. "]+)") do
    total = total + 1
    table.insert(args, total, str)
  end

  if args[1] == "config" then
    Settings.OpenToCategory(Options.GlobalSettingsDialog["Id"])
    return
  elseif args[1] == "add" then
    if (args[2] ~= nil) then
      PetModule:AddPetToCurrentLocation(args[2])
      return
    end
  end

  PetModule:SummonCompanion(true);
end
