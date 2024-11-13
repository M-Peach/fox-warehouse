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
exports['qb-target']:AddBoxZone("disableSecurity", vector3(977.71, -1497.37, 31.29), 1.0, 1.0, {
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

-- Event for Disabling Security
RegisterNetEvent('warehouse:disableSecurity', function()
    local playerPed = PlayerPedId()
    local hasItem = QBCore.Functions.HasItem("electronickit")

    if hasItem then
        -- Start the hacking sequence
        if exports["hacking"]:StartNumbersGame(4, 10, 5) then
            if exports["hacking"]:StartNumbersGame(6, 20, 5) then
                if exports["hacking"]:StartNumbersGame(8, 30, 8) then
                    -- Successful hack
                    QBCore.Functions.Notify("Security disabled. You have limited time before it reactivates!")
                    -- Additional actions for disabling security, such as setting a timer or triggering an alarm countdown
                else
                    -- Failed at the final stage
                    QBCore.Functions.Notify("Hack failed! Police have been alerted.", "error")
                    TriggerServerEvent("warehouse:alertPolice")
                end
            else
                -- Failed at the second stage
                QBCore.Functions.Notify("Hack failed! Police have been alerted.", "error")
                TriggerServerEvent("warehouse:alertPolice")
            end
        else
            -- Failed at the first stage
            QBCore.Functions.Notify("Hack failed! Police have been alerted.", "error")
            TriggerServerEvent("warehouse:alertPolice")
        end
    else
        QBCore.Functions.Notify("You need an electronickit to disable the security!", "error")
    end
end)
