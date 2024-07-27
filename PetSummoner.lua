PetSummoner = LibStub("AceAddon-3.0"):NewAddon("PetSummoner", "AceConsole-3.0", "AceEvent-3.0")

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

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
    AC:RegisterOptionsTable("PetSummoner", options)
    self.optionsFrame, self.optionsCategoryId = ACD:AddToBlizOptions("PetSummoner", "PetSummoner")

    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    AC:RegisterOptionsTable("PetSummoner_Profiles", profiles)
    ACD:AddToBlizOptions("PetSummoner_Profiles", "Profiles", "PetSummoner")

    self:RegisterChatCommand("petsummon", "SlashCommand")
    self:RegisterChatCommand("ps", "SlashCommand")
    self:RegisterChatCommand("summonhelp", "SlashCommand")
    self:RegisterChatCommand("sh", "SlashCommand")
    self:LoadFavoritePets()
end

function PetSummoner:OnEnable()
end

function PetSummoner:OnDisable()
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

    local numPets, _ = C_PetJournal.GetNumPets()
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

    local favoritePets = db.profile["FavoritePets"]
    if #favoritePets <= 0 then
        self:Print("Favorite Pets have not been Loaded")
        return
    end
    local isCustomName = db.profile.useCustomName
    local msgFormat = db.profile.msgFormat

    local rand = math.random(#favoritePets)
    local selectedPet = favoritePets[rand]

    C_PetJournal.SummonPetByGUID(selectedPet.petID)

    local name = isCustomName and selectedPet.customName or selectedPet.speciesName

    SendChatMessage(format(msgFormat, name), db.profile.channel)
end

-- function f:OnEvent(event, ...)
--     self[event](self, event, ...)
-- end

-- function f:ADDON_LOADED(event, name)
--     if name ~= addOnName then return end
--     PetSummonerDB = PetSummonerDB or CopyTable(defaults)
--     self.db = PetSummonerDB
--     -- self:InitializeOptions()
-- end

-- function f:ResetData()
--     PetSummonerDB = CopyTable(defaults)
--     self.db = PetSummonerDB
--     print("Pet Summoner Data Reset")
-- end

-- function f:SummonFavoritePet()
--     local db = self.db

--     if C_PetJournal.HasFavoritePets() == false then
--         print("No Favorite Pets Found")
--     end

--     C_PetJournal.SetDefaultFilters()
--     C_PetJournal.SetSearchFilter("")

--     local numPets, numOwned = C_PetJournal.GetNumPets()

--     local favoritePets = {}

--     for i = 1, numPets do
--         local petID, _, owned, customName, _, isFavorite, _, speciesName, _, _, _, _, description, _, _, _, _, _ =
--             C_PetJournal.GetPetInfoByIndex(i)

--         if isFavorite then
--             favoritePets[i] = {
--                 ["petID"] = petID,
--                 ["owned"] = owned,
--                 ["customName"] = customName,
--                 ["favorite"] = isFavorite,
--                 ["speciesName"] = speciesName,
--                 ["description"] = description
--             }
--         end
--     end

--     db["FavoritePets"] = favoritePets

--     local rand = math.random(#db["FavoritePets"])
--     local selectedPet = db["FavoritePets"][rand]
--     local id = selectedPet.petID
--     local name = selectedPet.customName or selectedPet.speciesName

--     C_PetJournal.SummonPetByGUID(id)

--     SendChatMessage(format(db["msgFormat"], name))
-- end

-- f:RegisterEvent("ADDON_LOADED")
-- f:SetScript("OnEvent", f.OnEvent)

-- SLASH_PETSUMMONER_SUMMONHELP1, SLASH_PETSUMMONER_SUMMONHELP2, SLASH_PETSUMMONER_SUMMONHELP3, SLASH_PETSUMMONER_SUMMONHELP4 =
--     "/summonhelp", "/sh", "/petsummon", "/ps";
-- SLASH_PETSUMMONER_RESET1 = "/psreset"

-- SlashCmdList["PETSUMMONER_SUMMONHELP"] = function(msg, editbox)
--     f:SummonFavoritePet()
-- end

-- SlashCmdList["PETSUMMONER_RESET"] = function(msg, editbox)
--     f:ResetData()
-- end
