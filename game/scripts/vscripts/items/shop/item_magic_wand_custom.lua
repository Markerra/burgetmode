LinkLuaModifier("item_magic_wand_custom_modifier", "items/shop/item_magic_wand_custom", LUA_MODIFIER_MOTION_NONE)

item_magic_wand_custom = class({})

function item_magic_wand_custom:GetIntrinsicModifierName()
	return "item_magic_wand_custom_modifier"
end

function item_magic_wand_custom:OnSpellStart()
	local caster = self:GetCaster()

	local particle_cast = "particles/items2_fx/magic_stick.vpcf"

	-- Parameters
	local restore_per_charge = self:GetSpecialValueFor("restore_per_charge")

	-- Fetch current charges
	local current_charges = self:GetCurrentCharges()

	-- Play sound
	caster:EmitSound("DOTA_Item.MagicWand.Activate")

	-- Play particle
	local stick_pfx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(stick_pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(stick_pfx, 1, Vector(10,0,0))
	-- Restore health and mana to the caster
	caster:Heal(current_charges * restore_per_charge, self)
	caster:GiveMana(current_charges * restore_per_charge)

	-- Set remaining charges to zero
	self:SetCurrentCharges(0)
end

item_magic_wand_custom_modifier = class({})

function item_magic_wand_custom_modifier:IsPurgable() return false end
function item_magic_wand_custom_modifier:IsDebuff() return false end
function item_magic_wand_custom_modifier:IsHidden() return true end

function item_magic_wand_custom_modifier:OnCreated()
	local interval = self:GetAbility():GetSpecialValueFor("charge_interval")
	self:StartIntervalThink(interval)
end

-- бесплатный заряд
function item_magic_wand_custom_modifier:OnIntervalThink()
	if IsServer() then
		local currentCharges = self:GetAbility():GetCurrentCharges()
		local max 			 = self:GetAbility():GetSpecialValueFor("max_charges")
    	self:GetAbility():SetCurrentCharges(math.min(currentCharges + 1, max))
    end
end

function item_magic_wand_custom_modifier:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

-- заряд за каждый прожатый скил в радиусе
function item_magic_wand_custom_modifier:OnAbilityExecuted(params)
	if IsServer() then
        local caster = self:GetParent()
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        local max    = self:GetAbility():GetSpecialValueFor("max_charges")

        if not params.ability or params.ability:GetCooldown(-1) <= 0 or params.ability:GetCaster() == caster or not params.ability:ProcsMagicStick() or params.ability:IsItem() then return end

        if params.unit:GetTeam() ~= caster:GetTeam() and (params.unit:GetOrigin() - caster:GetOrigin()):Length2D() <= radius then
            local currentCharges = self:GetAbility():GetCurrentCharges()
            self:GetAbility():SetCurrentCharges(math.min(currentCharges + 1, max))
        end
    end
end