Config = {}

-- Warehouse Location
Config.Warehouse = {
    entry = vector3(978.14, -1500.14, 31.51),       
    frontExit = vector3(1105.07, -3099.63, -39.0),  
    backExit = vector3(1087.44, -3099.38, -39.0),   
    disableSecurity = vector3(977.71, -1497.37, 31.29),
    crateOne = vector4(1101.32, -3096.59, -39.0, 0),   
    crateTwo = vector4(1097.69, -3096.59, -39.0, 0),  
    crateThree = vector4(1095.01, -3096.59, -39.0, 90), 
    crateFour = vector4(1091.53, -3096.59, -39.0, 0), 
    weaponCrate = vector4(1095.94, -3102.36, -39.0, 180) 
}

-- Guard Positions
Config.Guards = {
    guardOne = vector4(1089.17, -3101.77, -39.0, 270),  
    guardTwo = vector4(1091.4, -3098.38, -39.0, 270),   
    guardDog = vector4(1097.76, -3102.53, -39.0, 291.53)   
}

-- Settings for robbery
Config.Robbery = {
    requiredPolice = 2,                 
    requiredStartItem = "electronickit",
    robberyTime = 600,                  
    coolDown = 1800                     
}  

-- Item and reward settings
Config.Items = {
    {item = "gold_bar", chance = 50},   
    {item = "diamond", chance = 30},    
    {item = "cash_stack", chance = 70},  
}

-- Weapon Crate loot settings
Config.WeaponCrateLoot = {
    {item = "weapon_pistol50", chance = 30, max = 1},
    {item = "pistol_ammo", chance = 100, max = 6},
    {item = "weapon_pistol", chance = 50, max = 1},
    {item = "weapon_combatpistol", chance = 40, max = 1}
}

-- Crate loot settings
Config.CrateLoot = {
    {item = "coke_small_brick", chance = 40, max = 2},
    {item = "c4_bomb", chance = 40, max = 2},
    {item = "advancedlockpick", chance = 70, max = 3},
    {item = "weapon_knuckle", chance = 60, max = 2},
    {item = "armor", chance = 50, max = 2},
    {item = "goldbar", chance = 60, max = 3},
    {item = "ifaks", chance = 50, max = 3},
    {item = "bandage", chance = 80, max = 4},
    {item = "radioscanner", chance = 60, max = 1},
    {item = "nos", chance = 60, max = 3}
}
