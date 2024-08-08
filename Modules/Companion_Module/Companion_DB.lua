local addonName, addonTable = ...
local addOn = addonTable.addOn
local companionModule = addOn:GetModule("CompanionModule")

local defaults = {
  ["profile"] = {
    ["Settings"] = {
      ["MessageFormat"] = "Help me %s you're my only hope!!!",
      ["Channel"] = "SAY",
      ["UseCustomName"] = true,
      ["Automation"] = {
        ["delay"] = 2,
        ["GLOBAL"] = true,
        ["SCENARIO"] = true,
        ["RAID"] = true,
        ["DUNGEON"] = true,
        ["ARENA"] = true,
        ["BATTLEGROUND"] = true,
        ["RESTING"] = true,
        ["PetOfTheDay"] =
        {
          Enabled = true,
          Date = {
            ["year"] = 2004,
            ["month"] = 11,
            ["day"] = 23,
          },
          PetId = nil,
        },
      }
    },
    ["Companions"] = {
      ["FavoritePets"] = {},
    }
  }
}

function companionModule:Zone_Contains(id, zone)
  for i, v in ipairs(self.db["profile"]["Companions"][zone]) do
    if v == id then
      return true
    end
  end
  return false
end

function companionModule:GetDefaultDbValues()
  return defaults
end

function companionModule:LoadDatabase()
  self.db = LibStub("AceDB-3.0"):New("GMM_CompanionDB", self:GetDefaultDbValues(), true)
end

function companionModule:GetCurrentZoneCompanionList()
  local location = GetZoneText()
  if self.db["profile"]["Companions"][location] ~= nil and #self.db["profile"]["Companions"][location] > 0 then
    return self.db["profile"]["Companions"][location]
  end

  location = addOn.GetCurrentZoneType()

  if self.db["profile"]["Companions"][location] ~= nil and #self.db["profile"]["Companions"][location] > 0 then
    return self.db["profile"]["Companions"][location]
  end

  return self.db["profile"]["Companions"]["FavoritePets"]
end

function companionModule:AddCompanionToZone(id, zone)
  if not self.db["profile"]["Companions"][zone] then
    self.db["profile"]["Companions"][zone] = {} -- Create New Table for Zone if Not exist.
  end
  if not self:Zone_Contains(id, zone) then
    self.db["profile"]["Companions"][zone][#self.db["profile"]["Companions"][zone] + 1] = id
  end
end

function companionModule:RemoveCompanionFromZone(id, zone)
  if not self.db["profile"]["Companions"][zone] then
    return
  end
  if self:Zone_Contains(id, zone) then
    self.db["profile"]["Companions"][zone][i] = nil
  end
end
