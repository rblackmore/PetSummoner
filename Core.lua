local addonName, addonTable = ...
addonTable.addOn = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
---@class AceAddon: AceConsole-3.0, AceEvent-3.0
local addOn = addonTable.addOn
addOn:SetDefaultModuleState(false)
addOn:SetDefaultModuleLibraries("AceEvent-3.0", "AceConsole-3.0")

---@class AceModule
local Options = addOn:NewModule("Options")


local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function addOn:OnInitialize()
  -- Setup Options
  -- Get OptionsTable, then Register With AceConfig -- Repeat for Each Options Set


  addOn:RegisterChatCommand("gmm", "SlashCommand")
  addOn:RegisterChatCommand("gmsummon", "ExecuteChatCommand")
end

function addOn:SlashCommand(args)
  if InCombatLockdown() then
    return
  end

  -- Open Config
end

function addOn:OnEnable()
  for name, module in self:IterateModules() do
    module:Enable()
  end
end

function addOn:OnDisable()
  for name, module in self:IterateModules() do
    module:Disable()
  end
end

function addOn:ExecuteChatCommand(args)
  PetModule:SummonCompanion(true);
end
