require("utils/timers")

LinkLuaModifier("item_admin_tp_hero_modifier", "items/admin/item_admin_tp_hero", LUA_MODIFIER_MOTION_NONE)

item_admin_tp_hero = class({})

function item_admin_tp_hero:OnSpellStart()
	if not IsServer() then return end

	local hero 	 = self:GetCaster()
	local target = self:GetCursorTarget()

	local pos 	= hero:GetAbsOrigin()

	if not target then
		target = hero
		pos = self:GetCursorPosition()
		print(pos)
	end

	local pos2	= target:GetAbsOrigin()
	local delay = self:GetSpecialValueFor("delay")

	target:StartGesture(ACT_DOTA_TELEPORT)
	target:AddNewModifier(hero, self, "item_admin_tp_hero_modifier", {duration = delay})

	self.teleportFromEffect = ParticleManager:CreateParticle("particles/econ/events/spring_2021/teleport_start_spring_2021.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(self.teleportFromEffect, 2, Vector(255, 255, 255))

	target:EmitSound("Portal.Loop_Appear")

	self.teleport_center = CreateUnitByName("npc_dota_companion", pos, false, nil, nil, 0)
	
	hero:EmitSound("Portal.Loop_Appear")

	self.teleport_center:AddNewModifier(self.teleport_center, nil, "modifier_phased", {})
	self.teleport_center:AddNewModifier(self.teleport_center, nil, "modifier_invulnerable", {})
	self.teleport_center:SetAbsOrigin(pos)
	
	self.teleportToEffect = ParticleManager:CreateParticle("particles/econ/events/spring_2021/teleport_end_spring_2021.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.teleport_center)
	ParticleManager:SetParticleControlEnt(self.teleportToEffect, 1, self.teleport_center, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.teleport_center:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.teleportToEffect, 3, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.teleport_center:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.teleportToEffect, 4, Vector(0.9, 0, 0))
	ParticleManager:SetParticleControlEnt(self.teleportToEffect, 5, self.teleport_center, PATTACH_POINT_FOLLOW, "attach_hitloc", self.teleport_center:GetAbsOrigin(), true)

	Timers:CreateTimer(delay, function()
		target:StopSound("Portal.Loop_Appear")
		ParticleManager:DestroyParticle(self.teleportFromEffect, true)
    	ParticleManager:ReleaseParticleIndex(self.teleportFromEffect)

    	StopSoundOn("Portal.Loop_Appear", self.teleport_center)
		hero:StopSound("Portal.Loop_Appear")
	
   	 	self.teleport_center:Destroy()
		target:RemoveGesture(ACT_DOTA_TELEPORT)
		EmitSoundOnLocationWithCaster(pos2, "Portal.Hero_Disappear", self:GetCaster())
		target:SetAbsOrigin(pos)
		FindClearSpaceForUnit(target, pos, true)
		target:Stop()
		target:Interrupt()
		EmitSoundOn("Portal.Hero_Disappear", self:GetCaster())
		target:StartGesture(ACT_DOTA_TELEPORT_END)
	end)
end

item_admin_tp_hero_modifier = class({})


function item_admin_tp_hero_modifier:IsDebuff() return false end
function item_admin_tp_hero_modifier:IsHidden() return true end

function item_admin_tp_hero_modifier:CheckState()
    return {
    	[MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end