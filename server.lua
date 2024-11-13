local QBCore = exports['qb-core']:GetCoreObject()

-- Server event to enable entry for all players
RegisterNetEvent('warehouse:enableEntryForAll', function()
    TriggerClientEvent('warehouse:enableEntryTarget', -1)  -- Broadcast to all clients
end)

-- Police alert event
RegisterNetEvent('warehouse:alertPolice', function()
    -- Code to notify police or trigger an alarm
end)

RegisterNetEvent("warehouse:AddItem", function(item, amount)
    local src = source
	exports['codem-inventory']:AddItem(src, item, amount, nil, nil)
end)

RegisterNetEvent('warehouse:disableEntryForAll', function()
    TriggerClientEvent('warehouse:disableEntryTarget', -1)  -- Broadcast to all clients
end)
