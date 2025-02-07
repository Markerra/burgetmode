
LinkLuaModifier("modifier_sergopy_hamster", "abilities/sergopy/sergopy_hamster", LUA_MODIFIER_MOTION_NONE)

sergopy_hamster = class({})

function sergopy_hamster:GetIntrinsicModifierName()
    return "modifier_sergopy_hamster"
end

modifier_sergopy_hamster = class({})

function modifier_sergopy_hamster:IsHidden() return true end
function modifier_sergopy_hamster:IsPurgable() return false end
function modifier_sergopy_hamster:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_sergopy_hamster:OnAbilityExecuted(keys)
    if self:GetCaster():PassivesDisabled() then return end
    
    if not IsServer() then return end

    local caster  = self:GetCaster()
    local chance  = self:GetAbility():GetSpecialValueFor("chance")
    local parent  = self:GetParent()
    local ability = keys.ability
    local unit    = keys.unit

    if unit and unit:GetTeam() ~= caster:GetTeam() and ability and not ability:IsPassive() and ability:IsFullyCastable() then

        local radius = self:GetAbility():GetSpecialValueFor("radius")

        if (caster:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D() <= radius then

            if RollPercentage(chance) then

                for abilitySlot = 0, caster:GetAbilityCount() - 1 do

                    local casterAbility = caster:GetAbilityByIndex(abilitySlot)

                    if casterAbility and not casterAbility:IsPassive() then
                        casterAbility:EndCooldown()
                    end

                end

                local shard  = caster:HasModifier("modifier_item_aghanims_shard")

                if shard then 
                    local mana = self:GetAbility():GetSpecialValueFor("mana_restore")
                    print(mana.." mana restored")
                    SendOverheadEventMessage(nil, 11, caster, mana, nil)
                    caster:GiveMana(mana)
                end

                -- партикл рефрешера
                local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher_c.vpcf", 13, parent)
                ParticleManager:ReleaseParticleIndex(particle)
                parent:EmitSound("DOTA_Item.Refresher.Activate")

            end
        end
    end
end
