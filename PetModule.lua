---@diagnostic disable: duplicate-set-field

---@class AceAddon: AceConsole-3.0, AceEvent-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")

---@class AceModule
local Options = addOn:GetModule("Options")
---@class AceModule: AceConsole-3.0, AceEvent-3.0
local PetModule = addOn:GetModule("PetModule")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local eventsToRegister = {

}

local registeredEvents = {}

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

function PetModule:GetPetModuleDefaultDatabase()
    local defaults = {
        ["profile"] = {
            ["MessageFormat"] = "Help me %s you're my only hope!!!",
            ["UseCustomName"] = true,
            ["FavoritePets"] = {},
        }
    }
    return defaults
end

local petModuleOptions = {
    ["MessageFormat"] = {
        type = "input",
        name = "Message Format",
        desc = "Format of the message to display, use %s in place where pet name should be shown.",
        usage = "<Your message>",
        get = "GetValue",
        set = "SetValue",
    },
    ["UseCustomName"] = {
        type = "toggle",
        name = "Custom Name",
        desc = "Use Custom Name if one is set, otherwise Species Name.",
        get = "GetValue",
        set = "SetValue",
    },
}

function PetModule:GetPetModuleOptionsTable()
    local options = {
        name = "Pets",
        handler = PetModule,
        type = "group",
        args = petModuleOptions
    }
    return options
end

function PetModule:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PetSummoner_PetModuleDB", self:GetPetModuleDefaultDatabase(), true)

    AceConfig:RegisterOptionsTable("PetSummoner_PetModule", self:GetPetModuleOptionsTable(), "petconfig")

    local petmoduleFrame, petmoduleId =
        AceConfigDialog:AddToBlizOptions("PetSummoner_PetModule", "Pets", Options.GlobalSettingsDialog["Id"])

    Options.PetModuleSettingsDialog = {
        ["Frame"] = petmoduleFrame,
        ["Id"] = petmoduleId,
    }

    for _, event in ipairs(eventsToRegister) do
        if not registeredEvents[event] then
            self:RegisterEvent(event)
            registeredEvents[event] = true
        end
    end
end

function PetModule:OnEnable()
end

function PetModule:OnDisable()
end

function PetModule:GetValue(info)
    if info.arg then
        return self.db.profile[info.arg][info[#info]]
    else
        return self.db.profile[info[#info]]
    end
end

function PetModule:SetValue(info, value)
    if info.arg then
        self.db.profile[info.arg][info[#info]] = value
    else
        self.db.profile[info[#info]] = value
    end
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
    
    if moduleDB["FavoritePets"] == nil then
        self:LoadFavoritePets()
    end

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
    local msgFormat = self.db.profile["MessageFormat"]
    local channel = addOn.db.profile["Channel"]

    SendChatMessage(format(msgFormat, petName), channel)
end
