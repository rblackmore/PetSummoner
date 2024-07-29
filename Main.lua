---@diagnostic disable: duplicate-set-field
---@class AceAddon AceConsole AceEvent
local addOn = LibStub("AceAddon-3.0"):NewAddon("PetSummoner", "AceConsole-3.0", "AceEvent-3.0")
---@class AceModule
local Options = addOn:NewModule("Options")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")



function addOn:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("PetSummonerDB", Options:GetDefaultOptions(), true)

  local globalOptions = Options:GetOptionsTable()
  AceConfig:RegisterOptionsTable("PetSummoner", globalOptions)

  self.globalOptionsFrame, self.globalOptionsCategoryId =
      AceConfigDialog:AddToBlizOptions("PetSummoner", "PetSummoner")

  local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

  AceConfig:RegisterOptionsTable("PetSummoner_Profiles", profiles)
  AceConfigDialog:AddToBlizOptions("PetSummoner_Profiles", "Profiles", "PetSummoner")

  self:RegisterChatCommand("petsummon", "ExecuteChatCommand")
  self:RegisterChatCommand("ps", "ExecuteChatCommand")
  self:RegisterChatCommand("summonhelp", "ExecuteChatCommand")
  self:RegisterChatCommand("sh", "ExecuteChatCommand")
  -- self:LoadFavoritePets()
  -- self:LoadMounts()
end

function addOn:OnEnable()
end

function addOn:OnDisable()
end

function addOn:ExecuteChatCommand(msg)
  if msg:trim() == "config" then
    Settings.OpenToCategory(self.globalOptionsCategoryId)
    return
  end

  self:SummonFavoritePet();
end
