---@diagnostic disable: duplicate-set-field

---@class AceAddon: AceConsole-3.0, AceEvent-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")

---@class AceModule
local Options = addOn:GetModule("Options")
---@class AceModule: AceConsole-3.0, AceEvent-3.0
local PetModule = addOn:GetModule("PetModule")

-- Iterator, iterates over all pets, and returns each petID.
local function iPetIDs()
    local iterator = 0
    local numPets, ownedPets = C_PetJournal.GetNumPets()

    return function()
        iterator = iterator + 1
        if iterator <= numPets then
            local petID = C_PetJournal.GetPetInfoByIndex(iterator)
            return petID
        end
    end
end

function PetModule:GetDefaultOptions()
    local defaults = {
        ["profile"] = {
            ["UseCustomName"] = true,
            ["FavoritePets"] = {},
        }
    }
    return defaults
end

function PetModule:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PetSummoner_PetModuleDB", self:GetDefaultOptions(), true)
    self:LoadFavoritePets()
end

function PetModule:OnEnable()
end

function PetModule:OnDisable()
end

function PetModule:LoadFavoritePets()
    if C_PetJournal.HasFavoritePets() == false then
        self:Print("No Favorite Pets Found")
        return
    end
    -- Clear Filters, if We dont' do this, we may not find any favorite pets in the filter.
    C_PetJournal.SetDefaultFilters()
    C_PetJournal.SetSearchFilter("")

    local favoritePets = {}
    -- Loop over all Pet Ids, if they are set as favorite, add the Id to list.
    for id in iPetIDs() do
        local petInfo = C_PetJournal.GetPetInfoTableByPetID(id)
        if petInfo.isFavorite then
            favoritePets[#favoritePets + 1] = id
        end
    end

    -- Add list of favorite pet ids to database.
    self.db.profile["FavoritePets"] = favoritePets
end

function PetModule:SummonFavoritePet()
    local moduleDB = self.db;

    local favoritePets = moduleDB.profile["FavoritePets"]
    local useCustomName = moduleDB.profile["UseCustomName"]

    local rand = math.random(#favoritePets)
    local selectedPetID = favoritePets[rand]

    C_PetJournal.SummonPetByGUID(selectedPetID)
    local _, customName, _, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(selectedPetID)
    local name = useCustomName and customName or name

    self:AnnounceSummon(name)
end

function PetModule:AnnounceSummon(petName)
    local addOnDB = addOn.db;
    local msgFormat = addOnDB.profile["MessageFormat"]
    local channel = addOnDB.profile["Channel"]

    SendChatMessage(format(msgFormat, petName), channel)
end
