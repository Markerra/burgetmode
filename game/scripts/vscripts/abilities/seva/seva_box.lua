seva_box = {}

function seva_box:Roll()
    -- Получение уровня способности
    local caster = self:GetCaster()
    local cgld = self:GetSpecialValueFor("c1")
    local cstr = self:GetSpecialValueFor("c2")
    local clvl = self:GetSpecialValueFor("c3")
    local cnug = self:GetSpecialValueFor("c4")
    local clvl7 = self:GetSpecialValueFor("c5")
    local cpot = self:GetSpecialValueFor("c6")

    -- Таблица вероятностей
    local chances = {
        gold = cgld,
        strength = cstr,
        level = clvl,
        mega_nuggets = cnug,
        levels_7 = clvl7,
        ultra_potato = cpot
    }

    -- Вычисляем общее значение вероятностей
    local total_chance = chances.gold +
                         chances.strength +
                         chances.level +
                         --chances.mega_nuggets +
                         chances.levels_7-- +
                         --chances.ultra_potato

    -- Случайное число
    local roll = RandomFloat(0, total_chance)
    local accumulated = 0
    -- 1. Золото
    accumulated = accumulated + chances.gold
    if roll <= accumulated then
        local particle = "particles/econ/events/ti9/shovel_revealed_loot_variant_0_treasure.vpcf"
        local overhead_particle = ParticleManager:CreateParticle(particle, 8, caster)
        local offset = Vector(100, 100, 0)
        caster:ModifyGold(30, true, DOTA_ModifyGold_Unspecified)
        SendOverheadEventMessage(nil, 0, caster, 30, nil)
        ParticleManager:SetParticleControl(overhead_particle, 0, caster:GetAbsOrigin() + offset)
        ParticleManager:ReleaseParticleIndex(overhead_particle)
        --print("Получено 30 золота!")
        return
    end

    -- 2. Сила
    accumulated = accumulated + chances.strength
    if roll <= accumulated then
        local particle = "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf"
        local overhead_particle = ParticleManager:CreateParticle(particle, 0, caster)
        caster:ModifyStrength(10)
        ParticleManager:SetParticleControl(overhead_particle, 0, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(overhead_particle)
        caster:EmitSound("DOTA_Item.Armlet.Activate")
        --print("Получено 10 силы!")
        return
    end

    -- 3. 1 уровень
    accumulated = accumulated + chances.level
    if roll <= accumulated then
        caster:HeroLevelUp(true)
        --print("Получен 1 уровень!")
        return
    end

    -- 4. Мега-Нагетс
    --accumulated = accumulated + chances.mega_nuggets
    --if roll <= accumulated then
    --    EmitSoundOn("Item.PickUpGemShop", caster)
    --    print("Получен Мега-Нагетс!")
    --    return
    --end

    -- 5. 7 уровней
    accumulated = accumulated + chances.levels_7
    if roll <= accumulated then
        for i = 1, 7 do
            caster:HeroLevelUp(true)
        end
        --print("Получено 7 уровней!")
        return
    end

    -- 6. Ультра-Картошка
    --accumulated = accumulated + chances.ultra_potato
    --if roll <= accumulated then
    --    EmitSoundOn("Item.PickUpGemShop", caster)
    --    print("Получена Ультра-Картошка!")
    --    return
    --end
end

function seva_box:OnSpellStart()
    self:Roll() 
end
