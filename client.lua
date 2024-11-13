local QBCore = exports['qb-core']:GetCoreObject()
local spawnedObjects = {}

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

-- Function for the Full Hacking Sequence
function StartHackingSequence()
    if exports["numbers"]:StartNumbersGame(6, 10, 5) then
        QBCore.Functions.Notify("Security disabled. All players can now enter the warehouse!")
        TriggerServerEvent("warehouse:enableEntryForAll")  -- Notify the server to enable entry for all players
        return true
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
        -- Call the hacking sequence
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

function SpawnLootCrates()
    local crateModel = "prop_boxpile_06a"
    local weaponCrateModel = "prop_mil_crate_01"

    -- Request Models
    RequestModel(crateModel)
    RequestModel(weaponCrateModel)
    while not HasModelLoaded(crateModel) or not HasModelLoaded(weaponCrateModel) do
        Wait(100)
    end

    -- Spawn regular crates
    local crateLocations = {
        Config.Warehouse.crateOne,
        Config.Warehouse.crateTwo,
        Config.Warehouse.crateThree,
        Config.Warehouse.crateFour
    }

    for _, cratePos in ipairs(crateLocations) do
        local crateObject = CreateObject(crateModel, cratePos.x, cratePos.y, cratePos.z, false, true, false)
        SetEntityHeading(crateObject, cratePos.w)
        PlaceObjectOnGroundProperly(crateObject)
        FreezeEntityPosition(crateObject, true)
        table.insert(spawnedObjects, crateObject)

        -- Add qb-target for searching
        exports['qb-target']:AddTargetEntity(crateObject, {
            options = {
                {
                    type = "client",
                    event = "warehouse:searchCrate",
                    icon = "fas fa-search",
                    label = "Search Crate",
                    crateId = crateObject  -- Pass unique identifier
                }
            },
            distance = 2.5
        })
    end

    -- Spawn weapons crate with qb-target
    local weaponCratePos = Config.Warehouse.weaponCrate
    local weaponCrateObject = CreateObject(weaponCrateModel, weaponCratePos.x, weaponCratePos.y, weaponCratePos.z, false, true, false)
    SetEntityHeading(weaponCrateObject, weaponCratePos.w)
    PlaceObjectOnGroundProperly(weaponCrateObject)
    FreezeEntityPosition(weaponCrateObject, true)
    table.insert(spawnedObjects, weaponCrateObject)

    -- Add qb-target for searching weapon crate
    exports['qb-target']:AddTargetEntity(weaponCrateObject, {
        options = {
            {
                type = "client",
                event = "warehouse:searchCrate",
                icon = "fas fa-search",
                label = "Search Crate",
                crateId = weaponCrateObject  -- Pass unique identifier
            }
        },
        distance = 2.5
    })
end

RegisterNetEvent('warehouse:searchCrate', function(data)
    local crateId = data.crateId
    local playerPed = PlayerPedId()

    -- Animation setup
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Wait(100)
    end

    -- Start animation
    TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 1, 0, false, false, false)

    -- Show progress bar
    QBCore.Functions.Progressbar("search_crate", "Searching crate...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()  -- onComplete function
        -- Stop animation
        ClearPedTasks(playerPed)

        -- Determine loot rewards (up to 2 items)
        local loot = {}
        while #loot < 2 do
            local randomItem = Config.CrateLoot[math.random(1, #Config.CrateLoot)]
            if math.random(1, 100) <= randomItem.chance then
                local amount = math.random(1, randomItem.max)
                table.insert(loot, { item = randomItem.item, amount = amount })
            end
        end

        -- Provide loot to player
        for _, reward in ipairs(loot) do
            TriggerServerEvent("warehouse:AddItem", reward.item, reward.amount)
            QBCore.Functions.Notify("You found " .. reward.amount .. "x " .. reward.item)
        end

        -- Disable further searches on this crate (optional)
        exports['qb-target']:RemoveTargetEntity(crateId, "Search Crate")

    end, function()  -- onCancel function
        -- Cancel search, stop animation
        ClearPedTasks(playerPed)
        QBCore.Functions.Notify("Search canceled", "error")
    end)
end)

-- Client event to enable entry and exit targets for all players
RegisterNetEvent('warehouse:enableEntryTarget', function()
    -- Spawn loot crates
    SpawnLootCrates()
	SpawnGuards()

    -- Entry Target
    exports['qb-target']:AddBoxZone("warehouseEntryLock", Config.Warehouse.entry, 1.0, 1.0, {
        name = "warehouseEntryLock",
        heading = 0,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "warehouse:enterWarehouse",
                icon = "fas fa-door-open",
                label = "Enter Warehouse",
            },
            {
                type = "server",
                event = "warehouse:disableEntryForAll",
                icon = "fas fa-lock",
                label = "Lock Warehouse",
                job = "police"  -- Restrict this option to police only
            }
        },
        distance = 2.5
    })

    -- Front Exit Target
    exports['qb-target']:AddBoxZone("warehouseFrontExit", Config.Warehouse.frontExit, 1.0, 1.0, {
        name = "warehouseFrontExit",
        heading = 0,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "warehouse:exitWarehouse",
                icon = "fas fa-door-open",
                label = "Exit Warehouse (Front)"
            },
        },
        distance = 2.5
    })

    -- Back Exit Target
    exports['qb-target']:AddBoxZone("warehouseBackExit", Config.Warehouse.backExit, 1.0, 1.0, {
        name = "warehouseBackExit",
        heading = 0,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "warehouse:exitWarehouse",
                icon = "fas fa-door-open",
                label = "Exit Warehouse (Back)"
            },
        },
        distance = 2.5
    })
end)

-- Event to Exit the Warehouse
RegisterNetEvent('warehouse:exitWarehouse', function()
    SetEntityCoords(PlayerPedId(), Config.Warehouse.entry.x, Config.Warehouse.entry.y, Config.Warehouse.entry.z)
    QBCore.Functions.Notify("You have exited the warehouse.")
end)

function SpawnGuards()
    local guardOneModel = "s_m_m_armoured_01"
    local guardTwoModel = "s_m_m_armoured_02"
    local dogModel = "a_c_chop"
	local relationshipGroup = "warehouse_guards"

	AddRelationshipGroup(relationshipGroup)
	
    -- Request Models
    RequestModel(guardOneModel)
    RequestModel(guardTwoModel)
    RequestModel(dogModel)

    while not HasModelLoaded(guardOneModel) or not HasModelLoaded(guardTwoModel) or not HasModelLoaded(dogModel) do
        Wait(100)
    end

    -- Spawn and configure Guard One
    local guardOne = CreatePed(4, guardOneModel, Config.Guards.guardOne.x, Config.Guards.guardOne.y, Config.Guards.guardOne.z, Config.Guards.guardOne.w, true, true)
    SetPedArmour(guardOne, 100)
    SetEntityHealth(guardOne, 100)
    GiveWeaponToPed(guardOne, GetHashKey("WEAPON_PISTOL"), 250, false, true)
    SetPedCombatAttributes(guardOne, 46, true)  -- Aggressive
    SetPedCombatAbility(guardOne, 2)  -- High combat ability
    SetPedCombatRange(guardOne, 2)  -- Combat range: medium
    SetPedCombatMovement(guardOne, 2)  -- Combat movement: advance
	SetPedRelationshipGroupHash(guardOne, GetHashKey(relationshipGroup))

    -- Spawn and configure Guard Two
    local guardTwo = CreatePed(4, guardTwoModel, Config.Guards.guardTwo.x, Config.Guards.guardTwo.y, Config.Guards.guardTwo.z, Config.Guards.guardTwo.w, true, true)
    SetPedArmour(guardTwo, 100)
    SetEntityHealth(guardTwo, 100)
    GiveWeaponToPed(guardTwo, GetHashKey("WEAPON_PISTOL"), 250, false, true)
    SetPedCombatAttributes(guardTwo, 46, true)  -- Aggressive
    SetPedCombatAbility(guardTwo, 2)  -- High combat ability
    SetPedCombatRange(guardTwo, 2)  -- Combat range: medium
    SetPedCombatMovement(guardTwo, 2)  -- Combat movement: advance
	SetPedRelationshipGroupHash(guardTwo, GetHashKey(relationshipGroup))

    -- Spawn and configure Guard Dog
    local guardDog = CreatePed(4, dogModel, Config.Guards.guardDog.x, Config.Guards.guardDog.y, Config.Guards.guardDog.z, Config.Guards.guardDog.w, true, true)
    SetEntityHealth(guardDog, 100)
    SetPedFleeAttributes(guardDog, 0, false)
    SetPedCombatAttributes(guardDog, 5, true)  -- Always fight
    SetPedCombatAttributes(guardDog, 46, true) -- Aggressive
	SetPedRelationshipGroupHash(guardDog, GetHashKey(relationshipGroup))
	
	SetRelationshipBetweenGroups(0, GetHashKey(relationshipGroup), GetHashKey(relationshipGroup))  
    SetRelationshipBetweenGroups(5, GetHashKey(relationshipGroup), GetHashKey("PLAYER")) 


    -- Configure guards and dog to attack players on sight
    local playerPed = PlayerPedId()
    TaskCombatPed(guardOne, playerPed, 0, 16)  -- Set to attack player
    TaskCombatPed(guardTwo, playerPed, 0, 16)  -- Set to attack player
    TaskCombatPed(guardDog, playerPed, 0, 16)  -- Dog set to attack player
end

RegisterNetEvent('warehouse:disableEntryForAll', function()
    exports['qb-target']:RemoveZone("warehouseEntryLock")
end)
