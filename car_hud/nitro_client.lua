Config = {}
Config.RequirePurge = true

local display = false
local preventNitro = false
local purge = {}
local nosActivated, purgeActivated = false, false
local keybindNos, keybindPurge
local vehicleModel, vehicleMaxSpeed
local screenEffect = false

---@param status boolean
local function setHUD(status)
    display = status
    -- SendNUIMessage removed
end

local function enableScreenEffect(enable)
    if enable then
        screenEffect = true
        SetTimecycleModifier("rply_motionblur")
        ShakeGameplayCam("SKY_DIVING_SHAKE", 0.25)
        return
    end
    screenEffect = false
    StopGameplayCamShaking(true)
    SetTransitionTimecycleModifier("default", 0.35)
end

---@param checkDriver boolean
---@return boolean
local function isInVehicle(checkDriver)
    return checkDriver and cache.seat == -1 and cache.vehicle or cache.vehicle
end

---@param veh entity
---@return boolean
local function vehicleHasNitro(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local state = Entity(veh).state
    local value = state.nd_nitro_nos
    return value and value > 0
end

---@param setType string
---@param value number
local function vehicleSetValue(setType, value)
    local veh = isInVehicle(true)
    if not veh or not DoesEntityExist(veh) then return end
    local state = Entity(veh).state
    state:set(("nd_nitro_%s"):format(setType), value, true)
    if setType == "nos" then
        -- SendNUIMessage removed
    else
        -- SendNUIMessage removed
    end
end

---@param veh entity
---@param setType string
---@param value boolean
local function vehicleActivate(veh, setType, value)
    if not veh or not DoesEntityExist(veh) then return end
    local state = Entity(veh).state
    state:set(("nd_nitro_activated_%s"):format(setType), value, true)
end

---@param veh number
---@return number
---@return number
local function vehicleGetValues(veh)
    if not veh or not DoesEntityExist(veh) then return end
    local state = Entity(veh).state
    return state.nd_nitro_nos, state.nd_nitro_purge
end

local function vehicleAddNitro()
    vehicleSetValue("nos", 100.0)
    vehicleSetValue("purge", 0.0)
    setHUD(true)
end

---@param veh entity
local function startedNos(veh)
    local noslvl, purgelvl = vehicleGetValues(veh)

    if purgelvl < 100 then
        local lvl = purgelvl+4.0
        if lvl > 100 then
            lvl = 100
        end
        vehicleSetValue("purge", lvl)
        if preventNitro then
            preventNitro = false
        end
        else
        if Config.RequirePurge then
            preventNitro = true
            return vehicleActivate(veh, "flames", false)
        end
    end

    local lvl = noslvl-1.0
    if lvl < 0 then
        lvl = 0
    end
    vehicleSetValue("nos", lvl)

    if lvl <= 0 then
        vehicleActivate(veh, "flames", false)
        vehicleActivate(veh, "purge", false)
        setHUD(false)
    end
end

---@param veh entity
local function startedPurge(veh)
    local noslvl, purgelvl = vehicleGetValues(veh)
    if purgelvl < 100 then
        preventNitro = false
    end
    if purgelvl > 0 then
        local lvl = purgelvl-15.0
        if lvl < 0 then
            lvl = 0
        end
        vehicleSetValue("purge", lvl)
    elseif purgelvl == 0 then
        local lvl = noslvl-5.0
        if lvl < 0 then
            lvl = 0
        end
        vehicleSetValue("nos", lvl)
        if lvl <= 0 then
            vehicleActivate(veh, "flames", false)
            vehicleActivate(veh, "purge", false)
            setHUD(false)
        end
    end
end

---@param veh entity
---@return boolean
local function nitroCheck(veh)
    if not DoesEntityExist(veh) then return end
    
    local noslvl, purgelvl = vehicleGetValues(veh)
    if noslvl <= 0 or purgelvl >= 100 then return end

    local speed = GetEntitySpeed(veh)
    local mph = speed*2.236936

    local model = GetEntityModel(veh)
    if model ~= vehicleModel or maxSpeed == 0 then
        vehicleModel = model
        vehicleMaxSpeed = GetVehicleModelMaxSpeed(model)
    end

    if mph < 5.0 then
        SetControlNormal(0, 71, 0.5)
    else
        local multiplier =  2.0*vehicleMaxSpeed/GetEntitySpeed(veh)
        SetVehicleCheatPowerIncrease(veh, multiplier)
    end

    if screenEffect and mph < 15.0 then
        enableScreenEffect(false)
    elseif not screenEffect and mph > 15.0 then
        enableScreenEffect(true)
    end

    return true
end

---@param veh entity
local function displayNitro(veh)
    local noslvl, purgelvl = vehicleGetValues(veh)
    if not noslvl or noslvl <= 0 then return end
    -- SendNUIMessage removed
    -- SendNUIMessage removed
    setHUD(true)
end

-- this is used with inventory to add nitro bottle to vehicle.
exports("nos", function(data, slot)
    local veh = isInVehicle(checkDriver)
    if not veh or not DoesEntityExist(veh) then return end
    if data then exports.ox_inventory:useItem(data) end
    vehicleAddNitro()
end)

keybindNos = lib.addKeybind({
    name = "nd_nitro_boost",
    description = "Nitro: boost",
    defaultKey = "LSHIFT",
    onPressed = function(self)
        if not IsControlPressed(0, 71) then Wait(10) end
        
        local veh = isInVehicle(true)
        if preventNitro or not veh or not DoesEntityExist(veh) or not vehicleHasNitro(veh) or keybindNos.disabled then return end
        if not display then setHUD(true) end
    
        self.isPressed = true
        keybindPurge:disable(true)
        lib.requestNamedPtfxAsset("veh_xs_vehicle_mods")
        vehicleActivate(veh, "flames", true)
        
        CreateThread(function()
            while self.isPressed and isInVehicle(true) == veh and DoesEntityExist(veh) do
                Wait(1000)
                startedNos(veh)
            end
        end)
    end,
    onReleased = function(self)
        if screenEffect then
            enableScreenEffect(false)
        end
        
        self.isPressed = false
        local veh = isInVehicle(true)
        if not veh or not DoesEntityExist(veh) or not vehicleHasNitro(veh) then return end

        keybindPurge:disable(false)
        vehicleActivate(veh, "flames", false)
    end
})

keybindPurge = lib.addKeybind({
    name = "nd_nitro_purge",
    description = "Nitro: purge",
    defaultKey = "LMENU",
    onPressed = function(self)
        local veh = isInVehicle(true)
        if not veh or not DoesEntityExist(veh) or not vehicleHasNitro(veh) or keybindPurge.disabled then return end
        if not display then setHUD(true) end

        self.isPressed = true
        keybindNos:disable(true)
        vehicleActivate(veh, "purge", true)

        CreateThread(function()
            while self.isPressed and isInVehicle(true) == veh and DoesEntityExist(veh) do
                Wait(1000)
                startedPurge(veh)
            end
        end)
    end,
    onReleased = function(self)
        self.isPressed = false
        local veh = isInVehicle(true)
        if not veh or not DoesEntityExist(veh) or not vehicleHasNitro(veh) then return end

        keybindNos:disable(false)
        vehicleActivate(veh, "purge", false)
    end
})

AddEventHandler("onResourceStart", function(resourceName)
    if cache.resource ~= resourceName then return end
    Wait(500)
    displayNitro(cache.vehicle)
end)

lib.onCache("vehicle", function(value)
    local isDriver = GetPedInVehicleSeat(value, -1) == cache.ped
    if not value and screenEffect then
        enableScreenEffect(false)
    end
    if not isDriver or not value then
        return setHUD(false)
    end
    displayNitro(value)
end)

lib.onCache("seat", function(seat)
    if seat ~= -1 then
        return setHUD(false)
    end
    displayNitro(cache.vehicle)
end)

AddStateBagChangeHandler("nd_nitro_activated_flames", nil, function(bagName, key, value, reserved, replicated)
    if replicated or value == nil then return end
    local entity = GetEntityFromStateBagName(bagName)
    if not entity or not DoesEntityExist(entity) then return end
    
    lib.requestNamedPtfxAsset("veh_xs_vehicle_mods")
    SetVehicleNitroEnabled(entity, value)
    EnableVehicleExhaustPops(entity, not value)
    SetVehicleBoostActive(entity, value)
    
    if value then
        CreateBlueFlames(entity)
    else
        StopBlueFlames(entity)
    end
    
    local driver, passenger = isInVehicle(true) == entity, isInVehicle() == entity
    if not value then
        if driver then
            SetVehicleCheatPowerIncrease(entity, 1.0)
        end
        if driver or passenger and screenEffect then
            enableScreenEffect(false)
        end
        return
    end

    if not driver and not passenger then return end
    CreateThread(function()
        local state = Entity(entity).state
        while state.nd_nitro_activated_flames and nitroCheck(entity) do
            Wait(0)
        end
        if screenEffect then
            enableScreenEffect(false)
        end
    end)
end)

AddStateBagChangeHandler("nd_nitro_activated_purge", nil, function(bagName, key, value, reserved, replicated)
    if replicated or value == nil then return end

    local entity = GetEntityFromStateBagName(bagName)
    if not entity or not DoesEntityExist(entity) then return end

    if not value then
        local currentPurge = purge[entity]
        if currentPurge?.left then
            StopParticleFxLooped(currentPurge.left)
        end
        if currentPurge?.right then
            StopParticleFxLooped(currentPurge.right)
        end
        purge[entity] = nil
        return
    end

    local bone = GetEntityBoneIndexByName(entity, "bonnet")
    local pos = GetWorldPositionOfEntityBone(entity, bone)
    local off = GetOffsetFromEntityGivenWorldCoords(entity, pos.x, pos.y, pos.z)
    if bone ~= -1 then
        UseParticleFxAssetNextCall("core")
        local leftPurge = StartParticleFxLoopedOnEntity("ent_sht_steam", entity, off.x - 0.5, off.y + 0.05, off.z, 40.0, -20.0, 0.0, 0.3, false, false, false)
        UseParticleFxAssetNextCall("core")
        local rightPurge = StartParticleFxLoopedOnEntity("ent_sht_steam", entity, off.x + 0.5, off.y + 0.05, off.z, 40.0, 20.0, 0.0, 0.3, false, false, false)
        purge[entity] = {left = leftPurge, right = rightPurge}
    PlaySoundFromEntity(-1, "Air_Release", entity, "DLC_Biker_Computer_Sounds", false, 0)
        return
    end

    local bone = GetEntityBoneIndexByName(entity, "engine")
    local pos = GetWorldPositionOfEntityBone(entity, bone)
    local off = GetOffsetFromEntityGivenWorldCoords(entity, pos.x, pos.y, pos.z)
    UseParticleFxAssetNextCall("core")
    local leftPurge = StartParticleFxLoopedOnEntity("ent_sht_steam", entity, off.x - 0.5, off.y - 0.2, off.z + 0.2, 40.0, -20.0, 0.0, 0.3, false, false, false)
    UseParticleFxAssetNextCall("core")
    local rightPurge = StartParticleFxLoopedOnEntity("ent_sht_steam", entity, off.x + 0.5, off.y - 0.2, off.z + 0.2, 40.0, 20.0, 0.0, 0.3, false, false, false)
    purge[entity] = {left = leftPurge, right = rightPurge}
    PlaySoundFromEntity(-1, "Air_Release", entity, "DLC_Biker_Computer_Sounds", false, 0)
end)

-- QBCore Item Install
RegisterNetEvent('nitrous:client:Install', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
        local state = Entity(veh).state
        if state.nd_nitro_nos and state.nd_nitro_nos >= 100 then
            exports['qb-core']:GetCoreObject().Functions.Notify("Bu aracin nitrosu zaten tamamen dolu!", "error")
            return
        end
        local text = state.nd_nitro_nos and "Nitro Yenileniyor..." or "Nitro Tesisati Kuruluyor..."
        exports['qb-core']:GetCoreObject().Functions.Progressbar("install_nos", text, 5000, false, true, {
            disableMovement = false, disableCarMovement = true, disableMouse = false, disableCombat = true,
        }, {}, {}, {}, function()
            TriggerServerEvent('nitrous:server:Apply', VehToNet(veh))
        end, function()
            exports['qb-core']:GetCoreObject().Functions.Notify("Iptal edildi.", "error")
        end)
    else
        exports['qb-core']:GetCoreObject().Functions.Notify("Bir aracin surucu koltugunda olmalisin!", "error")
    end
end)

-- Blue Flames Logic
local blueFlames = {}

function CreateBlueFlames(veh)
    if blueFlames[veh] then return end
    blueFlames[veh] = {}
    local bones = {"exhaust", "exhaust_2", "exhaust_3", "exhaust_4", "exhaust_5", "exhaust_6"}
    
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do Wait(0) end
    
    for _, bone in pairs(bones) do
        local boneIndex = GetEntityBoneIndexByName(veh, bone)
        if boneIndex ~= -1 then
            UseParticleFxAsset("core")
            local ptfx = StartParticleFxLoopedOnEntityBone("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, boneIndex, 2.0, false, false, false)
            SetParticleFxLoopedColour(ptfx, 0.0, 0.3, 1.0, false)
            table.insert(blueFlames[veh], ptfx)
        end
    end
end

function StopBlueFlames(veh)
    if blueFlames[veh] then
        for _, ptfx in pairs(blueFlames[veh]) do
            StopParticleFxLooped(ptfx, 0)
            RemoveParticleFx(ptfx, 0)
        end
        blueFlames[veh] = nil
    end
end
