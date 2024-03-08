Config =  {}

Config.debug = true

--Webhook
Config.webhook = {
    Logs         = true,  --enable logs
    Discord      = true,  --if you use discord whitelist
    webhook      = "https://discord.com/api/webhooks/1122282793880260658/2fvxIt9fI93jCq1dre1PJM7rZG540bGmmLriSO_k-bu_3G3UaUXrh5aGntQUiUPXhmyW",
    webhookColor = 16711680,
    name         = "twh_respawn", 
    logo         = "https://via.placeholder.com/30x30", -- Header
    footerLogo   = "https://via.placeholder.com/30x30", -- Footer
    Avatar       = "https://via.placeholder.com/30x30", -- Avatar
}

Config.keys = {
    lostAndFound = 0x760A9C6F, --G
    collect = 0x760A9C6F, --G
}


Config.twh_social = true --if you have twh_social installed, set this to true
Config.mega_doctorjob = {
    enabled = true, --if you have mega_doctorjob installed, set this to true
    disease = "infection", --set this to the disease you want the player to get after respawn
}

Config.remove = {
    items = { --if you dont use twh_social only modify the 0 value
        [0] = 0.0, --at social level 0 you will lose 0% of your items
        [5] = 0.5, --at social level 5 you will lose 50% of your items
        [7] = 1.0, --at social level 7 you will lose 100% of your items
    },
    weapons = {
        [0] = 1.0, --at social level 0 you will lose 0% of your weapons
        [5] = 1.0, --at social level 5 you will lose 50% of your weapons
        [7] = 1.0, --at social level 7 you will lose 100% of your weapons
    },
    money = {
        [0] = 0.0, --at social level 0 you will lose 0% of your money
        [5] = 0.25, --at social level 5 you will lose 50% of your money
    }
}

Config.blacklistedWeapons = { --weapons that should not be removed
    "WEAPON_MELEE_HAMMER",
}

Config.blacklistedItems= { --items that should not be removed
    "catering_voucher",
    "badge_anniversary_one"
}

Config.dropLootAtRespwan = false --set to false if you dont want to drop loot at respawn and all is just gone
Config.dropLootatRespwanChance = 1.0 -- 100% chance to drop loot at respawn

Config.lootCanBePickedUp = false --if loot should can be picked up by everyone instead of only the owner (only if you use dropLootAtRespwan)


Config.lostAndFound = true --if you want to have a lost and found system (only use this if you don't use dropLootAtRespwan, otherweise loot is duplicated)
Config.spawnDistance = 200.0 --distance to spawn the lost and found location npcs from the player
Config.lostAndFoundLocations = {
    Valentine = {
        coords = {x = -179.41174316406 , y = 648.20336914063 , z = 113.48121643066},
        distance = 1.5,
        npcModel = "A_M_M_ValTownfolk_01", --set this to nil if you dont want to use any npcModel
        npcCoords = {x = -177.88916015625 , y = 647.09985351563 , z = 112.48399353027, h = 54.68},
        costToRetrieve = 5.0, --cost to retrieve your items
        canRetrieve = { --how many percent of the lost stuff is given back
            items = { --if you dont use twh_social only modify the 0 value. If you use twh_social, you can modify the values for each social level same logic as in config.remove
                [0] = 1.0, 
            },
            weapons = {
                [0] = 1.0, 
            },
            money = {
                [0] = 0.0, 
            }
        }
    },
    SaintDenis = {
        coords = {x = 2695.7731933594 , y = -1433.7395019531 , z = 46.120071411133},
        distance = 1.5,
        npcModel = "A_M_M_ValTownfolk_01", --set this to nil if you dont want to use any npcModel
        npcCoords = {x = 2695.7731933594 , y = -1433.7395019531 , z = 45.120071411133, h = 68.371},
        costToRetrieve = 5.0, --cost to retrieve your items
        canRetrieve = { --how many percent of the lost stuff is given back
            items = { --if you dont use twh_social only modify the 0 value. If you use twh_social, you can modify the values for each social level same logic as in config.remove
                [0] = 1.0, 
            },
            weapons = {
                [0] = 1.0, 
            },
            money = {
                [0] = 0.0, 
            }
        }
    },
}
