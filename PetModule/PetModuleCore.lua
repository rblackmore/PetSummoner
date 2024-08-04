---@diagnostic disable: duplicate-set-field

---@class AceAddon: AceConsole-3.0, AceEvent-3.0
local addOn = LibStub("AceAddon-3.0"):GetAddon("PetSummoner")

---@class AceModule
local Options = addOn:GetModule("Options")
---@class AceModule: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local PetModule = addOn:GetModule("PetModule")
---@class AceModule: AceConsole-3.0, AceEvent-3.0, AceTimer-3.0
local PetAutomationModule = PetModule:NewModule("PetAutomationModule", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")


local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")



local eventsToRegister = {
    -- "PET_JOURNAL_LIST_UPDATE",
    "ZONE_CHANGED_NEW_AREA", -- Player changes major Zone, et, Orgrimmar -> Durotar
    "ZONE_CHANGED",          -- Player changes minor zone, eg, Valley of Honor -> The Drag
}

local registeredEvents = {}

function PetModule:ZONE_CHANGED_NEW_AREA()
end

function PetModule:ZONE_CHANGED()
end

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

function PetModule:GetDefaultDatabase()
    local defaults = {
        ["profile"] = {
            ["Settings"] = {
                ["MessageFormat"] = "Help me %s you're my only hope!!!",
                ["UseCustomName"] = true,
                ["AutoSummon"] = {
                    ["delay"] = 2,
                    ["GLOBAL"] = true,
                    ["SCENARIO"] = true,
                    ["RAID"] = true,
                    ["DUNGEON"] = true,
                    ["ARENA"] = true,
                    ["BATTLEGROUND"] = true,
                    ["RESTING"] = true,
                    PetOfTheDay = { Enabled = false, Date = 0, PetId = 0 }
                }
            },
            ["FavoritePets"] = {},
            ["Companions"] = {}
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
    ["RefreshFavoritesList"] = {
        type = "execute",
        name = "Refersh",
        desc = "Refreshes list of Favorite Pets by Scanning the Pet Journal and adds them to database",
        handler = PetModule,
        func = "LoadFavoritePets"
    }
}

function PetModule:GetOptionsTable()
    local options = {
        name = "Pets",
        handler = PetModule,
        type = "group",
        args = petModuleOptions
    }
    return options
end

function PetModule:OnInitialize()
    self:ConfigureOptionsDataBase()

    for _, event in ipairs(eventsToRegister) do
        if not registeredEvents[event] then
            self:RegisterEvent(event)
            registeredEvents[event] = true
        end
    end
end

function PetModule:ConfigureOptionsDataBase()
    self.db = LibStub("AceDB-3.0"):New("PetSummoner_PetModuleDB", self:GetDefaultDatabase(), true)

    AceConfig:RegisterOptionsTable("PetSummoner_PetModule", self:GetOptionsTable(), "petconfig")

    local petmoduleFrame, petmoduleId =
        AceConfigDialog:AddToBlizOptions("PetSummoner_PetModule", "Pets", Options.GlobalSettingsDialog["Id"])

    Options.PetModuleSettingsDialog = {
        ["Frame"] = petmoduleFrame,
        ["Id"] = petmoduleId,
    }
end

function PetModule:OnEnable()
end

function PetModule:OnDisable()
end

function PetModule:GetValue(info)
    if info.arg then
        return self.db["profile"].Settings[info.arg][info[#info]]
    else
        return self.db["profile"].Settings[info[#info]]
    end
end

function PetModule:SetValue(info, value)
    if info.arg then
        self.db["profile"].Settings[info.arg][info[#info]] = value
    else
        self.db["profile"].Settings[info[#info]] = value
    end
end

function PetModule:AddFavoritesToLocation(location)
    self:LoadFavoritePets()
    self.db["profile"]["Companions"][location] = self.db["profile"]["FavoritePets"]
end

function PetModule:LoadFavoritePets()
    if C_PetJournal.HasFavoritePets() == false then
        self:Print("No Favorite Pets Found")
        return
    end
    -- Clear Filters, if We dont' do this, we may not find any favorite pets in the filter.
    if not C_PetJournal.IsUsingDefaultFilters() then
        self:Print("Clearing Default Pet Filters")
        C_PetJournal.SetDefaultFilters()
        C_PetJournal.ClearSearchFilter()
    end

    local favoritePets = {}
    -- Loop over all Pet Ids, if they are set as favorite, add the Id to list.
    for id in iPetIDs() do
        local petInfo = C_PetJournal.GetPetInfoTableByPetID(id)
        if petInfo.isFavorite then
            favoritePets[#favoritePets + 1] = id
        end
    end

    -- Add list of favorite pet ids to database.
    self.db["profile"]["FavoritePets"] = favoritePets
    self:Printf("%u pets added to Pet Summoner", #self.db["profile"]["FavoritePets"])

    return favoritePets
end

function PetModule:GetCurrentZoneCompanionList()
    local location = GetZoneText()
    if self.db["profile"]["Companions"][location] ~= nil and #self.db["profile"]["Companions"][location] > 0 then
        return self.db["profile"]["Companions"][location]
    end

    ---@diagnostic disable-next-line: cast-local-type
    location = PETSUMMONER_LOCATIONTYPES.GetCurrentZoneType()

    if self.db["profile"]["Companions"][location] ~= nil and #self.db["profile"]["Companions"][location] > 0 then
        return self.db["profile"]["Companions"][location]
    end

    return self.db["profile"]["FavoritePets"]
end

--[[
    Gets Eligable Summons.
    Filters out currently summoned pet from current zone pets.
    More Filters to come, based on class, race, faction etc.
--]]
function PetModule:GetEligableSummons()
    local currentZoneCompanions = self:GetCurrentZoneCompanionList()
    local companionSlots = {}

    local summonedId = C_PetJournal.GetSummonedPetGUID()
    for i = 1, #currentZoneCompanions do
        if currentZoneCompanions[i] ~= summonedId then
            companionSlots[i] = currentZoneCompanions[i]
        end
    end

    return companionSlots
end

function PetModule:SummonCompanion(announce)
    local eligablePets = self:GetEligableSummons()

    local randoPetId = eligablePets[math.random(#eligablePets)]

    C_PetJournal.SummonPetByGUID(randoPetId)

    local _, customName, _, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(randoPetId)

    local useCustomName = self.db["profile"].Settings["UseCustomName"]
    local name = useCustomName and customName or name

    if announce then
        self:AnnounceSummon(name)
    end
end

function PetModule:AnnounceSummon(petName)
    local msgFormat = PetModule.db["profile"].Settings["MessageFormat"]
    local channel = Options.db["profile"]["Channel"]

    SendChatMessage(format(msgFormat, petName), channel)
end
