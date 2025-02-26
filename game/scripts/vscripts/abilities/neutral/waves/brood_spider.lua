brood_spider = class({})

function brood_spider:OnAbilityPhaseStart()
	EmitSoundOn("SpawnSpiderlingsCast", self:GetCaster())
end

function brood_spider:OnAbilityPhaseInterrupted()
	StopSoundOn("SpawnSpiderlingsCast", self:GetCaster())
end

function brood_spider:OnSpellStart()
	local caster         = self:GetCaster()
    local forward_vector = caster:GetForwardVector()
    local lvl            = self:GetLevel()
    local spawn_distance = 150 
    local spawn_point    = caster:GetAbsOrigin() + forward_vector * spawn_distance
    local duration       = self:GetSpecialValueFor("duration") 

    local units = {
    	"npc_broodmother_spider",
    	"npc_broodmother_spider",
    	"npc_broodmother_spider",
    	"npc_broodmother_spider",
    	"npc_broodmother_spider",
    	"npc_broodmother_spider",
    }

	for i=1, #units do
		if not units then return end
		local creep = CreateUnitByName(units[i], spawn_point, true, caster, caster, caster:GetTeamNumber())
    	creep:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    	creep:AddNewModifier(caster, nil, "modifier_kill", { duration = duration })
    	FindClearSpaceForUnit(creep, point, true)
    	creep:CreatureLevelUp( (creep:GetLevel() - level) * (-1) )
    	EmitSoundOnClient("NeutralStack.Success", caster)
	end
    
    if lvl == 2 then
        creep:CreatureLevelUp(1)
    elseif lvl == 3 then
        creep:CreatureLevelUp(2)
    elseif lvl == 4 then
        creep:CreatureLevelUp(3)
    end

    local particle_path = "particles/econ/items/dazzle/dazzle_ti9/dazzle_shadow_wave_ti9_crimson_impact_damage.vpcf"
    ParticleManager:CreateParticle(particle_path, PATTACH_ABSORIGIN, creep)

    EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", caster)

    local dmg = self:GetSpecialValueFor("dmg")
    local max_hp  = self:GetSpecialValueFor("max_hp")
    local armor   = self:GetSpecialValueFor("creep_armor")

    local base_damage = caster:GetBaseDamageMin()
    creep:SetBaseDamageMin(dmg-RandomInt(3, 5))
    creep:SetBaseDamageMax(dmg+RandomInt(2, 6))
    creep:SetPhysicalArmorBaseValue(armor)
    creep:SetMaxHealth(max_hp)
    creep:SetHealth(max_hp)
end