---@diagnostic disable: duplicate-set-field
---@class AceAddon AceConsole AceEvent
PetSummoner = LibStub("AceAddon-3.0"):NewAddon("PetSummoner", "AceConsole-3.0", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local defaults = {
    profile = {
        ["msgFormat"] = "Help me %s you're my only hope!!!",
        ["channel"] = "SAY",
        ["useCustomName"] = true,
        ["FavoritePets"] = {}
    }
}

local options = {
    name = "PetSummoner",
    handler = PetSummoner,
    type = "group",
    args = {
        msgFormat = {
            type = "input",
            name = "Message Format",
            desc = "Format of the message to display, use %s in place where pet name should be shown.",
            usage = "<Your message>",
            get = "GetMessageFormat",
            set = "SetMessageFormat",
        },
        useCustomName = {
            type = "toggle",
            name = "Custom Name",
            desc = "Use Custom Name if one is set, otherwise Species Name.",
            get = "IsCustomName",
            set = "ToggleCustomName"
        },
        channel = {
            type = "select",
            name = "Channel",
            desc = "The Channel to Announce your Pet Summon",
            values = {
                ["SAY"] = "SAY",
                ["EMOTE"] = "EMOTE",
                ["YELL"] = "YELL",
                ["PARTY"] = "PARTY",
                ["RAID"] = "RAID",
                ["INSTANCE_CHAT"] = "INSTANCE_CHAT",
                ["GUILD"] = "GUILD",
            },
            get = "GetAnnounceChannel",
            set = "SetAnnounceChannel",
        }
    }
}

-- #region LifeTime Functions
function PetSummoner:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("PetSummonerDB", defaults, true)
    AceConfig:RegisterOptionsTable("PetSummoner", options)
    self.optionsFrame, self.optionsCategoryId = AceConfigDialog:AddToBlizOptions("PetSummoner", "PetSummoner")

    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    AceConfig:RegisterOptionsTable("PetSummoner_Profiles", profiles)
    AceConfigDialog:AddToBlizOptions("PetSummoner_Profiles", "Profiles", "PetSummoner")

    self:RegisterChatCommand("petsummon", "SlashCommand")
    self:RegisterChatCommand("ps", "SlashCommand")
    self:RegisterChatCommand("summonhelp", "SlashCommand")
    self:RegisterChatCommand("sh", "SlashCommand")
    -- self:LoadFavoritePets()
    -- self:LoadMounts()
end

function PetSummoner:OnEnable()
end

function PetSummoner:OnDisable()
end

local function iter_Pets()
    local iterator = 0
    local numPets, ownedPets = C_PetJournal.GetNumPets()

    PetSummoner:Print("Num Pets:", numPets)
    PetSummoner:Print("Owned Pets:", ownedPets)

    return function()
        iterator = iterator + 1
        if iterator <= numPets then
            ---@type string
            local petID = C_PetJournal.GetPetInfoByIndex(iterator)

            ---@class PetJournalPetInfo
            local petTable = C_PetJournal.GetPetInfoTableByPetID(petID)
            PetSummoner:Print("ID:", petID)
            PetSummoner:Print("Details:", petTable.name, petTable.isFavorite)
            petTable.petID = petID
            return petTable
        end
    end
end

function PetSummoner:LoadMounts()
    local numMounts = C_MountJournal.GetNumMounts()
    PetSummoner:Print("Num Mounts:", numMounts)
end

-- #endregion
function PetSummoner:LoadFavoritePets()
    if C_PetJournal.HasFavoritePets() == false then
        self:Print("No Favorite Pets Found")
        return
    end
    -- Clear Filters, if We dont' do this, we may not find any favorite pets in the filter.
    C_PetJournal.SetDefaultFilters()
    C_PetJournal.SetSearchFilter("")

    local favoritePets = {}
    for pet in iter_Pets() do
        PetSummoner:Print("Testing:", pet.name)
        PetSummoner:Print("isFavorite:", pet.isFavorite)
        if pet.isFavorite then
            PetSummoner:Print("is Favorite")
            favoritePets[#favoritePets + 1] = pet
        end
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
