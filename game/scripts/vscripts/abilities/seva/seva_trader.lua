LinkLuaModifier( "modifier_seva_trader", "abilities/seva/seva_trader", LUA_MODIFIER_MOTION_NONE )

seva_trader = {}

function seva_trader:GetIntrinsicModifierName()
    return "modifier_doom_bringer_devils_bargain"
end

function seva_trader:OnUpgrade()
    local caster = self:GetCaster()
    modif = caster:FindModifierByName("modifier_seva_trader")
    if modif then
        caster:RemoveModifierByName("modifier_seva_trader")
    end
    caster:AddNewModifier(caster, self, "modifier_seva_trader", {})
end

modifier_seva_trader = {}

function modifier_seva_trader:IsPurgable()
    return false
end

function modifier_seva_trader:IsHidden()
    return true
end

function modifier_seva_trader:OnCreated()
    self:StartIntervalThink(1)
end

function modifier_seva_trader:OnIntervalThink()
    if not IsServer() then return end
    local parent = self:GetParent()

    for slot = 0, 5 do
        local item = parent:GetItemInSlot(slot)
        if item then
            local original_cost = item:GetCost()
            item._original_cost = original_cost
            print(item)
            function item:GetCost()
                return 0
            end

        end
    end

    return 1
end