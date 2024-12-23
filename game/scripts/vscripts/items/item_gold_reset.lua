item_gold_reset = class({})

function item_gold_reset:OnSpellStart()
	local caster = self:GetCaster()

	local current_gold = caster:GetGold()

	caster:ModifyGold(-current_gold, true, 8)
end