LinkLuaModifier("modifier_arsen_achievements_farmer", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_damagedealer", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_killer", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_pianist", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_businessman", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_outbid", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_buyback", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_buyback_2", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_villain", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arsen_achievements_arseniy", "abilities/arsen/arsen_achievements", LUA_MODIFIER_MOTION_NONE)

arsen_achievements = class({})

function arsen_achievements:Spawn()
    if not IsServer() then return end
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_farmer", {})
    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_damagedealer", {})
    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_killer", {})
    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_pianist", {})
    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_businessman", {})
    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_outbid", {})
    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_buyback", {})
    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_villain", {})
    caster:AddNewModifier(caster, self, "modifier_arsen_achievements_arseniy", {})
end

modifier_arsen_achievements_farmer = class({})

function modifier_arsen_achievements_farmer:IsHidden() return true end
function modifier_arsen_achievements_farmer:IsPurgable() return false end

function modifier_arsen_achievements_farmer:OnCreated()
    self.stages = {
        tier1 = {
            completed = false,
            given = false,
            req = 120,
            progress = 0
        },
        tier2 = {
            completed = false,
            given = false,
            req = 240,
            progress = 0
        },
        tier3 = {
            completed = false,
            given = false,
            req = 360,
            progress = 0
        }
    }

    self:StartIntervalThink(0.9)
end

function modifier_arsen_achievements_farmer:OnIntervalThink()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local ability = self:GetAbility()

    local lhs = caster:GetLastHits()
    if lhs >= self.stages.tier1.req then self.stages.tier1.completed = true end
    if lhs >= self.stages.tier2.req then self.stages.tier2.completed = true end
    if lhs >= self.stages.tier3.req then self.stages.tier3.completed = true end

    if ability:GetLevel() == 1 and self.stages.tier1.completed and not self.stages.tier1.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_farmer", tier = 1})
        self.stages.tier1.given = true
    end
    if ability:GetLevel() == 2 and self.stages.tier2.completed and not self.stages.tier2.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_farmer", tier = 2})
        self.stages.tier2.given = true
    end
    if ability:GetLevel() == 3 and self.stages.tier3.completed and not self.stages.tier3.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_farmer", tier = 3})
        self.stages.tier3.given = true
    end
end


modifier_arsen_achievements_damagedealer = class({})

function modifier_arsen_achievements_damagedealer:IsHidden() return true end
function modifier_arsen_achievements_damagedealer:IsPurgable() return false end

function modifier_arsen_achievements_damagedealer:OnCreated()
    self.stages = {
        tier1 = {
            completed = false,
            given = false,
            req = 15000,
            progress = 0
        },
        tier2 = {
            completed = false,
            given = false,
            req = 30000,
            progress = 0
        },
        tier3 = {
            completed = false,
            given = false,
            req = 45000,
            progress = 0
        }
    }
end

function modifier_arsen_achievements_damagedealer:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DAMAGE_CALCULATED
    }
end

function modifier_arsen_achievements_damagedealer:OnDamageCalculated(event)
    if not IsServer() then return end

    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local ability = self:GetAbility()
    local attacker = event.attacker
    local damage = event.damage

    if attacker == caster then
        if not self.total_damage then self.total_damage = 0 end
        self.total_damage = self.total_damage + damage
        if self.total_damage >= self.stages.tier1.req then self.stages.tier1.completed = true end
        if self.total_damage >= self.stages.tier2.req then self.stages.tier2.completed = true end
        if self.total_damage >= self.stages.tier3.req then self.stages.tier3.completed = true end

        if ability:GetLevel() == 1 and self.stages.tier1.completed and not self.stages.tier1.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_damagedealer", tier = 1})
        self.stages.tier1.given = true
        end
        if ability:GetLevel() == 2 and self.stages.tier2.completed and not self.stages.tier2.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_damagedealer", tier = 2})
        self.stages.tier2.given = true
        end
        if ability:GetLevel() == 3 and self.stages.tier3.completed and not self.stages.tier3.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_damagedealer", tier = 3})
        self.stages.tier3.given = true
        end

    end
end


modifier_arsen_achievements_killer = class({})

function modifier_arsen_achievements_killer:IsHidden() return true end
function modifier_arsen_achievements_killer:IsPurgable() return false end

function modifier_arsen_achievements_killer:OnCreated()
    self.stages = {
        tier1 = {
            completed = false,
            given = false,
            req = 8,
            progress = 0
        },
        tier2 = {
            completed = false,
            given = false,
            req = 16,
            progress = 0
        },
        tier3 = {
            completed = false,
            given = false,
            req = 24,
            progress = 0
        }
    }

    self:StartIntervalThink(1.4)
end

function modifier_arsen_achievements_killer:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local ability = self:GetAbility()

    local kills = caster:GetKills()
    if kills >= self.stages.tier1.req then self.stages.tier1.completed = true end
    if kills >= self.stages.tier2.req then self.stages.tier2.completed = true end
    if kills >= self.stages.tier3.req then self.stages.tier3.completed = true end

    if ability:GetLevel() == 1 and self.stages.tier1.completed and not self.stages.tier1.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_killer", tier = 1})
        self.stages.tier1.given = true
    end
    if ability:GetLevel() == 2 and self.stages.tier2.completed and not self.stages.tier2.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_killer", tier = 2})
        self.stages.tier2.given = true
    end
    if ability:GetLevel() == 3 and self.stages.tier3.completed and not self.stages.tier3.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_killer", tier = 3})
        self.stages.tier3.given = true
    end
end


modifier_arsen_achievements_pianist = class({})

function modifier_arsen_achievements_pianist:IsHidden() return true end
function modifier_arsen_achievements_pianist:IsPurgable() return false end

function modifier_arsen_achievements_pianist:OnCreated()
    self.stages = {
        tier1 = {
            completed = false,
            given = false,
            req = 60,
            progress = 0
        },
        tier2 = {
            completed = false,
            given = false,
            req = 90,
            progress = 0
        },
        tier3 = {
            completed = false,
            given = false,
            req = 120,
            progress = 0
        }
    }
end

function modifier_arsen_achievements_pianist:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }
end

function modifier_arsen_achievements_pianist:OnAbilityExecuted(event)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local ability = self:GetAbility()
    local casted_ability = event.ability

    if casted_ability and casted_ability:GetCaster() == caster then
        if casted_ability:GetBehavior() == DOTA_ABILITY_BEHAVIOR_PASSIVE then return end
        if not self.total_abilities then self.total_abilities = 0 end
        self.total_abilities = self.total_abilities + 1
        print("ABILITY EXECUTED! TOTAL NUMBER OF EXECUTED ABILITIES: ", self.total_abilities)

        if self.total_abilities >= self.stages.tier1.req then self.stages.tier1.completed = true end
        if self.total_abilities >= self.stages.tier2.req then self.stages.tier2.completed = true end
        if self.total_abilities >= self.stages.tier3.req then self.stages.tier3.completed = true end

        if ability:GetLevel() == 1 and self.stages.tier1.completed and not self.stages.tier1.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_pianist", tier = 1})
        self.stages.tier1.given = true
        end
        if ability:GetLevel() == 2 and self.stages.tier2.completed and not self.stages.tier2.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_pianist", tier = 2})
        self.stages.tier2.given = true
        end
        if ability:GetLevel() == 3 and self.stages.tier3.completed and not self.stages.tier3.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_pianist", tier = 3})
        self.stages.tier3.given = true
        end
        
    end
end


modifier_arsen_achievements_businessman = class({})

function modifier_arsen_achievements_businessman:IsHidden() return true end
function modifier_arsen_achievements_businessman:IsPurgable() return false end

function modifier_arsen_achievements_businessman:OnCreated()
    self.stages = {
        tier1 = {
            completed = false,
            given = false,
            req = 5000,
            progress = 0
        },
        tier2 = {
            completed = false,
            given = false,
            req = 7500,
            progress = 0
        },
        tier3 = {
            completed = false,
            given = false,
            req = 10000,
            progress = 0
        }
    }

    self:StartIntervalThink(1.0)
end


function modifier_arsen_achievements_businessman:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local ability = self:GetAbility()
    local gold = caster:GetGold()

    if gold >= self.stages.tier1.req then self.stages.tier1.completed = true end
    if gold >= self.stages.tier2.req then self.stages.tier2.completed = true end
    if gold >= self.stages.tier3.req then self.stages.tier3.completed = true end

    if ability:GetLevel() == 1 and self.stages.tier1.completed and not self.stages.tier1.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_businessman", tier = 1})
        self.stages.tier1.given = true
    end
    if ability:GetLevel() == 2 and self.stages.tier2.completed and not self.stages.tier2.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_businessman", tier = 2})
        self.stages.tier2.given = true
    end
    if ability:GetLevel() == 3 and self.stages.tier3.completed and not self.stages.tier3.given then
        self.stages.tier3.given = true
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_businessman", tier = 3})
        self:StartIntervalThink(-1)
    end
end


modifier_arsen_achievements_outbid = class({})

function modifier_arsen_achievements_outbid:IsHidden() return true end
function modifier_arsen_achievements_outbid:IsPurgable() return false end

--function modifier_arsen_achievements_outbid:OnCreated()
--    self.stages = {
--        tier1 = {
--            completed = false,
--            given = false,
--            req = 0,
--            progress = 0
--        },
--        tier2 = {
--            completed = false,
--            given = false,
--            req = 0,
--            progress = 0
--        },
--        tier3 = {
--            completed = false,
--            given = false,
--            req = 0,
--            progress = 0
--        }
--    }
--end
--
--function modifier_arsen_achievements_outbid:DeclareFunctions()
--    return {
--
--    }
--end
--
--function modifier_arsen_achievements_outbid:()
--
--end


modifier_arsen_achievements_buyback = class({})

function modifier_arsen_achievements_buyback:IsHidden() return true end
function modifier_arsen_achievements_buyback:IsPurgable() return false end

function modifier_arsen_achievements_buyback:OnCreated()
    self.stages = {
        tier1 = {
            completed = false,
            given = false,
            req = 0,
            progress = 0
        },

    }
end

function modifier_arsen_achievements_buyback:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_arsen_achievements_buyback:OnDeath(event)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local attacker = event.attacker
    local unit = event.unit

    if attacker == caster then
        --caster:AddNewModifier(caster, ability, "modifier_arsen_achievements_buyback_2", {duration = 4})
    end
end


modifier_arsen_achievements_buyback_2 = class({})

function modifier_arsen_achievements_buyback_2:DeclareFunctions()
    return {}
end

modifier_arsen_achievements_villain = class({})

function modifier_arsen_achievements_villain:IsHidden() return true end
function modifier_arsen_achievements_villain:IsPurgable() return false end

function modifier_arsen_achievements_villain:OnCreated()
    self.stages = {
        tier1 = {
            completed = false,
            given = false
        }
    }

    self:StartIntervalThink(5.0)
end

function modifier_arsen_achievements_villain:OnIntervalThink()
    if not IsServer() then return end
    local ability = self:GetAbility()
    if ability:GetLevel() >= 1 and self.stages.tier1.completed and not self.stages.tier1.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_villain", tier = 1})
        self.stages.tier1.given = true 
    end
end

function modifier_arsen_achievements_villain:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_arsen_achievements_villain:OnDeath(event)
    if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local ability = self:GetAbility()
    local attacker = event.attacker
    local unit = event.unit

    if attacker == caster and unit:GetUnitName() == "npc_dota_custom_tower_main" then
        self.stages.tier1.completed = true

        self:OnIntervalThink()
    end
end


modifier_arsen_achievements_arseniy = class({})

function modifier_arsen_achievements_arseniy:IsHidden() return true end
function modifier_arsen_achievements_arseniy:IsPurgable() return false end

function modifier_arsen_achievements_arseniy:OnCreated()
    self.stages = {
        tier1 = {
            completed = false,
            given = false,
            progress = 0
        }
    }

    self:StartIntervalThink(1.1)
end

function modifier_arsen_achievements_arseniy:OnIntervalThink()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()

    local modifiers = {
        "modifier_arsen_achievements_farmer",
        "modifier_arsen_achievements_damagedealer",
        "modifier_arsen_achievements_killer",
        "modifier_arsen_achievements_pianist",
        "modifier_arsen_achievements_businessman",
        "modifier_arsen_achievements_outbid",
        "modifier_arsen_achievements_buyback",
        "modifier_arsen_achievements_villain"
    }

    for i=0, #modifiers - 1 do
        local modif = caster:FindModifierByName(modifiers[i])
        if not modif then return end
        if not stages.tier3.completed then return end
    end

    self.stages.tier1.completed = true

    if ability:GetLevel() >= 1 and self.stages.tier1.completed and not self.stages.tier1.given then
        CustomGameEventManager:Send_ServerToPlayer(player, "arsen_achievement_popup", {name = "arsen_achievement_arseniy", tier = 1})
        self.stages.tier1.given = true
    end

    self:StartIntervalThink(-1)
end