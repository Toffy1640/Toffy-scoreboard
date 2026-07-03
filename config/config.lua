Config = {}

Config.Framework = "auto" -- qbcore,qbox,esx
Config.Language = "en"
Config.InventoryImagePath = "nui://ox_inventory/web/images/"
Config.OpenCommand = "scoreboard"
Config.OpenKey = "F6" 
Config.Layout = "center-full"

Config.OverheadIds = {
    Enabled = true,
    Key = "F6",
    Distance = 15.0,
    DrawOutline = true,
}

Config.Privacy = {
    HidePing = false,
    HideJobs = false,
    AnonymousNames = false,
    UseRPName = true,
}

Config.Theme = {
    Primary = "#be2edd",  -- primary color
    Success = "#2ecc71",  -- success color
    Danger = "#e74c3c",   -- danger color
    Gold = "#f1c40f",     -- gold color
    BackgroundDark = "#0a0b0d", -- background dark color
    PanelBackground = "#101115",-- panel background color
    CardBackground = "#14151a"  -- card background color
}

Config.TrackedJobs = {
    { job = "police", label = "Police", icon = "fa-solid fa-shield-halved", color = "#60a5fa" },
    { job = "ambulance", label = "EMS", icon = "fa-solid fa-briefcase-medical", color = "#fb7185" },
    { job = "mechanic", label = "Mechanic", icon = "fa-solid fa-wrench", color = "#fb923c" },
    { job = "taxi", label = "Taxi", icon = "fa-solid fa-taxi", color = "#facc15" },
    { job = "cardealer", label = "Dealer", icon = "fa-solid fa-car", color = "#34d399" },
}

Config.Heists = {
    {
        id = "fleeca",
        label = "Fleeca Bank",
        icon = "fa-solid fa-building-columns",
        minCops = 1,
        enabled = true
    },
    {
        id = "paleto",
        label = "Paleto Bank",
        icon = "fa-solid fa-vault",
        minCops = 4,
        enabled = true
    },
    {
        id = "pacific",
        label = "Pacific Standard",
        icon = "fa-solid fa-landmark",
        minCops = 6,
        enabled = true
    },
    {
        id = "yacht",
        label = "Yacht Robbery",
        icon = "fa-solid fa-ship",
        minCops = 3,
        enabled = true
    },
    {
        id = "jewelry",
        label = "Vangelico Jewelry",
        icon = "fa-solid fa-gem",
        minCops = 3,
        enabled = true
    },
    {
        id = "humanelabs",
        label = "Humane Labs",
        icon = "fa-solid fa-flask",
        minCops = 5,
        enabled = true
    }
}
