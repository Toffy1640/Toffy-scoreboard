local isOpened = false
local showNearbyIds = false

local function ToggleScoreboard(state)
    if state == isOpened then return end
    isOpened = state
    
    SetNuiFocus(state, state)
    
    SendNUIMessage({
        action = "toggleScoreboard",
        status = state,
        theme = Config.Theme,
        layout = Config.Layout,
        locales = Locales[Config.Language or "tr"] or Locales["en"],
        trackedJobs = Config.TrackedJobs
    })
    
    if state then
        TriggerServerEvent('toffy-scoreboard:server:getScoreboardData')
    end
end

RegisterCommand('+scoreboard', function()
    ToggleScoreboard(true)
end, false)

RegisterCommand('-scoreboard', function()
    ToggleScoreboard(false)
end, false)

if Config.OpenKey then
    RegisterKeyMapping('+scoreboard', 'Open Scoreboard Menu', 'keyboard', Config.OpenKey)
end

RegisterCommand(Config.OpenCommand, function()
    ToggleScoreboard(not isOpened)
end, false)

RegisterNUICallback('close', function(data, cb)
    ToggleScoreboard(false)
    cb('ok')
end)

RegisterNetEvent('toffy-scoreboard:client:receiveScoreboardData', function(data)
    SendNUIMessage({
        action = "updateData",
        data = data
    })
end)

RegisterNetEvent('toffy-scoreboard:client:updateHeistStatus', function(heistId, status)
    SendNUIMessage({
        action = "updateHeist",
        heistId = heistId,
        status = status
    })
end)

local function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.1)
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 230)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        if Config.OverheadIds.DrawOutline then
            local factor = (string.len(text)) / 300
            DrawRect(_x, _y + 0.0125, 0.018 + factor, 0.03, 16, 17, 21, 200)
        end
    end
end

if Config.OverheadIds.Enabled then
    CreateThread(function()
        while true do
            local sleep = 500
            
            if IsControlPressed(0, 19) then
                sleep = 0
                local localPed = PlayerPedId()
                local localCoords = GetEntityCoords(localPed)
                local activePlayers = GetActivePlayers()
                
                for _, player in ipairs(activePlayers) do
                    local ped = GetPlayerPed(player)
                    if ped ~= localPed and DoesEntityExist(ped) then
                        local pedCoords = GetEntityCoords(ped)
                        local distance = #(localCoords - pedCoords)
                        
                        if distance <= Config.OverheadIds.Distance and HasEntityClearLosToEntity(localPed, ped, 17) then
                            local serverId = GetPlayerServerId(player)
                            DrawText3D(pedCoords, "ID: " .. tostring(serverId))
                        end
                    end
                end
            end
            
            Wait(sleep)
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isOpened then
            ToggleScoreboard(false)
        end
    end
end)
