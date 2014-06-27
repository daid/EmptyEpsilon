#include <SFML/OpenGL.hpp>
#include "spaceship.h"
#include "mesh.h"
#include "main.h"

static const int16_t CMD_TARGET_ROTATION = 0x0001;
static const int16_t CMD_IMPULSE = 0x0002;
static const int16_t CMD_WARP = 0x0003;
static const int16_t CMD_JUMP = 0x0004;
static const int16_t CMD_SET_TARGET = 0x0005;
static const int16_t CMD_LOAD_TUBE = 0x0006;
static const int16_t CMD_UNLOAD_TUBE = 0x0007;
static const int16_t CMD_FIRE_TUBE = 0x0008;

REGISTER_MULTIPLAYER_CLASS(SpaceShip, "SpaceShip");
SpaceShip::SpaceShip()
: SpaceObject(50, "SpaceShip")
{
    setCollisionPhysics(true, false); //Physics stuff.
    target_rotation = getRotation();
    impulse_request = 0;
    current_impulse = 0;
    has_warp_drive = true;
    warp_request = 0.0;
    current_warp = 0.0;
    has_jump_drive = true;
    jump_distance = 0.0;
    jump_delay = 0.0;
    weapon_tubes = 6;

    registerMemberReplication(&target_rotation);
    registerMemberReplication(&impulse_request);
    registerMemberReplication(&current_impulse);
    registerMemberReplication(&has_warp_drive);
    registerMemberReplication(&warp_request);
    registerMemberReplication(&current_warp);
    registerMemberReplication(&has_jump_drive);
    registerMemberReplication(&jump_delay, 0.2);
    registerMemberReplication(&weapon_tubes);
    registerMemberReplication(&target_id);

    for(int n=0; n < max_beam_weapons; n++)
    {
        beam_weapons[n].arc = 0;
        beam_weapons[n].direction = 0;
        beam_weapons[n].range = 0;
        beam_weapons[n].cycleTime = 6.0;
        beam_weapons[n].cooldown = 0.0;

        registerMemberReplication(&beam_weapons[n].arc);
        registerMemberReplication(&beam_weapons[n].direction);
        registerMemberReplication(&beam_weapons[n].range);
        registerMemberReplication(&beam_weapons[n].cycleTime);
        registerMemberReplication(&beam_weapons[n].cooldown, 0.2);
    }
    for(int n=0; n<max_weapon_tubes; n++)
    {
        weapon_tube[n].typeLoaded = MW_None;
        weapon_tube[n].loadingDelay = 0.0;

        registerMemberReplication(&weapon_tube[n].typeLoaded);
        registerMemberReplication(&weapon_tube[n].loadingDelay, 0.5);
    }
    beam_weapons[0].arc = 90.0;
    beam_weapons[0].range = 1000.0;
    beam_weapons[1].arc = 30.0;
    beam_weapons[1].direction = 180;
    beam_weapons[1].range = 2000.0;
}

void SpaceShip::draw3D()
{
    glTranslatef(0, 0, 10);
    glScalef(3.0, 3.0, 3.0);
    object_shader.setParameter("baseMap", *texture_manager.getTexture("space_frigate_6_color.png"));
    object_shader.setParameter("illuminationMap", *texture_manager.getTexture("space_frigate_6_illumination.png"));
    object_shader.setParameter("specularMap", *texture_manager.getTexture("space_frigate_6_specular.png"));
    sf::Shader::bind(&object_shader);
    Mesh* m = Mesh::getMesh("space_frigate_6.obj");
    m->render();
}

void SpaceShip::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale)
{
    for(int n=0; n<max_beam_weapons; n++)
    {
        if (beam_weapons[n].range == 0.0) continue;
        sf::Color color = sf::Color::Red;
        if (beam_weapons[n].cooldown > 0)
            color = sf::Color(255, 255 * (beam_weapons[n].cooldown / beam_weapons[n].cycleTime), 0);

        sf::VertexArray a(sf::LinesStrip, 3);
        a[0].color = color;
        a[1].color = color;
        a[2].color = sf::Color(color.r, color.g, color.b, 0);
        a[0].position = position;
        a[1].position = position + sf::vector2FromAngle(getRotation() + (beam_weapons[n].direction + beam_weapons[n].arc / 2.0f)) * beam_weapons[n].range * scale;
        a[2].position = position + sf::vector2FromAngle(getRotation() + (beam_weapons[n].direction + beam_weapons[n].arc / 2.0f)) * beam_weapons[n].range * scale * 1.3f;
        window.draw(a);
        a[1].position = position + sf::vector2FromAngle(getRotation() + (beam_weapons[n].direction - beam_weapons[n].arc / 2.0f)) * beam_weapons[n].range * scale;
        a[2].position = position + sf::vector2FromAngle(getRotation() + (beam_weapons[n].direction - beam_weapons[n].arc / 2.0f)) * beam_weapons[n].range * scale * 1.3f;
        window.draw(a);

        int arcPoints = int(beam_weapons[n].arc / 10) + 1;
        sf::VertexArray arc(sf::LinesStrip, arcPoints);
        for(int i=0; i<arcPoints; i++)
        {
            arc[i].color = color;
            arc[i].position = position + sf::vector2FromAngle(getRotation() + (beam_weapons[n].direction - beam_weapons[n].arc / 2.0f + 10 * i)) * beam_weapons[n].range * scale;
        }
        arc[arcPoints-1].position = position + sf::vector2FromAngle(getRotation() + (beam_weapons[n].direction + beam_weapons[n].arc / 2.0f)) * beam_weapons[n].range * scale;
        window.draw(arc);
    }

    sf::Sprite objectSprite;
    texture_manager.setTexture(objectSprite, "RadarArrow.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    window.draw(objectSprite);
}

void SpaceShip::update(float delta)
{
    float rotationDiff = target_rotation - getRotation();
    if (rotationDiff < -180)
    {
        target_rotation += 360;
        rotationDiff = target_rotation - getRotation();
    }
    if (rotationDiff > 180)
    {
        target_rotation -= 360;
        rotationDiff = target_rotation - getRotation();
    }

    if (rotationDiff > 1.0)
        setAngularVelocity(10);
    else if (rotationDiff < -1.0)
        setAngularVelocity(-10);
    else
        setAngularVelocity(rotationDiff * 10.0);

    if (has_jump_drive && jump_delay > 0)
    {
        if (current_impulse > 1.0)
        {
            current_impulse -= delta;
            if (current_impulse < 0.0)
                current_impulse = 0.0;
        }
        jump_delay -= delta;
        if (jump_delay <= 0.0)
        {
            setPosition(getPosition() + sf::vector2FromAngle(getRotation()) * jump_distance * 1000.0f);
            jump_delay = 0.0;
        }
    }else if (has_warp_drive && (warp_request > 0 || current_warp > 0))
    {
        if (current_impulse < 1.0)
        {
            current_impulse += delta;
            if (current_impulse > 1.0)
                current_impulse = 1.0;
        }else{
            if (current_warp < warp_request)
            {
                current_warp += delta;
                if (current_warp > warp_request)
                    current_warp = warp_request;
            }else if (current_warp > warp_request)
            {
                current_warp -= delta;
                if (current_warp < warp_request)
                    current_warp = warp_request;
            }
        }
    }else{
        if (current_impulse < impulse_request)
        {
            current_impulse += delta;
            if (current_impulse > impulse_request)
                current_impulse = impulse_request;
        }else if (current_impulse > impulse_request)
        {
            current_impulse -= delta;
            if (current_impulse < impulse_request)
                current_impulse = impulse_request;
        }
    }
    setVelocity(sf::vector2FromAngle(getRotation()) * (current_impulse * 500.0f + current_warp * 1000.0f));

    for(int n=0; n<max_beam_weapons; n++)
    {
        if (beam_weapons[n].cooldown > 0.0)
            beam_weapons[n].cooldown -= delta;
    }

    P<SpaceObject> target = getTarget();
    if (gameServer && target && delta > 0) // Only fire beam weapons if we are on the server, have a target, and are not paused.
    {
        sf::Vector2f diff = target->getPosition() - getPosition();
        float distance = sf::length(diff);
        float angle = sf::vector2ToAngle(diff);
        for(int n=0; n<max_beam_weapons; n++)
        {
            if (beam_weapons[n].cooldown <= 0.0 && distance < beam_weapons[n].range)
            {
                float angleDiff = angle - (beam_weapons[n].direction + getRotation());
                while(angleDiff > 180) angleDiff -= 360;
                while(angleDiff < -180) angleDiff += 360;
                if (abs(angleDiff) < beam_weapons[n].arc / 2.0)
                {
                    beam_weapons[n].cooldown = beam_weapons[n].cycleTime;
                }
            }
        }
    }
}

P<SpaceObject> SpaceShip::getTarget()
{
    if (gameServer)
        return gameServer->getObjectById(target_id);
    return gameClient->getObjectById(target_id);
}

void SpaceShip::onReceiveCommand(int32_t client_id, sf::Packet& packet)
{
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_TARGET_ROTATION:
        packet >> target_rotation;
        break;
    case CMD_IMPULSE:
        packet >> impulse_request;
        break;
    case CMD_WARP:
        packet >> warp_request;
        break;
    case CMD_JUMP:
        if (jump_delay <= 0.0)
        {
            packet >> jump_distance;
            jump_delay = 10.0;
        }
        break;
    case CMD_SET_TARGET:
        {
            packet >> target_id;
        }
        break;
    case CMD_LOAD_TUBE:
        {
            int8_t tubeNr;
            EMissileWeapons type;
            packet >> tubeNr >> type;

            if (tubeNr >= 0 && tubeNr < max_weapon_tubes)
                weapon_tube[tubeNr].typeLoaded = type;
        }
        break;
    case CMD_UNLOAD_TUBE:
        {
            int8_t tubeNr;
            packet >> tubeNr;

            if (tubeNr >= 0 && tubeNr < max_weapon_tubes)
                weapon_tube[tubeNr].typeLoaded = MW_None;
        }
        break;
    case CMD_FIRE_TUBE:
        {
            int8_t tubeNr;
            packet >> tubeNr;

            if (tubeNr >= 0 && tubeNr < max_weapon_tubes)
                weapon_tube[tubeNr].typeLoaded = MW_None;
        }
        break;
    }
}

void SpaceShip::commandTargetRotation(float target)
{
    sf::Packet packet;
    packet << CMD_TARGET_ROTATION << target;
    sendCommand(packet);
}

void SpaceShip::commandImpulse(float target)
{
    sf::Packet packet;
    packet << CMD_IMPULSE << target;
    sendCommand(packet);
}

void SpaceShip::commandWarp(int8_t target)
{
    sf::Packet packet;
    packet << CMD_WARP << target;
    sendCommand(packet);
}

void SpaceShip::commandJump(float distance)
{
    sf::Packet packet;
    packet << CMD_JUMP << distance;
    sendCommand(packet);
}

void SpaceShip::commandSetTarget(P<SpaceObject> target)
{
    sf::Packet packet;
    if (target)
        packet << CMD_SET_TARGET << target->getMultiplayerId();
    else
        packet << CMD_SET_TARGET << int32_t(-1);
    sendCommand(packet);
}

void SpaceShip::commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType)
{
    sf::Packet packet;
    packet << CMD_LOAD_TUBE << tubeNumber << missileType;
    sendCommand(packet);
}

void SpaceShip::commandUnloadTube(int8_t tubeNumber)
{
    sf::Packet packet;
    packet << CMD_UNLOAD_TUBE << tubeNumber;
    sendCommand(packet);
}

void SpaceShip::commandFireTube(int8_t tubeNumber)
{
    sf::Packet packet;
    packet << CMD_FIRE_TUBE << tubeNumber;
    sendCommand(packet);
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
