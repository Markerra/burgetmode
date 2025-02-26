require("utils/timers")

LinkLuaModifier("modifier_marker_armlet", "abilities/marker/marker_armlet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_marker_armlet_active", "abilities/marker/marker_armlet", LUA_MODIFIER_MOTION_NONE)


marker_armlet = class({
    IsToggle = true,
})

function marker_armlet:ProcsMagicStick() return false end

function marker_armlet:GetAbilityTextureName()
    if self:GetToggleState() then
        return "marker/marker_armlet_active"
    else
        return "marker/marker_armlet_deactive"
    end
end

function marker_armlet:OnToggle()
    if not IsServer() then return end

    local caster = self:GetCaster()

    self:GetAbilityTextureName()

    if self:GetToggleState() then

        caster:AddNewModifier(caster, self, "modifier_marker_armlet_active", {})

        -- Включаем бонусы к силе и урону
        caster:AddNewModifier(caster, self, "modifier_marker_armlet", {})

        caster:EmitSound("DOTA_Item.Armlet.Activate")

    else
        -- Убираем активный модификатор
        caster:RemoveModifierByName("modifier_marker_armlet_active")
        -- Убираем бонусы к силе и урону
        caster:RemoveModifierByName("modifier_marker_armlet")

        caster:EmitSound("DOTA_Item.Armlet.DeActivate")
    end
end

modifier_marker_armlet = class({})

function modifier_marker_armlet:IsHidden() return true end
function modifier_marker_armlet:IsPurgable() return true end
function modifier_marker_armlet:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_marker_armlet:GetModifierPreAttack_BonusDamage()
    if self:GetAbility():GetToggleState() then
        local bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
        local damage_growth = self:GetAbility():GetSpecialValueFor("damage_growth")
        local damage = bonus_damage + damage_growth * (self:GetCaster():GetLevel() - 1)
        return damage
    end
    return 0
end

function modifier_marker_armlet:GetModifierBonusStats_Strength()
    if self:GetAbility():GetToggleState() then
        local bonus_strength = self:GetAbility():GetSpecialValueFor("bonus_strength")
        local strength_growth = self:GetAbility():GetSpecialValueFor("strength_growth")
        local strength = bonus_strength + strength_growth * (self:GetCaster():GetLevel() - 1)
        return strength
    end
    return 0
end

modifier_marker_armlet_active = class({})

function modifier_marker_armlet_active:IsHidden() return false end
function modifier_marker_armlet_active:IsPurgable() return false end
function modifier_marker_armlet_active:GetEffectName()
    return "particles/items_fx/armlet.vpcf"
end
function modifier_marker_armlet_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_marker_armlet_active:OnCreated()

    --if not self:GetParent():IsAlive() then return end

    self.unholy_bonus_strength  = self:GetAbility():GetSpecialValueFor("bonus_strength")

    -- Adjust caster's health
    local caster = self:GetCaster()
    local strength_growth = self:GetAbility():GetSpecialValueFor("strength_growth")
    local bonus_health    = (self:GetAbility():GetSpecialValueFor("bonus_strength") + strength_growth * (self:GetCaster():GetLevel() - 1)) * 22
    local health_before_activation = caster:GetHealth()
    
    if not IsServer() then return end

    if not self:GetParent():IsIllusion() then
        Timers:CreateTimer(0.001, function()
            caster:Heal(bonus_health, self:GetAbility())
        end)
    end
    
    self:StartIntervalThink(0.1)

end

function modifier_marker_armlet_active:OnIntervalThink()
    if not IsServer() then return end 
    if not self:GetParent():IsAlive() then return end

    local caster             = self:GetCaster()
    local health_loss        = self:GetAbility():GetSpecialValueFor("health_loss")
    local health_loss_growth = self:GetAbility():GetSpecialValueFor("health_loss_growth")
    local total_health_loss  = (caster:GetHealth() * (health_loss * 0.01)) + (health_loss_growth * (caster:GetLevel() - 1))
    local new_health         = math.max( self:GetParent():GetHealth() - total_health_loss * 0.1, 1)
    self:GetParent():SetHealth(new_health) 
end

function modifier_marker_armlet_active:OnDestroy()
    if IsServer() then
        if self:GetCaster():IsAlive() then
            local caster = self:GetCaster()
            local strength_growth = self:GetAbility():GetSpecialValueFor("strength_growth")
            local bonus_health = (self:GetAbility():GetSpecialValueFor("bonus_strength") + strength_growth * (self:GetCaster():GetLevel() - 1)) * 22
            local health_before_deactivation = caster:GetHealthPercent() * (caster:GetMaxHealth() + bonus_health) * 0.01
            caster:SetHealth(math.max(health_before_deactivation - bonus_health, 1))
        end
    end
end

