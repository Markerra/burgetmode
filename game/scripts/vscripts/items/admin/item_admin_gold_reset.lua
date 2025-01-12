item_admin_gold_reset = class({})

function item_admin_gold_reset:OnSpellStart()
	local caster = self:GetCaster()

	local current_gold = caster:GetGold()

	caster:ModifyGold(-current_gold, true, 8)

	print("Admin Item: Gold Reset for "..caster:GetUnitName().." ("..-current_gold..")")

end