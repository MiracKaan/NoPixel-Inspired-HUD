local QBCore = exports["qb-core"]:GetCoreObject()
local hunger = 100
local thirst = 100
local stress = 0
local isBleeding = false
local isTalkingOnRadio = false
local pName = "Unknown"
local pJob = "Unemployed"
local pCash = 0
local pBank = 0

local function updatePlayerDetails(PlayerData)
    if not PlayerData then return end
    if PlayerData.charinfo then
        pName = (PlayerData.charinfo.firstname or "") .. " " .. (PlayerData.charinfo.lastname or "")
    end
    if PlayerData.job then
        local jobName = PlayerData.job.label or ""
        local gradeName = ""
        if PlayerData.job.grade and PlayerData.job.grade.name then
            gradeName = PlayerData.job.grade.name
        end
        pJob = jobName .. " - " .. gradeName
    end
    if PlayerData.money then
        pCash = PlayerData.money.cash or 0
        pBank = PlayerData.money.bank or 0
    end
end
local isBoneBroken = false
local bleedPercent = 0

-- Data tracking QBCore/QBX
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        hunger = PlayerData.metadata['hunger'] or 100
        thirst = PlayerData.metadata['thirst'] or 100
                stress = PlayerData.metadata['stress'] or 0
    end
    updatePlayerDetails(PlayerData)
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    if val and val.metadata then
        hunger = val.metadata['hunger'] or hunger
        thirst = val.metadata['thirst'] or thirst
                stress = val.metadata['stress'] or stress
    end
    updatePlayerDetails(val)
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    hunger = newHunger
    thirst = newThirst
end)

RegisterNetEvent('pma-voice:radioActive', function(talking)
    isTalkingOnRadio = talking
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress)
    stress = newStress
end)

AddStateBagChangeHandler('stress', nil, function(bagName, key, value, _reserved, replicated)
    if bagName == ('player:%s'):format(GetPlayerServerId(PlayerId())) then
        stress = value or 0
    end
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

local devmode = false
RegisterCommand("developermode", function() devmode = not devmode end, false)

-- ==========================================
-- ANA HUD DONGUSU (200ms)
-- ==========================================
CreateThread(function()
    while true do
        Wait(200)

        if not LocalPlayer.state.isLoggedIn then
            SendNUIMessage({ action = "hide" })
            goto continue
        end

        local ped = PlayerPedId()

        -- Her dongude kirik sifirla, kanama ise metadata'dan kontrol et
        isBoneBroken = false
        local wasBleedingBefore = isBleeding
        isBleeding = false

        -- QBX_HOSPITAL / QB-AMBULANCEJOB ENTEGRASYONU
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.metadata then
            -- Kanama kontrolleri
            if PlayerData.metadata['bleedlevel'] and type(PlayerData.metadata['bleedlevel']) == 'number' and PlayerData.metadata['bleedlevel'] > 0 then
                isBleeding = true
            end
            if PlayerData.metadata['bloodvolume'] and type(PlayerData.metadata['bloodvolume']) == 'number' and PlayerData.metadata['bloodvolume'] < 100 then
                isBleeding = true
            end
            if PlayerData.metadata['isbleeding'] or PlayerData.metadata['isBleeding'] then
                isBleeding = true
            end

            -- Kirik kontrolleri
            if PlayerData.metadata['injuries'] and type(PlayerData.metadata['injuries']) == 'table' then
                for part, damage in pairs(PlayerData.metadata['injuries']) do
                    if (type(damage) == 'number' and damage > 0) or (type(damage) == 'boolean' and damage) then
                        isBoneBroken = true
                        break
                    end
                end
            end
            if PlayerData.metadata['bone'] or PlayerData.metadata['isbroken'] or PlayerData.metadata['isBoneBroken'] then
                isBoneBroken = true
            end

            -- Olum / Last Stand
            if PlayerData.metadata['isdead'] or PlayerData.metadata['inlaststand'] then
                isBleeding = true
                isBoneBroken = true
            end
        end

        -- STATEBAG KONTROLLERI (ox_lib / Overextended)
        if LocalPlayer.state.isBleeding then isBleeding = true end
        if LocalPlayer.state.bleedingLevel and type(LocalPlayer.state.bleedingLevel) == 'number' and LocalPlayer.state.bleedingLevel > 0 then
            isBleeding = true
        end
        if LocalPlayer.state.isBoneBroken then isBoneBroken = true end
        if LocalPlayer.state.stress then stress = LocalPlayer.state.stress end

        -- KANAMA: Can bari ile ortak calissin (can azaldikca kanama devreye girer)
        local rawHealth = GetEntityHealth(ped)
        if rawHealth < Config.BleedingHealthThreshold then
            isBleeding = true
        end

        -- REVIVE / HEAL FAILSAFE: Can fullendiginde takili kalmalari zorla coz
        if rawHealth >= GetEntityMaxHealth(ped) - 5 then
            isBleeding = false
            isBoneBroken = false
            bleedPercent = 0
            ClearEntityLastWeaponDamage(ped)
        end

        -- Kanama bari: stress gibi yavasce artsin (yaklaik 1% / saniye)
        if isBleeding then
            bleedTimer = (bleedTimer or 0) + 200
            if bleedTimer >= 1000 then -- Her 1 saniyede 1 artir
                bleedPercent = bleedPercent + 1
                if bleedPercent > 100 then bleedPercent = 100 end
                bleedTimer = 0
            end
        else
            bleedTimer = 0
            -- Kanama bitti, bar yavasce dussun
            if bleedPercent > 0 then
                bleedPercent = bleedPercent - 2
                if bleedPercent < 0 then bleedPercent = 0 end
            end
        end

        -- Stamina
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
                    showStress = Config.EnableStress,
                    stamina = finalStamina,
                    isUnderwater = isUnderwater,
                    oxygen = oxygen,
                    isTalking = isTalking,
                      isRadio = isTalkingOnRadio,
                    voice = voice,
                    isAiming = isAiming,
                    hasWeapon = hasWeapon,
                    ammoClip = ammoInClip,
                    ammoTotal = ammoTotal,
                    bleed = isBleeding,
                    bleedLevel = bleedPercent,
                    bone = isBoneBroken,
                                        devmode = devmode,
                    pId = GetPlayerServerId(PlayerId()),
                    pName = string.upper(pName),
                    pJob = string.upper(pJob),
                    pCash = pCash,
                    pBank = pBank
                }
            })
        else
            SendNUIMessage({ action = "hide" })
        end
        ::continue::
    end
end)

-- Sprint kilidi
CreateThread(function()
    while true do
        Wait(0)
        if finalStamina <= 0 then
            DisableControlAction(0, 21, true)
        end
    end
end)

-- Iyilesme eventleri
for _, eventName in ipairs(Config.HealingEvents) do
    RegisterNetEvent(eventName, function()
        isBleeding = false
        isBoneBroken = false
        bleedPercent = 0
        ClearEntityLastWeaponDamage(PlayerPedId())
        if Config.EnableStress then
            TriggerServerEvent('hud:server:RelieveStress', 100)
        end
    end)
end

-- ==========================================
-- QBX_HUD STRESS TETIKLEYICILERI
-- ==========================================

local function isWhitelistedWeaponStress(weapon)
    if not weapon then return false end
    for _, v in pairs(Config.Stress.whitelistedWeapons) do
        if weapon == v then
            return true
        end
    end
    return false
end

-- Arac hizi ile stres
CreateThread(function()
    while true do
        Wait(10000)
        if Config.EnableStress and LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                local vehClass = GetVehicleClass(veh)
                local speed = GetEntitySpeed(veh) * 3.6

                if vehClass ~= 13 and vehClass ~= 14 and vehClass ~= 15 and vehClass ~= 16 and vehClass ~= 21 then
                    local isBuckled = LocalPlayer.state.seatbelt
                    local stressSpeed = isBuckled and Config.Stress.minSpeedForStress or Config.Stress.minSpeedForStressUnbuckled

                    if speed >= stressSpeed then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 2))
                    end
                end
            end
        end
    end
end)

-- Silah atesi ile stres
CreateThread(function()
    while true do
        Wait(0)
        if Config.EnableStress then
            local ped = PlayerPedId()
            if IsPedShooting(ped) then
                local weapon = GetSelectedPedWeapon(ped)
                if not isWhitelistedWeaponStress(weapon) then
                    if math.random() <= Config.Stress.chance then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        Wait(5000)
                    end
                end
            end
        else
            Wait(1000)
        end
    end
end)

-- Stres ekran efektleri (blur + ragdoll)
local function getBlurIntensity(stresslevel)
    if stresslevel >= 90 then return 3000
    elseif stresslevel >= 80 then return 2700
    elseif stresslevel >= 70 then return 2500
    elseif stresslevel >= 60 then return 2000
    else return 1500 end
end

local function getEffectInterval(stresslevel)
    if stresslevel >= 90 then return math.random(15000, 20000)
    elseif stresslevel >= 80 then return math.random(20000, 30000)
    elseif stresslevel >= 70 then return math.random(30000, 40000)
    elseif stresslevel >= 60 then return math.random(40000, 50000)
    else return math.random(50000, 60000) end
end

CreateThread(function()
    while true do
        if Config.EnableStress and stress >= Config.Stress.minForShaking then
            local effectInterval = getEffectInterval(stress)
            Wait(effectInterval)

            if stress >= 100 then
                local blurIntensity = getBlurIntensity(stress)
                local fallRepeat = math.random(2, 4)
                local ragdollTimeout = fallRepeat * 1750
                TriggerScreenblurFadeIn(1000.0)

                local ped = PlayerPedId()
                if not IsPedInAnyVehicle(ped, false) and not IsPedFalling(ped) then
                    SetPedToRagdoll(ped, ragdollTimeout, ragdollTimeout, 0, false, false, false)
                end

                Wait(blurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            elseif stress >= Config.Stress.minForShaking then
                local blurIntensity = getBlurIntensity(stress)
                TriggerScreenblurFadeIn(1000.0)
                Wait(blurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        else
            Wait(2000)
        end
    end
end)

-- Yaralanma kaynakli stres (kanama/kirik varken yavasce stres artar)
CreateThread(function()
    while true do
        Wait(30000)
        if Config.EnableStress and LocalPlayer.state.isLoggedIn then
            if isBleeding or isBoneBroken then
                TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
            end
        end
    end
end)