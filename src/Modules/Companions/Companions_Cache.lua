--------------------------------------------------------------------------------
--- Companions Cache
--- Handles caching of current effectivecompanion data and refreshing it on relevant events.
--------------------------------------------------------------------------------

local addonName, addonTable = ...
---@class AceAddon: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon(addonName)
---@class AceAddon: AceTimer-3.0, GMM_Companion
local companionsModule = addOn:GetModule("CompanionModule")

local Data = addOn.Data
local Cache = companionsModule.Cache
local Database = companionsModule.Database

LibStub("AceTimer-3.0"):Embed(Cache)
LibStub("AceBucket-3.0"):Embed(Cache)
LibStub("AceEvent-3.0"):Embed(Cache)

--- Local Constants
local BUCKET_INTERVAL = 0.5

local EVENTS_TO_REGISTER = {
  "PLAYER_ENTERING_WORLD",
  "ZONE_CHANGED",
  "ZONE_CHANGED_INDOORS",
  "ZONE_CHANGED_NEW_AREA",
  "NEW_WMO_CHUNK",
  "TRANSMOG_COLLECTION_UPDATED"
}
--------------------------------------------------------------------------------
--- Cache Local State
--------------------------------------------------------------------------------
---@class GMM_Companion_List
local effectivePetListCache = nil
---@class GMM_Companion_List
local fallbackPetList = nil

--------------------------------------------------------------------------------
--- Cache Public API
--------------------------------------------------------------------------------
function Cache:Init()
  self:RegisterBucketEvent(EVENTS_TO_REGISTER, BUCKET_INTERVAL, "RefreshEffectiveList")
  self:RegisterBucketEvent("PET_JOURNAL_LIST_UPDATE", BUCKET_INTERVAL, "RefreshEffectiveList")

  Data.Companions.RegisterCallback(self, "OnProfileChanged", "RefreshEffectiveList")
  Data.Companions.RegisterCallback(self, "OnProfileCopied", "RefreshEffectiveList")
  Data.Companions.RegisterCallback(self, "OnProfileReset", "RefreshEffectiveList")

  self:RegisterMessage("GMM_CONFIG_USEFAVORITES_CHANGED", "RefreshFallback")

  self:Refresh()
end

function Cache:Refresh()
  self:RefreshEffectiveList()
  self:RefreshFallback()
end

function Cache:RefreshEffectiveList()
  local list = Database:GetCurrentContextPetList()
  effectivePetListCache = list

  self:SendMessage("GMM_EFFECTIVE_PET_LIST_UPDATED")
end

function Cache:RefreshFallback()
  fallbackPetList = Database:BuildFallbackList()
  self:SendMessage("GMM_FALLBACK_PET_LIST_UPDATED")
end

function Cache:GetEffectivePetList()
  if effectivePetListCache and not effectivePetListCache:isEmpty() then
    return effectivePetListCache
  end

  if fallbackPetList and not fallbackPetList:isEmpty() then
    return fallbackPetList
  end
  addOn:Print("Uh Oh")

  -- Uh Oh!!!!
end
