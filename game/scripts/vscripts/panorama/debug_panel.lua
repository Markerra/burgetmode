require("utils/selection")

LinkLuaModifier("wtfModifier", "panorama/debug_panel", LUA_MODIFIER_MOTION_NONE)

function GameMode:Admin_SpawnBot(data)

	local heroName = data.hero
	local playerID = data.id
	local offset   = 100

	print(heroName)
	print(playerID)

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
    local botHero = CreateUnitByName(heroName, spawnPosition, true, nil, nil, player:GetTeamNumber())
    botHero:SetControllableByPlayer(playerID, true)
    botHero:SetPlayerID(HeroList:GetHeroCount() - 1)
    print("bot id: ", botHero:GetPlayerID())
end

function GameMode:Admin_GiveItem(data)

	local item_name = data.item

	local hero = PlayerResource:GetSelectedHeroEntity(data.id)
	print("NAME "..PlayerResource:GetSelectedHeroName(data.id))
	if not hero or hero == "" then
        print("debug_panel: неверное имя героя")
        return nil
    end

    local item = CreateItem(item_name, hero, hero)
	if item then
		hero:AddItem(item)
	end
    
end

function GameMode:Admin_Refresh(data)
	local player = PlayerResource:GetPlayer(data.id)
    local hero = player:GetAssignedHero()
    if not hero or not hero:IsAlive() then
        return
    end

    -- Восстанавливаем здоровье и ману
    hero:SetHealth(hero:GetMaxHealth())
    hero:SetMana(hero:GetMaxMana())

    -- Снимаем все кулдауны у способностей
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability then
            ability:EndCooldown() -- Снимает кулдаун
            if ability:GetToggleState() then
                ability:ToggleAbility() -- Выключает способности в режиме переключения
            end
        end
    end

    -- Снимаем кулдауны у всех предметов
    for slot = 0, 5 do
        local item = hero:GetItemInSlot(slot)
        if item then
            item:EndCooldown() -- Снимает кулдаун предмета
        end
    end

    -- Удаляем дебаффы и эффекты контроля
    hero:Purge(false, true, false, true, true) -- Снимаем отрицательные эффекты, оставляем положительные
end

function GameMode:Admin_WTFMode()
    print(wtfMode)

    if wtfMode == true then
        -- Включаем режим WTF
        if not IsServer() then return end
			local playerCount = PlayerResource:GetPlayerCount() - 1 
    		for playerID = 0, playerCount do
    			if PlayerResource:IsValidPlayerID(playerID) then
    				PlayerResource:GetPlayer(playerID):GetAssignedHero():AddNewModifier(nil, nil, "wtfModifier", nil)
				end
			end
        print("WTF Mode: ON")
    	wtfMode = false
    elseif wtfMode == false then
        -- Выключаем режим WTF
        if not IsServer() then return end
			local playerCount = PlayerResource:GetPlayerCount() - 1 
    		for playerID = 0, playerCount do
    			if PlayerResource:IsValidPlayerID(playerID) then
    				PlayerResource:GetPlayer(playerID):GetAssignedHero():RemoveModifierByName("wtfModifier")
				end
			end

        print("WTF Mode: OFF")
        wtfMode = true
    else
    	-- Включаем режим WTF
        if not IsServer() then return end
			local playerCount = PlayerResource:GetPlayerCount() - 1 
    		for playerID = 0, playerCount do
    			if PlayerResource:IsValidPlayerID(playerID) then
    				PlayerResource:GetPlayer(playerID):GetAssignedHero():AddNewModifier(nil, nil, "wtfModifier", nil)
				end
			end
        print("WTF Mode: ON")
    	wtfMode = false
    end
end

function GameMode:Admin_lvlUp(data)
	if not IsServer() then return end
	--local playerID = data.id
	--local player   = PlayerResource:GetPlayer(playerID)
	--for i=1, data.lvl do
	--	player:GetAssignedHero():HeroLevelUp(true)	
	--end
	for player=1, HeroList:GetHeroCount() do
		for i=1, data.lvl do
			print(HeroList:GetHeroCount())
			HeroList:GetHero(player-1):HeroLevelUp(true)	
		end
	end

end

function GameMode:Admin_GiveGold(data)
	local hero = PlayerResource:GetPlayer(data.id):GetAssignedHero()
	EmitSoundOnEntityForPlayer("General.Coins", hero,data.id)
	PlayerResource:ModifyGold(data.id, data.amout, false, 8)
	SendOverheadEventMessage(nil, 0, hero, data.amout, nil)
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