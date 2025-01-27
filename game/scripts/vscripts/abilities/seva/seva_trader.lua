LinkLuaModifier( "th_modifier_seva_trader", "abilities/seva/seva_trader", LUA_MODIFIER_MOTION_NONE )

seva_trader = {}

function seva_trader:OnUpgrade()
    local caster = self:GetCaster()
    modif = caster:FindModifierByName("th_modifier_seva_trader")
    if modif then
        caster:RemoveModifierByName("th_modifier_seva_trader")
    end
    caster:AddNewModifier(caster, self, "th_modifier_seva_trader", {})
	--CreateModifierThinker(caster, self, "th_modifier_seva_trader", {duration = 1}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
end

th_modifier_seva_trader = {}

function th_modifier_seva_trader:IsPurgable()
    return false
end

function th_modifier_seva_trader:IsHidden()
    return true
end

function th_modifier_seva_trader:OnCreated()
    if not IsServer() then return end
    local time_stack = self:GetAbility():GetSpecialValueFor("time_stack")
    self:StartIntervalThink(time_stack)
end

function th_modifier_seva_trader:OnIntervalThink()
    if self:GetCaster():PassivesDisabled() then return end
    if not IsServer() then return end
    local parent = self:GetParent()
    local gpm = self:GetAbility():GetSpecialValueFor("gold_per_stack")
    parent:ModifyGold(gpm, false, DOTA_ModifyGold_GameTick)
	return 
end


 

------------------------------------------------------
