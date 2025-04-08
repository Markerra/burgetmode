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

function matvey_magic_modifier:GetOverrideAttackMagical() 
	return 1 
end

function matvey_magic_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function matvey_magic_modifier:GetModifierOverrideAttackDamage()
	if not IsServer() then return end

	local ability = self:GetAbility()
	local caster = ability:GetCaster()

	if caster:GetMana() < ability:GetManaCost(ability:GetLevel()) then
		return 0
	end

	local transform_pct = ability:GetSpecialValueFor("transform_pct")
	return caster:GetAttackDamage() * (transform_pct / 100)
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

	if caster == attacker then
		local bonus_pct = ability:GetSpecialValueFor("bonus_pct")
		local dmg = caster:GetMana() * (bonus_pct / 100) 

		ApplyDamage({ -- bonus part of damage (magical)
			victim = event.target,
			attacker = attacker,
			damage = dmg,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability
		})
		
		local transform_pct = ability:GetSpecialValueFor("transform_pct")
		dmg = caster:GetAttackDamage() * (1 - (transform_pct / 100))

		ApplyDamage({ -- other part of damage (physical)
			victim = event.target,
			attacker = attacker,
			damage = dmg,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			ability = ability
		})
	end
end