LinkLuaModifier("maxim_isaac_modif", "abilities/maxim/maxim_isaac", LUA_MODIFIER_MOTION_NONE)

function GiveItemWithLevel(hero, item_name, level)
    if not IsServer() then return end

    local item = CreateItem(item_name, hero, hero)

    if item then

        item:SetLevel(level)
        hero:AddItem(item)

    end
end

maxim_isaac = {}

function maxim_isaac:OnSpellStart()
	local caster   = self:GetCaster()
	local level    = self:GetLevel()
	local rnd 	   = RandomInt(1, 5)
	if rnd == 1 then
		GiveItemWithLevel(caster, "item_maxim_polyphemus", level)
	elseif rnd == 2 then
		GiveItemWithLevel(caster, "item_maxim_abaddon",    level)
	elseif rnd == 3 then
		GiveItemWithLevel(caster, "item_maxim_thewafer",   level)
	elseif rnd == 4 then
		GiveItemWithLevel(caster, "item_maxim_relevation", level)
	elseif rnd == 5 then
		GiveItemWithLevel(caster, "item_maxim_godhead",    level)
	end

	EmitSoundOn("maxim_isaac_cast", caster)
end 

maxim_isaac_modif = {}

function maxim_isaac_modif:OnCreated()
	
end