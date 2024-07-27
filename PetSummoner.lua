local addOnName, pSummoner = ...
_G[addOnName] = pSummoner

local f = CreateFrame("Frame")

local defaults = {
    ["msgFormat"] = "Help me %s you're my only hope!!!",
    ["channelType"] = "SAY",
    ["FavoritePets"] = {}
}

function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

function f:ADDON_LOADED(event, name)
    if name ~= addOnName then return end
    PetSummonerDB = PetSummonerDB or CopyTable(defaults)
    self.db = PetSummonerDB
    -- self:InitializeOptions()
end

function f:ResetData()
    PetSummonerDB = CopyTable(defaults)
    self.db = PetSummonerDB
    print("Pet Summoner Data Reset")
end

function f:SummonFavoritePet()
    local db = self.db

    if C_PetJournal.HasFavoritePets() == false then
        print("No Favorite Pets Found")
    end

    C_PetJournal.SetDefaultFilters()
    C_PetJournal.SetSearchFilter("")

    local numPets, numOwned = C_PetJournal.GetNumPets()

    local favoritePets = {}

    for i = 1, numPets do
        local petID, _, owned, customName, _, isFavorite, _, speciesName, _, _, _, _, description, _, _, _, _, _ =
            C_PetJournal.GetPetInfoByIndex(i)

        if isFavorite then
            favoritePets[i] = {
                ["petID"] = petID,
                ["owned"] = owned,
                ["customName"] = customName,
                ["favorite"] = isFavorite,
                ["speciesName"] = speciesName,
                ["description"] = description
            }
        end
    end

    db["FavoritePets"] = favoritePets

    local rand = math.random(#db["FavoritePets"])
    local selectedPet = db["FavoritePets"][rand]
    local id = selectedPet.petID
    local name = selectedPet.customName or selectedPet.speciesName

    C_PetJournal.SummonPetByGUID(id)

    SendChatMessage(format(db["msgFormat"], name))
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

SLASH_PETSUMMONER_SUMMONHELP1, SLASH_PETSUMMONER_SUMMONHELP2, SLASH_PETSUMMONER_SUMMONHELP3, SLASH_PETSUMMONER_SUMMONHELP4 =
    "/summonhelp", "/sh", "/petsummon", "/ps";
SLASH_PETSUMMONER_RESET1 = "/psreset"

SlashCmdList["PETSUMMONER_SUMMONHELP"] = function(msg, editbox)
    f:SummonFavoritePet()
end

SlashCmdList["PETSUMMONER_RESET"] = function(msg, editbox)
    f:ResetData()
end
