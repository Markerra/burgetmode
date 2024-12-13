LinkLuaModifier( "th_modifier_seva_phone", "abilities/seva/seva_phone", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "db_modifier_seva_phone", "abilities/seva/seva_phone", LUA_MODIFIER_MOTION_NONE )

function HasTalent(unit, talent_name)
    local talent = unit:FindAbilityByName(talent_name)
    if talent and talent:GetLevel() > 0 then
        return true
    end
    return false
end

seva_phone = {}

function seva_phone:GetIntrinsicModifierName()
    return "modifier_seva_phone"
end

function seva_phone:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function seva_phone:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local point = self:GetCursorPosition() 

    CreateModifierThinker(caster, self, "th_modifier_seva_phone", {duration = duration}, point, caster:GetTeamNumber(), false)
end

-----------------------------------------------------------------

th_modifier_seva_phone = {}
db_modifier_seva_phone = {}

function th_modifier_seva_phone:OnCreated()
    local radius   = self:GetAbility():GetSpecialValueFor("radius")
    if not IsServer() then return end
    self:StartIntervalThink(1)
    self.effect_cast = ParticleManager:CreateParticle("particles/econ/items/riki/riki_head_ti8/riki_smokebomb_ti8_crimson_smoke_ground.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetOrigin()) 
    ParticleManager:SetParticleControl(self.effect_cast, 1, Vector( radius, radius, radius))
end

function th_modifier_seva_phone:OnDestroy()
    ParticleManager:DestroyParticle(self.effect_cast, false) 
end

function db_modifier_seva_phone:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end
function db_modifier_seva_phone:GetModifierMoveSpeedBonus_Constant()
    return -300
end

function db_modifier_seva_phone:IsHidden()
    return true
end

-----------------------------------------------------------------

function th_modifier_seva_phone:OnIntervalThink()
    local caster    =   self:GetCaster()
    local parent    =   self:GetParent()
    local radius    =   self:GetAbility():GetSpecialValueFor("radius")
    local dmg       =   self:GetAbility():GetSpecialValueFor("pure_damage")
    local mduration =   self:GetAbility():GetSpecialValueFor("mute_duration")
    local enemies   =   FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 1, 8192, 0, false)
    for _,value in ipairs(enemies) do
        if HasTalent(caster, "special_bonus_unique_seva_phone_silence") then
            value:AddNewModifier(caster, self:GetAbility(), "modifier_silence", {duration = mduration})
        end
        value:AddNewModifier(caster, self:GetAbility(), "modifier_muted", {duration = mduration})
        value:AddNewModifier(caster, self:GetAbility(), "db_modifier_seva_phone", {duration = mduration})
        ApplyDamage({
            victim = value,
            attacker = caster,
            damage = dmg,
            damage_type = DAMAGE_TYPE_PURE,
            ability = self:GetAbility()   
        })
    end

end