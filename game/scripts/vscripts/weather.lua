function SetWeather(type)
	if not IsServer() then return end
	local playerCount = PlayerResource:GetPlayerCount() - 1 
    for playerID = 0, playerCount do
    	if PlayerResource:IsValidPlayerID(playerID) then
    		local player = PlayerResource:GetPlayer(playerID)
			if type == "snow" then
				local particle = "particles/winter_fx/weather_frostivus_snow.vpcf"
				ParticleManager:CreateParticleForPlayer(particle, PATTACH_EYES_FOLLOW, player:GetAssignedHero(), player)
				print("snow for ", player)
			elseif type == "spring" then
				local particle = "particles/rain_fx/econ_weather_spring.vpcf"
				ParticleManager:CreateParticleForPlayer(particle, PATTACH_EYES_FOLLOW, player:GetAssignedHero(), player)
			end
		end
	end
end