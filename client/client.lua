local lvlAPI
local doctorAPI
local socialLvl = 0 
if Config.twh_social then
    lvlAPI = exports['twh_social'].lvlAPI()
end
if Config.mega_doctorjob.enabled then
    doctorAPI = exports['mega_doctorjob'].ClientAPI()
end


------------------------
-- Threads and Functions
------------------------
local function spawnNPC(locationKey)
    local v = Config.lostAndFoundLocations[locationKey]
    local x, y, z, h = v.npcCoords.x, v.npcCoords.y, v.npcCoords.z, v.npcCoords.h
    DebugPrint("Spawning NPC at " .. x .. " " .. y .. " " .. z .. " " .. h)
    -- Loading Model
    local hashModel = GetHashKey(v.npcModel) 
    if IsModelValid(hashModel) then 
        RequestModel(hashModel)
        while not HasModelLoaded(hashModel) do                
            Wait(100)
        end
    else 
        print(v.npcmodel .. " is not valid") -- Concatenations
    end        
    -- Spawn Ped
    local npc = CreatePed(hashModel, x, y, z, h, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
    SetEntityNoCollisionEntity(PlayerPedId(), npc, false)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(1000)
    FreezeEntityPosition(npc, true) -- NPC can't escape
    SetBlockingOfNonTemporaryEvents(npc, true) -- NPC can't be scared
    Config.lostAndFoundLocations[locationKey].NPC = npc

end

local function dynamicNpcSpawn() 
    -- dynamic spawn of NPCs when a player is near
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local coordsDist = vector3(coords.x, coords.y, coords.z)
    
    for locationKey, locationConfig in pairs(Config.lostAndFoundLocations) do
        if locationConfig.npcModel then
            local coordsNpc = vector3(locationConfig.npcCoords.x, locationConfig.npcCoords.y, locationConfig.npcCoords.z)
            local distance = #(coordsDist - coordsNpc)
            if not Config.lostAndFoundLocations[locationKey].NPC then
              if distance < Config.spawnDistance then
                spawnNPC(locationKey)
              end
            elseif Config.lostAndFoundLocations[locationKey].NPC then
              if distance > Config.spawnDistance then
                  DeleteEntity(Config.lostAndFoundLocations[locationKey].NPC)
                  DeletePed(Config.lostAndFoundLocations[locationKey].NPC)
                  SetEntityAsNoLongerNeeded(Config.lostAndFoundLocations[locationKey].NPC)
                  Config.lostAndFoundLocations[locationKey].NPC = nil
              end
            end
        end
      
    end
  
end
local function initPrompts()
	if Config.lostAndFound then
        CreatePromptButton("collect",Language.lostAndFoundPrompt,Config.keys.lostAndFound,1000)
    elseif Config.dropLootAtRespwan then
        CreatePromptButton("collect",Language.collect,Config.keys.collect,1000)
    end
end

Citizen.CreateThread(function()
    initPrompts()
    while true do
        Citizen.Wait(1000)
        if Config.lostAndFound then
            dynamicNpcSpawn()
        end
    end
end)

Citizen.CreateThread(function ()
    if Config.lostAndFound then
        while true do
            Citizen.Wait(0)
            local sleep = true

            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            local coordsDist = vector3(coords.x, coords.y, coords.z)
            for locationKey, locationConfig in pairs(Config.lostAndFoundLocations) do
                local coordsNpc = vector3(locationConfig.npcCoords.x, locationConfig.npcCoords.y, locationConfig.npcCoords.z)
                local distance = #(coordsDist - coordsNpc)
                if distance < locationConfig.distance then
                    sleep = false
                    if locationConfig.costToRetrieve > 0 then
                        DisplayPrompt("collect",Language.lostAndFound..Language.cost..locationConfig.costToRetrieve.."$" )
                    else
                        DisplayPrompt("collect",Language.lostAndFound )
                    end
                    if IsPromptCompleted("collect", Config.keys.lostAndFound) then
                        if Config.twh_social then
                            socialLvl = lvlAPI.getSocialLevel()
                        end
                        TriggerServerEvent('twh_respawn:lostAndFoundTriggered',socialLvl, locationKey)
                        Citizen.Wait(5000)
                    end
                end
            end
            if sleep then
                Citizen.Wait(1000)
            end
        end    
    end
end)


------------------------
-- Events
------------------------
RegisterNetEvent('vorp:PlayerForceRespawn')
AddEventHandler('vorp:PlayerForceRespawn', function()
    if Config.twh_social then
        socialLvl = lvlAPI.getSocialLevel()
    end

    TriggerServerEvent('twh_respawn:respawnTriggered',socialLvl)

    if Config.mega_doctorjob.enabled then
        doctorAPI.giveDisease(Config.mega_doctorjob.disease)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
       --delete all NPCs from lostAndFoundLocations
       for locationKey, locationConfig in pairs(Config.lostAndFoundLocations) do
            if locationConfig.npcModel then
                if Config.lostAndFoundLocations[locationKey].NPC then
                    DeleteEntity(Config.lostAndFoundLocations[locationKey].NPC)
                    DeletePed(Config.lostAndFoundLocations[locationKey].NPC)
                    SetEntityAsNoLongerNeeded(Config.lostAndFoundLocations[locationKey].NPC)
                    Config.lostAndFoundLocations[locationKey].NPC = nil
                end
            end
        end
    end
end)



--register command to test respawn
RegisterCommand("testrespawn", function ()
    socialLvl = 5
    TriggerServerEvent('twh_respawn:respawnTriggered',socialLvl)
    --if Config.mega_doctorjob.enabled then
    --    doctorAPI.giveDisease(Config.mega_doctorjob.disease)
    --end
end)