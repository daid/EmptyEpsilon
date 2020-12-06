#include "shipTemplateBasedObject.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(ShipTemplateBasedObject, SpaceObject)
{
    /// Set the ship template to be used for this station. Stations use ship-templates to define hull/shields/looks
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setTemplate);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShipTemplate);
    /// Set the class name of this object. Normally the class name is copied from the template name (Ex "Cruiser") but you can override it with this function.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setTypeName);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getTypeName);
    /// Get the current amount of hull
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getHull);
    /// Get the maximum hull value
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getHullMax);
    /// Set the current hull value, note that setting this to 0 does not destroy the station.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setHull);
    /// Set the maximum amount of hull for this station. Stations never repair hull damage, so this only effects the percentage displays
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setHullMax);
    /// Set whether the object can be destroyed.
    /// Requires a Boolean value.
    /// Example: ship:setCanBeDestroyed(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setCanBeDestroyed);
    /// Get whether the object can be destroyed.
    /// Returns a Boolean value.
    /// Example: ship:getCanBeDestroyed()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getCanBeDestroyed);
    /// Get the specified shield's current level.
    /// Requires an integer index value.
    /// Returns a float value.
    /// Example to get shield level on front shields of a ship with two shields:
    ///     ship:getShieldLevel(0)
    /// Rear shields: ship:getShieldLevel(1)
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldLevel);
    /// Get the number of shields on this object.
    /// For example, a ship with 1 shield count has a single shield covering
    /// all angles, a ship with 2 covers front and back, etc.
    /// Returns an integer count.
    /// Example: ship:getShieldCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldCount);
    /// Get the maxium shield level.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldMax);
    /// Set the current amount of shields.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShields);
    /// Set the maximum shield level. Note that this does low the current shield level when the max becomes lower, but it does not increase the shield level.
    /// A seperate call to setShield is needed for that.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShieldsMax);
    /// Set the icon to be used for this object on the radar.
    /// For example, station:setRadarTrace("RadarArrow.png") will show an arrow instead of a dot for this station.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRadarTrace);
    /// Set the sound file to be used for this object's impulse engines.
    /// Requires a string for a filename relative to the resources path.
    /// Example: setImpulseSoundFile("engine.wav")
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setImpulseSoundFile);
    /// Are the shields online or not. Currently always returns true except for player ships, as only players can turn off shields.
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShieldsActive);

    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getSharesEnergyWithDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setSharesEnergyWithDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRepairDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRepairDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRestocksScanProbes);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRestocksScanProbes);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRestocksMissilesDocked);
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRestocksMissilesDocked);

    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getFrontShield);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getFrontShieldMax);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setFrontShield);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setFrontShieldMax);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRearShield);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getRearShieldMax);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRearShield);
    /// [Depricated]
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setRearShieldMax);
    /// Set a function that will be called if the object is taking damage.
    /// First argument given to the function will be the object taking damage, the second the instigator SpaceObject (or nil).
    /// If instigator is not nil, you will get in this order :
    /// a string which is the damage type as defined in EDamageType, 
    /// an integer which is the frequency used, a string which is the subsystem hit, 
    /// and an integer which is the shield index if shield is hit, -1 if no shield is hit
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, onTakingDamage);
    /// Set a function that will be called if the object is destroyed by taking damage.
    /// First argument given to the function will be the object taking damage, the second the instigator SpaceObject that gave the final blow (or nil).
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, onDestruction);
}

ShipTemplateBasedObject::ShipTemplateBasedObject(float collision_range, string multiplayer_name, float multiplayer_significant_range)
: SpaceObject(collision_range, multiplayer_name, multiplayer_significant_range)
{
    setCollisionPhysics(true, true);

    shield_count = 0;
    for(int n=0; n<max_shield_count; n++)
    {
        shield_level[n] = 0.0;
        shield_max[n] = 0.0;
        shield_hit_effect[n] = 0.0;
    }
    hull_strength = hull_max = 100.0;

    registerMemberReplication(&template_name);
    registerMemberReplication(&type_name);
    registerMemberReplication(&shield_count);
    for(int n=0; n<max_shield_count; n++)
    {
        registerMemberReplication(&shield_level[n], 0.5);
        registerMemberReplication(&shield_max[n]);
        registerMemberReplication(&shield_hit_effect[n], 0.5);
    }
    registerMemberReplication(&radar_trace);
    registerMemberReplication(&impulse_sound_file);
    registerMemberReplication(&hull_strength, 0.5);
    registerMemberReplication(&hull_max);

    callsign = "[" + string(getMultiplayerId()) + "]";

    can_be_destroyed = true;
    registerMemberReplication(&can_be_destroyed);
}

void ShipTemplateBasedObject::drawShieldsOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, float sprite_scale, bool show_levels)
{
    if (!getShieldsActive())
        return;
    if (shield_count == 1)
    {
        sf::Sprite objectSprite;
        textureManager.setTexture(objectSprite, "shield_circle.png");
        objectSprite.setPosition(position);

        objectSprite.setScale(sprite_scale * 0.25f * 1.5f, sprite_scale * 0.25f * 1.5f);

        sf::Color color = sf::Color(255, 255, 255, 64);
        if (show_levels)
        {
            float level = shield_level[0] / shield_max[0];
            color = Tween<sf::Color>::linear(level, 1.0f, 0.0f, sf::Color(128, 128, 255, 128), sf::Color(255, 0, 0, 64));
        }
        if (shield_hit_effect[0] > 0.0)
        {
            color = Tween<sf::Color>::linear(shield_hit_effect[0], 0.0f, 1.0f, color, sf::Color(255, 0, 0, 128));
        }
        objectSprite.setColor(color);

        window.draw(objectSprite);
    }else if (shield_count > 1) {
        float direction = getRotation()-rotation;
        float arc = 360.0f / float(shield_count);

        for(int n=0; n<shield_count; n++)
        {
            sf::Color color = sf::Color(255, 255, 255, 64);
            if (show_levels)
            {
                float level = shield_level[n] / shield_max[n];
                color = Tween<sf::Color>::linear(level, 1.0f, 0.0f, sf::Color(128, 128, 255, 128), sf::Color(255, 0, 0, 64));
            }
            if (shield_hit_effect[n] > 0.0)
            {
                color = Tween<sf::Color>::linear(shield_hit_effect[n], 0.0f, 1.0f, color, sf::Color(255, 0, 0, 128));
            }
            sf::VertexArray a(sf::TrianglesFan, 4);
            sf::Vector2f delta_a = sf::vector2FromAngle(direction - arc / 2.0f);
            sf::Vector2f delta_b = sf::vector2FromAngle(direction);
            sf::Vector2f delta_c = sf::vector2FromAngle(direction + arc / 2.0f);
            a[0].position = position + delta_b * sprite_scale * 32.0f * 0.05f;
            a[1].position = a[0].position + delta_a * sprite_scale * 32.0f * 1.5f;
            a[2].position = a[0].position + delta_b * sprite_scale * 32.0f * 1.5f;
            a[3].position = a[0].position + delta_c * sprite_scale * 32.0f * 1.5f;
            a[0].texCoords = sf::Vector2f(128, 128);
            a[1].texCoords = sf::Vector2f(128, 128) + delta_a * 128.0f;
            a[2].texCoords = sf::Vector2f(128, 128) + delta_b * 128.0f;
            a[3].texCoords = sf::Vector2f(128, 128) + delta_c * 128.0f;
            a[0].color = color;
            a[1].color = color;
            a[2].color = color;
            a[3].color = color;
            window.draw(a, textureManager.getTexture("shield_circle.png"));

            direction += arc;
        }
    }
}

#if FEATURE_3D_RENDERING
void ShipTemplateBasedObject::draw3DTransparent()
{
    if (shield_count < 1)
        return;

    float angle = 0.0;
    float arc = 360.0f / shield_count;
    for(int n = 0; n<shield_count; n++)
    {
        if (shield_hit_effect[n] > 0)
        {
            if (shield_count > 1)
            {
                model_info.renderShield((shield_level[n] / shield_max[n]) * shield_hit_effect[n], angle);
            }else{
                model_info.renderShield((shield_level[n] / shield_max[n]) * shield_hit_effect[n]);
            }
        }
        angle += arc;
    }
}
#endif//FEATURE_3D_RENDERING

void ShipTemplateBasedObject::update(float delta)
{
    if (!ship_template || ship_template->getName() != template_name)
    {
        ship_template = ShipTemplate::getTemplate(template_name);
        if (!ship_template)
            return;
        ship_template->setCollisionData(this);
        model_info.setData(ship_template->model_data);
    }

    for(int n=0; n<shield_count; n++)
    {
        if (shield_level[n] < shield_max[n])
        {
            shield_level[n] = std::min(shield_max[n], shield_level[n] + delta * getShieldRechargeRate(n));
        }
        if (shield_hit_effect[n] > 0)
        {
            shield_hit_effect[n] -= delta;
        }
    }
}

std::unordered_map<string, string> ShipTemplateBasedObject::getGMInfo()
{
    std::unordered_map<string, string> ret;
    ret["CallSign"] = callsign;
    ret["Type"] = type_name;
    ret["Hull"] = string(hull_strength) + "/" + string(hull_max);
    for(int n=0; n<shield_count; n++)
    {
        ret["Shield" + string(n + 1)] = string(shield_level[n]) + "/" + string(shield_max[n]);
    }
    return ret;
}

bool ShipTemplateBasedObject::hasShield()
{
    for(int n=0; n<shield_count; n++)
    {
        if (shield_level[n] < shield_max[n] / 50)
            return false;
    }
    return true;
}

void ShipTemplateBasedObject::takeDamage(float damage_amount, DamageInfo info)
{
    signed int hit_shield_index = -1;
    if (shield_count > 0 && getShieldsActive())
    {
        float angle = sf::angleDifference(getRotation(), sf::vector2ToAngle(info.location - getPosition()));
        if (angle < 0)
            angle += 360.0f;
        float arc = 360.0f / float(shield_count);
        int shield_index = int((angle + arc / 2.0f) / arc);
        shield_index %= shield_count;

        float shield_damage = damage_amount * getShieldDamageFactor(info, shield_index);
        damage_amount -= shield_level[shield_index];
        shield_level[shield_index] -= shield_damage;
        hit_shield_index = shield_index;

        if (shield_level[shield_index] < 0)
        {
            shield_level[shield_index] = 0.0;
        } else {
            shield_hit_effect[shield_index] = 1.0;
        }
        if (damage_amount < 0.0)
        {
            damage_amount = 0.0;
        }
    }

    if (info.type != DT_EMP && damage_amount > 0.0)
    {
        takeHullDamage(damage_amount, info);
    }

    if (hull_strength > 0)
    {
        if (on_taking_damage.isSet())
        {
            if (info.instigator)
            {
                on_taking_damage.call(P<ShipTemplateBasedObject>(this), P<SpaceObject>(info.instigator), info.type, info.frequency, info.system_target, hit_shield_index);
            } else {
                on_taking_damage.call(P<ShipTemplateBasedObject>(this));
            }
        }
    }
}

void ShipTemplateBasedObject::takeHullDamage(float damage_amount, DamageInfo& info)
{
    hull_strength -= damage_amount;
    if (hull_strength <= 0.0 && !can_be_destroyed)
    {
        hull_strength = 1;
    }
    if (hull_strength <= 0.0)
    {
        destroyedByDamage(info);
        if (on_destruction.isSet())
        {
            if (info.instigator)
            {
                on_destruction.call(P<ShipTemplateBasedObject>(this), P<SpaceObject>(info.instigator));
            } else {
                on_destruction.call(P<ShipTemplateBasedObject>(this));
            }
        }
        destroy();
    }
}

float ShipTemplateBasedObject::getShieldDamageFactor(DamageInfo& info, int shield_index)
{
    return 1.0f;
}

float ShipTemplateBasedObject::getShieldRechargeRate(int shield_index)
{
    return 0.3;
}

void ShipTemplateBasedObject::setTemplate(string template_name)
{
    P<ShipTemplate> new_ship_template = ShipTemplate::getTemplate(template_name);
    this->template_name = template_name;
    ship_template = new_ship_template;
    type_name = template_name;

    hull_strength = hull_max = ship_template->hull;
    shield_count = ship_template->shield_count;
    for(int n=0; n<shield_count; n++)
        shield_level[n] = shield_max[n] = ship_template->shield_level[n];

    radar_trace = ship_template->radar_trace;
    impulse_sound_file = ship_template->impulse_sound_file;

    shares_energy_with_docked = ship_template->shares_energy_with_docked;
    repair_docked = ship_template->repair_docked;

    ship_template->setCollisionData(this);
    model_info.setData(ship_template->model_data);

    //Call the virtual applyTemplateValues function so subclasses can get extra values from the ship templates.
    applyTemplateValues();
}

void ShipTemplateBasedObject::setShields(std::vector<float> amounts)
{
    for(int n=0; n<std::min(int(amounts.size()), shield_count); n++)
    {
        shield_level[n] = amounts[n];
    }
}

void ShipTemplateBasedObject::setShieldsMax(std::vector<float> amounts)
{
    shield_count = std::min(max_shield_count, int(amounts.size()));
    for(int n=0; n<shield_count; n++)
    {
        shield_max[n] = amounts[n];
        shield_level[n] = std::min(shield_level[n], shield_max[n]);
    }
}

ESystem ShipTemplateBasedObject::getShieldSystemForShieldIndex(int index)
{
    if (shield_count < 2)
        return SYS_FrontShield;
    float angle = index * 360.0 / shield_count;
    if (std::abs(sf::angleDifference(angle, 0.0f)) < 90)
        return SYS_FrontShield;
    return SYS_RearShield;
}

void ShipTemplateBasedObject::onTakingDamage(ScriptSimpleCallback callback)
{
    this->on_taking_damage = callback;
}

void ShipTemplateBasedObject::onDestruction(ScriptSimpleCallback callback)
{
    this->on_destruction = callback;
}

string ShipTemplateBasedObject::getShieldDataString()
{
    string data = "";
    for(int n=0; n<shield_count; n++)
    {
        if (n > 0)
            data += ":";
        data += string(int(shield_level[n]));
    }
    return data;
}
