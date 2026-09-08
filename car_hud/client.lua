local QBCore = exports['qb-core']:GetCoreObject()

-- Emniyet Kemeri Ses Bankasi Yukleme
CreateThread(function()
    RequestScriptAudioBank("audiodirectory/seatbelt_sounds", false)
end)

local seatbeltOn = false

RegisterCommand('toggleseatbelt', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local class = GetVehicleClass(veh)
        -- Motosiklet, Bisiklet, Tekne gibi araclarda kemer takilmaz
        if class ~= 8 and class ~= 13 and class ~= 14 then
            seatbeltOn = not seatbeltOn
            LocalPlayer.state:set("seatbelt", seatbeltOn, true)
            PlaySoundFrontend(-1, seatbeltOn and 'carbuckle' or 'carunbuckle', 'seatbelt_soundset', true)
        end
    end
end, false)
RegisterKeyMapping('toggleseatbelt', 'Emniyet Kemeri Tak/Cikar', 'keyboard', 'B')

local wasInVehicle = false
local cinematicMode = false

RegisterNetEvent("hud:client:ToggleCinematic", function(state)
    cinematicMode = state
end)

CreateThread(function()
    while true do
        Wait(50)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) and not IsPauseMenuActive() and not cinematicMode then
            wasInVehicle = true
            local veh = GetVehiclePedIsIn(ped, false)
            
            -- Speed
            local speed = math.floor(GetEntitySpeed(veh) * 3.6)
            
            -- RPM (0.0 to 1.0)
            local rpm = GetVehicleCurrentRpm(veh)
            
            -- Gear
            local gear = GetVehicleCurrentGear(veh)
            if speed == 0 and gear == 0 then gear = "N"
            elseif gear == 0 then gear = "R" end
            
            -- Fuel
            local fuel = GetVehicleFuelLevel(veh)
            
            -- Lights
            local _, lightsOn, highbeamsOn = GetVehicleLightsState(veh)
            local isLightsOn = lightsOn == 1 or highbeamsOn == 1
            
            -- Seatbelt
            local seatbelt = LocalPlayer.state.seatbelt or false
            
            -- Lock Status
            local lockStatus = GetVehicleDoorLockStatus(veh)
            local isLocked = lockStatus == 2 or lockStatus == 3
            
            -- Engine Health
            local engineHealth = GetVehicleEngineHealth(veh)
            
            SendNUIMessage({
                action = "updateCarHud",
                speed = speed,
                rpm = rpm,
                gear = gear,
                fuel = fuel,
                lights = isLightsOn,
                seatbelt = seatbelt,
                locked = isLocked,
                engine = engineHealth
            })
        else
            if wasInVehicle then
                wasInVehicle = false
                if seatbeltOn then
                    seatbeltOn = false
                    LocalPlayer.state:set("seatbelt", false, true)
                end
            end
            SendNUIMessage({ action = "hideCarHud" })
        end
    end
end)
