CreateThread(function()
    Wait(1500)
    
    RequestStreamedTextureDict("circlemap", false)
    while not HasStreamedTextureDictLoaded("circlemap") do
        Wait(10)
    end
    
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
    SetMinimapClipType(1) 
    
    local function UpdateMinimapCoords()
        local resX, resY = GetActiveScreenResolution()
        if resX == 0 or resY == 0 then return end
        
        local aspectRatio = resX / resY
        local safeZone = GetSafeZoneSize()
        local safeZoneOffsetX = resX * ((1.0 - safeZone) / 2.0)
        local safeZoneOffsetY = resY * ((1.0 - safeZone) / 2.0)
        
        -- Orijinal mükemmel değerlerin (1920x1080)
        local targetX = 0.837
        local targetY = 0.110
        local targetWidth = 0.120
        -- Haritanın yuvarlak olması için AspectRatio ile büküyoruz
        local targetHeight = 0.75 * targetWidth * aspectRatio
        
        -- SafeZone'u GTA için tersine çevirme (Çünkü GTA L,T'de otomatik SafeZone uygular)
        local gtaX = ((targetX * resX) - safeZoneOffsetX) / (resX * safeZone)
        local gtaY = ((targetY * resY) - safeZoneOffsetY) / (resY * safeZone)
        local gtaWidth = targetWidth / safeZone
        local gtaHeight = targetHeight / safeZone
        
        SetMinimapComponentPosition("minimap", "L", "T", gtaX, gtaY, gtaWidth, gtaHeight)
        SetMinimapComponentPosition("minimap_mask", "L", "T", gtaX + (0.01/safeZone), gtaY + (0.02/safeZone), gtaWidth - (0.02/safeZone), gtaHeight - (0.04/safeZone))
        SetMinimapComponentPosition("minimap_blur", "L", "T", gtaX - (0.01/safeZone), gtaY - (0.01/safeZone), gtaWidth + (0.02/safeZone), gtaHeight + (0.02/safeZone))
    end
    
    UpdateMinimapCoords()
    
    local minimap = RequestScaleformMovie("minimap")
    while not HasScaleformMovieLoaded(minimap) do
        Wait(10)
    end
    
    SetRadarBigmapEnabled(true, false)
    Wait(50)
    SetRadarBigmapEnabled(false, false)
    
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    DisplayRadar(true)

    CreateThread(function()
        local lastResX, lastResY, lastSafeZone = 0, 0, 0
        local warningActive = false
        
        while true do
            Wait(1000)
            local rx, ry = GetActiveScreenResolution()
            local sz = GetSafeZoneSize()
            
            -- Uyarı Ekranı Mantığı
            if sz < 0.99 then
                if not warningActive then
                    warningActive = true
                    SendNUIMessage({ action = "showSafezoneWarning" })
                end
            else
                if warningActive then
                    warningActive = false
                    SendNUIMessage({ action = "hideSafezoneWarning" })
                end
            end
            
            if rx ~= lastResX or ry ~= lastResY or sz ~= lastSafeZone then
                lastResX, lastResY, lastSafeZone = rx, ry, sz
                UpdateMinimapCoords()
                
                SetRadarBigmapEnabled(true, false)
                Wait(50)
                SetRadarBigmapEnabled(false, false)
            end
        end
    end)
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
