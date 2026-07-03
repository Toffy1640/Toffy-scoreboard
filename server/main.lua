local Framework = nil
local FrameworkName = "none"
local ESX = nil
local QBCore = nil
local heistCustomStates = {}

local function DetectFramework()
    local fw = Config.Framework

    if fw == "auto" then
        if GetResourceState('qbx_core') == 'started' then
            fw = "qbx"
        elseif GetResourceState('qb-core') == 'started' then
            fw = "qbcore"
        elseif GetResourceState('es_extended') == 'started' then
            fw = "esx"
        else
            fw = "none"
        end
    end

    if fw == "none" then
        return false
    end

    FrameworkName = fw

    if fw == "qbcore" and not QBCore then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif fw == "esx" and not ESX then
        ESX = exports['es_extended']:getSharedObject()
    end

    return true
end

CreateThread(function()
    -- Keep retrying so load order can't leave us stuck on "none"
    -- (e.g. this resource starting before qbx_core / qb-core / es_extended).
    local tries = 0
    while not DetectFramework() and tries < 60 do
        tries = tries + 1
        Wait(500)
    end

    if FrameworkName == "qbcore" then
        print("^2[toffy-scoreboard] Successfully loaded QBCore Framework.^7")
    elseif FrameworkName == "qbx" then
        print("^2[toffy-scoreboard] Successfully loaded QBox Framework.^7")
    elseif FrameworkName == "esx" then
        print("^2[toffy-scoreboard] Successfully loaded ESX Framework.^7")
    else
        print("^1[toffy-scoreboard] WARNING: Running without framework integration. Only basic features will work.^7")
    end
end)

local function IsPlayerStaff(src)
    if IsPlayerAceAllowed(src, "admin") or IsPlayerAceAllowed(src, "god") or IsPlayerAceAllowed(src, "command") then
        return true
    end

    if FrameworkName == "qbcore" and QBCore then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            local permission = QBCore.Functions.GetPermission(src)
            if permission == "admin" or permission == "god" then
                return true
            end
        end
    elseif FrameworkName == "qbx" then
        if exports.qbx_core:HasPermission(src, 'admin') or exports.qbx_core:HasPermission(src, 'god') then
            return true
        end
    elseif FrameworkName == "esx" and ESX then
        local player = ESX.GetPlayerFromId(src)
        if player then
            local group = player.getGroup()
            if group == "admin" or group == "superadmin" or group == "god" or group == "mod" then
                return true
            end
        end
    end

    return false
end

local function BuildRPName(player, src)
    local data = player and player.PlayerData
    local charinfo = data and data.charinfo
    if charinfo then
        local first = charinfo.firstname or ""
        local last = charinfo.lastname or ""
        local full = (first .. " " .. last):gsub("^%s+", ""):gsub("%s+$", "")
        if full ~= "" then
            return full
        end
    end
    return GetPlayerName(src) or "Unknown"
end

local function GetPlayerDetails(src)
    local name = GetPlayerName(src) or "Unknown"
    local jobName = "unemployed"
    local jobLabel = "Civilian"
    local onDuty = true

    if FrameworkName == "qbcore" and QBCore then
        local player = QBCore.Functions.GetPlayer(src)
        if player and player.PlayerData then
            if Config.Privacy.UseRPName then
                name = BuildRPName(player, src)
            end
            jobName = player.PlayerData.job.name
            jobLabel = player.PlayerData.job.label
            onDuty = player.PlayerData.job.onduty
        end
    elseif FrameworkName == "qbx" then
        local player = exports.qbx_core:GetPlayer(src)
        if player and player.PlayerData then
            if Config.Privacy.UseRPName then
                name = BuildRPName(player, src)
            end
            jobName = player.PlayerData.job.name
            jobLabel = player.PlayerData.job.label
            onDuty = player.PlayerData.job.onduty
        end
    elseif FrameworkName == "esx" and ESX then
        local player = ESX.GetPlayerFromId(src)
        if player then
            if Config.Privacy.UseRPName then
                name = player.getName() or (player.get('firstName') .. " " .. player.get('lastName'))
            end
            jobName = player.job.name
            jobLabel = player.job.label
            onDuty = true
        end
    end

    if Config.Privacy.AnonymousNames and not IsPlayerStaff(src) then
        name = "Player " .. src
    end

    return {
        id = src,
        name = name,
        jobName = jobName,
        jobLabel = jobLabel,
        onDuty = onDuty,
        ping = GetPlayerPing(src) or 0,
        isStaff = IsPlayerStaff(src)
    }
end

exports('SetHeistStatus', function(heistId, status)
    heistCustomStates[heistId] = status
    TriggerClientEvent('toffy-scoreboard:client:updateHeistStatus', -1, heistId, status)
end)

exports('ResetHeistStatus', function(heistId)
    heistCustomStates[heistId] = nil
    TriggerClientEvent('toffy-scoreboard:client:updateHeistStatus', -1, heistId, nil)
end)

local function GetScoreboardData()
    -- Recover if the framework wasn't ready when the resource booted.
    if FrameworkName == "none" then
        DetectFramework()
    end

    local players = {}
    local jobCounts = {}
    local staffCount = 0
    
    for _, jobInfo in ipairs(Config.TrackedJobs) do
        jobCounts[jobInfo.job] = 0
    end

    local activePlayers = GetPlayers()
    for _, playerIdStr in ipairs(activePlayers) do
        local src = tonumber(playerIdStr)
        if src then
            local details = GetPlayerDetails(src)
            table.insert(players, {
                id = details.id,
                name = details.name,
                job = Config.Privacy.HideJobs and "Civilian" or details.jobLabel,
                jobName = details.jobName,
                onDuty = details.onDuty,
                ping = Config.Privacy.HidePing and 0 or details.ping,
                isStaff = details.isStaff
            })

            if details.isStaff then
                staffCount = staffCount + 1
            end

            if jobCounts[details.jobName] ~= nil then
                if details.onDuty then
                    jobCounts[details.jobName] = jobCounts[details.jobName] + 1
                end
            end
        end
    end

    local heists = {}
    local policeCount = jobCounts["police"] or 0
    
    for _, heist in ipairs(Config.Heists) do
        if heist.enabled then
            local status = "unavailable"
            
            if heistCustomStates[heist.id] then
                status = heistCustomStates[heist.id]
            else
                if policeCount >= heist.minCops then
                    status = "available"
                end
            end
            
            table.insert(heists, {
                id = heist.id,
                label = heist.label,
                icon = heist.icon,
                minCops = heist.minCops,
                status = status
            })
        end
    end

    local jobStats = {}
    for _, jobInfo in ipairs(Config.TrackedJobs) do
        table.insert(jobStats, {
            job = jobInfo.job,
            label = jobInfo.label,
            icon = jobInfo.icon,
            color = jobInfo.color,
            count = jobCounts[jobInfo.job] or 0
        })
    end

    return {
        players = players,
        jobStats = jobStats,
        heists = heists,
        staffOnline = staffCount,
        totalPlayers = #activePlayers
    }
end

RegisterNetEvent('toffy-scoreboard:server:getScoreboardData', function()
    local src = source
    local data = GetScoreboardData()
    TriggerClientEvent('toffy-scoreboard:client:receiveScoreboardData', src, data)
end)

