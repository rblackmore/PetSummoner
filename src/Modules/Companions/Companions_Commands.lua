local addonName, addonTable = ...
---@class AceAddon: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon(addonName)
---@class AceAddon: AceTimer-3.0, GMM_Companion
local companionModule = addOn:GetModule("CompanionModule")

local Commands = companionModule.Commands
local Database = companionModule.Database

local MapUtils = addonTable.MapUtils
local Enums = addonTable.Enums
local CombatLockdownUtils = addonTable.CombatLockdownUtils

--------------------------------------------------------------------------------
--- Local Functions and Constants
--------------------------------------------------------------------------------

local SCOPES = Enums.SCOPES

local actions = {
  add = "add",
  remove = "remove",
  clear = "clear",
  list = "list"
}

local function getScopeWithArgs(...)
  local scope = SCOPES[select(1, ...)]

  if not scope then
    return SCOPES.world, { select(1, ...) }
  end

  return scope, { select(2, ...) }
end

--------------------------------------------------------------------------------
--- Module API
--------------------------------------------------------------------------------
function Commands:HandleAction(action, ...)
  -- ... = { everything users passed after action }
  -- Could be: { "zone", "[item:123]", "[item:456]"}
  -- or: {"[item:123]", "[item:456]"}
  -- or: {"zone"} -- scope without items means action of list or clear.

  local scope, args = getScopeWithArgs(...);
  local ensure = action == actions.add
  local list = Database:GetListForContextScope(scope, ensure)

  if action == actions.list then
    if not list then
      addOn:Print("No List for " .. scope)
      return
    end

    for i, v in ipairs(list.order) do
      local petTable = C_PetJournal.GetPetInfoTableByPetID(v)
      addOn:Printf("[%d] %s", i, petTable.name)
    end
    return
  end

  if action == actions.clear then
    list:clear()
    return
  end

  if not args[1] or type(args[1]) ~= "string" or not LinkUtil.IsLinkType(args[1], LinkTypes.BattlePet) then
    return
  end

  local _, linkOptions, _ = LinkUtil.ExtractLink(args[1])
  local _, _, _, _, _, _, petGUID = LinkUtil.SplitLinkOptions(linkOptions)

  if action == actions.add then
    list:add(petGUID)
    return
  end

  if action == actions.remove then
    list:remove(petGUID)
  end
end
