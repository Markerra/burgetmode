LinkLuaModifier("matvey_magic_modifier",
 "abilities/matvey/matvey_magic", LUA_MODIFIER_MOTION_NONE)

matvey_magic = class({})

function matvey_magic:GetManaCost( level )
	local mana = self:GetCaster():GetMana()
	local manacost = self:GetSpecialValueFor("manacost_pct")
	return math.floor( mana * (manacost / 100) )
end

function matvey_magic:GetIntrinsicModifierName()
	return "matvey_magic_modifier"
end

matvey_magic_modifier = class({})

function matvey_magic_modifier:IsHidden() return true end
function matvey_magic_modifier:IsDebuff() return false end
function matvey_magic_modifier:IsPurgable() return false end

function matvey_magic_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function matvey_magic_modifier:GetModifierBaseDamageOutgoing_Percentage()
	local ability = self:GetAbility()
	local caster = ability:GetCaster()

	if caster:GetMana() < ability:GetManaCost(ability:GetLevel()) then
		return -100
	end

	local transform_pct = ability:GetSpecialValueFor("transform_pct")
	return -transform_pct
end

function matvey_magic_modifier:OnAttack( event )
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local attacker = event.attacker

	if caster == attacker then
		caster:SpendMana(ability:GetManaCost(ability:GetLevel()), ability)
	end
end

function matvey_magic_modifier:OnAttackLanded( event )
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local attacker = event.attacker
	local target = event.target

	if caster == attacker then

		local bonus_pct = ability:GetSpecialValueFor("bonus_pct")
		local bonus_dmg = ability:GetManaCost(ability:GetLevel()) * (bonus_pct / 100) 

		if event.cleave then 
			bonus_dmg = bonus_dmg * event.cleave_mult
		end

		ApplyDamage({ -- bonus part of damage (magical)
			victim = target,
			attacker = attacker,
			damage = bonus_dmg,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability
		})
		
		local transform_pct = ability:GetSpecialValueFor("transform_pct")
		local avg = (attacker:GetBaseDamageMin() + attacker:GetBaseDamageMax()) / 2
		local dmg = avg * (transform_pct / 100)

		if event.cleave then 
			dmg = dmg * event.cleave_mult
		end

		ApplyDamage({ -- other part of damage (magical)
			victim = target,
			attacker = attacker,
			damage = dmg,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability
		})

		if event.cleave then
			local modif = caster:FindModifierByName("modifier_matvey_bf")
			if modif then modif:ManaRestore(dmg + bonus_dmg) end
		end

		--print("Damage: "..event.damage)
		--print("Transform: "..transform_pct.."%")
		--print("Magical Damage: "..dmg)
		--print("Magical Bonus Damage: "..bonus_dmg)
	end
end