local QBCore = exports["qb-core"]:GetCoreObject()
local hunger = 100
local thirst = 100
local stress = 0

RegisterNetEvent("hud:client:UpdateNeeds", function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
end)

RegisterNetEvent("hud:client:UpdateStress", function(newStress)
    stress = newStress
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

local isBleeding = false
local isBoneBroken = false
local devmode = false

RegisterCommand("developermode", function()
    devmode = not devmode
end, false)

RegisterCommand("bleeding", function()
    isBleeding = not isBleeding
end, false)

RegisterCommand("broken", function()
    isBoneBroken = not isBoneBroken
end, false)

local lastSpeed = 0
CreateThread(function()
    while true do
        Wait(200)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local speed = GetEntitySpeed(veh)
            if lastSpeed - speed > Config.CrashSpeedThreshold then
                isBoneBroken = true
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.5)
            end
            lastSpeed = speed
        else
            lastSpeed = 0
        end
    end
end)

CreateThread(function()
    while true do
        Wait(200)
        local ped = PlayerPedId()
        local rawHealth = GetEntityHealth(ped)
        
        if rawHealth >= GetEntityMaxHealth(ped) - 5 then
            isBleeding = false
            isBoneBroken = false
            ClearEntityLastWeaponDamage(ped)
        end
        
        if Config.UseQbxMedical then
            
            if LocalPlayer.state.isBleeding ~= nil then
                isBleeding = LocalPlayer.state.isBleeding
            elseif LocalPlayer.state.bleedingLevel ~= nil then
                isBleeding = (LocalPlayer.state.bleedingLevel > 0)
            end
            
           
            if LocalPlayer.state.isBoneBroken ~= nil then
                isBoneBroken = LocalPlayer.state.isBoneBroken
            end
        end
        
        if not isBleeding then
            local rawHealth = GetEntityHealth(ped)
            if rawHealth < Config.BleedingHealthThreshold then 
                isBleeding = true
            end
            
            if HasEntityBeenDamagedByWeapon(ped, 0, 2) then
                ClearEntityLastWeaponDamage(ped)
                isBleeding = true
            end
        end

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
            
            local isAiming = IsPlayerFreeAiming(PlayerId())
            
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
                    stress = stress,
                    stamina = finalStamina,
                    isUnderwater = isUnderwater,
                    oxygen = oxygen,
                    isTalking = isTalking,
                    voice = voice,
                    isAiming = isAiming,
                    hasWeapon = hasWeapon,
                    ammoClip = ammoInClip,
                    ammoTotal = ammoTotal,
                    bleed = isBleeding,
                    bone = isBoneBroken,
                    devmode = devmode
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

for _, eventName in ipairs(Config.HealingEvents) do
    RegisterNetEvent(eventName, function()
        isBleeding = false
        isBoneBroken = false
        ClearEntityLastWeaponDamage(PlayerPedId())
    end)
end