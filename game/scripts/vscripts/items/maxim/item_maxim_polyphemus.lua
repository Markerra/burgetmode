LinkLuaModifier("modifier_item_maxim_polyphemus", "items/maxim/item_maxim_polyphemus", LUA_MODIFIER_MOTION_NONE)

item_maxim_polyphemus = {}

function item_maxim_polyphemus:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster():HasAbility("maxim_isaac") then return end
	local duration = self:GetSpecialValueFor("duration")
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_maxim_polyphemus", {duration = duration})
	caster:EmitSound("item_maxim_polyphemus_cast")
	local removed_item = caster:TakeItem(self)
	if removed_item then
        UTIL_Remove(removed_item)
    end
end

modifier_item_maxim_polyphemus = {}

function modifier_item_maxim_polyphemus:GetTexture() return "modifiers/modifier_maxim_polyphemus" end
function modifier_item_maxim_polyphemus:IsDebuff() 	 return false end
function modifier_item_maxim_polyphemus:IsPurgable() return true  end

function modifier_item_maxim_polyphemus:OnCreated()
	if not IsServer() then return end
	local damage_amp = self:GetAbility():GetSpecialValueFor("damage_amp")
	print(damage_amp)
	self.atdmg = self:GetParent():GetAverageTrueAttackDamage(self:GetParent()) * (damage_amp - 1)
end

function modifier_item_maxim_polyphemus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
	}
end

function modifier_item_maxim_polyphemus:GetModifierBaseAttack_BonusDamage()
	return (self.atdmg or 0)
end