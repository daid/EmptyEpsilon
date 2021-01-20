#ifndef AI_H
#define AI_H

#include <SFML/System.hpp>
#include "pathPlanner.h"

///Forward declaration
class CpuShip;

/**!
 * Base for all ship AIs. This base class handles basic AI which just follows orders straight on and attacks head on.
 * ShipAI objects are only created on the server.
 */
class ShipAI : sf::NonCopyable
{
protected:
    /**!
     * Artificial delay between missile fires. The AI missile fire is 'faked' with this value.
     */
    float missile_fire_delay;
    bool has_missiles;
    bool has_beams;
    float beam_weapon_range;
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
    CpuShip* owner;

    ShipAI(CpuShip* owner);
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


    virtual void drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f draw_position, float scale);
protected:
    virtual void updateWeaponState(float delta);
    virtual void updateTarget();
    virtual void runOrders();
    virtual void runAttack(P<SpaceObject> target);
    virtual void flyTowards(sf::Vector2f target, float keep_distance = 100.0);
    virtual void flyFormation(P<SpaceObject> target, sf::Vector2f offset);

    P<SpaceObject> findBestTarget(sf::Vector2f position, float radius);
    float targetScore(P<SpaceObject> target);

    /**!
     * Check if new target is better than old target.
     * \param new_target
     * \param current_target
     * \return bool True if the new target is 'better'
     */
    bool betterTarget(P<SpaceObject> new_target, P<SpaceObject> current_target);

    /**!
     * Used for missiles, as they require some intelligence to fire.
     */
    float calculateFiringSolution(P<SpaceObject> target, int tube_index);
    P<SpaceObject> findBestMissileRestockTarget(sf::Vector2f position, float radius);

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
