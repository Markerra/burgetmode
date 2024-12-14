LinkLuaModifier("modifier_maxim_zxc", "abilities/maxim/maxim_zxc", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maxim_zxc_debuff", "abilities/maxim/maxim_zxc", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maxim_animation", "abilities/maxim/maxim_zxc", LUA_MODIFIER_MOTION_NONE)

maxim_zxc = class({})

function maxim_zxc:OnAbilityPhaseStart()
    if not IsServer() then return end

    local caster = self:GetCaster()

    EmitSoundOn("maxim_zxc_pre", caster)
    
    return true 
end

function maxim_zxc:OnAbilityPhaseInterrupted()
    if not IsServer() then return end

    local caster = self:GetCaster()
    StopSoundOn("maxim_zxc_pre", caster)
end

function maxim_zxc:GetChannelAnimation() return ACT_DOTA_TAUNT end

function maxim_zxc:OnSpellStart()
    local caster = self:GetCaster()
    local shard  = caster:HasModifier("modifier_item_aghanims_shard")
    caster:AddNewModifier(caster, self, "modifier_maxim_zxc", {duration = self:GetChannelTime()})
    caster:AddNewModifier(caster, self, "modifier_maxim_animation", {duration = self:GetChannelTime() + 0.1})
	caster:AddActivityModifier("swag_gesture")
	ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_wings_grow_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	if shard then
		caster:AddNewModifier(caster, self, "modifier_black_king_bar_immune", {duration = self:GetChannelTime()})
	end
    EmitSoundOn("maxim_zxc_cast", caster)
end

function maxim_zxc:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()
    caster:FadeGesture(ACT_DOTA_TAUNT)
    if caster:HasModifier("modifier_maxim_zxc") then
        caster:RemoveModifierByName("modifier_maxim_zxc")
    end
end

modifier_maxim_zxc = class({})

function modifier_maxim_zxc:IsHidden() 	 return true end
function modifier_maxim_zxc:IsDebuff()   return false end
function modifier_maxim_zxc:IsPurgable() return false end

function modifier_maxim_zxc:OnCreated()
    if not IsServer() then return end

    self.ability  = self:GetAbility()
    self.caster   = self:GetCaster()
    self.interval = self.ability:GetSpecialValueFor("interval")
    self.dmg_raze = self.ability:GetSpecialValueFor("dmg_raze")
    self.radius   = self.ability:GetSpecialValueFor("radius")
    self.damage   = self.ability:GetSpecialValueFor("damage")
    self:StartIntervalThink(self.interval)
end

function modifier_maxim_zxc:OnIntervalThink()
	self:ShadowRaze(RandomFloat(-100, 100), RandomFloat(0, 360))
end

function modifier_maxim_zxc:ShadowRaze(radius_offset, angle_offset)
	if not IsServer() then return end


	local caster  = self:GetCaster()
	local ability = self:GetAbility()
	local radius  = self.radius + (radius_offset or 0)
	local damage  = self.damage

	local angle    = angle_offset or 0
	local position = caster:GetAbsOrigin() + Vector(math.cos(angle), math.sin(angle), 0) * radius

	local stacks   = self:GetStackCount()

	local particle = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, position)
	ParticleManager:ReleaseParticleIndex(particle)
	EmitSoundOn("Hero_Nevermore.ShadowRaze", caster)
	
	local enemies = FindUnitsInRadius(
	    caster:GetTeamNumber(),
	    position,
	    nil,
	    radius,
	    DOTA_UNIT_TARGET_TEAM_ENEMY,
	    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    DOTA_UNIT_TARGET_FLAG_NONE,
	    FIND_ANY_ORDER,
	    false
	)
	
	for _, enemy in pairs(enemies) do
		if enemy:IsDebuffImmune() == true then
			ApplyDamage({
	        victim = enemy,
	        attacker = caster,
	        damage = damage,
	        damage_type = DAMAGE_TYPE_MAGICAL,
	        ability = ability
	    })
		else
			if not enemy:HasModifier("modifier_maxim_zxc_debuff") then
				enemy:AddNewModifier(caster, ability, "modifier_maxim_zxc_debuff", {duration = self:GetAbility():GetChannelTime()})
			end
			ApplyDamage({
	        victim = enemy,
	        attacker = caster,
	        damage = damage + (stacks*self.dmg_raze),
	        damage_type = DAMAGE_TYPE_MAGICAL,
	        ability = ability
	    })
			if enemy:IsAlive() then
				enemy:FindModifierByName("modifier_maxim_zxc_debuff"):IncrementStackCount()
			end
		end
	    
	    self:IncrementStackCount()
	    local sf_fire_hit = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_ember.vpcf"
	    local sf_fire = ParticleManager:CreateParticle(sf_fire_hit, PATTACH_ABSORIGIN_FOLLOW, caster)
	    		ParticleManager:SetParticleControl(sf_fire, 0, caster:GetAbsOrigin())
	    print("стаки: "..stacks)
	    print("доп урон: "..stacks*self.dmg_raze)
	    
	    if caster:HasScepter() then
	    	local raze_amout  = 10
	    	
	    	if stacks == 1 then
	    		local sf_fire2 = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_double.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    		ParticleManager:SetParticleControl(sf_fire2, 0, caster:GetAbsOrigin())
	    		EmitSoundOn("maxim_zxc_raze_double", caster)
	    	end

	    	if stacks == 2 then
	    		for i=360-raze_amout,360 do
	    			self:ShadowRaze(0, i)
	    		end
	    		local sf_fire3 = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_triple.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    		ParticleManager:SetParticleControl(sf_fire3, 0, caster:GetAbsOrigin())
	    		EmitSoundOn("maxim_zxc_raze_triple", caster)
	    		
	    	end
	    end
	end
end

function modifier_maxim_zxc:OnDestroy()
    if not IsServer() then return end
    local caster = self:GetCaster()
    caster:FadeGesture(ACT_DOTA_TAUNT)
    caster:RemoveModifierByName("modifier_maxim_animation")
    caster:RemoveModifierByName("modifier_black_king_bar_immune")
end

modifier_maxim_zxc_debuff = {}

function modifier_maxim_zxc_debuff:IsHidden()   return false end
function modifier_maxim_zxc_debuff:IsDebuff()   return true end
function modifier_maxim_zxc_debuff:IsPurgable() return false end
function modifier_maxim_zxc_debuff:GetTexture() return "modifiers/modifier_maxim_zxc" end

modifier_maxim_animation = {}

function modifier_maxim_animation:IsHidden()   return true end
function modifier_maxim_animation:IsDebuff()   return false end
function modifier_maxim_animation:IsPurgable() return false end
function modifier_maxim_animation:OnCreated()
	self:StartIntervalThink(2.7)
end

function modifier_maxim_animation:OnIntervalThink()
	local caster = self:GetAbility():GetCaster()
	caster:FadeGesture(ACT_DOTA_TAUNT)
	if not caster:HasModifier("modifier_maxim_zxc") then return end
	caster:StartGesture(ACT_DOTA_TAUNT)
end