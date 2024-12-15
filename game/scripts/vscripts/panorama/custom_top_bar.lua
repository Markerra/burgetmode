require("utils/timers")

function SendHeroDataToClient(time)

    local interval = time

    print("top_bar_lua")
    Timers:CreateTimer(time, function()
        local playersData = { -- example
            [0] = { id = 0, hero = "npc_dota_hero_bristleback", networth = 600 },
           --[1] = { id = 1, hero = "npc_dota_hero_huskar", networth = 900 },
           --[2] = { id = 2, hero = "npc_dota_hero_nevermore", networth = 750 },
           --[3] = { id = 3, hero = "npc_dota_hero_legion_commander", networth = 1250 },
           --[4] = { id = 4, hero = "npc_dota_hero_pudge", networth = 3250 },
        }
    
            local playerCount = PlayerResource:GetPlayerCount()
        
            for playerID = 0, playerCount - 1 do -- player id
                if PlayerResource:IsValidPlayerID(playerID) then -- check is player id real
                    local player   = PlayerResource:GetPlayer(playerID)
                    local heroName = player:GetAssignedHero():GetUnitName()
                    local networth = PlayerResource:GetNetWorth(playerID)
                    playersData[playerID] = { id = playerID, hero = heroName, networth = networth }
                    print("Sending HeroData:\n==================")
                    print("id = ", playersData[playerID].id)
                    print("hero = ", playersData[playerID].hero)
                    print("networth = ", playersData[playerID].networth, "\n==================")
                    table.sort(playersData, function(a, b) return a.networth > b.networth end)
                    CustomGameEventManager:Send_ServerToAllClients("update_top_bar", {data = playersData,})
                end
            end 
        
    return time
    end)
end
