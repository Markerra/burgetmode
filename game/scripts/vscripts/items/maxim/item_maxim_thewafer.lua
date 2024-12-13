LinkLuaModifier("the_wafer_modif", "items/maxim/item_maxim_thewafer", LUA_MODIFIER_MOTION_NONE)

item_maxim_thewafer = {}

function item_maxim_thewafer:OnSpellStart()
	if not IsServer() then return end
	if not self:GetCaster():HasAbility("maxim_isaac") then return end
	local duration = self:GetSpecialValueFor("duration")
	local caster   = self:GetCaster()
	dmg_res 	   = self:GetSpecialValueFor("dmg_res")

	caster:AddNewModifier(caster, self, "the_wafer_modif", {duration = duration})

	EmitSoundOn("item_maxim_thewafer_cast", caster)

	local removed_item = caster:TakeItem(self)
	if removed_item then
        UTIL_Remove(removed_item)
    end

end

the_wafer_modif = {}

function the_wafer_modif:GetTexture() return "modifiers/modifier_maxim_thewafer" end
function the_wafer_modif:IsDebuff()   return false end
function the_wafer_modif:IsPurgable() return true end

function the_wafer_modif:OnCreated()
	if not IsServer() then return end
	self.particle = ParticleManager:CreateParticle(
        "particles/econ/events/ti6/mjollnir_shield_ti6.vpcf", 
        PATTACH_ABSORIGIN_FOLLOW, 
        self:GetParent()
    )
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
end

function the_wafer_modif:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.particle, false)
end

function the_wafer_modif:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function the_wafer_modif:GetModifierIncomingDamage_Percentage()
	return -dmg_res
end