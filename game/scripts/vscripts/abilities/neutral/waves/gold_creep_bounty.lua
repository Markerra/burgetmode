LinkLuaModifier("modifier_gold_creep_bounty", "abilities/neutral/waves/gold_creep_bounty", LUA_MODIFIER_MOTION_NONE)

gold_creep_bounty = class({})

function gold_creep_bounty:GetIntrinsicModifierName()
	return "modifier_gold_creep_bounty"
end

modifier_gold_creep_bounty = class({})

function modifier_gold_creep_bounty:IsPurgable() return false end
function modifier_gold_creep_bounty:IsDebuff() return false end
function modifier_gold_creep_bounty:IsHidden() return true end

function modifier_gold_creep_bounty:OnCreated()
	local parent = self:GetParent()
	local gold = self:GetAbility():GetSpecialValueFor("bounty")
	local i = 15

	if IsServer() then
		parent:SetMinimumGoldBounty(gold + RandomInt(-i, 0))
		parent:SetMaximumGoldBounty(gold + RandomInt(0, i))
	end
end

function modifier_gold_creep_bounty:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_gold_creep_bounty:OnAttackLanded( aa )
	local parent = self:GetParent()
	local target = aa.target
	local attacker = aa.attacker

	if target == parent and attacker:IsHero() then
		local gold = self:GetAbility():GetSpecialValueFor("gpa")
		attacker:ModifyGold( gold, false, 0 )
		SendOverheadEventMessage(nil, 0, attacker, gold, nil)
	end
end