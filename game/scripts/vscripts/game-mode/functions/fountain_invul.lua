function DeactivateFountainsInvul(delay)
	Timers:CreateTimer(CUSTOM_FOUNTAIN_VUL_DELAY, function() -- спустя 10 минут активирует возможность атаковать фонтан
		local fountain = Entities:FindByClassname(nil, "ent_dota_fountain") 
		while fountain do
		    fountain:RemoveModifierByName("modifier_invulnerable")
		    print("Removed invulnerability from fountain")
		    fountain = Entities:FindByClassname(fountain, "ent_dota_fountain")
		end
	end)
end