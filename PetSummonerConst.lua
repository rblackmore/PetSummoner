PETSUMMONER_MAPTYPES = {
  [0] = "COSMIC",
  [1] = "WORLD",
  [2] = "CONTINENT",
  [3] = "ZONE",
  [4] = "DUNGEON",
  [5] = "MICRO",
  [6] = "ORPHAN"
}

PETSUMMONER_LOCATIONTYPES = {
  ["pvp"] = "BATTLEGROUND",
  ["arena"] = "ARENA",
  ["party"] = "DUNGEON",
  ["raid"] = "RAID",
  ["scenario"] = "SCENARIO",
  ["none"] = "GLOBAL",
  GetCurrentZoneType = function()
    local _, instanceType = IsInInstance()
    local zoneType = PETSUMMONER_LOCATIONTYPES[instanceType]

    if IsResting() then
      zoneType = "RESTING"
    end

    return zoneType
  end
}
