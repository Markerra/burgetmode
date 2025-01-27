require("utils/timers")

LinkLuaModifier("modifier_sergopy_refresh", "abilities/sergopy/sergopy_refresh", LUA_MODIFIER_MOTION_NONE)

sergopy_refresh = class({})

function sergopy_refresh:GetIntrinsicModifierName()
    return "modifier_sergopy_refresh"
end

-- Modifier: Sergopy Refresh
modifier_sergopy_refresh = class({})

function modifier_sergopy_refresh:IsHidden() return true end
function modifier_sergopy_refresh:IsPurgable() return false end
function modifier_sergopy_refresh:IsDebuff() return false end

function modifier_sergopy_refresh:OnCreated()
    if not IsServer() then return end

    self.cast_count = 0
end

function modifier_sergopy_refresh:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_sergopy_refresh:OnAbilityExecuted(params)
    if self:GetCaster():PassivesDisabled() then return end

    if not IsServer() then return end

    if params.unit == self:GetParent() then

        local ability = params.ability
        local chance  = self:GetAbility():GetSpecialValueFor("chance")
        local aghanim_chance = self:GetAbility():GetSpecialValueFor("aghanim_chance")

        if not ability or ability:IsItem() or ability:GetCooldown(-1) <= 0 then
            return
        end

        local parent = self:GetParent()
        self.success = false
        self.success2 = false

        if RollPercentage(chance) then
            Timers:CreateTimer(0.02, function()
                for i = 0, parent:GetAbilityCount() - 1 do
                    local ability = parent:GetAbilityByIndex(i)
                    if ability and ability:GetCooldown(-1) > 0 then
                        ability:EndCooldown()
                    end
                end

                -- партикл рефрешера
                local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher_b.vpcf", 13, parent)
                ParticleManager:ReleaseParticleIndex(particle)
                parent:EmitSound("DOTA_Item.Refresher.Activate")
            end)
        end

        if parent:HasScepter() then
            if RollPercentage(aghanim_chance) then
                for i = 0, 5 do -- Iterate over inventory slots
                    local item = parent:GetItemInSlot(i)
                    if item and item:GetCooldown(-1) > 0 then
                        item:EndCooldown() -- Refresh the item cooldown
                    end
                end

                -- партикл рефрешера
                local particle2 = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", 13, parent)
                ParticleManager:ReleaseParticleIndex(particle2)
                parent:EmitSound("DOTA_Item.Refresher.Activate")
            end
        end

    end
end
