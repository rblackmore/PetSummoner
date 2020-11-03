SLASH_SUMMONHELP1 = "/summonhelp"
SLASH_SUMMONHELP2 = "/sh"
SLASH_SUMMONHELP3 = "/petsummon"
SLASH_SUMMONHELP4 = "/ps"
SlashCmdList["SUMMONHELP"] = function(self, txt)
    numPets, numOwned = C_PetJournal.GetNumPets()
    rand = math.random(numOwned)
    petID, _, _, name, _, isFavorite, _, specname = C_PetJournal.GetPetInfoByIndex(rand)

    summonedID = C_PetJournal.GetSummonedPetGUID()

    while (isFavorite == false or summonedID == petID)
    do
        rand = math.random(numOwned)
        petID, _, _, name, _, isFavorite, _, specname = C_PetJournal.GetPetInfoByIndex(rand)
    end

    C_PetJournal.SummonPetByGUID(petID)
    
    if (name == nil) then
        name = specname
    end

    SendChatMessage("Help me ".. name .. " you're my only hope!!!","SAY")
end