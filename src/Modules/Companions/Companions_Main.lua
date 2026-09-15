--------------------------------------------------------------------------------
-- Companion Module Initialization and Lifecycle
--------------------------------------------------------------------------------
---
local addonName, addonTable = ...
---@class AceAddon: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon(addonName)
---@class AceAddon: AceTimer-3.0, GMM_Companion
local companionModule = addOn:NewModule("CompanionModule", "AceTimer-3.0");

_G["GMM_Companions"] = mod

---@class GMM_Companion
---@field Commands table
---@field Database table
---@field Automation table,
---@field Summoning table,
---@field Config table,
---@field Settings table,
---@field Cache table

Mixin(companionModule, {
  Commands = {},
  Database = {},
  Automation = {},
  Summoning = {},
  Config = {},
  Settings = {},
  Cache = {},
})

function companionModule:OnInitialize()
  companionModule.Database:Init()
  companionModule.Settings:Init()
  companionModule.Cache:Init()
  companionModule.Automation:Init()
  companionModule.Config:Init()
end

function companionModule:OnEnable()
end

function companionModule:OnDisable()
end
