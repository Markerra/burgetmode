LinkLuaModifier("marker_shot_modifier", "abilities/marker/marker_shot", LUA_MODIFIER_MOTION_NONE)

marker_shot = class({})

function marker_shot:GetChannelTime()
	return self:GetSpecialValueFor("channel_time")
end

function marker_shot:OnSpellStart()

	local caster = self:GetCaster()
	self.target = self:GetCursorTarget()

	caster:StartGesture(ACT_DOTA_TELEPORT)

	self.effect = ParticleManager:CreateParticle(
	"particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_cast_moonfall.vpcf", 
	PATTACH_ABSORIGIN_FOLLOW, caster)

	ParticleManager:SetParticleControl(self.effect, 3, caster:GetAbsOrigin())

	self.sound_cast = "Hero_Visage.GraveChill.Cast"
	caster:EmitSound(self.sound_cast)
end


function marker_shot:OnChannelFinish( bInterrupted )

	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime())/self:GetChannelTime()

	local duration = self:GetSpecialValueFor("duration")

	local modif = caster:FindModifierByName("marker_shot_modifier")
	local scepter = caster:HasScepter()

	if modif then caster:RemoveModifierByName("marker_shot_modifier") end
	if scepter then
		caster:AddNewModifier(caster, self, "marker_shot_modifier", {pct = channel_pct})
	else
		caster:AddNewModifier(caster, self, "marker_shot_modifier", {pct = channel_pct, duration=duration})
	end
	local sound_cast = "Ability.MKG_AssassinateLoad"
	
	if bInterrupted then
		caster:StopSound( self.sound_cast )
		caster:EmitSound( "Hero_StormSpirit.ElectricRave" )
		ParticleManager:DestroyParticle(self.effect, true)
	end

	ParticleManager:DestroyParticle(self.effect, false)
	ParticleManager:ReleaseParticleIndex(self.effect)

	caster:FadeGesture(ACT_DOTA_TELEPORT)
	caster:EmitSound( sound_cast )
end

marker_shot_modifier = class({})

function marker_shot_modifier:IsPurgable() return true end
function marker_shot_modifier:IsHidden() return false end
function marker_shot_modifier:IsDebuff() return false end

function marker_shot_modifier:OnCreated( kv )
	if not IsServer() then return end

	local caster = self:GetAbility():GetCaster()
	self.aghanim = caster:HasScepter()

	if self.aghanim then
		local charges = self:GetAbility():GetSpecialValueFor("scepter_charges")
		self:SetStackCount( charges )
	end

	self:SetHasCustomTransmitterData( true )

	self.pct = kv.pct

	self:SendBuffRefreshToClients() 
end

function marker_shot_modifier:AddCustomTransmitterData()
    local data = {
        pct = self.pct,
    }
    return data
end

function marker_shot_modifier:HandleCustomTransmitterData(data)
    self.pct = data.pct
end

function marker_shot_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function marker_shot_modifier:GetModifierPreAttack_BonusDamage()
	local bonus_range = self:GetAbility():GetSpecialValueFor("max_bonus_damage")
	local bonus = self.pct * bonus_range
	return bonus
end

function marker_shot_modifier:GetModifierAttackRangeBonus()
	local bonus_range = self:GetAbility():GetSpecialValueFor("max_bonus_range")
	local bonus = self.pct * bonus_range
	return bonus
end

function marker_shot_modifier:OnAttackLanded( event )
	local caster = self:GetAbility():GetCaster()
	if event.attacker == caster then
		if self.aghanim then
			local stacks = self:GetStackCount()

			if stacks ~= 1 then
				self:SetStackCount(stacks - 1)
			else
				caster:RemoveModifierByName("marker_shot_modifier")
			end
		else
			caster:RemoveModifierByName("marker_shot_modifier")
		end

		event.target:AddNewModifier(caster, self:GetAbility(), 
		"modifier_stunned", {duration = self.pct})

		if self.pct > 0.5 then 
			local effect2 = ParticleManager:CreateParticle(
			"particles/units/heroes/hero_luna/luna_lucent_beam_impact_bits.vpcf",
			PATTACH_ABSORIGIN_FOLLOW, event.target)
			ParticleManager:SetParticleControl(effect2, 1, event.target:GetOrigin())
			ParticleManager:ReleaseParticleIndex(effect2)
			event.target:EmitSound("Hero_Luna.Eclipse.Target")
			ScreenShake(event.target:GetAbsOrigin(), 100, 1.1, 0.5, 1200, 0, true)
		else
			event.target:EmitSound("Hero_Luna.Eclipse.NoTarget")
			ScreenShake(event.target:GetAbsOrigin(), 5, 1.1, 0.3, 1200, 0, true)
		end

		local effect = ParticleManager:CreateParticle(
		"particles/econ/items/luna/luna_lucent_ti5/luna_lucent_beam_cast_ti_5.vpcf",
		PATTACH_ABSORIGIN_FOLLOW, event.target)
		ParticleManager:SetParticleControl(effect, 6, event.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(effect)

	end
end