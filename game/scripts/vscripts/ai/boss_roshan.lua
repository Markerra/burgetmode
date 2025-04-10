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
            _G.boss_stage = false
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
