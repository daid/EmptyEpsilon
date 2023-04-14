#include "supplyDrop.h"
#include "spaceship.h"
#include "playerInfo.h"
#include "playerSpaceship.h"
#include "components/reactor.h"
#include "components/missiletubes.h"
#include "components/rendering.h"
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

    if (entity) {
        auto& mrc = entity.getOrAddComponent<MeshRenderComponent>();
        auto model_data = ModelData::getModel("ammo_box");
        mrc.mesh.name = model_data->mesh_name;
        mrc.texture.name = model_data->texture_name;
        mrc.specular_texture.name = model_data->specular_texture_name;
        mrc.illumination_texture.name = model_data->illumination_texture_name;
        mrc.scale = model_data->scale;
        mrc.mesh_offset.x = model_data->mesh_offset.x;
        mrc.mesh_offset.y = model_data->mesh_offset.y;
        mrc.mesh_offset.z = model_data->mesh_offset.z;
    }
}

void SupplyDrop::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    glm::u8vec4 color(100, 200, 255, 255);
    if (my_spaceship && Faction::getRelation(entity, my_spaceship) != FactionRelation::Friendly)
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
