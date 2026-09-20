local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('nitrous', function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('nitrous:client:Install', src)
end)

RegisterNetEvent('nitrous:server:Apply', function(netId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh and veh > 0 then
        if Player.Functions.RemoveItem('nitrous', 1) then
            Entity(veh).state:set('nd_nitro_nos', 100.0, true)
            Entity(veh).state:set('nd_nitro_purge', 0.0, true)
            TriggerClientEvent('QBCore:Notify', src, 'Nitro başarıyla kuruldu / yenilendi!', 'success')
        end
    end
end)