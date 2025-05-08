LinkLuaModifier("modifier_arsen_quadrober", "abilities/arsen/arsen_quadrober", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_quadrober_bonus", "abilities/arsen/arsen_quadrober", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_quadrober_shard", "abilities/arsen/arsen_quadrober", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_quadrober_shard_debuff", "abilities/arsen/arsen_quadrober", LUA_MODIFIER_MOTION_NONE)

arsen_quadrober = class({})

function arsen_quadrober:GetBehavior()
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    else
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
end

function arsen_quadrober:GetCooldown()
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        return self:GetSpecialValueFor("shard_cooldown")
    else
        return 0
    end
end


function arsen_quadrober:GetManaCost()
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        return self:GetSpecialValueFor("shard_manacost")
    else
        return 0
    end
end

function arsen_quadrober:GetCastRange()
    return self:GetSpecialValueFor("radius")
end

function arsen_quadrober:CastFilterResult()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local units = FindUnitsInRadius(
	    caster:GetTeamNumber(),
	    Vector(0, 0, 0),
	    nil,
	    FIND_UNITS_EVERYWHERE,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_BASIC,
	    DOTA_UNIT_TARGET_FLAG_NONE,
	    FIND_CLOSEST,
	    true
	)
	if #units > 0 then
		return UF_SUCCESS 
	else
		return UF_FAIL_CUSTOM
	end
end

function arsen_quadrober:GetCustomCastError()
	return "Нет призванных юнитов"
end

function arsen_quadrober:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()

    local units = FindUnitsInRadius(
	    caster:GetTeamNumber(),
	    Vector(0, 0, 0),
	    nil,
	    FIND_UNITS_EVERYWHERE,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_BASIC,
	    DOTA_UNIT_TARGET_FLAG_NONE,
	    FIND_CLOSEST,
	    true
	)

    local summons = 0
    local hp_regen = 0

    if #units == 0 then return end

    local duration = self:GetSpecialValueFor("shard_duration")

    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_arsen_summon" then
            local regen = unit:GetHealthRegen()
            hp_regen = hp_regen + regen
            summons = summons + 1
            unit:AddNewModifier(caster, self, "modifier_arsen_quadrober_shard_debuff", {duration = duration, regen = regen})
        end
    end

    caster:AddNewModifier(caster, self, "modifier_arsen_quadrober_shard", {duration = duration, regen = hp_regen})
    caster:FindAbilityByName("arsen_quadrober_shard_ability"):SetLevel(self:GetLevel())
    caster:UnHideAbilityToSlot("arsen_quadrober_shard_ability", "arsen_quadrober")
end

function arsen_quadrober:GetIntrinsicModifierName()
    return "modifier_arsen_quadrober"
end

modifier_arsen_quadrober = class({})

function modifier_arsen_quadrober:IsHidden() return true end
function modifier_arsen_quadrober:IsDebuff() return false end
function modifier_arsen_quadrober:IsPurgable() return false end

function modifier_arsen_quadrober:OnCreated()
    self:StartIntervalThink(GameRules:GetGameFrameTime())
end

function modifier_arsen_quadrober:OnIntervalThink()
    local parent = self:GetParent()
    local ability = self:GetAbility() 
    local radius = ability:GetSpecialValueFor("radius")
    local duration = ability:GetSpecialValueFor("duration")

    if not IsServer() then return end

    local units = FindUnitsInRadius(
	    parent:GetTeamNumber(),
	    parent:GetAbsOrigin(),
	    nil,
	    radius,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_BASIC,
	    DOTA_UNIT_TARGET_FLAG_NONE,
	    FIND_CLOSEST,
	    true
	)

    local stacks = 0

    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_arsen_summon" then
            stacks = stacks + 1
        end
    end
    
    if stacks > 0 then
        local modif = parent:AddNewModifier(parent, ability, "modifier_arsen_quadrober_bonus", {duration = duration})
        modif:SetStackCount(stacks)
    end

    if stacks <= 0 and duration <= 0 then
        parent:RemoveModifierByName("modifier_arsen_quadrober_bonus")
    end
end

modifier_arsen_quadrober_bonus = class({})

function modifier_arsen_quadrober_bonus:IsHidden() return false end
function modifier_arsen_quadrober_bonus:IsDebuff() return false end
function modifier_arsen_quadrober_bonus:IsPurgable() return true end

function modifier_arsen_quadrober_bonus:OnCreated()
    if not IsServer() then return end
    local ability = self:GetAbility()
    
    local stacks = self:GetStackCount()
    self.hp_bonus = ability:GetSpecialValueFor("hp_bonus") * stacks
    self.armor_bonus = ability:GetSpecialValueFor("armor_bonus") * stacks
    self.dmg_bonus = ability:GetSpecialValueFor("dmg_bonus") * stacks
    self.ms_bonus = ability:GetSpecialValueFor("ms_bonus") * stacks
    
    self:SetHasCustomTransmitterData(true)
    self:GetCaster():CalculateStatBonus(true)
    self:SendBuffRefreshToClients()
end

function modifier_arsen_quadrober_bonus:OnRefresh()
    if not IsServer() then return end
    local ability = self:GetAbility()

    local stacks = self:GetStackCount()
    self.hp_bonus = ability:GetSpecialValueFor("hp_bonus") * stacks
    self.armor_bonus = ability:GetSpecialValueFor("armor_bonus") * stacks
    self.dmg_bonus = ability:GetSpecialValueFor("dmg_bonus") * stacks
    self.ms_bonus = ability:GetSpecialValueFor("ms_bonus") * stacks
    
    self:GetCaster():CalculateStatBonus(true)
    self:SendBuffRefreshToClients()
end

function modifier_arsen_quadrober_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end

function modifier_arsen_quadrober_bonus:GetModifierHealthBonus()
    return self.hp_bonus
end

function modifier_arsen_quadrober_bonus:GetModifierPhysicalArmorBonus()
    return self.armor_bonus
end

function modifier_arsen_quadrober_bonus:GetModifierPreAttack_BonusDamage()
    return self.dmg_bonus
end

function modifier_arsen_quadrober_bonus:GetModifierMoveSpeedBonus_Constant()
    return self.ms_bonus
end

function modifier_arsen_quadrober_bonus:AddCustomTransmitterData()
    local data = {
        hp_bonus = self.hp_bonus,
        armor_bonus = self.armor_bonus,
        dmg_bonus = self.dmg_bonus,
        ms_bonus = self.ms_bonus
    }
    return data
end

function modifier_arsen_quadrober_bonus:HandleCustomTransmitterData(data)
    self.hp_bonus = data.hp_bonus
    self.armor_bonus = data.armor_bonus
    self.dmg_bonus = data.dmg_bonus
    self.ms_bonus = data.ms_bonus
end

modifier_arsen_quadrober_shard = class({})

function modifier_arsen_quadrober_shard:IsPurgable() return false end
function modifier_arsen_quadrober_shard:IsHidden() return false end
function modifier_arsen_quadrober_shard:IsDebuff() return false end


function modifier_arsen_quadrober_shard:GetEffectAttachType() return PATTACH_POINT_FOLLOW end
function modifier_arsen_quadrober_shard:GetEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf"
end

function modifier_arsen_quadrober_shard:OnCreated(kv)
    self:SetHasCustomTransmitterData(true)
    if not IsServer() then return end

    self.regen = kv.regen

    self:SendBuffRefreshToClients()

    self:GetParent():EmitSound("Hero_Broodmother.InsatiableHunger")
end

function modifier_arsen_quadrober_shard:OnDestroy()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:UnHideAbilityToSlot("arsen_quadrober", "arsen_quadrober_shard_ability")
    self:GetParent():StopSound("Hero_Broodmother.InsatiableHunger")
end

function modifier_arsen_quadrober_shard:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_arsen_quadrober_shard:GetModifierConstantHealthRegen()
    return self.regen
end

function modifier_arsen_quadrober_shard:OnTooltip()
    return self.regen
end

function modifier_arsen_quadrober_shard:AddCustomTransmitterData()
    local data = {
        regen = self.regen
    }
    return data
end

function modifier_arsen_quadrober_shard:HandleCustomTransmitterData(data)
    self.regen = data.regen
end

modifier_arsen_quadrober_shard_debuff = class({})

function modifier_arsen_quadrober_shard_debuff:IsPurgable() return false end
function modifier_arsen_quadrober_shard_debuff:IsHidden() return true end
function modifier_arsen_quadrober_shard_debuff:IsDebuff() return false end

function modifier_arsen_quadrober_shard_debuff:OnCreated(kv)
    self:SetHasCustomTransmitterData(true)
    if not IsServer() then return end

    self.regen = kv.regen

    self:SendBuffRefreshToClients()
end

function modifier_arsen_quadrober_shard_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end

function modifier_arsen_quadrober_shard_debuff:GetModifierConstantHealthRegen()
    return -self.regen
end

function modifier_arsen_quadrober_shard_debuff:AddCustomTransmitterData()
    local data = {
        regen = self.regen
    }
    return data
end

function modifier_arsen_quadrober_shard_debuff:HandleCustomTransmitterData(data)
    self.regen = data.regen
end

arsen_quadrober_shard_ability = class({})

function arsen_quadrober_shard_ability:OnAbilityPhaseStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:EmitSound("Hero_Broodmother.SpawnSpiderlingsImpact")
end

function arsen_quadrober_shard_ability:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:StopSound("Hero_Broodmother.SpawnSpiderlingsImpact")
end

function arsen_quadrober_shard_ability:CastFilterResult()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local units = FindUnitsInRadius(
	    caster:GetTeamNumber(),
	    Vector(0, 0, 0),
	    nil,
	    FIND_UNITS_EVERYWHERE,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_BASIC,
	    DOTA_UNIT_TARGET_FLAG_NONE,
	    FIND_CLOSEST,
	    true
	)
	if #units > 0 then
		return UF_SUCCESS 
	else
        caster:UnHideAbilityToSlot("arsen_quadrober", "arsen_quadrober_shard_ability")
		return UF_FAIL_CUSTOM
	end
end

function arsen_quadrober_shard_ability:GetCustomCastError()
	return "Нет призванных юнитов"
end


function arsen_quadrober_shard_ability:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("arsen_quadrober")

    local health_pct = ability:GetSpecialValueFor("shard_health_pct")

    local units = FindUnitsInRadius(
	    caster:GetTeamNumber(),
	    Vector(0, 0, 0),
	    nil,
	    FIND_UNITS_EVERYWHERE,
	    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	    DOTA_UNIT_TARGET_BASIC,
	    DOTA_UNIT_TARGET_FLAG_NONE,
	    FIND_CLOSEST,
	    true
	)

    local total_health = 0

    if #units == 0 then return end

    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_arsen_summon" then
            local hp = unit:GetHealth() * (health_pct / 100)
            total_health = total_health + hp
            unit:ForceKill(false)
        end
    end

    caster:Heal(total_health, self)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, total_health, nil)

    local modif = caster:FindModifierByName("modifier_arsen_quadrober_shard")
    if modif then caster:RemoveModifierByName("modifier_arsen_quadrober_shard") end

    caster:UnHideAbilityToSlot("arsen_quadrober", "arsen_quadrober_shard_ability")
end