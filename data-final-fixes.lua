---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Inicio del MOD ]---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, Spaces in pairs(This_MOD.to_be_processed) do
        for _, Space in pairs(Spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Actualizar las entidades
            This_MOD.update_entity(Space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Valores de la referencia ]---
---------------------------------------------------------------------------

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar las opciones en setting-final-fixes.lua
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Propiedades a Cambiar
    This_MOD.properties = {
        "energy_usage",               --- Para todas las entidades
        "energy_per_sector",          --- Radar
        "active_energy_usage",        --- Entidades logicas
        "energy_per_movement",        --- Insertador
        "energy_per_rotation",        --- Insertador
        "energy_usage_per_tick",      --- Lamaparas y altavoz
        "energy_per_nearby_scan",     --- Radar
        "movement_energy_consumption" --- Spidertron
    }

    --- Nuevo valor
    This_MOD.new_value = 0.01

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cambios del MOD ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_entity(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el item
        if not item then return end
        if GMOD.is_hidde(item) then return end

        --- Validar el tipo
        if GMOD.is_hidde(entity) then return end

        ---- Validación del tipo de energia
        if not entity.energy_source then return end
        if entity.energy_source.type ~= "electric" then return end

        --- Buscar las propiedades
        local Flag
        for _, property in pairs(This_MOD.properties) do
            repeat
                if not entity[property] then break end

                local Value, _ = GMOD.number_unit(entity[property])
                if Value == This_MOD.new_value then break end

                Flag = true
            until true
            if Flag then break end
        end

        --- Arma de energía
        local Weapon
        repeat
            if not entity.attack_parameters then break end

            Weapon = entity.attack_parameters
            if not Weapon.ammo_type then
                Weapon = nil
                break
            end

            Weapon = Weapon.ammo_type
            if not Weapon.energy_consumption then
                Weapon = nil
                break
            end

            local Value, _ = GMOD.number_unit(Weapon.energy_consumption)
            if Value == This_MOD.new_value then
                Weapon = nil
                break
            end
        until true

        if not Flag and not Weapon then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.entity = entity
        Space.weapon = Weapon

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Preparar los datos a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for item_name, entity in pairs(GMOD.entities) do
        validate_entity(GMOD.items[item_name], entity)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.update_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Actualizar el consumo en las entidades en general
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, property in pairs(This_MOD.properties) do
        repeat
            if not space.entity[property] then break end

            local Value, Unit = GMOD.number_unit(space.entity[property])
            if Value == This_MOD.new_value then break end

            space.entity[property] = This_MOD.new_value .. Unit
        until true
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Arma de energía
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Weapon
    repeat
        if not space.entity.attack_parameters then break end

        Weapon = space.entity.attack_parameters
        if not Weapon.ammo_type then
            Weapon = nil
            break
        end

        Weapon = Weapon.ammo_type
        if not Weapon.energy_consumption then
            Weapon = nil
            break
        end

        local Value, Unit = GMOD.number_unit(Weapon.energy_consumption)
        if Value == This_MOD.new_value then
            Weapon = nil
            break
        end

        Weapon.energy_consumption = This_MOD.new_value .. Unit
    until true

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
