#include "supplyDrop.h"
#include "spaceship.h"
#include "playerInfo.h"
#include "playerSpaceship.h"
#include "components/reactor.h"
#include "components/missiletubes.h"
#include "main.h"

#include "scriptInterface.h"

/// A supply drop.
REGISTER_SCRIPT_SUBCLASS(SupplyDrop, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(SupplyDrop, setEnergy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SupplyDrop, setWeaponStorage);
    /// Set a function that will be called if a player picks up the supply drop.
    /// First argument given to the function will be the supply drop, the second the player.
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

void SupplyDrop::collide(SpaceObject* target, float force)
{
    P<SpaceShip> ship = P<SpaceObject>(target);
    if (ship && isFriendly(ship))
    {
        bool picked_up = false;
        auto reactor = ship->entity.getComponent<Reactor>();
        if (reactor)
        {
            reactor->energy += energy;
            picked_up = true;
        }
        auto missiletubes = ship->entity.getComponent<MissileTubes>();
        if (missiletubes) {
            for(int n=0; n<MW_Count; n++)
            {
                uint8_t delta = std::min(int(missiletubes->storage[n]), missiletubes->storage_max[n] - missiletubes->storage[n]);
                if (delta > 0)
                {
                    missiletubes->storage[n] += delta;
                    weapon_storage[n] -= delta;
                    picked_up = true;
                }
            }
        }
        if (on_pickup_callback.isSet())
        {
            on_pickup_callback.call<void>(P<SupplyDrop>(this), ship);
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
