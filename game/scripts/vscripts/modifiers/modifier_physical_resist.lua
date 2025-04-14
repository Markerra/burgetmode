modifier_physical_resist = class({})

function modifier_physical_resist:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE
    }
end

function modifier_physical_resist:GetModifierIncomingPhysicalDamage_Percentage()
    return -95
end