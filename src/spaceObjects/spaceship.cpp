#include "spaceship.h"
#include "mesh.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "spaceObjects/beamEffect.h"
#include "factionInfo.h"
#include "spaceObjects/explosionEffect.h"
#include "particleEffect.h"
#include "spaceObjects/warpJammer.h"
#include "gameGlobalInfo.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(SpaceShip, ShipTemplateBasedObject)
{
    //[DEPRICATED]
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentified);
    //[DEPRICATED]
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScanned);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedBy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedBy);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFriendOrFoeIdentifiedByFaction);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isFullyScannedByFaction);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorageMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorageMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getShieldsFrequency);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHealth);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHealth);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemHeat);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setSystemHeat);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getSystemPower);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getImpulseMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setImpulseMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getRotationMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setRotationMaxSpeed);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setJumpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, hasWarpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWarpDrive);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponArc);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponDirection);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponRange);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponCycleTime);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getBeamWeaponDamage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeapon);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setBeamWeaponTexture);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeCount);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponTubeCount);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponTubeLoadType);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, weaponTubeAllowMissle);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, weaponTubeDisallowMissle);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponTubeExclusiveFor);
    /// Set the icon to be used for this ship on the radar.
    /// For example, ship:setRadarTrace("RadarBlip.png") will show a dot instead of an arrow for this ship.
    /// Note: Icon is only shown after scanning, before the ship is scanned it is always shown as an arrow.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setRadarTrace);

    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, addBroadcast);
}

/* Define script conversion function for the EMainScreenSetting enum. */
template<> void convert<EMainScreenSetting>::param(lua_State* L, int& idx, EMainScreenSetting& mss)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "front")
        mss = MSS_Front;
    else if (str == "back")
        mss = MSS_Back;
    else if (str == "left")
        mss = MSS_Left;
    else if (str == "right")
        mss = MSS_Right;
    else if (str == "tactical")
        mss = MSS_Tactical;
    else if (str == "longrange")
        mss = MSS_LongRange;
    else
        mss = MSS_Front;
}

SpaceShip::SpaceShip(string multiplayerClassName, float multiplayer_significant_range)
: ShipTemplateBasedObject(50, multiplayerClassName, multiplayer_significant_range)
{
    setCollisionPhysics(true, false);

    target_rotation = getRotation();
    impulse_request = 0;
    current_impulse = 0;
    has_warp_drive = true;
    warp_request = 0.0;
    current_warp = 0.0;
    has_jump_drive = true;
    jump_drive_charge = jump_drive_max_distance;
    jump_distance = 0.0;
    jump_delay = 0.0;
    wormhole_alpha = 0.0;
    weapon_tube_count = 0;
    turn_speed = 10.0;
    impulse_max_speed = 600.0;
    warp_speed_per_warp_level = 1000.0;
    combat_maneuver_charge = 1.0;
    combat_maneuver_boost_request = 0.0;
    combat_maneuver_boost_active = 0.0;
    combat_maneuver_strafe_request = 0.0;
    combat_maneuver_strafe_active = 0.0;
    target_id = -1;
    beam_frequency = irandom(0, max_frequency);
    beam_system_target = SYS_None;
    shield_frequency = irandom(0, max_frequency);
    docking_state = DS_NotDocking;
    impulse_acceleration = 20.0;
    energy_level = 1000;
    max_energy_level = 1000;

    registerMemberReplication(&target_rotation, 1.5);
    registerMemberReplication(&impulse_request, 0.1);
    registerMemberReplication(&current_impulse, 0.5);
    registerMemberReplication(&has_warp_drive);
    registerMemberReplication(&warp_request, 0.1);
    registerMemberReplication(&current_warp, 0.1);
    registerMemberReplication(&has_jump_drive);
    registerMemberReplication(&jump_drive_charge, 0.5);
    registerMemberReplication(&jump_delay, 0.5);
    registerMemberReplication(&wormhole_alpha, 0.5);
    registerMemberReplication(&weapon_tube_count);
    registerMemberReplication(&target_id);
    registerMemberReplication(&turn_speed);
    registerMemberReplication(&impulse_max_speed);
    registerMemberReplication(&impulse_acceleration);
    registerMemberReplication(&warp_speed_per_warp_level);
    registerMemberReplication(&shield_frequency);
    registerMemberReplication(&docking_state);
    registerMemberReplication(&beam_frequency);
    registerMemberReplication(&combat_maneuver_charge, 0.5);
    registerMemberReplication(&combat_maneuver_boost_request);
    registerMemberReplication(&combat_maneuver_boost_active, 0.2);
    registerMemberReplication(&combat_maneuver_strafe_request);
    registerMemberReplication(&combat_maneuver_strafe_active, 0.2);
    registerMemberReplication(&radar_trace);

    for(int n=0; n<SYS_COUNT; n++)
    {
        systems[n].health = 1.0;
        systems[n].power_level = 1.0;
        systems[n].coolant_level = 0.0;
        systems[n].heat_level = 0.0;

        registerMemberReplication(&systems[n].health, 0.1);
    }

    for(int n = 0; n < max_beam_weapons; n++)
    {
        beam_weapons[n].setParent(this);
    }
    for(int n = 0; n < max_weapon_tubes; n++)
    {
        weapon_tube[n].setParent(this);
        weapon_tube[n].setIndex(n);
    }
    for(int n = 0; n < MW_Count; n++)
    {
        weapon_storage[n] = 0;
        weapon_storage_max[n] = 0;
        registerMemberReplication(&weapon_storage[n]);
        registerMemberReplication(&weapon_storage_max[n]);
    }

    scanning_complexity_value = -1;
    scanning_depth_value = -1;

    if (game_server)
        setCallSign(gameGlobalInfo->getNextShipCallsign());
}

void SpaceShip::applyTemplateValues()
{
    for(int n=0; n<max_beam_weapons; n++)
    {
        beam_weapons[n].setPosition(ship_template->model_data->getBeamPosition(n));
        beam_weapons[n].setArc(ship_template->beams[n].getArc());
        beam_weapons[n].setDirection(ship_template->beams[n].getDirection());
        beam_weapons[n].setRange(ship_template->beams[n].getRange());
        beam_weapons[n].setCycleTime(ship_template->beams[n].getCycleTime());
        beam_weapons[n].setDamage(ship_template->beams[n].getDamage());
        beam_weapons[n].setBeamTexture(ship_template->beams[n].getBeamTexture());
    }
    weapon_tube_count = ship_template->weapon_tube_count;
    energy_level = max_energy_level = ship_template->energy_storage_amount;

    impulse_max_speed = ship_template->impulse_speed;
    impulse_acceleration = ship_template->impulse_acceleration;
    turn_speed = ship_template->turn_speed;
    has_warp_drive = ship_template->warp_speed > 0.0;
    warp_speed_per_warp_level = ship_template->warp_speed;
    has_jump_drive = ship_template->has_jump_drive;
    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].setLoadTimeConfig(ship_template->weapon_tube[n].load_time);
        for(int m=0; m<MW_Count; m++)
        {
            if (ship_template->weapon_tube[n].type_allowed_mask & (1 << m))
                weapon_tube[n].allowLoadOf(EMissileWeapons(m));
            else
                weapon_tube[n].disallowLoadOf(EMissileWeapons(m));
        }
    }
    //shipTemplate->has_cloaking;
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = weapon_storage_max[n] = ship_template->weapon_storage[n];

    ship_template->setCollisionData(this);
    model_info.setData(ship_template->model_data);
}

#if FEATURE_3D_RENDERING
void SpaceShip::draw3DTransparent()
{
    if (!ship_template) return;
    ShipTemplateBasedObject::draw3DTransparent();

    if ((has_jump_drive && jump_delay > 0.0f) ||
        (wormhole_alpha > 0.0f))
    {
        float delay = jump_delay;
        if (wormhole_alpha > 0.0f)
            delay = wormhole_alpha;
        float alpha = 1.0f - (delay / 10.0f);
        model_info.renderOverlay(textureManager.getTexture("electric_sphere_texture.png"), alpha);
    }
}
#endif//FEATURE_3D_RENDERING

void SpaceShip::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (!long_range && (!my_spaceship || (getScannedStateFor(my_spaceship) == SS_FullScan)))
    {
        for(int n=0; n<max_beam_weapons; n++)
        {
            if (beam_weapons[n].getRange() == 0.0) continue;
            sf::Color color = sf::Color::Red;
            if (beam_weapons[n].getCooldown() > 0)
                color = sf::Color(255, 255 * (beam_weapons[n].getCooldown() / beam_weapons[n].getCycleTime()), 0);

            float direction = beam_weapons[n].getDirection();
            float arc = beam_weapons[n].getArc();
            float range = beam_weapons[n].getRange();

            sf::Vector2f beam_offset = sf::rotateVector(ship_template->model_data->getBeamPosition2D(n) * scale, getRotation());
            sf::VertexArray a(sf::LinesStrip, 3);
            a[0].color = color;
            a[1].color = color;
            a[2].color = sf::Color(color.r, color.g, color.b, 0);
            a[0].position = beam_offset + position;
            a[1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (direction + arc / 2.0f)) * range * scale;
            a[2].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (direction + arc / 2.0f)) * range * scale * 1.3f;
            window.draw(a);
            a[1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (direction - arc / 2.0f)) * range * scale;
            a[2].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (direction - arc / 2.0f)) * range * scale * 1.3f;
            window.draw(a);

            int arcPoints = int(arc / 10) + 1;
            sf::VertexArray arc_line(sf::LinesStrip, arcPoints);
            for(int i=0; i<arcPoints; i++)
            {
                arc_line[i].color = color;
                arc_line[i].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (direction - arc / 2.0f + 10 * i)) * range * scale;
            }
            arc_line[arcPoints-1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (direction + arc / 2.0f)) * range * scale;
            window.draw(arc_line);
        }
    }
    if (!long_range)
    {
        if (!my_spaceship || getScannedStateFor(my_spaceship) >= SS_SimpleScan)
        {
            drawShieldsOnRadar(window, position, scale, 1.0, true);
        } else {
            drawShieldsOnRadar(window, position, scale, 1.0, false);
        }
    }

    sf::Sprite objectSprite;

    //if the ship is not scanned, set the default icon, else the ship specific
    if (my_spaceship && (getScannedStateFor(my_spaceship) == SS_NotScanned || getScannedStateFor(my_spaceship) == SS_FriendOrFoeIdentified))
    {
        textureManager.setTexture(objectSprite, "RadarArrow.png");
    }
    else
    {
        textureManager.setTexture(objectSprite, radar_trace);
    }

    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    if (long_range)
    {
        objectSprite.setScale(0.7, 0.7);
    }
    if (my_spaceship == this)
    {
        objectSprite.setColor(sf::Color(192, 192, 255));
    }else if (my_spaceship)
    {
        if (getScannedStateFor(my_spaceship) != SS_NotScanned)
        {
            if (isEnemy(my_spaceship))
                objectSprite.setColor(sf::Color::Red);
            else if (isFriendly(my_spaceship))
                objectSprite.setColor(sf::Color(128, 255, 128));
            else
                objectSprite.setColor(sf::Color(128, 128, 255));
        }else{
            objectSprite.setColor(sf::Color(192, 192, 192));
        }
    }else{
        objectSprite.setColor(factionInfo[getFactionId()]->gm_color);
    }
    window.draw(objectSprite);
}

void SpaceShip::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (!long_range)
    {
        sf::RectangleShape bar(sf::Vector2f(60, 10));
        bar.setPosition(position.x - 30, position.y - 30);
        bar.setSize(sf::Vector2f(60 * hull_strength / hull_max, 5));
        bar.setFillColor(sf::Color(128, 255, 128, 128));
        window.draw(bar);
    }
}

void SpaceShip::update(float delta)
{
    ShipTemplateBasedObject::update(delta);

    if (game_server)
    {
        if (docking_state == DS_Docking)
        {
            if (!docking_target)
                docking_state = DS_NotDocking;
            else
                target_rotation = sf::vector2ToAngle(getPosition() - docking_target->getPosition());
            if (fabs(sf::angleDifference(target_rotation, getRotation())) < 10.0)
                impulse_request = -1.0;
            else
                impulse_request = 0.0;
        }
        if (docking_state == DS_Docked)
        {
            if (!docking_target)
            {
                docking_state = DS_NotDocking;
            }else{
                setPosition(docking_target->getPosition() + sf::rotateVector(docking_offset, docking_target->getRotation()));
                target_rotation = sf::vector2ToAngle(getPosition() - docking_target->getPosition());
            }
            impulse_request = 0.0;
        }
        if ((docking_state == DS_Docked) || (docking_state == DS_Docking))
            warp_request= 0.0;
    }

    float rotationDiff = sf::angleDifference(getRotation(), target_rotation);

    if (rotationDiff > 1.0)
        setAngularVelocity(turn_speed * getSystemEffectiveness(SYS_Maneuver));
    else if (rotationDiff < -1.0)
        setAngularVelocity(-turn_speed * getSystemEffectiveness(SYS_Maneuver));
    else
        setAngularVelocity(rotationDiff * turn_speed * getSystemEffectiveness(SYS_Maneuver));

    if ((has_jump_drive && jump_delay > 0) || (has_warp_drive && warp_request > 0))
    {
        if (WarpJammer::isWarpJammed(getPosition()))
        {
            jump_delay = 0;
            warp_request = 0.0f;
        }
    }
    if (has_jump_drive && jump_delay > 0)
    {
        if (current_impulse > 0.0)
        {
            if (impulse_max_speed > 0)
                current_impulse -= delta * (impulse_acceleration / impulse_max_speed);
            if (current_impulse < 0.0)
                current_impulse = 0.0;
        }
        if (current_warp > 0.0)
        {
            current_warp -= delta;
            if (current_warp < 0.0)
                current_warp = 0.0;
        }
        jump_delay -= delta * getSystemEffectiveness(SYS_JumpDrive);
        if (jump_delay <= 0.0)
        {
            executeJump(jump_distance);
            jump_delay = 0.0;
        }
    }else if (has_warp_drive && (warp_request > 0 || current_warp > 0))
    {
        if (current_impulse > 0.0)
        {
            if (impulse_max_speed > 0)
                current_impulse -= delta * (impulse_acceleration / impulse_max_speed);
            if (current_impulse < 0.0)
                current_impulse = 0.0;
        }else{
            if (current_warp < warp_request)
            {
                current_warp += delta / warp_charge_time;
                if (current_warp > warp_request)
                    current_warp = warp_request;
            }else if (current_warp > warp_request)
            {
                current_warp -= delta / warp_decharge_time;
                if (current_warp < warp_request)
                    current_warp = warp_request;
            }
        }
    }else{
        if (has_jump_drive)
        {
            float f = Tween<float>::linear(getSystemEffectiveness(SYS_JumpDrive), 0.0, 1.0, -0.25, 1.0);
            if (f > 0)
            {
                if (jump_drive_charge < jump_drive_max_distance)
                {
                    float extra_charge = (delta / jump_drive_charge_time_per_km) * f;
                    if (useEnergy(extra_charge * jump_drive_energy_per_km_charge))
                    {
                        jump_drive_charge += extra_charge;
                        if (jump_drive_charge >= jump_drive_max_distance)
                            jump_drive_charge = jump_drive_max_distance;
                    }
                }
            }else{
                jump_drive_charge += (delta / jump_drive_charge_time_per_km) * f;
                if (jump_drive_charge < 0.0f)
                    jump_drive_charge = 0.0f;
            }
        }
        current_warp = 0.0;
        if (impulse_request > 1.0)
            impulse_request = 1.0;
        if (impulse_request < -1.0)
            impulse_request = -1.0;
        if (current_impulse < impulse_request)
        {
            if (impulse_max_speed > 0)
                current_impulse += delta * (impulse_acceleration / impulse_max_speed);
            if (current_impulse > impulse_request)
                current_impulse = impulse_request;
        }else if (current_impulse > impulse_request)
        {
            if (impulse_max_speed > 0)
                current_impulse -= delta * (impulse_acceleration / impulse_max_speed);
            if (current_impulse < impulse_request)
                current_impulse = impulse_request;
        }
    }
    sf::Vector2f forward = sf::vector2FromAngle(getRotation());
    setVelocity(forward * (current_impulse * impulse_max_speed * getSystemEffectiveness(SYS_Impulse) + current_warp * warp_speed_per_warp_level * getSystemEffectiveness(SYS_Warp)));

    if (combat_maneuver_boost_active > combat_maneuver_boost_request)
    {
        combat_maneuver_boost_active -= delta;
        if (combat_maneuver_boost_active < combat_maneuver_boost_request)
            combat_maneuver_boost_active = combat_maneuver_boost_request;
    }
    if (combat_maneuver_boost_active < combat_maneuver_boost_request)
    {
        combat_maneuver_boost_active += delta;
        if (combat_maneuver_boost_active > combat_maneuver_boost_request)
            combat_maneuver_boost_active = combat_maneuver_boost_request;
    }
    if (combat_maneuver_strafe_active > combat_maneuver_strafe_request)
    {
        combat_maneuver_strafe_active -= delta;
        if (combat_maneuver_strafe_active < combat_maneuver_strafe_request)
            combat_maneuver_strafe_active = combat_maneuver_strafe_request;
    }
    if (combat_maneuver_strafe_active < combat_maneuver_strafe_request)
    {
        combat_maneuver_strafe_active += delta;
        if (combat_maneuver_strafe_active > combat_maneuver_strafe_request)
            combat_maneuver_strafe_active = combat_maneuver_strafe_request;
    }

    if (combat_maneuver_boost_active != 0.0)
    {
        combat_maneuver_charge -= combat_maneuver_boost_active * delta * 0.3;
        if (combat_maneuver_charge <= 0.0)
        {
            combat_maneuver_charge = 0.0;
            combat_maneuver_boost_request = 0.0;
        }else{
            setVelocity(getVelocity() + forward * impulse_max_speed * 5.0f * combat_maneuver_boost_active);
        }
    }else if (combat_maneuver_strafe_active != 0.0)
    {
        combat_maneuver_charge -= fabs(combat_maneuver_strafe_active) * delta * 0.3;
        if (combat_maneuver_charge <= 0.0)
        {
            combat_maneuver_charge = 0.0;
            combat_maneuver_strafe_request = 0.0;
        }else{
            setVelocity(getVelocity() + sf::vector2FromAngle(getRotation() + 90) * impulse_max_speed * 3.0f * combat_maneuver_strafe_active);
        }
    }else if (combat_maneuver_charge < 1.0)
    {
        combat_maneuver_charge += (delta / combat_maneuver_charge_time) * getSystemEffectiveness(SYS_Maneuver);
        if (combat_maneuver_charge > 1.0)
            combat_maneuver_charge = 1.0;
    }

    for(int n = 0; n < max_beam_weapons; n++)
    {
        beam_weapons[n].update(delta);
    }

    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].update(delta);
    }

    model_info.engine_scale = std::min(1.0, std::max(fabs(getAngularVelocity() / turn_speed), fabs(current_impulse)));
    if (has_jump_drive && jump_delay > 0.0f)
        model_info.warp_scale = (10.0f - jump_delay) / 10.0f;
    else
        model_info.warp_scale = 0.0;
}

float SpaceShip::getShieldRechargeRate(int shield_index)
{
    float rate = 0.2f;
    if (shield_index == 0)
        rate *= getSystemEffectiveness(SYS_FrontShield);
    else
        rate *= getSystemEffectiveness(SYS_RearShield);
    if (docking_state == DS_Docked)
        rate *= 5.0;
    return rate;
}

P<SpaceObject> SpaceShip::getTarget()
{
    if (game_server)
        return game_server->getObjectById(target_id);
    return game_client->getObjectById(target_id);
}

void SpaceShip::executeJump(float distance)
{
    float f = systems[SYS_JumpDrive].health;
    if (f <= 0.0)
        return;

    distance = (distance * f) + (distance * (1.0 - f) * random(0.5, 1.5));
    sf::Vector2f target_position = getPosition() + sf::vector2FromAngle(getRotation()) * distance * 1000.0f;
    if (WarpJammer::isWarpJammed(target_position))
        target_position = WarpJammer::getFirstNoneJammedPosition(getPosition(), target_position);
    setPosition(target_position);
    addHeat(SYS_JumpDrive, jump_drive_heat_per_jump);
}

bool SpaceShip::canBeDockedBy(P<SpaceObject> obj)
{
    if (isEnemy(obj) || !ship_template)
        return false;
    P<SpaceShip> ship = obj;
    if (!ship || !ship->ship_template)
        return false;
    return ship_template->size_class > ship->ship_template->size_class;
}

void SpaceShip::collide(Collisionable* other, float force)
{
    if (docking_state == DS_Docking)
    {
        P<SpaceObject> dock_object = P<Collisionable>(other);
        if (dock_object == docking_target)
        {
            docking_state = DS_Docked;
            docking_offset = sf::rotateVector(getPosition() - other->getPosition(), -other->getRotation());
            float length = sf::length(docking_offset);
            docking_offset = docking_offset / length * (length + 2.0f);
        }
    }
}

void SpaceShip::initializeJump(float distance)
{
    if (docking_state != DS_NotDocking)
        return;
    if (jump_drive_charge < jump_drive_max_distance) // You can only jump when the drive is fully charged
        return;
    if (jump_delay <= 0.0)
    {
        jump_distance = distance;
        jump_delay = 10.0;
        jump_drive_charge -= distance;
    }
}

void SpaceShip::requestDock(P<SpaceObject> target)
{
    if (!target || docking_state != DS_NotDocking || !target->canBeDockedBy(this))
        return;
    if (sf::length(getPosition() - target->getPosition()) > 1000 + target->getRadius())
        return;
    if (!canStartDocking())
        return;

    docking_state = DS_Docking;
    docking_target = target;
    warp_request = 0.0;
}

void SpaceShip::requestUndock()
{
    if (docking_state == DS_Docked)
    {
        docking_state = DS_NotDocking;
        impulse_request = 0.5;
    }
}

void SpaceShip::abortDock()
{
    if (docking_state == DS_Docking)
    {
        docking_state = DS_NotDocking;
        impulse_request = 0.0;
        warp_request = 0.0;
        target_rotation = getRotation();
    }
}

int SpaceShip::scanningComplexity(P<SpaceObject> other)
{
    if (scanning_complexity_value > -1)
        return scanning_complexity_value;
    switch(gameGlobalInfo->scanning_complexity)
    {
    case SC_None:
        return 0;
    case SC_Simple:
        return 1;
    case SC_Normal:
        if (getScannedStateFor(other) == SS_SimpleScan)
            return 2;
        return 1;
    case SC_Advanced:
        if (getScannedStateFor(other) == SS_SimpleScan)
            return 3;
        return 2;
    }
    return 0;
}

int SpaceShip::scanningChannelDepth(P<SpaceObject> other)
{
    if (scanning_depth_value > -1)
        return scanning_depth_value;
    switch(gameGlobalInfo->scanning_complexity)
    {
    case SC_None:
        return 0;
    case SC_Simple:
        return 1;
    case SC_Normal:
        return 2;
    case SC_Advanced:
        return 2;
    }
    return 0;
}

void SpaceShip::scannedBy(P<SpaceObject> other)
{
    switch(getScannedStateFor(other))
    {
    case SS_NotScanned:
    case SS_FriendOrFoeIdentified:
        setScannedStateFor(other, SS_SimpleScan);
        break;
    case SS_SimpleScan:
        setScannedStateFor(other, SS_FullScan);
        break;
    case SS_FullScan:
        break;
    }
}

bool SpaceShip::isFriendOrFoeIdentified()
{
    LOG(WARNING) << "Depricated \"isFriendOrFoeIdentified\" function called, use isFriendOrFoeIdentifiedBy or isFriendOrFoeIdentifiedByFaction.";
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) > SS_NotScanned)
            return true;
    }
    return false;
}

bool SpaceShip::isFullyScanned()
{
    LOG(WARNING) << "Depricated \"isFullyScanned\" function called, use isFullyScannedBy or isFullyScannedByFaction.";
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) >= SS_FullScan)
            return true;
    }
    return false;
}

bool SpaceShip::isFriendOrFoeIdentifiedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other) >= SS_FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedBy(P<SpaceObject> other)
{
    return getScannedStateFor(other) >= SS_FullScan;
}

bool SpaceShip::isFriendOrFoeIdentifiedByFaction(int faction_id)
{
    return getScannedStateForFaction(faction_id) >= SS_FriendOrFoeIdentified;
}

bool SpaceShip::isFullyScannedByFaction(int faction_id)
{
    return getScannedStateForFaction(faction_id) >= SS_FullScan;
}

float SpaceShip::getShieldDamageFactor(DamageInfo& info, int shield_index)
{
    float frequency_damage_factor = 1.0;
    if (info.type == DT_Energy && gameGlobalInfo->use_beam_shield_frequencies)
    {
        frequency_damage_factor = frequencyVsFrequencyDamageFactor(info.frequency, shield_frequency);
    }
    ESystem system = SYS_FrontShield;
    if (shield_index > 0)
        system = SYS_RearShield;
    float shield_damage_factor = 1.25 - getSystemEffectiveness(system) * 0.25;
    return shield_damage_factor * frequency_damage_factor;
}

void SpaceShip::didAnOffensiveAction()
{
    //We did an offensive action towards our target.
    // Check for each faction. If this faction knows if the target is an enemy or a friendly, it now knows if this object is an enemy or a friendly.
    for(unsigned int faction_id=0; faction_id<factionInfo.size(); faction_id++)
    {
        if (getScannedStateForFaction(faction_id) == SS_NotScanned)
        {
            if (getTarget() && getTarget()->getScannedStateForFaction(faction_id) != SS_NotScanned)
                setScannedStateForFaction(faction_id, SS_FriendOrFoeIdentified);
        }
    }
}

void SpaceShip::takeHullDamage(float damage_amount, DamageInfo& info)
{
    if (gameGlobalInfo->use_system_damage)
    {
        if (info.system_target != SYS_None)
        {
            //Target specific system
            float system_damage = (damage_amount / hull_max) * 1.0;
            if (info.type == DT_Energy)
                system_damage *= 3.0;   //Beam weapons do more system damage, as they penetrate the hull easier.
            systems[info.system_target].health -= system_damage;
            if (systems[info.system_target].health < -1.0)
                systems[info.system_target].health = -1.0;

            for(int n=0; n<2; n++)
            {
                ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
                //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
                float system_damage = (damage_amount / hull_max) * 1.0;
                systems[random_system].health -= system_damage;
                if (systems[random_system].health < -1.0)
                    systems[random_system].health = -1.0;
            }

            if (info.type == DT_Energy)
                damage_amount *= 0.02;
            else
                damage_amount *= 0.5;
        }else{
            for(int n=0; n<5; n++)
            {
                ESystem random_system = ESystem(irandom(0, SYS_COUNT - 1));
                //Damage the system compared to the amount of hull damage you would do. If we have less hull strength you get more system damage.
                float system_damage = (damage_amount / hull_max) * 0.8;
                if (info.type == DT_Energy)
                    system_damage *= 2.5;   //Beam weapons do more system damage, as they penetrate the hull easier.
                systems[random_system].health -= system_damage;
                if (systems[random_system].health < -1.0)
                    systems[random_system].health = -1.0;
            }
        }
    }

    ShipTemplateBasedObject::takeHullDamage(damage_amount, info);
}

void SpaceShip::destroyedByDamage(DamageInfo& info)
{
    ExplosionEffect* e = new ExplosionEffect();
    e->setSize(getRadius() * 1.5);
    e->setPosition(getPosition());

    if (info.instigator)
    {
        float points = hull_max * 0.1f;
        for(int n=0; n<shield_count; n++)
            points += shield_max[n] * 0.1f;
        if (isEnemy(info.instigator))
            info.instigator->addReputationPoints(points);
        else
            info.instigator->removeReputationPoints(points);
    }
}

bool SpaceShip::hasSystem(ESystem system)
{
    switch(system)
    {
    case SYS_None:
    case SYS_COUNT:
        return false;
    case SYS_Warp:
        return has_warp_drive;
    case SYS_JumpDrive:
        return has_jump_drive;
    case SYS_MissileSystem:
        return weapon_tube_count > 0;
    case SYS_FrontShield:
        return shield_count > 0;
    case SYS_RearShield:
        return shield_count > 1;
    case SYS_Reactor:
        return true;
    case SYS_BeamWeapons:
        return true;
    case SYS_Maneuver:
        return turn_speed > 0.0;
    case SYS_Impulse:
        return impulse_max_speed > 0.0;
    }
    return true;
}

float SpaceShip::getSystemEffectiveness(ESystem system)
{
    float power = systems[system].power_level;
    if (energy_level < 10.0)
        power = std::max(0.1f, power);
    if (gameGlobalInfo && gameGlobalInfo->use_system_damage)
        return std::max(0.0f, power * systems[system].health);
    return std::max(0.0f, power * (1.0f - systems[system].heat_level));
}

void SpaceShip::setWeaponTubeCount(int amount)
{
    weapon_tube_count = std::max(0, std::min(amount, max_weapon_tubes));
    for(int n=weapon_tube_count; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].forceUnload();
    }
}

int SpaceShip::getWeaponTubeCount()
{
    return weapon_tube_count;
}

EMissileWeapons SpaceShip::getWeaponTubeLoadType(int index)
{
    if (index < 0 || index >= weapon_tube_count)
        return MW_None;
    if (!weapon_tube[index].isLoaded())
        return MW_None;
    return weapon_tube[index].getLoadType();
}

void SpaceShip::weaponTubeAllowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].allowLoadOf(type);
}

void SpaceShip::weaponTubeDisallowMissle(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    weapon_tube[index].disallowLoadOf(type);
}

void SpaceShip::setWeaponTubeExclusiveFor(int index, EMissileWeapons type)
{
    if (index < 0 || index >= weapon_tube_count)
        return;
    for(int n=0; n<MW_Count; n++)
        weapon_tube[index].disallowLoadOf(EMissileWeapons(n));
    weapon_tube[index].allowLoadOf(type);
}

void SpaceShip::addBroadcast(int threshold, string message)
{
    if ((threshold < 0) || (threshold > 2))     //if an invalid threshold is defined, alert and default to ally only
    {
        LOG(ERROR) << "Invalid threshold: " << threshold;
        threshold = 0;
    }

    sf::Color color = sf::Color(255, 204, 51); //default : yellow, should never be seen
    bool addtolog = 0;

    for(int n=0; n<GameGlobalInfo::max_player_ships; n++)
    {
        P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(n);
        if (ship)
        {
            if (factionInfo[this->getFactionId()]->states[ship->getFactionId()] == FVF_Friendly)
            {
                color = sf::Color(154,255,154); //ally = light green
                addtolog = 1;
            }
            else if ((factionInfo[this->getFactionId()]->states[ship->getFactionId()] == FVF_Neutral) && ((threshold >= FVF_Neutral)))
            {
                color = sf::Color(128,128,128); //neutral = grey
                addtolog = 1;
            }
            else if ((factionInfo[this->getFactionId()]->states[ship->getFactionId()] == FVF_Enemy) && (threshold == FVF_Enemy))
            {
                color = sf::Color(255,102,102); //enemy = light red
                addtolog = 1;
            }

            if (addtolog)
            {
                ship->addToShipLog(message, color);
            }
        }
    }
}

std::unordered_map<string, string> SpaceShip::getGMInfo()
{
    std::unordered_map<string, string> ret;
    ret = ShipTemplateBasedObject::getGMInfo();
    return ret;
}

string SpaceShip::getScriptExportModificationsOnTemplate()
{
    string ret = "";
    if (getTypeName() != ship_template->getName())
        ret += ":setTypeName(" + getTypeName() + ")";
    if (hull_max != ship_template->hull)
        ret += ":setHullMax(" + string(hull_max, 0) + ")";
    if (hull_strength != ship_template->hull)
        ret += ":setHull(" + string(hull_strength, 0) + ")";
    if (impulse_max_speed != ship_template->impulse_speed)
        ret += ":setImpulseMaxSpeed(" + string(impulse_max_speed, 1) + ")";
    if (turn_speed != ship_template->turn_speed)
        ret += ":setRotationMaxSpeed(" + string(turn_speed, 1) + ")";
    if (has_jump_drive != ship_template->has_jump_drive)
        ret += ":setJumpDrive(" + string(has_jump_drive ? "true" : "false") + ")";
    if (has_warp_drive != (ship_template->warp_speed > 0))
        ret += ":setWarpDrive(" + string(has_warp_drive ? "true" : "false") + ")";
    
    /// shield data
    bool add_shields_max_line = getShieldCount() != ship_template->shield_count;
    bool add_shields_line = getShieldCount() != ship_template->shield_count;
    for(int n=0; n<getShieldCount(); n++)
    {
        if (getShieldMax(n) != ship_template->shield_level[n])
            add_shields_max_line = true;
        if (getShieldLevel(n) != ship_template->shield_level[n])
            add_shields_line = true;
    }
    if (add_shields_max_line)
    {
        ret += ":setShieldsMax(";
        for(int n=0; n<getShieldCount(); n++)
        {
            if (n > 0)
                ret += ", ";
            ret += getShieldMax(n);
        }
        ret += ")";
    }
    if (add_shields_line)
    {
        ret += ":setShields(";
        for(int n=0; n<getShieldCount(); n++)
        {
            if (n > 0)
                ret += ", ";
            ret += getShieldLevel(n);
        }
        ret += ")";
    }
    
    ///Missile weapon data
    if (weapon_tube_count != ship_template->weapon_tube_count)
        ret += ":setWeaponTubeCount(" + string(weapon_tube_count) + ")";
    //TODO: Weapon tube "type_allowed_mask"
    //TODO: Weapon tube "load_time"
    for(int n=0; n<MW_Count; n++)
    {
        if (weapon_storage_max[n] != ship_template->weapon_storage[n])
            ret += ":setWeaponStorageMax(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage_max[n]) + ")";
        if (weapon_storage[n] != ship_template->weapon_storage[n])
            ret += ":setWeaponStorage(\"" + getMissileWeaponName(EMissileWeapons(n)) + "\", " + string(weapon_storage[n]) + ")";
    }
    
    ///Beam weapon data
    for(int n=0; n<max_beam_weapons; n++)
    {
        if (beam_weapons[n].getArc() != ship_template->beams[n].getArc()
         || beam_weapons[n].getDirection() != ship_template->beams[n].getDirection()
         || beam_weapons[n].getRange() != ship_template->beams[n].getRange()
         || beam_weapons[n].getCycleTime() != ship_template->beams[n].getCycleTime()
         || beam_weapons[n].getDamage() != ship_template->beams[n].getDamage())
        {
            ret += ":setBeamWeapon(" + string(n) + ", " + string(beam_weapons[n].getArc(), 0) + ", " + string(beam_weapons[n].getDirection(), 0) + ", " + string(beam_weapons[n].getRange(), 0) + ", " + string(beam_weapons[n].getCycleTime(), 1) + ", " + string(beam_weapons[n].getDamage(), 1) + ")";
        }
    }
    
    return ret;
}

string getMissileWeaponName(EMissileWeapons missile)
{
    switch(missile)
    {
    case MW_None:
        return "-";
    case MW_Homing:
        return "Homing";
    case MW_Nuke:
        return "Nuke";
    case MW_Mine:
        return "Mine";
    case MW_EMP:
        return "EMP";
    case MW_HVLI:
        return "HVLI";
    default:
        return "UNK: " + string(int(missile));
    }
}

float frequencyVsFrequencyDamageFactor(int beam_frequency, int shield_frequency)
{
    if (beam_frequency < 0 || shield_frequency < 0)
        return 1.0;

    float diff = abs(beam_frequency - shield_frequency);
    float f1 = sinf(Tween<float>::linear(diff, 0, SpaceShip::max_frequency, 0, M_PI * (1.2 + shield_frequency * 0.05)) + M_PI / 2);
    f1 = f1 * Tween<float>::easeInCubic(diff, 0, SpaceShip::max_frequency, 1.0, 0.1);
    f1 = Tween<float>::linear(f1, 1.0, -1.0, 0.5, 1.5);
    return f1;
}

string frequencyToString(int frequency)
{
    return string(400 + (frequency * 20)) + "THz";
}
