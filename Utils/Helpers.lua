local _, addonTable = ...
local addOn = addonTable.addOn

local function convertInstanceTypeToZoneType(instanceType)
  local instanceTypes = {

    ["pvp"] = "BATTLEGROUND",
    ["arena"] = "ARENA",
    ["party"] = "DUNGEON",
    ["raid"] = "RAID",
    ["scenario"] = "SCENARIO",
    ["none"] = "GLOBAL",
  }

  local zoneType = instanceTypes[instanceType]
  return zoneType or ""
end

function addOn:GetCurrentZoneType()
  if IsResting() then
    return "RESTING"
  end
  local _, instanceType = IsInInstance()
  return convertInstanceTypeToZoneType(instanceType)
end

function addOn:ConvertDbNumberToMapType(number)
  local mapTypes = {
    [0] = "COSMIC",
    [1] = "WORLD",
    [2] = "CONTINENT",
    [3] = "ZONE",
    [4] = "DUNGEON",
    [5] = "MICRO",
    [6] = "ORPHAN"
  }
  local mapType = mapTypes[number]
  return mapType or ""
end