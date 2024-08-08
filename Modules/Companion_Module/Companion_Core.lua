local addonName, addonTable = ...
local addOn = addonTable.addOn
local companionModule = addOn:NewModule("CompanionModule")

function companionModule:OnInitialize()
  self:LoadDatabase()
end

function companionModule:OnEnable()
  for name, module in self:IterateModules() do
    module:Enable()
  end
  self:CatalogCompanions()
end

function companionModule:OnDisable()
  for name, module in self:IterateModules() do
    module:Disable()
  end
end

function companionModule:CatalogCompanions()
  -- Clear Filters, if We dont' do this, we may not find any pets in the filter
  C_PetJournal.ClearSearchFilter()

  if not C_PetJournal.IsUsingDefaultFilters() then
    C_PetJournal.SetDefaultFilters()
  end

  local ownedCompanionData = {}
  -- Loop over all Pet Ids, if they are set as favorite, add the Id to list.
  for petId, _, owned, customName, _, isFav, _, name in addonTable.CompanionData:CompanionIterator() do
    if isFav then
      self:AddCompanionToZone(petId, "FavoritePets")
    end
    if owned then
      ownedCompanionData[#ownedCompanionData + 1] = {
        petID = petId,
        owned = owned,
        customName = customName,
        favorite = isFav,
        name = name
      }
    end
  end

  addonTable.CompanionData.Owned = ownedCompanionData
end

--[[
  Gets Eligable Summons.
  Filters out currently summoned pet from current zone pets.
  More Filters to come, based on class, race, faction etc.
  --]]
function companionModule:GetEligableSummons()
  local currentZoneCompanions = self:GetCurrentZoneCompanionList()

  local inverted = {}
  for k, v in ipairs(currentZoneCompanions) do
    inverted[v] = k
  end

  local summonedId = C_PetJournal.GetSummonedPetGUID()
  inverted[summonedId] = nil

  return inverted
end

function companionModule:SummonCompanion(announce)
  local settings = self.db["profile"].Settings
  local summonedId

  if settings["PetOfTheDay"].Enabled then
    summonedId = self:SummonPetofTheDay()
  else
    summonedId = self:SummonRandomCompanion()
  end

  if not announce then
    return
  end

  self:AnnounceSummon(summonedId)
end

function companionModule:SummonPetofTheDay()
  local settings = self.db["profile"].Settings
  local petId

  local summonedDate = settings["PetOfTheDay"].Date
  local currentDate = date("*t")
  -- If Saved Date Is Today, used saved PetId
  if summonedDate.year == currentDate.year and summonedDate.month == currentDate.month and summonedDate.day == currentDate.day then
    if not settings["PetOfTheDay"].PetId then
      settings["PetOfTheDay"].PetId = self:PickRandomPetId()
    end
    petId = settings["PetOfTheDay"].PetId
  else
    settings["PetOfTheDay"].PetId = self:PickRandomPetId()
    petId = settings["PetOfTheDay"].PetId
    settings["PetOfTheDay"].Date = {
      ["year"] = currentDate.year,
      ["month"] = currentDate.month,
      ["day"] = currentDate.day,
    }
  end
  if C_PetJournal.GetSummonedPetGUID() ~= petId then
    C_PetJournal.SummonPetByGUID(petId)
  end

  return petId
end

function companionModule:PickRandomPetId()
  local eligablePets = self:GetEligableSummons()

  local randoPetId = eligablePets[math.random(#eligablePets)]

  return randoPetId
end

function companionModule:SummonRandomCompanion()
  local randoPetId = self:PickRandomPetId()

  C_PetJournal.SummonPetByGUID(randoPetId)

  return randoPetId
end

-- TODO: Maybe update this to work if settings are not restricted. see: https://x.com/deadlybossmods/status/1176
function companionModule:AnnounceSummon(petId)
  local _, customName, _, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(petId)

  local useCustomName = self.db["profile"].Settings["UseCustomName"]
  local name = useCustomName and customName or name

  local msgFormat = companionModule.db["profile"].Settings["MessageFormat"]
  local channel = Options.db["profile"]["Channel"]

  SendChatMessage(format(msgFormat, name), channel)
end

-- function PetModule:GetValue(info)
--   if info.arg then
--     return self.db["profile"].Settings[info.arg][info[#info]]
--   else
--     return self.db["profile"].Settings[info[#info]]
--   end
-- end

-- function PetModule:SetValue(info, value)
--   if info.arg then
--     self.db["profile"].Settings[info.arg][info[#info]] = value
--   else
--     self.db["profile"].Settings[info[#info]] = value
--   end
-- end
