require("utils/selection")

LinkLuaModifier("wtfModifier", "panorama/debug_panel", LUA_MODIFIER_MOTION_NONE)

function GameMode:Admin_SpawnBot(data)

	local heroName = data.hero
	local playerID = data.id
	local offset   = 100

	if not heroName or heroName == "" then
        print("debug_panel: неверное имя героя")
        return nil
    end

    -- Получаем объект игрока по playerID
    local player = PlayerResource:GetPlayer(playerID)
    if not player then
        print("debug_panel: неверный ID: " .. tostring(playerID))
        return nil
    end

    -- Получаем героя игрока
    local playerHero = player:GetAssignedHero()
    if not playerHero then
        print("Player does not have a hero")
        return nil
    end

    -- Получаем позицию героя игрока
    local playerPosition = playerHero:GetAbsOrigin()

    -- Добавляем смещение к позиции игрока (по умолчанию смещение по X-координате)
    local spawnPosition = playerPosition + Vector(offset, 0, 0)

    -- Создаем бота в указанной позиции
    local botHero = CreateUnitByName(heroName, spawnPosition, true, nil, nil, player:GetTeamNumber()+1)
    botHero:SetControllableByPlayer(playerID, true)
    botHero:SetPlayerID(HeroList:GetHeroCount() - 1)
    print("Admin Panel: Bot Spawned.","ID: "..botHero:GetPlayerID())
end

function GameMode:Admin_GiveItem(data)

	if not IsServer() then return end
	local entities = {}
	for key, value in pairs(data.ent) do
	    entities[tonumber(key)] = value
	end

	local item_name = data.item

	for key, value in pairs(entities) do
    	local hero = EntIndexToHScript(entities[key])
		print("Admin Panel: "..item_name.." Item for "..hero:GetUnitName())
		if not hero or hero == "" then
        	print("Admin Panel: "..item_name.." Item for ".." <Incorrect Hero Name>")
        	return nil
    	end
    	local item = CreateItem(item_name, hero, hero)
		if item then
			hero:AddItem(item)
		end
		
	end
    
end

function GameMode:Admin_Refresh(data)
    for i=1, HeroList:GetHeroCount() do
        local hero = HeroList:GetHero(i-1)
        if not hero then
            print("Admin Panel: Refresh - No hero with id "..i)
            return
        end
    
        if not hero:IsAlive() then
            hero:RespawnUnit()
        end

        hero:SetHealth(hero:GetMaxHealth())
        hero:SetMana(hero:GetMaxMana())
    
        for i = 0, hero:GetAbilityCount() - 1 do
            local ability = hero:GetAbilityByIndex(i)
            if ability then
                ability:EndCooldown()
                if ability:GetToggleState() then
                    ability:ToggleAbility()
                end
            end
        end
    
        for slot = 0, 16 do
            local item = hero:GetItemInSlot(slot)
            if item then
                item:EndCooldown()
            end
        end
    
        -- Удаляем дебаффы и эффекты контроля
        hero:Purge(false, true, false, true, true) -- Снимаем отрицательные эффекты, оставляем положительные
    end
    print("Admin Panel: Refresh All Heroes")
end

function GameMode:Admin_WTFMode()

    if wtfMode == true then
        if not IsServer() then return end
            GameMode:Admin_Refresh()
			local heroCount = HeroList:GetHeroCount()
    		for hero = 0, heroCount - 1 do
                local hHero = HeroList:GetHero(hero)
    			hHero:AddNewModifier(nil, nil, "wtfModifier", nil)
			end
        print("Admin Panel: WTF Mode: ON")
    	wtfMode = false
    elseif wtfMode == false then
        -- Выключаем режим WTF
        if not IsServer() then return end
			local heroCount = HeroList:GetHeroCount()
            for hero = 0, heroCount - 1 do
                local hHero = HeroList:GetHero(hero)
    			hHero:RemoveModifierByName("wtfModifier")
			end

        print("Admin Panel: WTF Mode: OFF")
        wtfMode = true
    else
        if not IsServer() then return end
            GameMode:Admin_Refresh()
			local heroCount = HeroList:GetHeroCount()
            for hero = 0, heroCount - 1 do
                local hHero = HeroList:GetHero(hero)
    			hHero:AddNewModifier(nil, nil, "wtfModifier", nil)
			end
        print("Admin Panel: WTF Mode: ON")
    	wtfMode = false
    end
end

function GameMode:Admin_lvlUp(data)
	if not IsServer() then return end
	local entities = {}
	for key, value in pairs(data.ent) do
	    entities[tonumber(key)] = value
	end
	for key, value in pairs(entities) do
    	local hero = EntIndexToHScript(entities[key])
		print("Admin Panel: "..data.lvl.." Level Up for "..hero:GetUnitName())
		for i=1, data.lvl do
			hero:HeroLevelUp(true)	
		end
	end
	
	--for player=1, HeroList:GetHeroCount() do
	--	for i=1, data.lvl do
	--		print(HeroList:GetHeroCount())
	--		HeroList:GetHero(player-1):HeroLevelUp(true)	
	--	end
	--end

end

function GameMode:Admin_GiveGold(data)
	local entities = {}

	for key, value in pairs(data.ent) do
	    entities[tonumber(key)] = value
	end

	for key, value in pairs(entities) do
    	local hero = EntIndexToHScript(entities[key])
		hero:ModifyGold(data.amout, false, 8)
		SendOverheadEventMessage(nil, 0, hero, data.amout, nil)
	end
end

function GameMode:Admin_SteamID_Check(data)
    require("game-mode/custom_params")
    local steamID = PlayerResource:GetSteamID(data.playerID):__tostring()
    CustomGameEventManager:Send_ServerToAllClients("admin_steamID_check2", {allowedID = CUSTOM_ADMIN_STEAMID64, steamID = steamID})
end

wtfModifier = class({})

function wtfModifier:IsPurgable() return false end
function wtfModifier:IsHidden()   return true end

function wtfModifier:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT,
		MODIFIER_PROPERTY_MANACOST_REDUCTION_CONSTANT,
	}
end

function wtfModifier:GetModifierManacostReduction_Constant()
	return 1000
end

function wtfModifier:GetModifierCooldownReduction_Constant()
	return 1000
end