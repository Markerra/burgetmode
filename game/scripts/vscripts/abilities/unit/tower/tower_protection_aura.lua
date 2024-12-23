LinkLuaModifier("modifier_tower_protection_aura", "abilities/unit/tower/modifier_tower_protection_aura", LUA_MODIFIER_MOTION_NONE)

tower_protection_aura = class({})

function tower_protection_aura:GetIntrinsicModifierName()
    return "modifier_tower_protection_aura"
end