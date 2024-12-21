LinkLuaModifier("modifier_item_maxim_photo", "items/maxim/item_maxim_photo", LUA_MODIFIER_MOTION_NONE)

item_maxim_photo = class({})

function item_maxim_photo:GetIntrinsicModifierName()
    return "modifier_item_maxim_photo"
end

modifier_item_maxim_photo = class({})

function modifier_item_maxim_photo:IsHidden()   return false end
function modifier_item_maxim_photo:IsPurgable() return false end

function modifier_item_maxim_photo:GetTexture() return "modifiers/modifier_maxim_photo" end

function modifier_item_maxim_photo:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_item_maxim_photo:OnDeath(params)
    if not IsServer() then return end

    local ability = self:GetAbility()
    local parent  = self:GetParent()
    local bonus   = self:GetParent():FindAbilityByName("maxim_photo"):GetSpecialValueFor("attackspeed_bonus")
    local unit 	  = params.unit

    if not parent or not unit then return end
    if not parent:IsAlive() or not ability then return end

    if not unit:IsHero() then return end 

    if unit:GetTeamNumber() == parent:GetTeamNumber() then return end

    if parent:CanEntityBeSeenByMyTeam(unit) then
        if ability and ability:GetCurrentCharges() then
            ability:SetCurrentCharges(ability:GetCurrentCharges() + 1)
            self:SetStackCount(ability:GetCurrentCharges() * bonus)
            EmitSoundOn("item_maxim_photo_cast", parent)
        end
    end
end

function modifier_item_maxim_photo:GetModifierAttackSpeedBonus_Constant()
	local ability = self:GetAbility()
	local bonus   = self:GetParent():FindAbilityByName("maxim_photo"):GetSpecialValueFor("attackspeed_bonus")
	return ability:GetCurrentCharges() * bonus
end