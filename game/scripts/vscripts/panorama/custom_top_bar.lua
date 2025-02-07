require("utils/timers")

function GetBotNetWorth(hero)
    if not hero or not hero:IsHero() then
        return 0
    end

    local totalItemValue = 0
    for slot = 0, 8 do
        local item = hero:GetItemInSlot(slot)
        if item then
            totalItemValue = totalItemValue + item:GetCost()
        end
    end

    local heroGold = hero:GetGold()

    local netWorth = totalItemValue + heroGold

    return netWorth
end

function SendHeroDataToClient(time, debug_mode)

    local interval = time

    Timers:CreateTimer(time+0.3, function()
        local playersData = { -- example
            [0] = { id = 0, hero = "npc_dota_hero_bristleback", networth = 600 },
           --[1] = { id = 1, hero = "npc_dota_hero_huskar", networth = 900 },
           --[2] = { id = 2, hero = "npc_dota_hero_nevermore", networth = 750 },
           --[3] = { id = 3, hero = "npc_dota_hero_legion_commander", networth = 1250 },
           --[4] = { id = 4, hero = "npc_dota_hero_pudge", networth = 3250 },
        }
            
            local playerCount = HeroList:GetHeroCount()
        
            for playerID = 0, playerCount - 1 do -- player id
                local hero     = HeroList:GetHero(playerID)
                local heroName = hero:GetUnitName()
                local isAlive  = hero:IsAlive()
                local networth = 0
                if PlayerResource:IsValidPlayerID(playerID) then
                    networth = PlayerResource:GetNetWorth(playerID)
                else
                    networth = GetBotNetWorth(hero)
                end

                local status = 0

                if not isAlive then
                    status = 1
                elseif hero.IsInGame == false then
                    status = 2
                end

                playersData[playerID] = { id = playerID, hero = heroName, status=status ,networth = networth }
                if debug_mode == true then
                    print("\nSending HeroData:\n==================")
                    print("id = ", playersData[playerID].id)
                    print("hero = ", playersData[playerID].hero)
                    print("status = ", playersData[playerID].status)
                    print("networth = ", playersData[playerID].networth, "\n==================")
                    DeepPrintTable(playersData)
                end
                CustomGameEventManager:Send_ServerToAllClients("update_top_bar", {data = playersData,})
            end 
        
    return time
    end)
end

function GameMode:TopBar_Select( data )
    local name = data.ent
    local index = 0
    for i = 0, HeroList:GetHeroCount() - 1 do
        local hero = HeroList:GetHero(i)
        if hero:GetUnitName() == data.ent then
            index = hero:GetEntityIndex()
            print("hero: "..hero:GetUnitName())
            print("index: "..index)
        end
    end
    CustomGameEventManager:Send_ServerToAllClients("top_bar_select_hero", {index = index})
end