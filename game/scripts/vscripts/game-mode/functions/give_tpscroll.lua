function GiveTPScroll()
	for i=1, HeroList:GetHeroCount() do
		local hero = HeroList:GetHero(i-1)
		hero:AddItemByName("item_tpscroll_custom")
	end
end