LinkLuaModifier("seva_ult_modif", "abilities/seva/seva_ult", LUA_MODIFIER_MOTION_NONE)

seva_ult = {}

function seva_ult:OnAbilityPhaseStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    EmitSoundOn("seva_ult_pre", caster)
    EmitSoundOn("onsight_pre", caster)
    
    return true 
end

function seva_ult:OnAbilityPhaseInterrupted()
    if not IsServer() then return end

    local caster = self:GetCaster()
    StopSoundOn("seva_ult_pre", caster)
    StopSoundOn("onsight_pre", caster)
end

function seva_ult:OnSpellStart()

    if not IsServer() then return end

    local caster    =    self:GetCaster()
    local duration  = self:GetSpecialValueFor("duration")
    local model_amp = self:GetSpecialValueFor("modelscale_amp")
    local lvl       = self:GetLevel()
    smodel          = caster:GetModelScale()
    local nmodel    = smodel * model_amp
    caster:AddNewModifier(caster, self, "seva_ult_modif", {duration = duration})
    caster:SetModelScale(nmodel)

    StopSoundOn("seva_tether_cast1", caster)
    StopSoundOn("seva_tether_cast2", caster)
    StopSoundOn("seva_tether_cast3", caster)
    StopSoundOn("seva_tether_cast4", caster)
    EmitSoundOn("seva_ult_cast", caster)

    if lvl == 1 then
        EmitGlobalSound("onsight_cast1")
    elseif lvl == 2 then 
        EmitGlobalSound("onsight_cast2")
    elseif lvl == 3 then
        EmitGlobalSound("onsight_cast3")
    end

    --caster:CreateModifierThinker(caster, self, "seva_ult_modif", {duration = duration}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
end

seva_ult_modif = {}

function seva_ult_modif:IsPurgable() return false end

function seva_ult_modif:OnDestroy()
    StopGlobalSound("onsight_cast1")
    StopGlobalSound("onsight_cast2")
    StopGlobalSound("onsight_cast3")
    local caster = self:GetCaster()
    caster:SetModelScale(smodel)

end

function seva_ult_modif:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function seva_ult_modif:GetModifierHealthBonus()
    local  bhp = self:GetAbility():GetSpecialValueFor("bonus_hp")
    return bhp
end

function seva_ult_modif:GetModifierConstantHealthRegen()
    local  br = self:GetAbility():GetSpecialValueFor("bonus_regen")
    return br
end

function seva_ult_modif:GetModifierPhysicalArmorBonus()
    local  ba = self:GetAbility():GetSpecialValueFor("bonus_armor")
    return ba
end

function seva_ult_modif:GetModifierPreAttack_BonusDamage()
    local hp    = self:GetParent():GetMaxHealth()
    local hpdmg = self:GetAbility():GetSpecialValueFor("hp_to_dmg")
    local dmg   = self:GetParent():GetDamageMax()
    local hpc   = hp / 100
    local bdmg  = hpc * hpdmg
  --print ("bonus damage = "..bdmg)
    return bdmg
end

function seva_ult_modif:GetModifierStatusResistanceStacking()
    local  bb = self:GetAbility():GetSpecialValueFor("bonus_bkb")
    return bb
end


--function seva_ult_modif:OnCreated()
--    local durat = self:GetAbility():GetSpecialValueFor("duration")
--    local chp   = self:GetParent():GetMaxHealth()
--    self:GetParent():SetMaxHealth(chp + bhp)
--    self:GetParent():
--    print (chp.." + "..bhp.." = "..self:GetParent():SetMaxHealth(chp + bhp))
--
--end