if chat_wheel == nil then
	chat_wheel = class({})
end

_G.Sound_list =
{

["general_ru"] = 
{

},

["general_eng"] = 
{
	{100, "Voice.General_eng_1", 1500},
	{101, "Voice.General_eng_2", 1500, 0, 1},

},

["general_other"] =
{
	{200, "Voice.General_other_1", 800},	

},

	["npc_dota_hero_huskar"] = {
		{0, "Voice.Huskar.1_1"},
		{1, "Voice.Huskar.2_1"},
		{2, "Voice.Huskar.3_1"},
		{3, "Voice.Huskar.4_1"},
		{4, "Voice.Huskar.5_1"},
		{5, "Voice.Huskar.6_1"},
		{6, "Voice.Huskar.7_1"},		
		{7, "Voice.Huskar.8_1"},
		{8, "Voice.Huskar.9_1"},			
	},

}

CustomNetTables:SetTableValue("custom_sounds", "sounds", Sound_list)

function chat_wheel:SelectChatWheel(keys)
	if keys.PlayerID == nil then return end
	local id_chatwheel = tostring(keys.id)
	local item_chatwheel = tostring(keys.sound_name)

	local player_table = CustomNetTables:GetTableValue('players_chat_wheel', tostring(keys.PlayerID))
	local player_chat_wheel_change = {}
	if player_table then
		for k, v in pairs(player_table) do
		      player_chat_wheel_change[k] = v
		end
	end

	local sub_data = CustomNetTables:GetTableValue('sub_data', tostring(keys.PlayerID))

	if sub_data and sub_data.chat_wheel then 
		sub_data.chat_wheel[id_chatwheel] = item_chatwheel
	end


	player_chat_wheel_change[id_chatwheel] = item_chatwheel
	player_table = player_chat_wheel_change
	CustomNetTables:SetTableValue('players_chat_wheel', tostring(keys.PlayerID), player_table)
	CustomNetTables:SetTableValue('sub_data', tostring(keys.PlayerID), sub_data)
end

function chat_wheel:SetDefaultSound(id)
    local sounds_random = table.random_some(Sound_list["general_ru"], 8)
    local player_chat_wheel_change = {}
    local player_table = CustomNetTables:GetTableValue("sub_data", tostring(id))


    for i=1,8 do
        if player_table then
            if player_table.chat_wheel then

                if player_table.chat_wheel[tostring(i)] and player_table.chat_wheel[tostring(i)] ~= 0 and player_table.chat_wheel[tostring(i)] ~= "0" then
                    player_chat_wheel_change[i] = player_table.chat_wheel[tostring(i)]
                else
                 --   player_chat_wheel_change[i] = sounds_random[i][1]
                end
            else
           --     player_chat_wheel_change[i] = sounds_random[i][1]
            end
        else
          --  player_chat_wheel_change[i] = sounds_random[i][1]
        end
    end

    CustomNetTables:SetTableValue('players_chat_wheel', tostring(id), player_chat_wheel_change)
end

function chat_wheel:SelectHeroVO(keys)
	if keys.PlayerID == nil then return end
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	print(keys.PlayerID)
	local sound_name = keys.num
	local heroes = {}
	local hero_name = "npc_dota_hero_omniknight"
	for i=0, PlayerResource:GetPlayerCount()-1 do
		if PlayerResource:IsValidPlayerID(i) then
			table.insert(heroes, PlayerResource:GetPlayer(i):GetAssignedHero())
		end
	end
	local hero = heroes[keys.PlayerID+1]
	if hero then
		--hero_name = hero:GetUnitName()
	end

	local tier_hero = 30
	local sound_string = "#"..keys.name
	local phase_tier = 30

	local table_data = CustomNetTables:GetTableValue("sub_data", tostring(keys.PlayerID))
		--if player.sound_use_one == nil then
		--    player.sound_use_one = 1
		--end

		--if player.sound_use_two == nil then
		--    player.sound_use_two = 0
		--end
		
		--if (player.sound_use_one and player.sound_use_one > 0) and (player.sound_use_two and player.sound_use_two > 0) then
		--  	local player = PlayerResource:GetPlayer(keys.PlayerID)
		--  	if player then
		--      	local cooldown_sound = math.max(player.sound_use_one, player.sound_use_two)
		--      	CustomGameEventManager:Send_ServerToPlayer(player, "panorama_cooldown_error", {message="#dota_sound_error", time=cooldown_sound})
		--  	end
		--  	EmitSoundOnClient("General.Cancel", player)
		--  	return
		--end

	  if true then --if player.sound_use_one > 0 then

	  		--local cd = 5
	  		--if test then 
	  		--	cd = 0
	  		--end

	      	--player.sound_use_two = cd
	      	--Timers:CreateTimer({
			--    useGameTime = false,
			--    endTime = 1,
			--    callback = function()
			--      	if player.sound_use_two <= 0 then return nil end
    		--        player.sound_use_two = player.sound_use_two - 1
    		--        return 1
			--    end
			--})

		CustomGameEventManager:Send_ServerToAllClients( 'chat_dota_sound', {hero_name = hero_name, player_id = keys.PlayerID, sound_name = sound_string, sound_name_global = sound_name, tier = tier_hero, phase_tier = phase_tier})
	else
		EmitSoundOnClient("General.Cancel", player)
	end
end

function chat_wheel:SelectVO(keys)
	if keys.PlayerID == nil then return end

	local table_data = CustomNetTables:GetTableValue("sub_data", tostring(keys.PlayerID))
	if not table_data then
		return
	end
	
	local player = PlayerResource:GetPlayer(keys.PlayerID)

	local heroes = {}
	local hero_name = ""
	for i=0, PlayerResource:GetPlayerCount()-1 do
		if PlayerResource:IsValidPlayerID(i) then
			table.insert(heroes, PlayerResource:GetPlayer(i):GetAssignedHero())
		end
	end
	local hero = heroes[keys.PlayerID]
	if hero then
		hero_name = hero:GetUnitName()
	end

	local sound_string = ""
	local sound_id = keys.num
	local sound_name = ""

	for _, sound_data in pairs(Sound_list["general_ru"]) do
		if sound_data[1] == sound_id then
			sound_string = "#"..sound_data[2]
			sound_name = sound_data[2]
		end
	end

	for _, sound_data in pairs(Sound_list["general_eng"]) do
		if sound_data[1] == sound_id then
			sound_string = "#"..sound_data[2]
			sound_name = sound_data[2]
		end
	end

	for _, sound_data in pairs(Sound_list["general_other"]) do
        if sound_data[1] == sound_id then
            sound_string = "#"..sound_data[2]
            sound_name = sound_data[2]
        end
    end

	if sound_string == "" then
		EmitSoundOnClient("General.Cancel", player)
		return
	end

	local tier_hero = 30

	if player.sound_use_one == nil then
	    player.sound_use_one = 0
	end

	if player.sound_use_two == nil then
	    player.sound_use_two = 0
	end
	
	if (player.sound_use_one and player.sound_use_one > 0) and (player.sound_use_two and player.sound_use_two > 0) then
	  	local player = PlayerResource:GetPlayer(keys.PlayerID)
	  	if player then
	     	local cooldown_sound = math.max(player.sound_use_one, player.sound_use_two)
	      	CustomGameEventManager:Send_ServerToPlayer(player, "panorama_cooldown_error", {message="#dota_sound_error", time=cooldown_sound})
	  	end
	  	EmitSoundOnClient("General.Cancel", player)
	  	return
	end

  	if player.sound_use_one > 0 then

	  	local cd = 30
	  	if test then 
	  		cd = 0
	  	end

      	player.sound_use_two = cd
      	Timers:CreateTimer({
		    useGameTime = false,
		    endTime = 1,
		    callback = function()
		      	if player.sound_use_two <= 0 then return nil end
		        player.sound_use_two = player.sound_use_two - 1
		        return 1
		    end
		})
  	else

	  	local cd = 30
	  	if test then 
	  		cd = 0
	  	end
	  	
      	player.sound_use_one = cd
      	Timers:CreateTimer({
		    useGameTime = false,
		    endTime = 1,
		    callback = function()
		      	if player.sound_use_one <= 0 then return nil end
		        player.sound_use_one = player.sound_use_one - 1
		        return 1
		    end
		})
  	end
  	print(sound_string)
  	pritn(sound_name)
	CustomGameEventManager:Send_ServerToAllClients( 'chat_dota_sound', {hero_name = hero_name, player_id = keys.PlayerID, sound_name = sound_string, sound_name_global = sound_name, tier = 30})
end

function table.count(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end

    return c
end

function table.contains(t, v)
    for _, _v in pairs(t or {}) do
        if _v == v then
            return true
        end
    end
end

function table.has_element_fit(t, func)
    for k, v in pairs(t) do
        if func(t, k, v) then
            return k, v
        end
    end
end

function table.findkey(t, v)
    for k, _v in pairs(t) do
        if _v == v then
            return k
        end
    end
end

function table.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else
        copy = orig
    end
    return copy
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function table.random(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    local key = keys[RandomInt(1, # keys)]
    return t[key], key
end

function table.shuffle(tbl)

    local t = table.shallowcopy(tbl)
    for i = # t, 2, - 1 do
        local j    = RandomInt(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function table.random_some(t, count)
    local key_table = table.make_key_table(t)
    key_table       = table.shuffle(key_table)
    local r         = {}
    for i = 1, count do
        local key = key_table[i]
        table.insert(r, t[key])
    end
    return r
end

function table.random_with_condition(t, func)
    local keys = {}
    for k, v in pairs(t) do
        if func(t, k, v) then
            table.insert(keys, k)
        end
    end

    local key = keys[RandomInt(1, # keys)]
    return t[key], key
end


function table.random_with_weight(t)
    local weight_table = {}
    local total_weight = 0
    for k, v in pairs(t) do
        local w
        if v.GetWeight then
            w = v:GetWeight()
        else
            w = v.Weight or v[2] or 0
        end
        total_weight = total_weight + w
        table.insert(weight_table, { key = k, total_weight = total_weight })
    end

    local randomValue = RandomFloat(0, total_weight)
    for i = 1, # weight_table do
        if weight_table[i].total_weight >= randomValue then
            local key = weight_table[i].key
            return t[key]
        end
    end
end


function table.filter(t, condition)
    local r = {}
    for k, v in pairs(t) do
        if condition(t, k, v) then
            r[k] = v
        end
    end
    return r
end


function table.make_key_table(t)
    local r = {}
    for k, _ in pairs(t) do
        table.insert(r, k)
    end
    return r
end


function table.is_equal(t1, t2)
    for k, v in pairs(t1) do
        if t2[k] ~= v then
            return false
        end
    end
    return true
end

function table.random_key(t)
    return table.random(table.make_key_table(t))
end

function table.print(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end


function table.safe_table(t)
    local r = {}
    for k,v in pairs(t) do
        if type(v) == "table" and k ~= "_M" then
            r[k] = table.safe_table(v)
        elseif type(v) == "string" or type(v) == "number" then
            r[k] = tostring(v)
        end
    end

    return r
end


function table.save_as_kv_file(tbl, filePath, headerName, utf16)
    local file = io.open(filePath, "w")
    if utf16 then
        file:write(utf8_to_utf16le("\"" .. (headerName or "unknown_header") .. "\"\n"))
        file:write(utf8_to_utf16le('{\n'))
        for _, line in pairs(table.to_kv_lines(tbl, 1)) do
            file:write(utf8_to_utf16le(line .. "\n"))
        end
        file:write(utf8_to_utf16le('}\n'))
    else
        file:write("\"" .. (headerName or "unknown_header") .. "\"\n")
        file:write('{\n')
        for _, line in pairs(table.to_kv_lines(tbl, 1)) do
            file:write(line .. "\n")
        end
        file:write('}\n')
    end

    file:flush()
    file:close()
end

function table.to_kv_lines(tbl, tabCount)
    tabCount = tabCount or 0
    local result = {}
    local preTabs = ""
    for i = 1, tabCount do
        preTabs = preTabs .. "\t"
    end
    for k,v in pairs(tbl) do
        if type(v) == "table" then
            table.insert(result, preTabs .. "\"" .. tostring(k) .. "\"")
            table.insert(result, preTabs .. "{")
            local lines = table.to_kv_lines(v, tabCount + 1)
            for _, line in pairs(lines) do
                table.insert(result, preTabs .. line)
            end
            table.insert(result, preTabs .. "}")
        else
            table.insert(result, string.format("%s\"%s\"\t\t\"%s\"", preTabs,k,v))
        end
    end
    return result
end

function table.join(...)
    local arg = {...}
    local r = {}
    for _, t in pairs(arg) do
        if type(t) == "table" then
            for _, v in pairs(t) do
                table.insert(r, v)
            end
        else

            table.insert(r, t)
        end
    end

    return r
end


function table.reverse(tbl)
    local t = {}
    for k, v in pairs(tbl) do
        t[v] = k
    end
    return t
end



function table.remove_item(tbl,item)
    local i,max=1,#tbl
    while i<=max do
        if tbl[i] == item then
            table.remove(tbl,i)
            i = i-1
            max = max-1
        end
        i= i+1
    end
    return tbl
end


function table.pop_back_item(tbl,item)
    for i = #tbl, 1,-1 do
       if tbl[i] == item then
            table.remove(tbl,i)
            break
       end
    end
    return tbl
end