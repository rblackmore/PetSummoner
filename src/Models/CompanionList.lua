local addonName, addonTable = ...
---@class AceAddon: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0, GMM_Addon
local addOn = LibStub("AceAddon-3.0"):GetAddon(addonName)

addonTable.Models = addonTable.Models or {}
local Models = addonTable.Models

local tinsert = table.insert
local tremove = table.remove
local rando = math.random

--------------------------------------------------------------------------------
--- Companion List Model
--------------------------------------------------------------------------------
local CompanionList = {}
CompanionList.__index = CompanionList

Models.CompanionList = CompanionList

function CompanionList:new(data)
  if data then
    return setmetatable(data, CompanionList)
  else
    return setmetatable({ pets = {}, order = {}, weights = {} }, CompanionList)
  end
end

function CompanionList:isEmpty()
  return #self.order == 0
end

function CompanionList:add(petGUID, weight)
  self.weights[petGUID] = tonumber(weight) or 1.0

  if self.pets[petGUID] then
    return false
  end

  self.pets[petGUID] = true
  tinsert(self.order, petGUID)
  return true
end

function CompanionList:remove(petGUID)
  if not petGUID then return false end
  for i, v in ipairs(self.order) do
    if v == petGUID then
      tremove(self.order, i)
    end
  end

  self.pets[petGUID] = nil
  self.weights[petGUID] = nil
  return true
end

function CompanionList:clear()
  -- TODO: if this is not the world list, I may want to erase the table from DB Completely
  self.pets = {}
  self.weights = {}
  self.order = {}
end

function CompanionList:getRandom(current)
  local count = #self.order

  if count == 0 then return nil end
  if current and count == 1 then return nil end

  local random = rando(#self.order)
  local picked = self.order[random]

  if picked == current then
    local nextIndex = (random % count) + 1
    picked = self.order[nextIndex]
  end

  return picked
end

function CompanionList:hasPet(petGUID)
  return self.pets and petGUID and self.pets[petGUID]
end

function CompanionList:getPetNames()
  local names = {}

  for i, v in ipairs(self.order) do
    local petTable = C_PetJournal.GetPetInfoTableByPetID(v)
    tinsert(names, petTable.name)
  end

  return names
end
