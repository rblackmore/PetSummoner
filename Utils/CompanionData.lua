local _, addonTable = ...
local addOn = addonTable.addOn

addonTable.CompanionData = {}
local companionData = addonTable.CompanionData

-- Iterates over ALL Pets in PetJounal, returning all values from GetPetInfoByIndex.
function companionData:CompanionIterator()
  local iterator = 0
  local numPets, _ = C_PetJournal.GetNumPets();
  return function()
    iterator = iterator + 1
    if iterator <= numPets then
      return C_PetJournal.GetPetInfoByIndex(iterator)
    end
  end
end
