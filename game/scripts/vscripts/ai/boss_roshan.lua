function Spawn( entityKeyValues )
    if not IsServer() then return end
    if not IsValidEntity(thisEntity) then return end

    thisEntity.agro = 2100
    thisEntity.spawn_radius = 2760 -- радиус в котором будет ходить босс

    thisEntity.clap = thisEntity:FindAbilityByName("boss_roshan_clap")
    thisEntity.rocks = thisEntity:FindAbilityByName("boss_roshan_rocks")
    thisEntity.amp = thisEntity:FindAbilityByName("boss_roshan_amp")

    thisEntity:SetContextThink( "bevavior", bevavior, FrameTime() )
end

function bevavior()
    if not IsValidEntity(thisEntity) then return -1 end

    if not thisEntity.spawn then 
        thisEntity.spawn = thisEntity:GetAbsOrigin()
        return 0.1 
    end

    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() then
        return 0.5
    end

    if thisEntity:IsChanneling() then 
        return 0.1
    end

    if thisEntity:HasModifier("modifier_arena_boss_sleep") then 
        return 2.0
    end

    local units = FindUnitsInRadius(thisEntity:GetTeamNumber(), Vector(0,0,0), nil, 4100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

    ---------------------------------------------------------------------------------------------------

    local enemy_for_attack = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, thisEntity.agro, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

    local control = false
    if thisEntity:IsSilenced() or thisEntity:IsHexed() or thisEntity:IsStunned() then
        control = true
    end

    if not control then
        if #units <= 0 then
            local player = nil
            local hero   = nil
        
            for player_id = 0, PlayerResource:GetPlayerCount() - 1 do
                player = PlayerResource:GetPlayer(player_id)
                if player and player:GetTeamNumber() == team then
                    if player.defeated == true or not PlayerResource:IsValidPlayerID(player_id) or not player:GetAssignedHero() then
                    return end
                end
            end

            --for team = DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_8 do
            --    hero = player:GetAssignedHero()
            --
            --    if not hero:IsAlive() then
            --        hero:RespawnHero(false, false)
            --    end
            --    
            --    hero:RemoveModifierByName("modifier_fountain_invulnerability")
            --
            --    local teleport = Entities:FindByName(nil, "arena_boss_tp_".. team-5)
            --    if not teleport then return -1 end
            --
            --    local point = teleport:GetAbsOrigin()
            --
            --    hero:Stop()
            --    FindClearSpaceForUnit(hero, point, true)
            --    hero:AddNewModifier(nil, nil, "modifier_arena_boss_sleep", {duration = 5.0})
            --
            --    PlayerResource:SetCameraTarget(player:GetPlayerID(), hero)
            --    Timers:CreateTimer(0.5, function()
            --        PlayerResource:SetCameraTarget(player:GetPlayerID(), nil)
            --    end)
            --
            --    hero:SetHealth(hero:GetMaxHealth())
            --    hero:Purge(true, true, false, true, true)
            --
            --    for i = 0, hero:GetAbilityCount() - 1 do
            --        local ability = hero:GetAbilityByIndex(i)
            --        if ability and ability:GetCooldown(-1) > 0 then
            --            ability:EndCooldown()
            --        end
            --    end
            --end
            thisEntity:ForceKill(false) 
        return -1 end

        if thisEntity.clap and thisEntity.clap:IsFullyCastable() then

            local enemy_for_ability = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, thisEntity.clap:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE , FIND_CLOSEST, false)

            if IsValidEntity(enemy_for_ability[1]) then
                thisEntity:CastAbilityNoTarget(thisEntity.clap, 1)
                return thisEntity.clap:GetCastPoint() + 1.0
            end
        end

        if thisEntity.rocks and thisEntity.rocks:IsFullyCastable() and thisEntity:HasModifier("modifier_boss_roshan_lotus_active") and not thisEntity:HasModifier("modifier_boss_roshan_amp_heal") then

            local enemy_for_ability = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, thisEntity.agro, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS , FIND_CLOSEST, false)
            
            if IsValidEntity(enemy_for_ability[1]) then

                thisEntity:CastAbilityNoTarget(thisEntity.rocks, 1)
                return 1.9
            end
        end


        if thisEntity.amp and thisEntity.amp:IsFullyCastable() and not thisEntity:HasModifier("modifier_boss_roshan_amp_heal") then

            local enemy_for_ability = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, thisEntity.amp:GetCastRange(thisEntity:GetAbsOrigin(), nil), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS , FIND_CLOSEST, false)
            
            if thisEntity:GetHealth() <= thisEntity:GetMaxHealth() * 0.7 then

                thisEntity:CastAbilityNoTarget(thisEntity.amp, 1)
                return 1
            end
        end

    end

    local enemy = enemy_for_attack[1]

    if ((thisEntity:GetAbsOrigin() - thisEntity.spawn):Length2D() < thisEntity.spawn_radius ) and IsValidEntity(enemy) then
        thisEntity:MoveToTargetToAttack(enemy)
    else
        thisEntity:MoveToPosition(Vector(0,0,0))
        return 4.0
    end

    return 0.5
end
