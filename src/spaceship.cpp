#include <SFML/OpenGL.hpp>
#include "spaceship.h"
#include "mesh.h"
#include "gui.h"
#include "main.h"
#include "shipTemplate.h"
#include "playerInfo.h"
#include "beamEffect.h"
#include "factionInfo.h"
#include "explosionEffect.h"
#include "EMPMissile.h"
#include "homingMissile.h"
#include "particleEffect.h"
#include "mine.h"
#include "nuke.h"
#include "gameGlobalInfo.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(SpaceShip, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setShipTemplate);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setScanned);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, isDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorage);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, getWeaponStorageMax);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setWeaponStorage);
}

SpaceShip::SpaceShip(string multiplayerClassName)
: SpaceObject(50, multiplayerClassName)
{
    setCollisionPhysics(true, false);

    engine_emit_delay = 0.0;
    targetRotation = getRotation();
    impulseRequest = 0;
    currentImpulse = 0;
    hasWarpdrive = true;
    warpRequest = 0.0;
    currentWarp = 0.0;
    hasJumpdrive = true;
    jumpDistance = 0.0;
    jumpDelay = 0.0;
    jumpSpeedFactor = 1.0;
    tubeLoadTime = 8.0;
    weaponTubes = 0;
    rotationSpeed = 10.0;
    impulseMaxSpeed = 600.0;
    warpSpeedPerWarpLevel = 1000.0;
    targetId = -1;
    hull_strength = hull_max = 70;
    shields_active = false;
    front_shield = rear_shield = front_shield_max = rear_shield_max = 50;
    front_shield_hit_effect = rear_shield_hit_effect = 0;
    front_shield_recharge_factor = rear_shield_recharge_factor = 1.0;
    scanned_by_player = SS_NotScanned;
    beamRechargeFactor = 1.0;
    beam_frequency = irandom(0, max_frequency);
    shield_frequency = irandom(0, max_frequency);
    tubeRechargeFactor = 1.0;
    docking_state = DS_NotDocking;

    registerMemberReplication(&targetRotation, 1.5);
    registerMemberReplication(&impulseRequest, 0.1);
    registerMemberReplication(&currentImpulse, 0.5);
    registerMemberReplication(&hasWarpdrive);
    registerMemberReplication(&warpRequest, 0.1);
    registerMemberReplication(&currentWarp, 0.1);
    registerMemberReplication(&hasJumpdrive);
    registerMemberReplication(&jumpDelay, 0.5);
    registerMemberReplication(&tubeLoadTime);
    registerMemberReplication(&weaponTubes);
    registerMemberReplication(&targetId);
    registerMemberReplication(&rotationSpeed);
    registerMemberReplication(&impulseMaxSpeed);
    registerMemberReplication(&warpSpeedPerWarpLevel);
    registerMemberReplication(&templateName);
    registerMemberReplication(&ship_type_name);
    registerMemberReplication(&front_shield, 1.0);
    registerMemberReplication(&rear_shield, 1.0);
    registerMemberReplication(&front_shield_max);
    registerMemberReplication(&rear_shield_max);
    registerMemberReplication(&shield_frequency);
    registerMemberReplication(&front_shield_hit_effect, 0.5);
    registerMemberReplication(&rear_shield_hit_effect, 0.5);
    registerMemberReplication(&scanned_by_player);
    registerMemberReplication(&docking_state);
    registerMemberReplication(&beam_frequency);

    for(int n=0; n<maxBeamWeapons; n++)
    {
        beamWeapons[n].arc = 0;
        beamWeapons[n].direction = 0;
        beamWeapons[n].range = 0;
        beamWeapons[n].cycleTime = 6.0;
        beamWeapons[n].cooldown = 0.0;
        beamWeapons[n].damage = 1.0;

        registerMemberReplication(&beamWeapons[n].arc);
        registerMemberReplication(&beamWeapons[n].direction);
        registerMemberReplication(&beamWeapons[n].range);
        registerMemberReplication(&beamWeapons[n].cycleTime);
        registerMemberReplication(&beamWeapons[n].cooldown, 0.5);
    }
    for(int n=0; n<maxWeaponTubes; n++)
    {
        weaponTube[n].type_loaded = MW_None;
        weaponTube[n].state = WTS_Empty;
        weaponTube[n].delay = 0.0;

        registerMemberReplication(&weaponTube[n].type_loaded);
        registerMemberReplication(&weaponTube[n].state);
        registerMemberReplication(&weaponTube[n].delay, 0.5);
    }
    for(int n=0; n<MW_Count; n++)
    {
        weapon_storage[n] = 0;
        weapon_storage_max[n] = 0;
        registerMemberReplication(&weapon_storage[n]);
        registerMemberReplication(&weapon_storage_max[n]);
    }
}

void SpaceShip::setShipTemplate(string templateName)
{
    this->templateName = templateName;
    this->ship_type_name = templateName;
    ship_template = ShipTemplate::getTemplate(templateName);
    if (!ship_template)
    {
        printf("Failed to find ship template: %s\n", templateName.c_str());
        return;
    }

    for(int n=0; n<maxBeamWeapons; n++)
    {
        beamWeapons[n].arc = ship_template->beams[n].arc;
        beamWeapons[n].direction = ship_template->beams[n].direction;
        beamWeapons[n].range = ship_template->beams[n].range;
        beamWeapons[n].cycleTime = ship_template->beams[n].cycle_time;
        beamWeapons[n].damage = ship_template->beams[n].damage;
    }
    weaponTubes = ship_template->weaponTubes;
    hull_strength = hull_max = ship_template->hull;
    front_shield = ship_template->frontShields;
    rear_shield = ship_template->rearShields;
    front_shield_max = ship_template->frontShields;
    rear_shield_max = ship_template->rearShields;
    impulseMaxSpeed = ship_template->impulseSpeed;
    rotationSpeed = ship_template->turnSpeed;
    hasWarpdrive = ship_template->warpSpeed > 0.0;
    warpSpeedPerWarpLevel = ship_template->warpSpeed;
    hasJumpdrive = ship_template->jumpDrive;
    tubeLoadTime = ship_template->tube_load_time;
    //shipTemplate->cloaking;
    for(int n=0; n<MW_Count; n++)
        weapon_storage[n] = weapon_storage_max[n] = ship_template->weapon_storage[n];

    setRadius(ship_template->radius);
    if (ship_template->collision_box.x > 0 && ship_template->collision_box.y > 0)
        setCollisionBox(ship_template->collision_box);
}

void SpaceShip::draw3D()
{
    if (!ship_template) return;

    glScalef(ship_template->scale, ship_template->scale, ship_template->scale);
    objectShader.setParameter("baseMap", *textureManager.getTexture(ship_template->colorTexture));
    objectShader.setParameter("illuminationMap", *textureManager.getTexture(ship_template->illuminationTexture));
    objectShader.setParameter("specularMap", *textureManager.getTexture(ship_template->specularTexture));
    sf::Shader::bind(&objectShader);
    Mesh* m = Mesh::getMesh(ship_template->model);
    m->render();
}

void SpaceShip::draw3DTransparent()
{
    if (front_shield_hit_effect > 0 || rear_shield_hit_effect > 0)
    {
        basicShader.setParameter("textureMap", *textureManager.getTexture("shield_hit_effect.png"));
        sf::Shader::bind(&basicShader);
        float f = (front_shield / front_shield_max) * front_shield_hit_effect;
        glColor4f(f, f, f, 1);
        glRotatef(engine->getElapsedTime() * 5, 1, 0, 0);
        glScalef(getRadius() * 1.2, getRadius() * 1.2, getRadius() * 1.2);
        Mesh* m = Mesh::getMesh("half_sphere.obj");
        if (front_shield_hit_effect > 0.0)
            m->render();

        f = (rear_shield / rear_shield_max) * rear_shield_hit_effect;
        glColor4f(f, f, f, 1);
        glScalef(1, -1, 1);
        if (rear_shield_hit_effect > 0.0)
            m->render();
    }
}

void SpaceShip::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (!long_range && ((scanned_by_player == SS_FullScan) || !my_spaceship))
    {
        for(int n=0; n<maxBeamWeapons; n++)
        {
            if (beamWeapons[n].range == 0.0) continue;
            sf::Color color = sf::Color::Red;
            if (beamWeapons[n].cooldown > 0)
                color = sf::Color(255, 255 * (beamWeapons[n].cooldown / beamWeapons[n].cycleTime), 0);

            sf::Vector2f beam_offset = sf::rotateVector(sf::Vector2f(ship_template->beamPosition[n].x, ship_template->beamPosition[n].y) * ship_template->scale * scale, getRotation());
            sf::VertexArray a(sf::LinesStrip, 3);
            a[0].color = color;
            a[1].color = color;
            a[2].color = sf::Color(color.r, color.g, color.b, 0);
            a[0].position = beam_offset + position;
            a[1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beamWeapons[n].direction + beamWeapons[n].arc / 2.0f)) * beamWeapons[n].range * scale;
            a[2].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beamWeapons[n].direction + beamWeapons[n].arc / 2.0f)) * beamWeapons[n].range * scale * 1.3f;
            window.draw(a);
            a[1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beamWeapons[n].direction - beamWeapons[n].arc / 2.0f)) * beamWeapons[n].range * scale;
            a[2].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beamWeapons[n].direction - beamWeapons[n].arc / 2.0f)) * beamWeapons[n].range * scale * 1.3f;
            window.draw(a);

            int arcPoints = int(beamWeapons[n].arc / 10) + 1;
            sf::VertexArray arc(sf::LinesStrip, arcPoints);
            for(int i=0; i<arcPoints; i++)
            {
                arc[i].color = color;
                arc[i].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beamWeapons[n].direction - beamWeapons[n].arc / 2.0f + 10 * i)) * beamWeapons[n].range * scale;
            }
            arc[arcPoints-1].position = beam_offset + position + sf::vector2FromAngle(getRotation() + (beamWeapons[n].direction + beamWeapons[n].arc / 2.0f)) * beamWeapons[n].range * scale;
            window.draw(arc);
        }
    }else{
        if (my_spaceship != this)
            GUI::text(sf::FloatRect(position.x, position.y - 15, 0, 0), getCallSign(), AlignCenter, 12);
    }

    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarArrow.png");
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
        if (scanned_by_player != SS_NotScanned)
        {
            if (isEnemy(my_spaceship))
                objectSprite.setColor(sf::Color::Red);
            if (isFriendly(my_spaceship))
                objectSprite.setColor(sf::Color(128, 255, 128));
        }else{
            objectSprite.setColor(sf::Color(128, 128, 128));
        }
    }else{
        objectSprite.setColor(factionInfo[faction_id]->gm_color);
    }
    window.draw(objectSprite);
}

void SpaceShip::update(float delta)
{
    if (!ship_template)
    {
        ship_template = ShipTemplate::getTemplate(templateName);
        setRadius(ship_template->radius);
    }

    if (game_server)
    {
        if (docking_state == DS_Docking)
        {
            if (!docking_target)
                docking_state = DS_NotDocking;
            else
                targetRotation = sf::vector2ToAngle(getPosition() - docking_target->getPosition());
            if (fabs(sf::angleDifference(targetRotation, getRotation())) < 10.0)
                impulseRequest = -1.0;
            else
                impulseRequest = 0.0;
        }
        if (docking_state == DS_Docked)
        {
            if (!docking_target)
            {
                docking_state = DS_NotDocking;
            }else{
                setPosition(docking_target->getPosition() + sf::rotateVector(docking_offset, docking_target->getRotation()));
                targetRotation = sf::vector2ToAngle(getPosition() - docking_target->getPosition());
            }
            impulseRequest = 0.0;
        }
    }

    if (front_shield < front_shield_max)
    {
        front_shield += delta * shield_recharge_rate * front_shield_recharge_factor;
        if (docking_state == DS_Docked)
            front_shield += delta * shield_recharge_rate * front_shield_recharge_factor * 5.0;
        if (front_shield > front_shield_max)
            front_shield = front_shield_max;
    }
    if (rear_shield < front_shield_max)
    {
        rear_shield += delta * shield_recharge_rate * rear_shield_recharge_factor;
        if (docking_state == DS_Docked)
            rear_shield += delta * shield_recharge_rate * rear_shield_recharge_factor * 5.0;
        if (rear_shield > rear_shield_max)
            rear_shield = rear_shield_max;
    }
    if (front_shield_hit_effect > 0)
        front_shield_hit_effect -= delta;
    if (rear_shield_hit_effect > 0)
        rear_shield_hit_effect -= delta;

    float rotationDiff = sf::angleDifference(getRotation(), targetRotation);

    if (rotationDiff > 1.0)
        setAngularVelocity(rotationSpeed);
    else if (rotationDiff < -1.0)
        setAngularVelocity(-rotationSpeed);
    else
        setAngularVelocity(rotationDiff * rotationSpeed);

    if (hasJumpdrive && jumpDelay > 0)
    {
        if (currentImpulse > 0.0)
        {
            currentImpulse -= delta;
            if (currentImpulse < 0.0)
                currentImpulse = 0.0;
        }
        if (currentWarp > 0.0)
        {
            currentWarp -= delta;
            if (currentWarp < 0.0)
                currentWarp = 0.0;
        }
        jumpDelay -= delta * jumpSpeedFactor;
        if (jumpDelay <= 0.0)
        {
            executeJump(jumpDistance);
            jumpDelay = 0.0;
        }
    }else if (hasWarpdrive && (warpRequest > 0 || currentWarp > 0))
    {
        if (currentImpulse < 1.0)
        {
            currentImpulse += delta;
            if (currentImpulse > 1.0)
                currentImpulse = 1.0;
        }else{
            if (currentWarp < warpRequest)
            {
                currentWarp += delta;
                if (currentWarp > warpRequest)
                    currentWarp = warpRequest;
            }else if (currentWarp > warpRequest)
            {
                currentWarp -= delta;
                if (currentWarp < warpRequest)
                    currentWarp = warpRequest;
            }
        }
    }else{
        if (impulseRequest > 1.0)
            impulseRequest = 1.0;
        if (impulseRequest < -1.0)
            impulseRequest = -1.0;
        if (currentImpulse < impulseRequest)
        {
            currentImpulse += delta;
            if (currentImpulse > impulseRequest)
                currentImpulse = impulseRequest;
        }else if (currentImpulse > impulseRequest)
        {
            currentImpulse -= delta;
            if (currentImpulse < impulseRequest)
                currentImpulse = impulseRequest;
        }
    }
    setVelocity(sf::vector2FromAngle(getRotation()) * (currentImpulse * impulseMaxSpeed + currentWarp * warpSpeedPerWarpLevel));

    for(int n=0; n<maxBeamWeapons; n++)
    {
        if (beamWeapons[n].cooldown > 0.0)
            beamWeapons[n].cooldown -= delta * beamRechargeFactor;
    }

    P<SpaceObject> target = getTarget();
    if (game_server && target && delta > 0 && currentWarp == 0.0 && docking_state == DS_NotDocking) // Only fire beam weapons if we are on the server, have a target, and are not paused.
    {
        for(int n=0; n<maxBeamWeapons; n++)
        {
            if (target && isEnemy(target) && beamWeapons[n].cooldown <= 0.0)
            {
                sf::Vector2f diff = target->getPosition() - (getPosition() + sf::rotateVector(sf::Vector2f(ship_template->beamPosition[n].x, ship_template->beamPosition[n].y) * ship_template->scale, getRotation()));
                float distance = sf::length(diff) - target->getRadius() / 2.0;
                float angle = sf::vector2ToAngle(diff);
                
                if (distance < beamWeapons[n].range)
                {
                    float angleDiff = sf::angleDifference(beamWeapons[n].direction + getRotation(), angle);
                    if (abs(angleDiff) < beamWeapons[n].arc / 2.0)
                    {
                        fireBeamWeapon(n, target);
                    }
                }
            }
        }
    }

    for(int n=0; n<maxWeaponTubes; n++)
    {
        if (weaponTube[n].delay > 0.0)
        {
            weaponTube[n].delay -= delta * tubeRechargeFactor;
        }else{
            switch(weaponTube[n].state)
            {
            case WTS_Loading:
                weaponTube[n].state = WTS_Loaded;
                break;
            case WTS_Unloading:
                weaponTube[n].state = WTS_Empty;
                if (weapon_storage[weaponTube[n].type_loaded] < weapon_storage_max[weaponTube[n].type_loaded])
                    weapon_storage[weaponTube[n].type_loaded] ++;
                weaponTube[n].type_loaded = MW_None;
                break;
            default:
                break;
            }
        }
    }

    if (currentImpulse != 0.0 || getAngularVelocity() != 0.0)
    {
        if (engine_emit_delay > 0.0)
        {
            engine_emit_delay -= delta;
        }else{
            for(unsigned int n=0; n<ship_template->engine_emitors.size(); n++)
            {
                sf::Vector3f offset = ship_template->engine_emitors[n].position * ship_template->scale;
                sf::Vector2f pos2d = getPosition() + sf::rotateVector(sf::Vector2f(offset.x, offset.y), getRotation());
                sf::Vector3f color = ship_template->engine_emitors[n].color;
                sf::Vector3f pos3d = sf::Vector3f(pos2d.x, pos2d.y, offset.z);
                float scale = ship_template->scale * ship_template->engine_emitors[n].scale;
                scale *= std::max(fabs(getAngularVelocity() / rotationSpeed), fabs(currentImpulse));
                ParticleEngine::spawn(pos3d, pos3d, color, color, scale, 0.0, 5.0);
            }
            engine_emit_delay += 0.1;
        }
    }
}

P<SpaceObject> SpaceShip::getTarget()
{
    if (game_server)
        return game_server->getObjectById(targetId);
    return game_client->getObjectById(targetId);
}

void SpaceShip::executeJump(float distance)
{
    setPosition(getPosition() + sf::vector2FromAngle(getRotation()) * distance * 1000.0f);
}

void SpaceShip::fireBeamWeapon(int index, P<SpaceObject> target)
{
    sf::Vector2f hitLocation = target->getPosition() - sf::normalize(target->getPosition() - getPosition()) * target->getRadius();

    beamWeapons[index].cooldown = beamWeapons[index].cycleTime;
    P<BeamEffect> effect = new BeamEffect();
    effect->setSource(this, ship_template->beamPosition[index] * ship_template->scale);
    effect->setTarget(target, hitLocation);

    target->takeDamage(beamWeapons[index].damage, hitLocation, DT_Energy, beam_frequency);
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

void SpaceShip::collision(Collisionable* other)
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

void SpaceShip::loadTube(int tubeNr, EMissileWeapons type)
{
    if (tubeNr >= 0 && tubeNr < maxWeaponTubes && type > MW_None && type < MW_Count)
    {
        if (weaponTube[tubeNr].state == WTS_Empty && weapon_storage[type] > 0)
        {
            weaponTube[tubeNr].state = WTS_Loading;
            weaponTube[tubeNr].delay = tubeLoadTime;
            weaponTube[tubeNr].type_loaded = type;
            weapon_storage[type]--;
        }
    }
}

void SpaceShip::fireTube(int tubeNr)
{
    if (docking_state != DS_NotDocking) return;
    if (currentWarp > 0.0) return;
    if (tubeNr < 0 || tubeNr >= maxWeaponTubes) return;
    if (weaponTube[tubeNr].state != WTS_Loaded) return;

    sf::Vector2f fireLocation = getPosition() + sf::rotateVector(ship_template->tubePosition[tubeNr], getRotation()) * ship_template->scale;
    switch(weaponTube[tubeNr].type_loaded)
    {
    case MW_Homing:
        {
            P<HomingMissile> missile = new HomingMissile();
            missile->owner = this;
            missile->faction_id = faction_id;
            missile->target_id = targetId;
            missile->setPosition(fireLocation);
            missile->setRotation(getRotation());
        }
        break;
    case MW_Nuke:
        {
            P<Nuke> missile = new Nuke();
            missile->owner = this;
            missile->faction_id = faction_id;
            missile->target_id = targetId;
            missile->setPosition(fireLocation);
            missile->setRotation(getRotation());
        }
        break;
    case MW_Mine:
        {
            P<Mine> missile = new Mine();
            missile->faction_id = faction_id;
            missile->setPosition(fireLocation);
            missile->setRotation(getRotation());
            missile->eject();
        }
        break;
    case MW_EMP:
        {
            P<EMPMissile> missile = new EMPMissile();
            missile->owner = this;
            missile->faction_id = faction_id;
            missile->target_id = targetId;
            missile->setPosition(fireLocation);
            missile->setRotation(getRotation());
        }
        break;
    default:
        break;
    }
    weaponTube[tubeNr].state = WTS_Empty;
    weaponTube[tubeNr].type_loaded = MW_None;
}

void SpaceShip::initJump(float distance)
{
    if (docking_state != DS_NotDocking) return;
    if (jumpDelay <= 0.0)
    {
        jumpDistance = distance;
        jumpDelay = 10.0;
    }
}

void SpaceShip::requestDock(P<SpaceObject> target)
{
    if (!target || docking_state != DS_NotDocking || !target->canBeDockedBy(this))
        return;
    if (sf::length(getPosition() - target->getPosition()) > 1000)
        return;

    docking_state = DS_Docking;
    docking_target = target;
}
void SpaceShip::requestUndock()
{
    if (docking_state == DS_Docked)
    {
        docking_state = DS_NotDocking;
        impulseRequest = 0.5;
    }
}

void SpaceShip::takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type, int frequency)
{
    if (shields_active)
    {
        float factor = 1.0;
        if (type == DT_Energy && gameGlobalInfo->use_beam_shield_frequencies)
            factor = frequencyVsFrequencyDamageFactor(frequency, shield_frequency);
        float angle = sf::angleDifference(getRotation(), sf::vector2ToAngle(getPosition() - damageLocation));
        bool front_hit = !(angle > -90 && angle < 90);
        float* shield = &front_shield;
        float* shield_hit_effect = &front_shield_hit_effect;
        if (!front_hit)
        {
            shield = &rear_shield;
            shield_hit_effect = &rear_shield_hit_effect;
        }

        *shield -= damageAmount * factor;

        if (*shield < 0)
        {
            hullDamage(-(*shield) / factor, damageLocation, type);
            *shield = 0.0;
        }else{
            *shield_hit_effect = 1.0;
        }
    }else{
        hullDamage(damageAmount, damageLocation, type);
    }
}

void SpaceShip::hullDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type)
{
    if (type == DT_EMP)
        return;
    hull_strength -= damageAmount;
    if (hull_strength <= 0.0)
    {
        ExplosionEffect* e = new ExplosionEffect();
        e->setSize(getRadius() * 1.5);
        e->setPosition(getPosition());

        for(unsigned int n=0; n<factionInfo.size(); n++)
        {
            if (factionInfo[n]->states[faction_id] == FVF_Enemy)
                factionInfo[n]->reputation_points += (hull_max + front_shield_max + rear_shield_max) * 0.1;
        }
        destroy();
    }
}

bool SpaceShip::hasSystem(ESystem system)
{
    if (system == SYS_None || system == SYS_COUNT) return false;
    if (system == SYS_Warp && !hasWarpdrive) return false;
    if (system == SYS_JumpDrive && !hasJumpdrive) return false;
    if (system == SYS_FrontShield && front_shield_max <= 0) return false;
    if (system == SYS_RearShield && rear_shield_max <= 0) return false;
    return true;
}

string SpaceShip::getCallSign()
{
    int32_t id = getMultiplayerId();
    switch(id / 100)
    {
    case 0: return "S" + string(id % 100);
    case 1: return "NC" + string(id % 100);
    case 2: return "CV" + string(id % 100);
    case 3: return "SS " + string(id % 100);
    case 4: return "VS" + string(id % 100);
    case 5: return "BR" + string(id % 100);
    case 6: return "C-" + string(id % 100);
    case 7: return "OV" + string(id % 100);
    }
    return "X-" + string(id);
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
    return string(400 + (frequency * 20)) + "Thz";
}
