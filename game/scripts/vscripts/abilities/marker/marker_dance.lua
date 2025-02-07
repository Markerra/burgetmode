require("utils/timers")

LinkLuaModifier("modifier_marker_dance_enemy", "abilities/marker/marker_dance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marker_dance_allies", "abilities/marker/marker_dance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marker_dance_enemy_aura", "abilities/marker/marker_dance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marker_dance_allies_aura", "abilities/marker/marker_dance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marker_dance_tracker", "abilities/marker/marker_dance", LUA_MODIFIER_MOTION_NONE)

marker_dance = class({})

function marker_dance:OnSpellStart()
	if not IsServer() then return end

    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local duration = self:GetSpecialValueFor("duration") 
    local totem_health = self:GetSpecialValueFor("totem_health") 
    local radius = self:GetSpecialValueFor("radius")

    EmitSoundOn("Hero_Visage.SummonFamiliars.Cast", caster)
    EmitSoundOn("Hero_Chen.PenitenceImpact", caster)

    -- totem
    local totem = CreateUnitByName("npc_dota_marker_dance_totem", point, false, caster, caster, caster:GetTeamNumber())
    totem:SetHealth(totem_health)
    totem:SetBaseMaxHealth(totem_health)
    totem:SetMaxHealth(totem_health)
    totem:SetHealth(totem_health)
    totem:SetControllableByPlayer(caster:GetPlayerID(), false)

    totem:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
    totem:AddNewModifier(caster, self, "modifier_marker_dance_tracker", {radius = radius})
    totem:AddNewModifier(caster, self, "modifier_marker_dance_enemy_aura", {duration = duration, radius = radius})
    totem:AddNewModifier(caster, self, "modifier_marker_dance_allies_aura", {duration = duration, radius = radius})
end

function marker_dance:GetAOERadius()
    local radius = self:GetSpecialValueFor("radius")
    return radius
end

modifier_marker_dance_enemy_aura = class({})

function modifier_marker_dance_enemy_aura:IsHidden() return true end
function modifier_marker_dance_enemy_aura:IsPurgable() return false end
function modifier_marker_dance_enemy_aura:IsAura() return true end
function modifier_marker_dance_enemy_aura:GetModifierAura() return "modifier_marker_dance_enemy" end
function modifier_marker_dance_enemy_aura:GetAuraRadius() return self.radius end
function modifier_marker_dance_enemy_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_marker_dance_enemy_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_marker_dance_enemy_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end

function modifier_marker_dance_enemy_aura:OnCreated( kv )
    if not IsServer() then return end

    self.radius = kv.radius
end

modifier_marker_dance_allies_aura = class({})

function modifier_marker_dance_allies_aura:IsHidden() return true end
function modifier_marker_dance_allies_aura:IsPurgable() return false end
function modifier_marker_dance_allies_aura:IsAura() return true end
function modifier_marker_dance_allies_aura:GetModifierAura() return "modifier_marker_dance_allies" end
function modifier_marker_dance_allies_aura:GetAuraRadius() return self.radius end
function modifier_marker_dance_allies_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_marker_dance_allies_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_marker_dance_allies_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end

function modifier_marker_dance_allies_aura:OnCreated(kv)
    if not IsServer() then return end
    self.radius = kv.radius
end


modifier_marker_dance_enemy = class({})

function modifier_marker_dance_enemy:IsDebuff() return true end
function modifier_marker_dance_enemy:IsHidden() return false end
function modifier_marker_dance_enemy:IsPurgable() return true end

function modifier_marker_dance_enemy:OnCreated(kv)
    if not IsServer() then return end

    local parent = self:GetParent()

    EmitSoundOn("Hero_EmberSpirit.SearingChains.Target", parent)

    self:SetHasCustomTransmitterData( true )

    self.bonus_armor_pct = self:GetAbility():GetSpecialValueFor("armor_decrease_pct")
	self.armor_decrease = 0
	self.base_armor = parent:GetPhysicalArmorBaseValue()

	if parent:GetUnitName() == "npc_dota_hero_nevermore" then
		parent:AddActivityModifier("swag_gesture")
	elseif parent:GetUnitName() == "npc_dota_hero_pudge" then
		parent:AddActivityModifier("shake_moneymaker")
		parent:AddActivityModifier("harpoon")
	end
	parent:StartGesture(ACT_DOTA_TAUNT)
    self:StartIntervalThink(1)
end

function modifier_marker_dance_enemy:CheckState()
	return {
    	[MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_marker_dance_enemy:OnIntervalThink()
    self.armor_decrease = self.armor_decrease + 1
    self:SendBuffRefreshToClients() 
end

function modifier_marker_dance_enemy:AddCustomTransmitterData()
    local data = {
        armor_decrease = self.armor_decrease,
        base_armor = self.base_armor,
    }
    return data
end

function modifier_marker_dance_enemy:HandleCustomTransmitterData(data)
    self.armor_decrease = data.armor_decrease
    self.base_armor = data.base_armor
end


function modifier_marker_dance_enemy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end

function modifier_marker_dance_enemy:GetModifierPhysicalArmorBonus()
	--print("base_armor = "..self.base_armor)
	--print("armor_decrease = "..self.armor_decrease)
	return -(self.base_armor / 100) * self.armor_decrease
end


modifier_marker_dance_allies = class({})

function modifier_marker_dance_allies:IsDebuff() return false end
function modifier_marker_dance_allies:IsHidden() return false end
function modifier_marker_dance_allies:IsPurgable() return true end

function modifier_marker_dance_allies:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }
end

function modifier_marker_dance_allies:GetModifierAttackSpeedBonus_Constant()
	local bonus = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    return bonus
end

function modifier_marker_dance_allies:GetModifierAttackRangeBonus()
    local bonus = self:GetAbility():GetSpecialValueFor("bonus_attack_range")
    return bonus
end

modifier_marker_dance_tracker = class({})

function modifier_marker_dance_tracker:IsDebuff() return false end
function modifier_marker_dance_tracker:IsHidden() return true end
function modifier_marker_dance_tracker:IsPurgable() return false end

function modifier_marker_dance_tracker:OnCreated( kv )
	if not IsServer() then return end

	self.radius = kv.radius
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local duration = self:GetAbility():GetSpecialValueFor("duration")

	EmitSoundOn("marker_discoball_spawn", parent)

	self.effect1 = ParticleManager:CreateParticle( "particles/ui_mouseactions/range_finder_aoe.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.effect1, 2, parent:GetAbsOrigin())
	ParticleManager:SetParticleControl( self.effect1, 3, Vector( self.radius, self.radius, self.radius ) )

    self.effect2 = ParticleManager:CreateParticle("particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf",
    PATTACH_ABSORIGIN_FOLLOW, parent)

    local disco_particle = "particles/econ/events/ti10/hot_potato/disco_ball_channel.vpcf"

    self.disco_effect = ParticleManager:CreateParticle(disco_particle, PATTACH_OVERHEAD_FOLLOW, parent)
    ParticleManager:SetParticleControl(self.disco_effect, 0, parent:GetAbsOrigin())

    local i = 0
    Timers:CreateTimer(0, function()
    	if self:GetParent() == nil then return end
    	if i < duration then
    		local radius = self.radius + 80
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, self.radius,
			2, 1 + 18, 0, 0, false)
			local dmg = self:GetAbility():GetSpecialValueFor("damage_per_second")

			for _,unit in ipairs(enemies) do
				ApplyDamage({
					victim = unit,
					attacker = parent,
					damage = dmg,
					damage_type = 2,
					ability = self:GetAbility()
				})
				if caster:GetHeroFacetID() == 5 then -- marker_stun Facet
					local stun_interval = self:GetAbility():GetSpecialValueFor("stun_interval")
					if i == stun_interval - 1 or i == stun_interval * 2 - 1 then
						local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
						unit:AddNewModifier(caster, self:GetAbility(), 
						"modifier_stunned", {duration = stun_duration})
					end
				end
			end

			self.effect3 = ParticleManager:CreateParticle( 
    		"particles/econ/items/oracle/oracle_fortune_ti7/oracle_fortune_ti7_aoe_ground_splash.vpcf",
    		PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(self.effect3, 1, Vector( radius, radius, radius ))
			ParticleManager:SetParticleControl(self.effect3, 3, parent:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(self.effect3)
			EmitSoundOn("Hero_Muerta.Revenants.End", parent)

			i = i + 1
		else return end
		return 1
	end)

end

function modifier_marker_dance_tracker:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_marker_dance_tracker:OnDestroy()
	if not IsServer() then return end

	ParticleManager:DestroyParticle(self.effect1, true)
	ParticleManager:DestroyParticle(self.effect2, true)
	ParticleManager:DestroyParticle(self.disco_effect, false)

    ParticleManager:ReleaseParticleIndex(self.effect1)
    ParticleManager:ReleaseParticleIndex(self.effect2)
    ParticleManager:ReleaseParticleIndex(self.disco_effect)
end

function modifier_marker_dance_tracker:OnDeath( event )
	if not IsServer() then return end

	local unit = event.unit

	if unit ~= self:GetParent() then return end

	self:GetParent():RemoveModifierByName("modifier_marker_dance_enemy_aura")
	self:GetParent():RemoveModifierByName("modifier_marker_dance_allies_aura")
	self:GetParent():RemoveModifierByName("modifier_marker_dance_tracker")
end