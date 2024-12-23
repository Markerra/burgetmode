LinkLuaModifier("modifier_item_jungle_staff", "items/shop/item_jungle_staff", LUA_MODIFIER_MOTION_NONE)

item_jungle_staff = class({})

function item_jungle_staff:GetIntrinsicModifierName() -- доп. урон по крипам
    return "modifier_item_jungle_staff"
end

function item_jungle_staff:OnSpellStart() -- срубание дерева
    local caster = self:GetCaster()
    local target_point = self:GetCursorPosition()

    local trees = GridNav:GetAllTreesAroundPoint(target_point, 10, false)

    if #trees > 0 then
        for _, tree in pairs(trees) do
            -- Срубаем дерево
            tree:CutDown(caster:GetTeamNumber())
        end
    else
        print("No tree found in range.")
    end
end

modifier_item_jungle_staff = class({})

function modifier_item_jungle_staff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_jungle_staff:OnAttackLanded(data)
    local target   = data.target
    local attacker = data.attacker

    local dmg_amp  = self:GetAbility():GetSpecialValueFor("damage_amp")

    local m_damage = self:GetAbility():GetSpecialValueFor("bonus_dmg_melee")
    local r_damage = self:GetAbility():GetSpecialValueFor("bonus_dmg_range")
    if attacker == self:GetParent() then
        if target:IsNeutralUnitType() or target:IsCreep() then

            ApplyDamage({ -- доп урон по крипам
                    victim = target,
                    attacker = attacker,
                    damage = (data.damage / 100) * dmg_amp,
                    damage_type = data.damage_type,
                    ability = self:GetAbility(),
                })
            print("%доп урон: "..(data.damage / 100) * dmg_amp)

            if attacker:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
                ApplyDamage({ -- доп урон для милишников
                    victim = target,
                    attacker = attacker,
                    damage = m_damage,
                    damage_type = data.damage_type,
                    ability = self:GetAbility(),
                })
            print("доп урон милишника: "..m_damage)
            else
                ApplyDamage({ -- доп урон для ренжей
                    victim = target,
                    attacker = attacker,
                    damage = r_damage,
                    damage_type = data.damage_type,
                    ability = self:GetAbility(),
                })
            print("доп урон ренжа: "..r_damage)
            end
        end
    end
end
