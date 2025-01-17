require("utils/timers")

function ActivateFountainInvul()
	for index=1, DOTA_MAX_PLAYERS do
		local fountain = Entities:FindByName(nil, "dota_custom"..index.."_fountain")
		while fountain do
			fountain:AddNewModifier(nil, nil, "modifier_invulnerable", nil)
			print("Added invulnerability to fountain #"..index)
			fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
		end
	end
end

function DeactivateFountainsInvul(delay)
	Timers:CreateTimer(delay, function() -- спустя 10 минут активирует возможность атаковать фонтан
		for index=1, DOTA_MAX_PLAYERS do
			local fountain = Entities:FindByName(nil, "dota_custom"..index.."_fountain")
			while fountain do
			    fountain:RemoveModifierByName("modifier_invulnerable")
			    print("Removed invulnerability from fountain #"..index)
			    fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
			end
		end
	end)
end