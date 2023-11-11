#include "supplyDrop.h"
#include "spaceship.h"
#include "playerInfo.h"
#include "playerSpaceship.h"
#include "main.h"

#include "scriptInterface.h"

/// A SupplyDrop is a collectible item picked up on collision with a friendly SpaceShip.
/// On pickup, the SupplyDrop restocks one type of the colliding SpaceShip's weapons.
/// If the ship is a PlayerSpaceship, it can also recharge its energy.
/// A SupplyDrop can also trigger a scripting function upon pickup.
/// For a more generic object with similar collision properties, see Artifact.
/// Example: SupplyDrop():setEnergy(500):setWeaponStorage("Homing",6)
REGISTER_SCRIPT_SUBCLASS(SupplyDrop, SpaceObject)
{
    /// Sets the amount of energy recharged upon pickup when a PlayerSpaceship collides with this SupplyDrop.
    /// Example: supply_drop:setEnergy(500)
    REGISTER_SCRIPT_CLASS_FUNCTION(SupplyDrop, setEnergy);
    /// Sets the weapon type and amount restocked upon pickup when a SpaceShip collides with this SupplyDrop.
    /// Example: supply_drop:setWeaponStorage("Homing",6)
    REGISTER_SCRIPT_CLASS_FUNCTION(SupplyDrop, setWeaponStorage);
    /// Defines a function to call when a SpaceShip collides with the supply drop.
    /// Passes the supply drop and the colliding ship (if it's a PlayerSpaceship) to the function.
    /// Example: supply_drop:onPickUp(function(drop,ship) print("Supply drop picked up") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(SupplyDrop, onPickUp);
}

REGISTER_MULTIPLAYER_CLASS(SupplyDrop, "SupplyDrop");

SupplyDrop::SupplyDrop()
: SpaceObject(100, "SupplyDrop")
{
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = 0;

    energy = 0.0;
    setRadarSignatureInfo(0.0, 0.1, 0.1);

    model_info.setData("ammo_box");
}

void SupplyDrop::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    glm::u8vec4 color(100, 200, 255, 255);
    if (my_spaceship && !my_spaceship->isFriendly(this))
        color = glm::u8vec4(200, 50, 50, 255);
    renderer.drawSprite("radar/blip.png", position, 8, color);
}

void SupplyDrop::collide(Collisionable* target, float force)
{
    P<SpaceShip> ship = P<Collisionable>(target);
    if (ship && isFriendly(ship))
    {
        bool picked_up = false;
        P<PlayerSpaceship> player = ship;
        if (player)
        {
            player->energy_level += energy;
            picked_up = true;
        }
        for(int n=0; n<MW_Count; n++)
        {
            uint8_t delta = std::min(int(weapon_storage[n]), ship->weapon_storage_max[n] - ship->weapon_storage[n]);
            if (delta > 0)
            {
                ship->weapon_storage[n] += delta;
                weapon_storage[n] -= delta;
                picked_up = true;
            }
        }
        if (on_pickup_callback.isSet())
        {
            on_pickup_callback.call<void>(P<SupplyDrop>(this), player);
            picked_up = true;
        }

        if (picked_up)
            destroy();
    }
}

void SupplyDrop::onPickUp(ScriptSimpleCallback callback)
{
    this->on_pickup_callback = callback;
}

void SupplyDrop::setEnergy(float amount)
{
    energy = amount;
    setRadarSignatureInfo(getRadarSignatureGravity(), getRadarSignatureElectrical() + (amount / 1000.0f), getRadarSignatureBiological());
}

void SupplyDrop::setWeaponStorage(EMissileWeapons weapon, int amount)
{
    if (weapon != MW_None)
    {
        weapon_storage[weapon] = amount;
        setRadarSignatureInfo(getRadarSignatureGravity() + (0.05f * amount), getRadarSignatureElectrical(), getRadarSignatureBiological());
    }
}

string SupplyDrop::getExportLine()
{
    string ret = "SupplyDrop():setFaction(\"" + getFaction() + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
    if (energy > 0)
        ret += ":setEnergy(" + string(energy, 0) + ")";
    for(int n=0; n<MW_Count; n++)
        if (weapon_storage[n] > 0)
            ret += ":setWeaponStorage(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage[n]) + ")";
    return ret;
}
