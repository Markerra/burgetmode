require("utils/timers")

LinkLuaModifier( "maxim_photo_give_item", "abilities/maxim/maxim_photo", LUA_MODIFIER_MOTION_NONE )

maxim_photo = {}

function maxim_photo:GetIntrinsicModifierName()
	return "maxim_photo_give_item"
end

maxim_photo_give_item = {}

function maxim_photo_give_item:OnCreated()
	local parent = self:GetParent()
	local firstItem = true
	Timers:CreateTimer(0.3, function()
		if not parent:HasItemInInventory("item_maxim_photo") and firstItem == true then
			parent:AddItemByName("item_maxim_photo")
			firstItem = false
		end
		self:Destroy()
	end)
end