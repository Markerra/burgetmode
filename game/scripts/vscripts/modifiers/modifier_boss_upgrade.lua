modifier_boss_upgrade = class({})

function modifier_boss_upgrade:IsHidden() return true end
function modifier_boss_upgrade:IsPurgable() return false end

function modifier_boss_upgrade:DeclareFunctions()
   return   {
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
  }
end

function modifier_boss_upgrade:CheckState()
	return {
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true
	}
end

function modifier_boss_upgrade:OnCreated( kv )
	if not IsServer() then return end

	self.health = 0
	self.damage = 0
  	self.speed  = 0
  	self.armor  = 0
  	self.amp    = 0
  	self.magic  = 0
	self.status_res = 0

	if wave >= 10 then 
  		self.health = 0
  		self.damage = 30
  		self.speed  = 30
  		self.status_res = 40
  	end
  	if wave >= 20 then 
  		self.health = 2000
  		self.damage = 80
  		self.speed  = 50
  		self.armor  = 5
  		self.amp    = 20
  		self.magic  = 25
  		self.status_res = 60
  	end 

	self:SetHasCustomTransmitterData(true)
end

function modifier_boss_upgrade:GetModifierStatusResistanceStacking() 
	return self.status_res
end

function modifier_boss_upgrade:AddCustomTransmitterData() 
	return {
		amp = self.amp,
		armor = self.armor,
		magic = self.magic,
		speed = self.speed
	} 
end

function modifier_boss_upgrade:HandleCustomTransmitterData(data)
	self.amp  = data.amp
	self.armor = data.armor
	self.magic = data.magic
	self.speed = data.speed
end

function modifier_boss_upgrade:GetModifierMagicalResistanceBonus()
	return self.magic
end

function modifier_boss_upgrade:GetModifierBaseAttack_BonusDamage()
	return self.change_damage
end

function modifier_boss_upgrade:GetModifierExtraHealthBonus()
	return self.change_health
end

function modifier_boss_upgrade:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_boss_upgrade:GetModifierSpellAmplify_Percentage() 
	return self.amp
end