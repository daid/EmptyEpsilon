/*TODO

REGISTER_MULTIPLAYER_CLASS(Planet, "Planet");
Planet::Planet()
: SpaceObject(5000, "Planet")
{
    planet_size = 5000;
    cloud_size = 5200;
    planet_texture = "";
    cloud_texture = "";
    atmosphere_texture = "";
    atmosphere_size = 0;
    distance_from_movement_plane = 0;
    axial_rotation_time = 0.0;
    orbit_target_id = -1;
    orbit_time = 0.0f;
    orbit_distance = 0.0f;

    collision_size = -2.0f;

    setRadarSignatureInfo(0.5f, 0.f, 0.3f);

    addComponent<PlanetRenderer>();
    registerMemberReplication(&planet_size);
    registerMemberReplication(&cloud_size);
    registerMemberReplication(&atmosphere_size);
    registerMemberReplication(&planet_texture);
    registerMemberReplication(&cloud_texture);
    registerMemberReplication(&atmosphere_texture);
    registerMemberReplication(&atmosphere_color);
    registerMemberReplication(&distance_from_movement_plane);
    registerMemberReplication(&axial_rotation_time);
    addComponent<Orbit>();
    registerMemberReplication(&orbit_target_id);
    registerMemberReplication(&orbit_time);
    registerMemberReplication(&orbit_distance);

    if (entity) {
        entity.getOrAddComponent<NeverRadarBlocked>();
    }
}

void Planet::setPlanetAtmosphereColor(float r, float g, float b)
{
    atmosphere_color = glm::vec3{ r, g, b };
}

void Planet::setPlanetAtmosphereTexture(std::string_view texture_name)
{
    atmosphere_texture = texture_name;
}

void Planet::setPlanetSurfaceTexture(std::string_view texture_name)
{
    planet_texture = texture_name;
}

void Planet::setPlanetCloudTexture(std::string_view texture_name)
{
    cloud_texture = texture_name;
}

float Planet::getPlanetRadius()
{
    return planet_size;
}

float Planet::getCollisionSize()
{
    return collision_size;
}

void Planet::setPlanetRadius(float size)
{
    this->planet_size = size;
    this->cloud_size = size * 1.05f;
    this->atmosphere_size = size * 1.2f;
}

void Planet::setPlanetCloudRadius(float size)
{
    cloud_size = size;
}

void Planet::setDistanceFromMovementPlane(float distance_from_movement_plane)
{
    this->distance_from_movement_plane = distance_from_movement_plane;
}

void Planet::setAxialRotationTime(float time)
{
    axial_rotation_time = time;
}

void Planet::setOrbit(P<SpaceObject> target, float orbit_time)
{
    if (!target)
        return;
    this->orbit_target_id = target->getMultiplayerId();
    this->orbit_distance = glm::length(getPosition() - target->getPosition());
    this->orbit_time = orbit_time;
}

void Planet::update(float delta)
{
    if (collision_size == -2.0f)
    {
        updateCollisionSize();
        if (collision_size > 0.0f) {
            entity.getOrAddComponent<AvoidObject>().range = collision_size;
        }
    }

    if (orbit_distance > 0.0f)
    {
        P<SpaceObject> orbit_target;
        if (game_server)
            orbit_target = game_server->getObjectById(orbit_target_id);
        else
            orbit_target = game_client->getObjectById(orbit_target_id);
        if (orbit_target)
        {
            float angle = vec2ToAngle(getPosition() - orbit_target->getPosition());
            angle += delta / orbit_time * 360.0f;
            setPosition(orbit_target->getPosition() + vec2FromAngle(angle) * orbit_distance);
        }
    }

    if (axial_rotation_time != 0.0f)
        setRotation(getRotation() + delta / axial_rotation_time * 360.0f);
}

void Planet::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (collision_size > 0)
    {
        renderer.fillCircle(position, collision_size * scale, glm::u8vec4(atmosphere_color * 255.f, 128));
    }
}

void Planet::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    renderer.drawCircleOutline(position, planet_size * scale, 3, glm::u8vec4(255, 255, 255, 128));
}

void Planet::updateCollisionSize()
{
    if (std::abs(distance_from_movement_plane) >= planet_size)
    {
        collision_size = -1.0;
        entity.removeComponent<sp::Physics>();
    }else{
        collision_size = sqrt((planet_size * planet_size) - (distance_from_movement_plane * distance_from_movement_plane)) * 1.1f;
        entity.getOrAddComponent<sp::Physics>().setCircle(sp::Physics::Type::Static, collision_size);
    }
}
*/
