LinkLuaModifier("modifier_shopkeeper_glyph", "abilities/neutral/shopkeeper/shopkeeper_glyph", LUA_MODIFIER_MOTION_NONE)

shopkeeper_glyph = class({})

require('utils/funcs')

function shopkeeper_glyph:Spawn()
    local caster = self:GetCaster()
    self.glyph_lvl = 0
end

function shopkeeper_glyph:GetCooldown(iLevel)
    local caster = self:GetCaster()
    local cd_increase = self:GetSpecialValueFor("cooldown_increase")
    local cooldown = self:GetSpecialValueFor("cooldown") + (self.glyph_lvl * cd_increase)
    
    return cooldown
end

function shopkeeper_glyph:OnSpellStart()
    local caster = self:GetCaster()
    local team = caster:GetTeam()

    local duration = self:GetSpecialValueFor("duration")

    local fx = "particles/econ/world/towers/ti10_radiant_tower/ti10_radiant_tower_destruction_sparkle.vpcf"

	local tower_main = GetTowerByTeam(caster:GetTeamNumber(), true)
    tower_main:AddNewModifier(caster, self, "modifier_shopkeeper_glyph", {duration = duration})

    local particle_main = ParticleManager:CreateParticle(fx, PATTACH_WORLDORIGIN, tower_main)
    ParticleManager:SetParticleControl(particle_main, 0, tower_main:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_main)

    local tower_1 = GetTowerByTeam(caster:GetTeamNumber(), false)
    tower_1:AddNewModifier(caster, self, "modifier_shopkeeper_glyph", {duration = duration})

    local particle_1 = ParticleManager:CreateParticle(fx, PATTACH_WORLDORIGIN, tower_1)
    ParticleManager:SetParticleControl(particle_1, 0, tower_1:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_1)

    self.glyph_lvl = self.glyph_lvl + 1
end

modifier_shopkeeper_glyph = class({})

function modifier_shopkeeper_glyph:CheckState()
    return {
    	[MODIFIER_STATE_INVULNERABLE] = true
    }
end

function modifier_shopkeeper_glyph:OnCreated()
    local parent = self:GetParent()
    local fx = "particles/tower_fx/shopkeeper_tower_glyph.vpcf"
    self.particle = ParticleManager:CreateParticle(fx, PATTACH_WORLDORIGIN, parent)
    ParticleManager:SetParticleControl(self.particle, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle, 3, Vector(400, 0, 0))
end

function modifier_shopkeeper_glyph:OnDestroy()
    if not IsServer then return end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end