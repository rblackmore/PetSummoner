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
  ["GetCurrentZoneType"] = function()
    if IsResting() then
      return "RESTING"
    end

    local _, instanceType = IsInInstance()
    return PETSUMMONER_LOCATIONTYPES[instanceType]
  end
}
