LinkLuaModifier( "maxim_photo_give_item", "abilities/maxim/maxim_photo", LUA_MODIFIER_MOTION_NONE )

maxim_photo = {}

function maxim_photo:GetIntrinsicModifierName()
	return "maxim_photo_give_item"
end

maxim_photo_give_item = {}

function maxim_photo_give_item:OnCreated()
	local parent = self:GetParent()

	if not parent:HasItemInInventory("item_maxim_photo") then
		parent:AddItemByName("item_maxim_photo")
	end
	self:Destroy()
end