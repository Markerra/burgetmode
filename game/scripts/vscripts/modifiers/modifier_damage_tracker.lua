modifier_damage_tracker = class({})

function modifier_damage_tracker:OnCreated( kv )
    if not IsServer() then return end
    self.damage_table = {}
end

function modifier_damage_tracker:OnDestroy()
    if not IsServer() then return end

    local max_damage = -1
    local max_damage_hero = ""

    for hero, damage in pairs(self.damage_table) do
        print("Hero: " .. hero .. " - Damage: " .. damage)
        
        if damage > max_damage then
            max_damage = damage
            max_damage_hero = hero
        end
    end

    if max_damage_hero ~= "" then
        print("Hero with the most damage: " .. max_damage_hero .. " - Damage: " .. max_damage)
    else
        print("No damage was dealt.")
    end
end

function modifier_damage_tracker:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DAMAGE_CALCULATED
	}
end

function modifier_damage_tracker:OnDamageCalculated(params)
    if not IsServer() then return end

    if params.target == self:GetParent() then
        local attacker = params.attacker

        if attacker:IsHero() then
            local hero_name = attacker:GetUnitName()

            if not self.damage_table[hero_name] then
                self.damage_table[hero_name] = 0
            end

            self.damage_table[hero_name] = self.damage_table[hero_name] + params.damage
        end
    end
end

function modifier_damage_tracker:IsPurgable()
    return false
end

function modifier_damage_tracker:IsHidden()
    return true
end