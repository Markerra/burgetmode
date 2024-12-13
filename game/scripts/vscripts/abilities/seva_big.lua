require("utils/timers")
LinkLuaModifier( "modifier_seva_big", "abilities/seva/seva_big", LUA_MODIFIER_MOTION_NONE )

seva_big = {}

function seva_big:GetIntrinsicModifierName()
	print("GetIntrinsicModifierName")
	return "modifier_seva_big"
end

------------------------------------------------------

modifier_seva_big = {}

function modifier_seva_big:IsHidden()
	return true
end

function seva_big:OnUpgrade()
    local caster = self:GetCaster()
    local upgradehp = caster:GetMaxHealth()
    local ts = self:GetSpecialValueFor("time_stack") --время
    local hp_per_stack = self:GetSpecialValueFor("hp_per_stack") --хп

    -- удаление таймера
    if caster.ability_timers and caster.ability_timers[self:GetAbilityName()] then
        Timers:RemoveTimer(caster.ability_timers[self:GetAbilityName()])
    end

    -- новый таймер
    caster.ability_timers = caster.ability_timers or {}
    caster.ability_timers[self:GetAbilityName()] = Timers:CreateTimer(1, function()
    	local ms = caster:GetModelScale()
        local current_max_health = caster:GetMaxHealth()

        local new_ms = ms * 1.007
        local new_max_health = current_max_health + hp_per_stack

        caster:SetModelScale(new_ms)
        caster:SetMaxHealth(new_max_health)

        local current_max_health = caster:GetMaxHealth()


        --print("upgradehp = ".. upgradehp)
        --print("макс хп: " .. caster:GetMaxHealth())
        --print("new_max_health: " .. new_max_health)
        --print("хп стак: " .. hp_per_stack)
        return ts
    end)
end

 

------------------------------------------------------
