local QBCore = exports["qb-core"]:GetCoreObject()
local hunger = 100
local thirst = 100

RegisterNetEvent("hud:client:UpdateNeeds", function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
end)

local staminaPenalty = 0.0
local finalStamina = 100

local cinematicMode = false

RegisterCommand("cinematic", function()
    cinematicMode = not cinematicMode
    TriggerEvent("hud:client:ToggleCinematic", cinematicMode)
    
    SendNUIMessage({
        action = "cinematicBars",
        state = cinematicMode
    })
end, false)

CreateThread(function()
    while true do
        Wait(200)
        local ped = PlayerPedId()
        
        -- Catismada Stamina Tuketimi (Penalty System)
        if IsPedShooting(ped) then
            staminaPenalty = staminaPenalty + 3.0
            if staminaPenalty > 100.0 then staminaPenalty = 100.0 end
        elseif staminaPenalty > 0 and not IsPedSprinting(ped) then
            staminaPenalty = staminaPenalty - 1.5
            if staminaPenalty < 0 then staminaPenalty = 0.0 end
        end
        
        if not IsPauseMenuActive() and not cinematicMode then
            local health = math.floor((GetEntityHealth(ped) - 100) / (GetEntityMaxHealth(ped) - 100) * 100)
            if health < 0 then health = 0 end
            if health > 100 then health = 100 end
            
            local armor = GetPedArmour(ped)
            
            local nativeStamina = 100 - math.floor(GetPlayerSprintStaminaRemaining(PlayerId()))
            finalStamina = math.floor(nativeStamina - staminaPenalty)
            if finalStamina < 0 then finalStamina = 0 end
            if finalStamina > 100 then finalStamina = 100 end
            
            local isUnderwater = IsPedSwimmingUnderWater(ped)
            local oxygen = 100
            if isUnderwater then
                oxygen = math.floor(GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10)
                if oxygen < 0 then oxygen = 0 end
                if oxygen > 100 then oxygen = 100 end
            end
            
            local isTalking = NetworkIsPlayerTalking(PlayerId())
            local voice = 2
            if LocalPlayer.state.proximity and LocalPlayer.state.proximity.index then
                voice = LocalPlayer.state.proximity.index
            end
            
            -- Custom Crosshair Icin Nisan Alma Kontrolu
            local isAiming = IsPlayerFreeAiming(PlayerId())
            
            -- Silah ve Mermi Kontrolü
            local weapon = GetSelectedPedWeapon(ped)
            local hasWeapon = false
            local ammoInClip = 0
            local ammoTotal = 0
            
            if weapon ~= `WEAPON_UNARMED` and weapon ~= 0 then
                hasWeapon = true
                local _, clip = GetAmmoInClip(ped, weapon)
                ammoInClip = clip
                local maxAmmo = GetAmmoInPedWeapon(ped, weapon)
                ammoTotal = maxAmmo - ammoInClip
                if ammoTotal < 0 then ammoTotal = 0 end
            end
            
            SendNUIMessage({
                action = "update",
                data = {
                    health = health,
                    armor = armor,
                    hunger = hunger,
                    thirst = thirst,
                    stamina = finalStamina,
                    isUnderwater = isUnderwater,
                    oxygen = oxygen,
                    isTalking = isTalking,
                    voice = voice,
                    isAiming = isAiming,
                    hasWeapon = hasWeapon,
                    ammoClip = ammoInClip,
                    ammoTotal = ammoTotal
                }
            })
        else
            SendNUIMessage({ action = "hide" })
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if finalStamina <= 0 then
            DisableControlAction(0, 21, true) -- Sprint
        end
    end
end)