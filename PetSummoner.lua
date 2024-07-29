---@diagnostic disable: duplicate-set-field

---@class AceAddon AceConsole AceEvent
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")
---@class AceModule
local Options = addOn:GetModule("Options")

local function iPetIDs()
    local iterator = 0
    local numPets, ownedPets = C_PetJournal.GetNumPets()

    return function()
        iterator = iterator + 1
        if iterator <= ownedPets then
            local petID = C_PetJournal.GetPetInfoByIndex(iterator)
            return petID
        end
    end
end
-- Currently, I load favorites when SummonFavoritePet() is called only.
-- There's a but when doing it onInitialize at logon, but not on reload.
-- I should look into various Events to hook into, and only call LoadFavoritePets() when approppriate
-- IE: On login, reload, fav pet added/removed.

function addOn:LoadFavoritePets()
    if C_PetJournal.HasFavoritePets() == false then
        self:Print("No Favorite Pets Found")
        return
    end
    -- Clear Filters, if We dont' do this, we may not find any favorite pets in the filter.
    C_PetJournal.SetDefaultFilters()
    C_PetJournal.SetSearchFilter("")

    local favoritePets = {}
    for id in iPetIDs() do
        -- if pet.isFavorite then
        local petInfo = C_PetJournal.GetPetInfoTableByPetID(id)
        if petInfo.isFavorite then
            favoritePets[#favoritePets + 1] = id
        end
        -- end
    end

    self.db.profile["FavoritePets"] = favoritePets
end

function addOn:SummonFavoritePet()
    local db = self.db;
    self:LoadFavoritePets()

    local favoritePets = db.profile["FavoritePets"]

    local useCustomName = db.profile["UseCustomName"]
    local msgFormat = db.profile["MessageFormat"]
    local channel = db.profile["Channel"]

    local rand = math.random(#favoritePets)
    local selectedPetID = favoritePets[rand]

    C_PetJournal.SummonPetByGUID(selectedPetID)
    local _, customName, _, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(selectedPetID)
    local name = useCustomName and customName or name

    SendChatMessage(format(msgFormat, name), channel)
end
