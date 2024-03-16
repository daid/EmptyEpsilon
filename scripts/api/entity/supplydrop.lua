--- A SupplyDrop is a collectible item picked up on collision with a friendly SpaceShip.
--- On pickup, the SupplyDrop restocks one type of the colliding SpaceShip's weapons.
--- If the ship is a PlayerSpaceship, it can also recharge its energy.
--- A SupplyDrop can also trigger a scripting function upon pickup.
--- For a more generic object with similar collision properties, see Artifact.
--- Example: SupplyDrop():setEnergy(500):setWeaponStorage("Homing",6)
function SupplyDrop()
    local e = createEntity()

    for k, v in pairs(__model_data["ammo_box"]) do
        if string.sub(1, 2) ~= "__" then
            e[k] = table.deepcopy(v)
        end
    end

    e.radar_trace = {
        color={100, 200, 255},
        icon="radar/blip.png",
        radius=120.0,
        rotate=false,
        color_by_faction=true,
    }

    return e
end

local Entity = getLuaEntityFunctionTable()
--- Sets the amount of energy recharged upon pickup when a PlayerSpaceship collides with this SupplyDrop.
--- Example: supply_drop:setEnergy(500)
function Entity:setEnergy(amount)
    --TODO
    return self
end    
--- Sets the weapon type and amount restocked upon pickup when a SpaceShip collides with this SupplyDrop.
--- Example: supply_drop:setWeaponStorage("Homing",6)
function Entity:setWeaponStorage(weapon, amount)
    --TODO
    return self
end    
--- Defines a function to call when a SpaceShip collides with the supply drop.
--- Passes the supply drop and the colliding ship (if it's a PlayerSpaceship) to the function.
--- Example: supply_drop:onPickUp(function(drop,ship) print("Supply drop picked up") end)
function Entity:onPickUp(callback)
    --TODO
    return self
end
