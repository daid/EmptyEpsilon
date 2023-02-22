#ifndef AI_H
#define AI_H

#include "nonCopyable.h"
#include "pathPlanner.h"
#include "components/missiletubes.h"

///Forward declaration
class CpuShip;

/**!
 * Base for all ship AIs. This base class handles basic AI which just follows orders straight on and attacks head on.
 * ShipAI objects are only created on the server.
 */
class ShipAI : sp::NonCopyable
{
protected:
    /**!
     * Artificial delay between missile fires. The AI missile fire is 'faked' with this value.
     */
    float missile_fire_delay = 0;
    bool has_missiles = false;
    bool has_beams = false;
    float beam_weapon_range = 1000;
    float short_range = 5000;
    float long_range = 30000;
    float relay_range = 60000;

    enum class EWeaponDirection
    {
        Front,
        Left,
        Right,
        Side,
        Rear
    };
    EWeaponDirection weapon_direction;
    EMissileWeapons best_missile_type;

    float update_target_delay;

    PathPlanner pathPlanner;
public:
    sp::ecs::Entity owner;

    ShipAI(sp::ecs::Entity owner);
    virtual ~ShipAI() = default;

    /**!
     * Run is called every frame to update the AI state and let the AI take actions.
     */
    virtual void run(float delta);

    /**!
     * Are we allowed to switch to a different AI right now?
     * When true is returned, and the CpuShip wants to change their AI this AI object will be destroyed and a new one will be created.
     */
    virtual bool canSwitchAI();


    virtual void drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 draw_position, float scale);
protected:
    virtual void updateWeaponState(float delta);
    virtual void updateTarget();
    virtual void runOrders();
    virtual void runAttack(sp::ecs::Entity target);
    virtual void flyTowards(glm::vec2 target, float keep_distance = 100.0);
    virtual void flyFormation(sp::ecs::Entity target, glm::vec2 offset);

    sp::ecs::Entity findBestTarget(glm::vec2 position, float radius);
    float targetScore(sp::ecs::Entity target);

    /**!
     * Check if new target is better than old target.
     * \param new_target
     * \param current_target
     * \return bool True if the new target is 'better'
     */
    bool betterTarget(sp::ecs::Entity new_target, sp::ecs::Entity current_target);

    /**!
     * Used for missiles, as they require some intelligence to fire.
     */
    float calculateFiringSolution(sp::ecs::Entity target, const MissileTubes::MountPoint& tube);
    sp::ecs::Entity findBestMissileRestockTarget(glm::vec2 position, float radius);

    static float getMissileWeaponStrength(EMissileWeapons type)
    {
        switch(type)
        {
        case MW_Nuke:
            return 250;
        case MW_EMP:
            return 150;
        case MW_HVLI:
            return 20;
        default:
            return 35;
        }
    }
};

#endif//AI_H
