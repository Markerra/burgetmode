modifier_wave_upgrade = class({})

function modifier_wave_upgrade:IsHidden() return false end
function modifier_wave_upgrade:IsPurgable() return false end

function modifier_wave_upgrade:DeclareFunctions()
   return   {
    MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
  }
end

function modifier_wave_upgrade:CheckState()
	return {
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true
	}
end

function modifier_wave_upgrade:OnCreated( kv )
	if not IsServer() then return end

	self.health = self:GetParent():GetBaseMaxHealth()
	self.damage = self:GetParent():GetBaseDamageMin()
	self.gold = self:GetParent():GetMinimumGoldBounty()*1.25
	self.exp = self:GetParent():GetDeathXP()
	self.armor = 0
	self.magic = 10
	self.amp = 0
	self.speed = 0

	for wave=2, GameMode.current_wave do

		self.health_mod = 1.00
  		self.damage_mod = 1.00
  		self.gold_mod   = 1.00
  		self.exp_mod    = 1.00

  		if wave >= 10 then 
  			self.health_mod = 1.18
  			self.damage_mod = 1.15
  			self.gold_mod   = 1.02
  			self.exp_mod    = 1.04
  		end 
		if wave >= 15 then 
			self.health_mod = 1.20 
			self.damage_mod = 1.18 
			self.armor =  10 
			self.speed =  40 
			self.magic = -20 
		end 
		if wave >= 20 then 
			self.health_mod = 1.22 
			self.damage_mod = 1.17 
			self.armor =  12 
			self.speed =  60 
			self.magic = -30 
		end 
		if wave >= 25 then 
			self.health_mod = 1.12
			self.damage_mod = 1.14 
			self.armor =  15 
			self.speed =  80 
			self.magic = -40 
		end
		if wave >= 30 then
			self.health_mod = RandomFloat(0.5, 99.5)
			self.damage_mod = RandomFloat(0.4, 25.5)
			self.armor = RandomInt(5, 90)
			self.speed = RandomInt(60, 600)
		end

		self.health = self.health*self.health_mod
		self.damage = self.damage*self.damage_mod
		self.gold = self.gold*self.gold_mod
		self.exp = self.exp*self.exp_mod
		self.amp = self.amp + 15

		--if kv.table ~= nil or kv.table ~= false then
		--	self.health = self.health*kv.table.health_mod
		--	self.damage = self.damage*kv.table.damage_mod
		--	self.gold   = self.gold*kv.table..gold_mod
		--	self.exp 	= self.exp*kv.table..exp_mod
		--	self.amp 	= self.amp + kv.table.amp_mod
		--end

		self.change_health = self.health - self:GetParent():GetBaseMaxHealth()
		self.change_damage = self.damage - self:GetParent():GetBaseDamageMin()

		self:GetParent():SetMinimumGoldBounty(self.gold)
  		self:GetParent():SetMaximumGoldBounty(self.gold)
  		self:GetParent():SetDeathXP(self.exp)

		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_wave_upgrade:GetModifierTotalDamageOutgoing_Percentage( params ) 
	if params.attacker == self:GetParent() then 
	   	if params.target then 
        	if params.target:IsBuilding() then 
				return -50
			end
		end
	end
end

function modifier_wave_upgrade:GetModifierStatusResistanceStacking() 
	return 30 
end

function modifier_wave_upgrade:AddCustomTransmitterData() 
	return {
		amp = self.amp,
		armor = self.armor,
		magic = self.magic,
		speed = self.speed
	} 
end

function modifier_wave_upgrade:HandleCustomTransmitterData(data)
	self.amp  = data.amp
	self.armor = data.armor
	self.magic = data.magic
	self.speed = data.speed
end

function modifier_wave_upgrade:GetModifierAttackSpeedBonus_Constant()
	return self.speed
end

function modifier_wave_upgrade:GetModifierMagicalResistanceBonus()
	return self.magic
end

function modifier_wave_upgrade:GetModifierBaseAttack_BonusDamage()
	return self.change_damage
end

function modifier_wave_upgrade:GetModifierHealthBonus()
	return self.change_health
end

function modifier_wave_upgrade:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_wave_upgrade:GetModifierSpellAmplify_Percentage() 
	return self.amp
end