--- A SupplyDrop is a collectible item picked up on collision with a friendly SpaceShip.
--- On pickup, the SupplyDrop restocks one type of the colliding SpaceShip's weapons.
--- If the ship is a PlayerSpaceship, it can also recharge its energy.
--- A SupplyDrop can also trigger a scripting function upon pickup.
--- For a more generic object with similar collision properties, see Artifact.
--- Example: SupplyDrop():setEnergy(500):setWeaponStorage("Homing",6)
--- @type creation
function SupplyDrop()
    local e = createEntity()
    e.components.transform = {}
    for k, v in pairs(__model_data["ammo_box"]) do
        if string.sub(1, 2) ~= "__" then
            e.components[k] = table.deepcopy(v)
        end
    end
    e.components = {
        physics={type="Sensor"},
        radar_trace={
            color={100, 200, 255},
            icon="radar/char_plus.png",
            radius=120.0,
            rotate=false,
            color_by_faction=true,
        },
        pickup={}
    }

    return e
end
