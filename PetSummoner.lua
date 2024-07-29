---@diagnostic disable: duplicate-set-field

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

function PetSummoner:LoadFavoritePets()
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

    PetSummoner:Print("Num Favorite Pets:", #favoritePets)
    self.db.profile["FavoritePets"] = favoritePets
end

function PetSummoner:SlashCommand(msg)
    if msg:trim() == "config" then
        Settings.OpenToCategory(self.optionsCategoryId)
        return
    end

    self:SummonFavoritePet();
end

function PetSummoner:GetMessageFormat(info)
    return self.db.profile.msgFormat
end

function PetSummoner:SetMessageFormat(info, value)
    self.db.profile.msgFormat = value
end

function PetSummoner:GetAnnounceChannel(info)
    return self.db.profile.channel
end

function PetSummoner:SetAnnounceChannel(info, value)
    self.db.profile.channel = value
end

function PetSummoner:IsCustomName(info)
    return self.db.profile.useCustomName
end

function PetSummoner:ToggleCustomName(info, value)
    self.db.profile.useCustomName = value
end

function PetSummoner:SummonFavoritePet()
    local db = self.db;
    self:LoadFavoritePets()

    local favoritePets = db.profile["FavoritePets"]

    local isCustomName = db.profile.useCustomName
    local msgFormat = db.profile.msgFormat

    local rand = math.random(#favoritePets)
    local selectedPetID = favoritePets[rand]

    C_PetJournal.SummonPetByGUID(selectedPetID)
    local _, customName, _, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(selectedPetID)
    local name = isCustomName and customName or name

    SendChatMessage(format(msgFormat, name), db.profile.channel)
end
