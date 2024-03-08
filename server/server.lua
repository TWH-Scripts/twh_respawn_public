local VorpCore = {}
VorpInv = exports.vorp_inventory:vorp_inventoryApi()

TriggerEvent("getCore",function(core)
    VorpCore = core
end)


local savedInventories = {}
-------------------
------ Intit ------
local function calculateLosses(level, dictionary)
    local losses = {}
    
    for key, subDict in pairs(dictionary) do
        local maxAvailableLevel = nil

        for k, v in pairs(subDict) do
            if (maxAvailableLevel == nil or k > maxAvailableLevel) and k <= level then
                maxAvailableLevel = k
                losses[key] = v
            end
        end
    end

    return losses
end

RegisterCommand("testloss", function (source, args, rawCommand)
    --print all saved inventories
    for k, v in pairs(savedInventories) do
        print(k)
        print("Items:")
        for key, item in pairs(v.items) do
            print(item.label, item.metadata)
        end
        print("Weapons:")
        for key, weapon in pairs(v.weapons) do
            print(weapon.label)
        end
    end
    
end)




RegisterServerEvent("twh_respawn:respawnTriggered")
AddEventHandler("twh_respawn:respawnTriggered", function(psocial)
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local money = Character.money
    local gold = Character.gold
    local rol = Character.rol
    local social = psocial
    savedInventories[charid] = {items = {}, weapons = {}, money = 0} --reset saved inventory
    local tableofstuff = {}

    exports.ghmattimysql:execute("UPDATE characters Set isdead=@isdead WHERE identifier=@identifier AND charidentifier = @charidentifier", {['isdead'] = 0,['identifier'] = identifier, ['charidentifier'] = charid})

    local losses = calculateLosses(social, Config.remove)

    for key, loss in pairs(losses) do
        if loss > 0 then
            if key == "money" then
                local moneyLoss = money * loss
                savedInventories[charid].money = moneyLoss
                Character.removeCurrency(0, moneyLoss)
            elseif key == "items" then
                TriggerEvent("vorpCore:getUserInventory", tonumber(_source), function(getInventory)
                    local itemCount = 0
                    for k, v in pairs (getInventory) do
                        itemCount = itemCount + 1
                    end
                    local itemLoss = math.ceil(itemCount * loss)
                    DebugPrint("itemLoss: " .. itemLoss .. " out of:"..itemCount)
                    itemCount = 0
                    for k, v in pairs (getInventory) do
                        if not Contains(Config.blacklistedItems,v.name) then 
                            if itemCount <= itemLoss then
                                savedInventories[charid].items[#savedInventories[charid].items+1] = {label = v.label, name = v.name, count = v.count, metadata = v.metadata}
                                VorpInv.subItem(_source, v.name, v.count, v.metadata)
                                itemCount = itemCount + 1
                            else
                                break
                            end
                        end 
                    end
                end) 
            elseif key == "weapons" then
                local weapons = VorpInv.getUserWeapons(_source)
                local weaponCount = 0
                for k, v in pairs (weapons) do
                    weaponCount = weaponCount + 1
                end
                local weaponLoss = math.ceil(weaponCount * loss)
                DebugPrint("weaponLoss: " .. weaponLoss .. " out of:"..weaponCount)
                weaponCount = 0
                for k, v in pairs (weapons) do
                    DebugPrint(json.encode(v))
                    if not Contains(Config.blacklistedWeapons,v.name) then 
                        if weaponCount <= weaponLoss then
                            DebugPrint("weapon: " .. v.name .. " id: " .. v.id)
                            local weaponComps = exports.vorp_inventory:getWeaponComponents(_source, tonumber(v.id)) -- VorpInv.getWeaponComponents(tonumber(_source), tonumber(v.id))
                            DebugPrint("weaponComps: " .. json.encode(weaponComps))
                            savedInventories[charid].weapons[#savedInventories[charid].weapons+1] = {name = v.name, comp = weaponComps, ammo = v.ammo, serial = v.serial_number}
                            exports.vorp_inventory:subWeapon(_source, v.id)
                            DebugPrint("weapon deleted"..v.id)
                            weaponCount = weaponCount + 1
                        else
                            break
                        end
                    end
                end
            end
        end
    end
end)


RegisterServerEvent("twh_respawn:lostAndFoundTriggered")
AddEventHandler("twh_respawn:lostAndFoundTriggered", function(psocial, locationKey)
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local charid = Character.charIdentifier
    local locationConfig = Config.lostAndFoundLocations[locationKey]
    local losses = calculateLosses(psocial, locationConfig.canRetrieve)
    DebugPrint("losses:")
    for key, loss in pairs(losses) do
        DebugPrint(key .. ": " .. loss)
    end
    local costToRetrieve  = locationConfig.costToRetrieve
    if savedInventories[charid] then
        if costToRetrieve > 0 then
            if Character.money >= costToRetrieve then
                Character.removeCurrency(0, costToRetrieve)
            else
                --notify left that player have not enough money
                VorpCore.NotifyLeft(_source,Language.titleLostAndFound, Language.notEnoughMoney, "menu_textures","cross", 5000, "COLOR_WHITE")
                return
            end
        end
        local items = savedInventories[charid].items
        local weapons = savedInventories[charid].weapons
        --calculate how many items are given back based on the items lost
        local itemCount = 0
        for key, item in pairs(items) do
            itemCount = itemCount + 1
        end
        local itemRetrive = math.ceil(itemCount * losses.items)
        for key, item in pairs(items) do
            if key <= itemRetrive then
                VorpInv.addItem(_source, item.name, item.count, item.metadata)
            else
                break
            end
        end
        --calculate how many weapons are given back based on the weapons lost
        local weaponCount = 0
        for key, weapon in pairs(weapons) do
            weaponCount = weaponCount + 1
        end
        local weaponRetrive = math.ceil(weaponCount * losses.weapons)
        for key, weapon in pairs(weapons) do
            if key <= weaponRetrive then
                exports.vorp_inventory:createWeapon(_source, weapon.name, weapon.ammo,{}, weapon.comp, function(success) 
                end, weapon.serial)
            else
                break
            end
        end
        if savedInventories[charid].money > 0 then
            local moneyRetrive = savedInventories[charid].money * losses.money
            Character.addCurrency(0, moneyRetrive)
        end
        savedInventories[charid] = nil --reset saved inventory
        VorpCore.NotifyLeft(_source, Language.titleLostAndFound, Language.allItemsRetrieved, "generic_textures","tick", 5000, "COLOR_WHITE")
    else
        --notify left that they have nothing to retrieve
        VorpCore.NotifyLeft(_source, Language.titleLostAndFound, Language.nothingToRetrieve, "menu_textures","cross", 5000, "COLOR_WHITE")
    end
    
end)


--register server event when player pickup all lost loot
RegisterServerEvent("twh_respawn:pickupAllTriggered")
AddEventHandler("twh_respawn:pickupAllTriggered", function()
    --retrieve all lost items
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local charid = Character.charIdentifier
    if savedInventories[charid] then
        local items = savedInventories[charid].items
        local weapons = savedInventories[charid].weapons
        for key, item in pairs(items) do
            VorpInv.addItem(_source, item.name, item.count, item.metadata)
        end
        for key, weapon in pairs(weapons) do
            VorpInv.createWeapon(_source, weapon.name, weapon.ammo, weapon.comp)
        end
        if savedInventories[charid].money > 0 then
            Character.addCurrency(0, savedInventories[charid].money)
        end
        savedInventories[charid] = nil --reset saved inventory

        --notify that all items are retrieved
        VorpCore.NotifyLeft(_source, Language.titleCollect, Language.allItemsCollected, "generic_textures","tick", 5000, "COLOR_WHITE")
    end

end)