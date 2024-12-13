LinkLuaModifier("modifier_maxim_creep_aura", "abilities/maxim/maxim_creep", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maxim_creep_aura_effect", "abilities/maxim/maxim_creep", LUA_MODIFIER_MOTION_NONE)

summon_maxim_creep = class({})

function summon_maxim_creep:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    -- Призыв крипа
    local creep = CreateUnitByName("npc_dota_maxim_creep", point, true, caster, caster, caster:GetTeamNumber())
    creep:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

    -- Задаем параметры крипа
    local base_damage = caster:GetBaseDamageMin()
    creep:SetBaseDamageMin(base_damage * 0.5)
    creep:SetBaseDamageMax(base_damage * 0.5)
    creep:SetBaseHealthRegen(0)
    creep:SetPhysicalArmorBaseValue(5)
    creep:SetMaxHealth(330)
    creep:SetHealth(330)
    creep:SetMana(0)

    -- Добавляем пассивную способность
    creep:AddNewModifier(creep, self, "modifier_maxim_creep_aura", {})
end

modifier_maxim_creep_aura = class({})

function modifier_maxim_creep_aura:IsAura() return true end
function modifier_maxim_creep_aura:IsHidden() return true end
function modifier_maxim_creep_aura:IsPurgable() return false end
function modifier_maxim_creep_aura:GetAuraRadius() return 800 end
function modifier_maxim_creep_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_maxim_creep_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_maxim_creep_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_maxim_creep_aura:GetModifierAura() return "modifier_maxim_creep_aura_effect" end

modifier_maxim_creep_aura_effect = class({})

function modifier_maxim_creep_aura_effect:IsHidden() return false end
function modifier_maxim_creep_aura_effect:IsDebuff() return true end
function modifier_maxim_creep_aura_effect:IsPurgable() return true end

function modifier_maxim_creep_aura_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_maxim_creep_aura_effect:GetModifierPhysicalArmorBonus()
    return -3 -- Снижение брони
end
