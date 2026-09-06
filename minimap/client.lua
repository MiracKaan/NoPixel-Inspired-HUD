CreateThread(function()
    Wait(1500)
    
    RequestStreamedTextureDict("circlemap", false)
    if not HasStreamedTextureDictLoaded("circlemap") then
        Wait(150)
    end
    
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
    SetMinimapClipType(1) 
    
    -- 1920x1080 Exact Math (14.5vw Box)
    local x = 0.823     -- (100vw - 4vw right - 14.5vw width) = 81.5vw
    local y = 0.100       -- 4vh top
    local width = 0.120   -- 14.5vw width
    local height = 0.1600 -- 14.5vw in pixels (278.4px) / 1080px = 0.2577
    
    SetMinimapComponentPosition("minimap", "L", "T", x, y, width, height)
    SetMinimapComponentPosition("minimap_mask", "L", "T", x + 0.01, y + 0.02, width - 0.02, height - 0.04)
    SetMinimapComponentPosition("minimap_blur", "L", "T", x - 0.01, y - 0.01, width + 0.02, height + 0.02)
    
    local minimap = RequestScaleformMovie("minimap")
    while not HasScaleformMovieLoaded(minimap) do
        Wait(10)
    end
    
    SetRadarBigmapEnabled(true, false)
    Wait(50)
    SetRadarBigmapEnabled(false, false)
    
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    DisplayRadar(true)
end)

local cinematicMode = false

RegisterNetEvent("hud:client:ToggleCinematic", function(state)
    cinematicMode = state
end)

CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    while true do
        Wait(0)
        -- Diger default HUD elementlerini gizle
        HideHudComponentThisFrame(1)
        HideHudComponentThisFrame(2)
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(4)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(21)
        HideHudComponentThisFrame(22)
        
        if not IsPauseMenuActive() and not cinematicMode then
            DisplayRadar(true)
            BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
        else
            DisplayRadar(false)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(50)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        local camRot = GetGameplayCamRot(2).z
        local heading = math.floor(360.0 - camRot)
        if heading < 0 then heading = heading + 360 end
        if heading > 360 then heading = heading - 360 end
        
        local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local streetName = GetStreetNameFromHashKey(street1)
        if streetName == nil or streetName == "" then streetName = "" end
        
        local zone = GetNameOfZone(coords.x, coords.y, coords.z)
        local zoneLabel = GetLabelText(zone)
        if zoneLabel == nil or zoneLabel == "" then zoneLabel = zone end

        if not IsPauseMenuActive() and not cinematicMode then
            SendNUIMessage({
                action = "updateCompass",
                heading = heading,
                street = string.upper(streetName),
                zone = string.upper(zoneLabel)
            })
        else
            SendNUIMessage({ action = "hideCompass" })
        end
    end
end)
