local QBCore = exports['qb-core']:GetCoreObject()
local notifyCooldowns = {}
local relieveCooldowns = {}

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local newStress = Player.PlayerData.metadata['stress'] or 0
    newStress = newStress + amount
    if newStress > 100 then newStress = 100 end
    
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    
    local currentTime = os.time()
    if not notifyCooldowns[src] or (currentTime - notifyCooldowns[src] > 30) then
        TriggerClientEvent('QBCore:Notify', src, "Stres seviyeniz yukseliyor...", 'error', 3500)
        notifyCooldowns[src] = currentTime
    end
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local newStress = Player.PlayerData.metadata['stress'] or 0
    newStress = newStress - amount
    if newStress < 0 then newStress = 0 end
    
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    
    local currentTime = os.time()
    if not relieveCooldowns[src] or (currentTime - relieveCooldowns[src] > 30) then
        TriggerClientEvent('QBCore:Notify', src, "Stresiniz azaldi, rahatliyorsunuz.", 'success', 3500)
        relieveCooldowns[src] = currentTime
    end
end)
