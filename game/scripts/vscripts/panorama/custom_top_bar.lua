require("utils/timers")

function SendHeroDataToClient(time)

    local interval = time

    print("top_bar_lua")
    Timers:CreateTimer(time, function()
        local playerData = {}
        local playerCount = PlayerResource:GetPlayerCount()
    
        for playerID = 0, playerCount - 1 do
    
            if PlayerResource:IsValidPlayerID(playerID) then
                local player = PlayerResource:GetPlayer(playerID)
    
                    Timers:CreateTimer(0.25, function()
    
                        local hero   = player:GetAssignedHero()
    
                        if hero then
                            print(hero:GetUnitName())
    
                            local gold = PlayerResource:GetNetWorth(playerID)
                            local heroName = hero:GetUnitName()
    
                            table.insert(playerData, {playerID = playerID, hero = heroName, gold = gold})
                            print("Sending player data:", DeepPrintTable(playerData))
    
                            -- отправка данных
                            CustomGameEventManager:Send_ServerToAllClients("update_top_bar", {players = playerData})
                        end
                    end)
            end
        end
        return time
    end)
end
