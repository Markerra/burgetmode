modifier_wave_mkb = class({})

function modifier_wave_mkb:IsHidden()		return true end
function modifier_wave_mkb:IsPurgable()	return false end
function modifier_wave_mkb:RemoveOnDeath()	return false end
function modifier_wave_mkb:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_wave_mkb:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

    local wave = GameMode.current_wave

	self.parent		= self:GetParent()

	self.bonus_damage			= 10
	self.bonus_range			= 30
	self.bonus_chance			= 35
	self.bonus_chance_damage	= 40

	if wave >= 5 then
		self.bonus_damage			= 20
		self.bonus_range			= 45
		self.bonus_chance			= 50
		self.bonus_chance_damage	= 45
	end
	if wave >= 10 then
		self.bonus_damage			= 30
		self.bonus_range			= 70
		self.bonus_chance			= 55
		self.bonus_chance_damage	= 50
	end
	if wave >= 15 then
		self.bonus_damage			= 45
		self.bonus_range			= 90
		self.bonus_chance			= 65
		self.bonus_chance_damage	= 50
	end
	if wave >= 20 then
		self.bonus_damage			= 55
		self.bonus_range			= 110
		self.bonus_chance			= 75
		self.bonus_chance_damage	= 65
	end
	if wave >= 20 then
		self.bonus_damage			= 65
		self.bonus_range			= 140
		self.bonus_chance			= 80
		self.bonus_chance_damage	= 65
	end
	if wave >= 25 then
		self.bonus_damage			= 65
		self.bonus_range			= 140
		self.bonus_chance			= 95
		self.bonus_chance_damage	= 65
	end
		
	self.pierce_proc 			= false
	self.pierce_records			= {}
end

function modifier_wave_mkb:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
		MODIFIER_EVENT_ON_ATTACK_RECORD,
	}
end

function modifier_wave_mkb:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_wave_mkb:GetModifierAttackRangeBonus()
	if not self.parent:IsRangedAttacker() and self:GetStackCount() == 1 then
		return self.bonus_range
	end
end

function modifier_wave_mkb:GetModifierProcAttack_BonusDamage_Magical(keys)
	for _, record in pairs(self.pierce_records) do	
		if record == keys.record then
			table.remove(self.pierce_records, _)
			if not self.parent:IsIllusion() and not keys.target:IsBuilding() then
				self.parent:EmitSound("DOTA_Item.MKB.ranged")
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, self.bonus_chance_damage, nil)
				return self.bonus_chance_damage
			end
		end
	end
end

function modifier_wave_mkb:OnAttackRecord(keys)
	if keys.attacker == self.parent then
		if self.pierce_proc then
			table.insert(self.pierce_records, keys.record)
			self.pierce_proc = false
		end
	
		if (not keys.target:IsMagicImmune() or self:GetName() == "modifier_wave_mkb") and RollPseudoRandom(self.bonus_chance, self) then
			self.pierce_proc = true
		end
	end
end

function modifier_wave_mkb:CheckState()
	local state = {}
	
	if self.pierce_proc then
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end

	return state
end