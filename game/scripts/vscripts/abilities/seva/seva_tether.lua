require("utils/timers")

LinkLuaModifier("modifier_seva_tether", "abilities/seva/seva_tether", LUA_MODIFIER_MOTION_NONE)

seva_tether = {}

function seva_tether:OnSpellStart()
    local caster   = self:GetCaster()
    local target   = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local lvl      = self:GetLevel()
    ability_target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then return end

    if not self:GetCaster():HasModifier("seva_ult_modif") then
        if lvl == 1 then
            EmitSoundOn("seva_tether_cast1", caster)
        elseif lvl == 2 then 
            EmitSoundOn("seva_tether_cast2", caster)
        elseif lvl == 3 then
            EmitSoundOn("seva_tether_cast3", caster)
        elseif lvl == 4 then
            EmitSoundOn("seva_tether_cast4", caster)
        end
    end

    Timers:CreateTimer(0.05, function()
        EmitSoundOn("DOTA_Item.BlinkDagger.Activate", caster)
        caster:AddNewModifier(target, self, "modifier_seva_tether", {target_entindex = target:entindex(), duration = duration})
        Timers:CreateTimer(0.01, function()
            target:AddNewModifier(caster, self, "modifier_seva_tether", {target_entindex = caster:entindex(), duration = duration})
        end
        )
    end
    )
    

    

end

-----------------------------------------------------------------------------------
-- модификатор привязки
-----------------------------------------------------------------------------------

modifier_seva_tether = {}

function modifier_seva_tether:GetEffectName() return "particles/econ/items/wisp/wisp_tether_ti7.vpcf" end
function modifier_seva_tether:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_seva_tether:IsPurgable() return true end
function modifier_seva_tether:OnTooltip() return 1 end
--function modifier_seva_tether:RemoveOnDeath() return true end

function modifier_seva_tether:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_seva_tether:OnCreated(params)
    if not IsServer() then return end
    self.target = EntIndexToHScript(params.target_entindex)
    self.tether_distance = self:GetAbility():GetSpecialValueFor("distance")

    if self.target:IsDebuffImmune() then return end
    self.particle = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_tether_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetAbility():GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle, 1, self.target, PATTACH_POINT_FOLLOW, "follow_origin", self.target:GetAbsOrigin(), false)
    self:StartIntervalThink(0.01)
end

function modifier_seva_tether:OnDestroy()
    if not IsServer() then return end

    -- explosion on death

    --local dmg           = self:GetAbility():GetSpecialValueFor("exp_damage")
    --local radius        = self:GetAbility():GetSpecialValueFor("radius")
    --local caster        = self:GetAbility():GetCaster()
    --local enemies       = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 1 + 18, 0, 0, false)
    --for _,value in ipairs(enemies) do
    --    print(value:GetUnitName())
    --    ApplyDamage({
    --        victim = value,
    --        attacker = caster,
    --        damage = dmg,
    --        damage_type = DAMAGE_TYPE_MAGICAL,
    --        ability = self:GetAbility() 
    --    })
    --end
    --EmitSoundOn("seva_exp", self.target)
    --local particle_exp  = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf"
    --local explosion     = ParticleManager:CreateParticle(particle_exp, PATTACH_WORLDORIGIN, self:GetParent())
    --local center        = (self:GetAbility():GetCaster():GetAbsOrigin() + self.target:GetAbsOrigin()) / 2
    --ParticleManager:SetParticleControl(explosion, 3, center)
    ParticleManager:DestroyParticle(self.particle, false)
end

function modifier_seva_tether:OnDeath(params)
    if params.unit == ability_target then -- если цель способности умерла
        self:GetAbility():GetCaster():RemoveModifierByName("modifier_seva_tether")
        self:SetStackCount(0)
        local current_stacks = self:GetStackCount()
        self:SetStackCount(current_stacks + 1)
    end
end

function modifier_seva_tether:OnIntervalThink()
    if not IsServer() then return end

    
    local distance = (self:GetParent():GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
    if distance > self.tether_distance then
        self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin() + (self.target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized() * (distance - self.tether_distance))
    end
end

function modifier_seva_tether:OnTakeDamage(params)
    if not IsServer() then return end

    if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= 0 then
        return
    end

    local damage_amp = self:GetAbility():GetSpecialValueFor("dmg_percent") / 100

    if params.unit == ability_target then -- если цель способности получила урон
        print(params.unit:GetUnitName().." получил "..params.damage.." урона")
        ApplyDamage({
            victim = self:GetCaster(),
            attacker = params.unit,
            damage = params.damage * damage_amp,
            damage_type = params.damage_type,
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
            ability = self:GetAbility(),
            })
    elseif params.unit == self:GetCaster() then -- если кастер способности получил урон
        ApplyDamage({
            victim = ability_target,
            attacker = self:GetCaster(),
            damage = params.damage * damage_amp,
            damage_type = params.damage_type,
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
            ability = self:GetAbility(),
            })
        print(params.unit:GetUnitName().." получил "..params.damage.." урона")
    end
end

function modifier_seva_tether:CheckState()
    local state = {}
    if not self:GetParent():IsDebuffImmune() then
        state[MODIFIER_STATE_TETHERED] = true
    end
    return state
end

