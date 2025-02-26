require("utils/timers")

LinkLuaModifier( "modifier_radiant_troop_stone_stunned", "abilities/neutral/waves/radiant_troop_stone", LUA_MODIFIER_MOTION_NONE )

radiant_troop_stone = class({})

function radiant_troop_stone:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function radiant_troop_stone:OnSpellStart()
    local vPos = self:GetCursorPosition()
    local caster = self:GetCaster()

    local delay = self:GetSpecialValueFor("projectile_duration")
    self.casterPos = caster:GetAbsOrigin()
    local distance = self:CalculateDistance(vPos, self.casterPos)
    self.direction = self:CalculateDirection(vPos, self.casterPos)
    local velocity = distance / delay * self.direction
    local ticks = 1 / self:GetSpecialValueFor("tick_interval")
    velocity.z = 0

    local info = 
    {
        Ability = self,
        EffectName = "particles/units/heroes/hero_tiny/tiny_avalanche_projectile.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = distance,
        fStartRadius = 0,
        fEndRadius = 0,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = false,
        vVelocity = velocity,
        bProvidesVision = true,
        iVisionRadius = 200,
        iVisionTeamNumber = caster:GetTeamNumber(),
        ExtraData = {ticks = ticks}
    }
    ProjectileManager:CreateLinearProjectile(info)
    EmitSoundOnLocationWithCaster(vPos, "Ability.Avalanche", caster)
end

function radiant_troop_stone:OnProjectileHit_ExtraData(hTarget, vLocation, extradata)
    local caster = self:GetCaster()
	
    local duration = self:GetSpecialValueFor("stun_duration")
    local radius = self:GetSpecialValueFor("radius")

    local interval = self:GetSpecialValueFor("tick_interval")
    local damage = self:GetSpecialValueFor("damage") * self:GetSpecialValueFor("tick_interval")
    self.repeat_increase = false
    local avalanche = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(avalanche, 0, vLocation + self.direction)
    ParticleManager:SetParticleControlOrientation(avalanche, 0, self.direction, self.direction, caster:GetUpVector())
    ParticleManager:SetParticleControl(avalanche, 1, Vector(radius, 1, radius/2))
    local offset = 0
    local ticks = extradata.ticks
    local hitLoc = vLocation
	local spellBlocked = {}
    Timers:CreateTimer(function()
        GridNav:DestroyTreesAroundPoint(hitLoc, radius, false)
        local enemies_tick = FindUnitsInRadius(
			caster:GetTeam(),
			hitLoc, 
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			true)
        for _,enemy in pairs(enemies_tick) do
			if not spellBlocked[enemy] and not enemy:TriggerSpellAbsorb( self ) then
				if enemy:HasModifier("modifier_tiny_toss_bh") and not self.repeat_increase then
					damage = damage * 2
					self.repeat_increase = true
				end
				ApplyDamage({
					victim=enemy,
					attacker=caster,
					damage=damage,
					damage_type=self:GetAbilityDamageType(),
					ability=self
				})
				enemy:AddNewModifier(caster, self, "modifier_radiant_troop_stone_stunned", {duration = duration})
			else
				spellBlocked[enemy] = true
			end
        end
        hitLoc = hitLoc + offset / ticks
        extradata.ticks = extradata.ticks - 1
        if extradata.ticks > 0 then
            return interval
        else
            ParticleManager:DestroyParticle(avalanche, false)
            ParticleManager:ReleaseParticleIndex(avalanche)
        end
    end)
end

modifier_radiant_troop_stone_stunned = class({})

function modifier_radiant_troop_stone_stunned:IsDebuff() return true end
function modifier_radiant_troop_stone_stunned:IsHidden() return true end
function modifier_radiant_troop_stone_stunned:IsPurgable() return true end

function modifier_radiant_troop_stone_stunned:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end

function radiant_troop_stone:CalculateDistance(ent1, ent2, b3D)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local vector = (pos1 - pos2)
	if b3D then
		return vector:Length()
	else
		return vector:Length2D()
	end
end

function radiant_troop_stone:CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2)
	direction.z = 0
	return direction:Normalized()
end