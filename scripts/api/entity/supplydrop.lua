--- A SupplyDrop is a collectible item picked up on collision with a friendly ship.
--- On pickup, the SupplyDrop can restock the colliding ship's weapons. Define SupplyDrop stocks and capacity with setWeaponStorage(), which doesn't have any defined maximum.
--- If the ship has the Reactor component, the collected SupplyDrop can also recharge the ship's energy. Define SupplyDrop energy storage with setEnergy(), which doesn't have any defined maximum.
--- A SupplyDrop can also trigger a scripting function upon pickup. Define SupplyDrop callback with onPickUp().
--- For a more generic entity type with similar collision properties, see Artifact.
--- Example: SupplyDrop():setEnergy(500):setWeaponStorage("Homing", 6)
--- @type creation
function SupplyDrop()
    local e = createEntity()
    e.components = {
        transform = {},
        physics={type="Sensor"},
        radar_trace={
            color={100, 200, 255},
            icon="radar/blip.png",
            radius=120.0,
            rotate=false,
            color_by_faction=true,
        },
        pickup={}
    }
    for k, v in pairs(__model_data["ammo_box"]) do
        if string.sub(1, 2) ~= "__" then
            e.components[k] = table.deepcopy(v)
        end
    end

    return e
end
