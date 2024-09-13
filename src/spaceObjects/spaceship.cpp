#include "spaceship.h"

#include <array>

#include <i18n.h>

#include "mesh.h"
#include "random.h"
#include "playerInfo.h"
#include "particleEffect.h"
#include "textureManager.h"
#include "multiplayer_client.h"
#include "gameGlobalInfo.h"
#include "components/collision.h"
#include "components/docking.h"
#include "components/impulse.h"
#include "components/maneuveringthrusters.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/shields.h"
#include "components/hull.h"
#include "components/missiletubes.h"
#include "components/target.h"
#include "components/shiplog.h"
#include "ecs/query.h"

#include <SDL_assert.h>


/*TODO
void SpaceShip::draw3DTransparent()
{
    auto jump = entity.getComponent<JumpDrive>();
    if ((jump && jump->delay > 0.0f) ||
        (wormhole_alpha > 0.0f))
    {
        float delay = jump ? jump->delay : 0.0f;
        if (wormhole_alpha > 0.0f)
            delay = wormhole_alpha;
        float alpha = 1.0f - (delay / 10.0f);
        model_info.renderOverlay(getModelMatrix(), textureManager.getTexture("texture/electric_sphere_texture.png"), alpha);
    }
}
*/

/*TODO
void SpaceShip::updateDynamicRadarSignature()
{
    // Adjust radar_signature dynamically based on current state and activity.
    // radar_signature becomes the ship's baseline radar signature.
    DynamicRadarSignatureInfo signature_delta;

    // For each ship system ...
    for(int n = 0; n < ShipSystem::COUNT; n++)
    {
        auto ship_system = static_cast<ShipSystem::Type>(n);

        // ... increase the biological band based on system heat, offset by
        // coolant.
        signature_delta.biological += std::max(
            0.0f,
            std::min(
                1.0f,
                getSystemHeat(ship_system) - (getSystemCoolant(ship_system) / 10.0f)
            )
        );

        // ... adjust the electrical band if system power allocation is not 100%.
        if (ship_system == ShipSystem::Type::JumpDrive)
        {
            auto jump = entity.getComponent<JumpDrive>();
            if (jump && jump->charge < jump->max_distance) {
                // ... elevate electrical after a jump, since recharging jump consumes energy.
                signature_delta.electrical += std::clamp(getSystemPower(ship_system) * (jump->charge + 0.01f / jump->max_distance), 0.0f, 1.0f);
            }
        } else if (getSystemPower(ship_system) != 1.0f)
        {
            // For non-Jump systems, allow underpowered systems to reduce the
            // total electrical signal output.
            signature_delta.electrical += std::max(
                -1.0f,
                std::min(
                    1.0f,
                    getSystemPower(ship_system) - 1.0f
                )
            );
        }
    }

    // Increase the gravitational band if the ship is about to jump, or is
    // actively warping.
    auto jump = entity.getComponent<JumpDrive>();
    if (jump && jump->delay > 0.0f)
    {
        signature_delta.gravity += std::clamp((1.0f / jump->delay + 0.01f) + 0.25f, 0.0f, 1.0f);
    }
    auto warp = entity.getComponent<WarpDrive>();
    if (warp && warp->current > 0.0f)
    {
        signature_delta.gravity += warp->current;
    }

    // Update the signature by adding the delta to its baseline.
    if (entity)
        entity.addComponent<DynamicRadarSignatureInfo>(signature_delta);
}
*/

/*TODO
void SpaceShip::update(float delta)
{
    ShipTemplateBasedObject::update(delta);

    auto jump = entity.getComponent<JumpDrive>();
    if (jump && jump->delay > 0.0f)
        model_info.warp_scale = (10.0f - jump->delay) / 10.0f;
    else
        model_info.warp_scale = 0.f;
    
    updateDynamicRadarSignature();
}
*/

/*TODO
void SpaceShip::addBroadcast(FactionRelation threshold, string message)
{
    if ((int(threshold) < 0) || (int(threshold) > 2))     //if an invalid threshold is defined, alert and default to ally only
    {
        LOG(Error, "Invalid threshold: ", int(threshold));
        threshold = FactionRelation::Enemy;
    }

    message = this->getCallSign() + " : " + message; //append the callsign at the start of broadcast

    glm::u8vec4 color = glm::u8vec4(255, 204, 51, 255); //default : yellow, should never be seen

    for(auto [ship, logs] : sp::ecs::Query<ShipLog>())
    {
        bool addtolog = false;
        if (Faction::getRelation(entity, ship) == FactionRelation::Friendly)
        {
            color = glm::u8vec4(154, 255, 154, 255); //ally = light green
            addtolog = true;
        }
        else if (Faction::getRelation(entity, ship) == FactionRelation::Neutral && int(threshold) >= int(FactionRelation::Neutral))
        {
            color = glm::u8vec4(128,128,128, 255); //neutral = grey
            addtolog = true;
        }
        else if (Faction::getRelation(entity, ship) == FactionRelation::Enemy && threshold == FactionRelation::Enemy)
        {
            color = glm::u8vec4(255,102,102, 255); //enemy = light red
            addtolog = true;
        }

        if (addtolog)
        {
            logs.entries.push_back({gameGlobalInfo->getMissionTime() + string(": "), message, color});
        }
    }
}
*/
