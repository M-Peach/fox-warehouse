local QBCore = exports['qb-core']:GetCoreObject()

-- Create Blip for Warehouse Location
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(980.26, -1497.75, 37.37)
    SetBlipSprite(blip, 478)                   -- Icon for warehouse
    SetBlipDisplay(blip, 4)                    -- Display option
    SetBlipScale(blip, 0.8)                    -- Scale
    SetBlipColour(blip, 1)                     -- Color
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Warehouse")
    EndTextCommandSetBlipName(blip)
end)

-- Target for Disabling Security
exports['qb-target']:AddBoxZone("disableSecurity", Config.Warehouse.disableSecurity, 1.0, 1.0, {
    name = "disableSecurity",
    heading = 0,
    debugPoly = false,
    minZ = 30.29,
    maxZ = 32.29
}, {
    options = {
        {
            type = "client",
            event = "warehouse:disableSecurity",
            icon = "fas fa-bolt",
            label = "Disable Security",
            item = "electronickit"   -- Requires the start item
        },
    },
    distance = 2.5
})

-- Function for a single hack attempt
function AttemptHack(level, showtime, typetime)
    return exports["numbers"]:StartNumbersGame(level, showtime, typetime)
end

-- Function for the Full Hacking Sequence
function StartHackingSequence()
    -- First hack attempt
    if AttemptHack(6, 10, 5) then
        Wait(200)
        
        -- Second hack attempt
        if AttemptHack(7, 10, 8) then
            QBCore.Functions.Notify("Security disabled. All players can now enter the warehouse!")
            TriggerServerEvent("warehouse:enableEntryForAll")  -- Notify the server to enable entry for all players
            return true
        end
    end

    -- Hacking failed
    QBCore.Functions.Notify("Hack failed! Police have been alerted.", "error")
    TriggerServerEvent("warehouse:alertPolice")
    return false
end

-- Event for Disabling Security
RegisterNetEvent('warehouse:disableSecurity', function()
    local hasItem = QBCore.Functions.HasItem("electronickit")

    if hasItem then
        -- Call the hacking sequence twice
        StartHackingSequence()
        Wait(2000) -- Arbitrary delay between hack attempts
        StartHackingSequence()
    else
        QBCore.Functions.Notify("You need an electronickit to disable the security!", "error")
    end
end)

-- Event to Enter the Warehouse
RegisterNetEvent('warehouse:enterWarehouse', function()
    SetEntityCoords(PlayerPedId(), Config.Warehouse.frontExit.x, Config.Warehouse.frontExit.y, Config.Warehouse.frontExit.z)
    QBCore.Functions.Notify("You have entered the warehouse.")
end)

-- Client event to enable entry target for all players
RegisterNetEvent('warehouse:enableEntryTarget', function()
    exports['qb-target']:AddBoxZone("warehouseEntry", Config.Warehouse.entry, 1.0, 1.0, {
        name = "warehouseEntry",
        heading = 0,
        debugPoly = false,
        minZ = Config.Warehouse.entry.z - 1.0,
        maxZ = Config.Warehouse.entry.z + 1.0
    }, {
        options = {
            {
                type = "client",
                event = "warehouse:enterWarehouse",
                icon = "fas fa-door-open",
                label = "Enter Warehouse"
            },
        },
        distance = 2.5
    })
end)
