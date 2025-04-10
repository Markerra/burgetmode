LinkLuaModifier("modifier_item_maxim_relevation", "items/maxim/item_maxim_relevation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_maxim_relevation_free_movement", "items/maxim/item_maxim_relevation", LUA_MODIFIER_MOTION_NONE)

item_maxim_relevation = {}

function item_maxim_relevation:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()

	--if not caster:HasAbility("maxim_isaac") then return end

	bat = self:GetSpecialValueFor("new_bat")
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_item_maxim_relevation", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_item_maxim_relevation_free_movement", {duration = duration})
	caster:EmitSound("item_maxim_relevation_cast")

	local removed_item = caster:TakeItem(self)
	if removed_item then
        UTIL_Remove(removed_item)
    end

end

modifier_item_maxim_relevation = {}

function modifier_item_maxim_relevation:GetTexture() return "modifiers/modifier_maxim_relevation" end
function modifier_item_maxim_relevation:IsDebuff()   return false end
function modifier_item_maxim_relevation:IsPurgable() return true end 

function modifier_item_maxim_relevation:OnCreated()
	local offset = Vector(0, 0, 10)
	self.particle = ParticleManager:CreateParticle(
        "particles/econ/courier/courier_babyroshan_ti10/courier_babyroshan_ti10_ambient_flying.vpcf", 
        PATTACH_ABSORIGIN_FOLLOW, 
        self:GetParent()
    )
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin() + offset)
end

function modifier_item_maxim_relevation:OnDestroy()
    ParticleManager:DestroyParticle(self.particle, false)
end

function modifier_item_maxim_relevation:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
end

function modifier_item_maxim_relevation:GetModifierBaseAttackTimeConstant()
	return bat
end

modifier_item_maxim_relevation_free_movement = class({})

function modifier_item_maxim_relevation_free_movement:IsHidden()   return true end
function modifier_item_maxim_relevation_free_movement:IsPurgable() return true end
function modifier_item_maxim_relevation_free_movement:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true, 
        [MODIFIER_STATE_FLYING] = true, 
    }
end