#include "spaceObject.h"
#include "factionInfo.h"
#include "gameGlobalInfo.h"
#include "shipTemplate.h"

#include "scriptInterface.h"
/// SpaceObject is the base for every object which can be seen in space.
/// General properties can read and set for each object.
/// Each object has a position, rotation, and collision shape.
REGISTER_SCRIPT_CLASS_NO_CREATE(SpaceObject)
{
    /// Sets this object's position on the map, in meters from the origin.
    /// Requires two numeric values.
    /// Example: obj:setPosition(x, y)
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setPosition);
    /// Gets this object's position on the map.
    /// Returns x, y as meters from the origin.
    /// Example: local x, y = obj:getPosition()
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getPosition);
    /// Sets this object's absolute rotation, in degrees.
    /// Unlike setHeading, a value of 0 points to the right of the map.
    /// The value can also be unbounded; it can be negative, or greater than
    /// 360 degrees.
    /// Requires a numeric value.
    /// Example: obj:setRotation(270)
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setRotation);
    /// Gets this object's absolute rotation.
    /// setHeading and setRotation do not change the target heading of
    /// PlayerSpaceships; use PlayerSpaceship's commandTargetRotation.
    /// Returns a value in degrees.
    /// Example: local rotation = obj:getRotation()
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getRotation);
    /// Sets this object's heading, in degrees ranging from 0 to 360.
    /// Unlike setRotation, a value of 0 points to the top of the map.
    /// Values that are negative or greater than 360 are are converted to values
    /// within that range.
    /// setHeading and setRotation do not change the target heading of
    /// PlayerSpaceships; use PlayerSpaceship's commandTargetRotation.
    /// Requires a numeric value.
    /// Example: obj:setHeading(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setHeading);
    /// Gets this object's heading, in degrees ranging from 0 to 360.
    /// Returns a value in degrees.
    /// Example: local heading = obj:getHeading(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getHeading);
    /// Gets this object's directional velocity within 2D space.
    /// Returns a value in meters/second.
    /// Example: local velocity = obj:getVelocity()
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getVelocity);
    /// Gets this object's rotational velocity within 2D space.
    /// Returns a value in degrees/second.
    /// Example: local angular_velocity = obj:getAngularVelocity()
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, getAngularVelocity);
    /// Sets the faction to which this object belongs, by faction name.
    /// Factions are defined by the FactionInfo() function, and default
    /// factions are defined in scripts/factionInfo.lua.
    /// Requires a faction name string as input.
    /// Example: obj:setFaction("Human Navy")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFaction);
    /// Gets the name of the faction to which this object belongs.
    /// Example: local faction = obj:getFaction()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getFaction);
    /// Gets the localized name of the faction to which this object belongs, for displaying to the players.
    /// Example: local faction = obj:getLocaleFaction()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getLocaleFaction);
    /// Sets the faction to which this object belongs, by the faction's index
    /// in the faction list.
    /// Requires the index of a faction in the faction list.
    /// Example: local faction_id = obj:getFactionId()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFactionId);
    /// Gets the faction list index for the faction to which this object
    /// belongs. Can be used in combination with setFactionId() to ensure that
    /// two objects have the same faction.
    /// Example: other:setFactionId(obj:getFactionId())
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getFactionId);
    /// Gets the friend-or-foe status of the parameter's faction relative to
    /// this object's faction.
    /// Requires a SpaceObject.
    /// Returns true if the parameter's faction is hostile to this object's.
    /// Example: local is_enemy = obj:isEnemy()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isEnemy);
    /// Requires a SpaceObject.
    /// Returns true if the parameter's faction is friendly to this object's.
    /// If an object is neither friendly nor enemy, it is neutral.
    /// Example: local is_friendly = obj:isFriendly()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isFriendly);
    /// Sets the communications script used when this object is hailed.
    /// Accepts the filename of a Lua script as a string, or can be set to an
    /// empty string to disable comms with this object.
    /// In the script, `comms_source` (or `player`, deprecated) (PlayerSpaceship)
    /// and `comms_target` (SpaceObject) are available.
    /// Compare `setCommsFunction`.
    /// Examples:
    ///   obj:setCommsScript("")
    ///   obj:setCommsScript("comms_custom_script.lua")
    /// Defaults:
    ///   "comms_station.lua" (in `spaceStation.cpp`)
    ///   "comms_ship.lua" (in `cpuShip.cpp`)
    /// Call `setCommsMessage` once and `addCommsReply` zero or more times in each dialogue.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCommsScript);
    /// Defines a callback function to use when handling hails, in lieu of any
    /// current or default comms script.
    /// For a detailed example, see scenario_53_escape.lua.
    /// Requires a function to call back to when hailed.
    /// The globals `comms_source` (PlayerSpaceship)
    /// and `comms_target` (SpaceObject) are made available in the scenario script.
    /// (Note: They remain as globals. As usual, such globals are not accessible in required files.)
    /// Compare `setCommsScript`.
    /// Example: obj:setCommsFunction(commsStation)
    /// where commsStation is a function
    /// calling `setCommsMessage` once and `addCommsReply` zero or more times.
    /// Instead of using the globals, the callback can take two parameters.
    /// Example: obj:setCommsFunction(function(comms_source, comms_target) ... end)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCommsFunction);
    /// Set this object's callsign. Objects are assigned random callsigns at
    /// creation; this function overrides that default.
    /// Requires a string value.
    /// Example: obj:setCallSign("Epsilon")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCallSign);
    /// Hails a PlayerSpaceship from this object. The players' comms station is
    /// notified and can accept or deny the hail. If the hail is answered, the
    /// specified message is displayed to the player.
    /// WARNING/TOFIX: If the PlayerSpaceship refuses the hail, the script
    /// DOES NOT receive any feedback.
    /// Returns true when the hail is accepted.
    /// Returns false when the target player cannot be hailed right now, for
    /// example because it's already communicating with something else.
    /// Requires a target option and message. The message can be an empty
    /// string.
    /// Example: obj:sendCommsMessage(player, "Prepare to die")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, sendCommsMessage);
    /// As sendCommsMessage, but sends an empty string as the message.
    /// Example: obj:openCommsTo(player)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, openCommsTo);
    /// Gets this object's callsign.
    /// Returns a string.
    /// Example: local callsign = obj:getCallSign()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getCallSign);
    /// Gets whether any objects from a hostile faction are within a specific
    /// radius of this object, in meters.
    /// Requires a numeric value for the radius.
    /// Returns true if hostiles are in range.
    /// Example: obj:areEnemiesInRange(5000)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, areEnemiesInRange);
    /// Gets any objects within a specific radius of this object, in meters.
    /// Requires a numeric value for the radius.
    /// Returns a list of SpaceObjects within range.
    /// Example: for _, obj_in_range in ipairs(obj:getObjectsInRange(5000)) ...
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getObjectsInRange);
    /// Sets this object's faction reputation to the specified amount.
    /// Requires a numeric value.
    /// Example: obj:setReputationPoints(1000)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setReputationPoints);
    /// Deduct a specified amount of faction reputation points from this object.
    /// Requires a numeric value.
    /// Returns true if there are enough points to deduct the specified amount.
    /// Returns false if there are not enough points, and does not deduct any.
    /// Example: local took_reputation = obj:takeReputationPoints(1000)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, takeReputationPoints);
    /// Adds a specified amount of faction reputation points to this object.
    /// Requires a numeric value.
    /// Example: obj:addReputationPoints(1000)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, addReputationPoints);
    /// Gets the name of the map sector, such as "A4", where this object is
    /// located.
    /// Returns a string value.
    /// Example: obj:getSectorName()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getSectorName);
    /// Gets this object's current faction reputation points.
    /// Returns an integer value.
    /// Example: local reputation = obj:getReputationPoints();
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getReputationPoints);
    /// Deals a specific amount of a specific type of damage to this object.
    /// Requires a numeric value for the damage amount, and accepts an optional
    /// DamageInfo type.
    /// The DamageInfo parameter can be empty, or a string that indicates
    /// whether to deal the default "energy" damage, "kinetic" damage, or "emp"
    /// damage, and can optionally be followed by the location of the damage's
    /// origin (for instance, to damage the correct shield on ships).
    /// SpaceObjects by default do not implement damage, instead leaving it to
    /// be overridden by specialized subclasses.
    /// Examples:
    ///              amount,  type,    x, y
    ///   obj:takeDamage(20, "emp", 1000, 0)
    ///   obj:takeDamage(20)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, takeDamage);
    /// Sets this object's description in unscanned and scanned states. These
    /// descriptions are displayed when this object is targeted from a ship's
    /// Science station.
    /// Requires two string values, one for the descriptions when unscanned
    /// and another for when it has been scanned.
    /// Example:
    ///   obj:setDescriptions([[A refitted Atlantis X23...]], [[It's a trap!]])
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setDescriptions);
    /// As setDescriptions, but sets the same description for both unscanned
    /// and scanned states.
    /// Requires a string value.
    /// Example: obj:setDescription([[A refitted Atlantis X23 for more ...]])
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setDescription);
    /// Sets a description for a specific EScannedState. String equivalents for
    /// EScannedState are defined in the convert<EScannedState> function of
    /// src/spaceObjects/spaceObject.cpp.
    /// Requires a string-equivalent EScannedState and a string description.
    /// Example:
    ///   obj:setDescriptionForScanState("friendorfoeidentified", [[This...]])
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setDescriptionForScanState);
    /// Gets this object's description.
    /// Accepts an optional string-equivalent EScannedState.
    /// Returns a string.
    /// Examples:
    ///   obj:getDescription()
    ///   obj:getDescription("friendorfoeidentified")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getDescription);
    /// Sets this object's radar signature, which creates noise on the Science
    /// station's raw radar signal ring.
    /// Certain SpaceObject types might modify their signatures using this value
    /// as a baseline. Default values also depend on the SpaceObject type.
    /// Requires numeric values ranging from 0.0 to 1.0 for the gravitational,
    /// electrical, and biological radar bands.
    /// Example: obj:setRadarSignatureInfo(0.0, 0.5, 1.0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setRadarSignatureInfo);
    /// Gets this object's component values from its radar signature.
    /// Returns a numeric value between 0.0 and 1.0; larger and negative values
    /// are possible, but currently have no visual effect on the bands.
    /// Examples:
    ///   local grav_band = obj:getRadarSignatureGravity()
    ///   local elec_band = obj:getRadarSignatureElectrical()
    ///   local bio_band = obj:getRadarSignatureBiological()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getRadarSignatureGravity);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getRadarSignatureElectrical);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getRadarSignatureBiological);
    /// Sets this object's scanning complexity (number of bars in the scanning
    /// minigame) and depth (number of scanning minigames to complete).
    /// Also clears the scanned state.
    /// Requires two integer values.
    /// Example: obj:setScanningParameters(2, 3)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setScanningParameters);
    /// Gets the scanning complexity for the parameter object.
    /// Requires a SpaceObject.
    /// Returns an integer value.
    /// Example: local scan_complexity = obj:scanningComplexity(obj)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, scanningComplexity);
    /// Gets the scanning depth for the parameter object.
    /// Requires a SpaceObject.
    /// Returns an integer value.
    /// Example: local scan_depth = obj:scanningChannelDepth(obj)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, scanningChannelDepth);
    /// Sets whether all factions consider this object as having been scanned.
    /// Requires a boolean value. If false, all factions treat this object as
    /// unscanned; if true, all factions treat this object as fully scanned.
    /// Example: obj:setScanned(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setScanned);
    /// [DEPRECATED]
    /// Gets whether this object has been scanned.
    /// Use isScannedBy or isScannedByFaction instead.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isScanned);
    /// Gets whether the parameter object has successfully scanned this object.
    /// Requires a SpaceObject.
    /// Returns a boolean value.
    /// Example: obj:isScannedBy(other)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isScannedBy);
    /// Sets whether a specific faction considers this object as having been
    /// scanned.
    /// Requires a faction name string value and a boolean value.
    /// Example: obj:setScannedByFaction("Human Navy", false)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setScannedByFaction);
    /// Gets whether the parameter faction has successfully scanned this object.
    /// Requires a faction name string value.
    /// Returns a boolean value.
    /// Example: obj:isScannedByFaction("Human Navy")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isScannedByFaction);
    // Register a callback that is called when this object is destroyed, by any means.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, onDestroyed);
}

PVector<SpaceObject> space_object_list;

SpaceObject::SpaceObject(float collision_range, string multiplayer_name, float multiplayer_significant_range)
: Collisionable(collision_range), MultiplayerObject(multiplayer_name)
{
    object_radius = collision_range;
    space_object_list.push_back(this);
    faction_id = 0;

    scanning_complexity_value = 0;
    scanning_depth_value = 0;

    registerMemberReplication(&callsign);
    registerMemberReplication(&faction_id);
    registerMemberReplication(&scanned_by_faction);
    registerMemberReplication(&object_description.not_scanned);
    registerMemberReplication(&object_description.friend_of_foe_identified);
    registerMemberReplication(&object_description.simple_scan);
    registerMemberReplication(&object_description.full_scan);
    registerMemberReplication(&radar_signature.gravity);
    registerMemberReplication(&radar_signature.electrical);
    registerMemberReplication(&radar_signature.biological);
    registerMemberReplication(&scanning_complexity_value);
    registerMemberReplication(&scanning_depth_value);
    registerCollisionableReplication(multiplayer_significant_range);
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
SpaceObject::~SpaceObject()
{
}

void SpaceObject::draw3D()
{
#if FEATURE_3D_RENDERING
    model_info.render(getPosition(), getRotation());
#endif//FEATURE_3D_RENDERING
}

void SpaceObject::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool longRange)
{
}

void SpaceObject::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool longRange)
{
}

void SpaceObject::destroy()
{
    on_destroyed.call(P<SpaceObject>(this));
    MultiplayerObject::destroy();
}

bool SpaceObject::canBeTargetedBy(P<SpaceObject> other)
{
    return false;
}

bool SpaceObject::canBeSelectedBy(P<SpaceObject> other)
{
    if (getDescriptionFor(other).length() > 0)
        return true;
    if (canBeScannedBy(other))
        return true;
    if (canBeTargetedBy(other))
        return true;
    return false;
}

bool SpaceObject::canBeScannedBy(P<SpaceObject> other)
{
    if (getScannedStateFor(other) == SS_FullScan)
        return false;
    if (scanning_complexity_value > 0)
        return true;
    if (scanning_depth_value > 0)
        return true;
    return false;
}

bool SpaceObject::canBeHackedBy(P<SpaceObject> other)
{
    return false;
}

std::vector<std::pair<string, float> > SpaceObject::getHackingTargets()
{
    return std::vector<std::pair<string, float> >();
}

void SpaceObject::hackFinished(P<SpaceObject> source, string target)
{
}

EScannedState SpaceObject::getScannedStateFor(P<SpaceObject> other)
{
    if (!other)
    {
        return SS_NotScanned;
    }
    return getScannedStateForFaction(other->getFactionId());
}

void SpaceObject::setScannedStateFor(P<SpaceObject> other, EScannedState state)
{
    if (!other)
    {
        LOG(ERROR) << "setScannedStateFor called with no other";
        return;
    }
    setScannedStateForFaction(other->getFactionId(), state);
}

EScannedState SpaceObject::getScannedStateForFaction(int faction_id)
{
    if (int(scanned_by_faction.size()) <= faction_id)
        return SS_NotScanned;
    return scanned_by_faction[faction_id];
}

void SpaceObject::setScannedStateForFaction(int faction_id, EScannedState state)
{
    while (int(scanned_by_faction.size()) <= faction_id)
        scanned_by_faction.push_back(SS_NotScanned);
    scanned_by_faction[faction_id] = state;
}

bool SpaceObject::isScanned()
{
    LOG(WARNING) << "Depricated \"isScanned\" function called, use isScannedBy or isScannedByFaction.";
    for(unsigned int faction_id = 0; faction_id < scanned_by_faction.size(); faction_id++)
    {
        if (scanned_by_faction[faction_id] > SS_FriendOrFoeIdentified)
            return true;
    }
    return false;
}

void SpaceObject::setScanned(bool scanned)
{
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
    {
        if (!scanned)
            setScannedStateForFaction(faction_id, SS_NotScanned);
        else
            setScannedStateForFaction(faction_id, SS_FullScan);
    }
}

void SpaceObject::setScannedByFaction(string faction_name, bool scanned)
{
    if (!scanned)
        setScannedStateForFaction(FactionInfo::findFactionId(faction_name), SS_NotScanned);
    else
        setScannedStateForFaction(FactionInfo::findFactionId(faction_name), SS_FullScan);
}

bool SpaceObject::isScannedBy(P<SpaceObject> obj)
{
    return getScannedStateFor(obj) > SS_FriendOrFoeIdentified;
}

bool SpaceObject::isScannedByFaction(string faction)
{
    int faction_id = FactionInfo::findFactionId(faction);
    return getScannedStateForFaction(faction_id) > SS_FriendOrFoeIdentified;
}

void SpaceObject::scannedBy(P<SpaceObject> other)
{
    setScannedStateFor(other, SS_FullScan);
}

void SpaceObject::setScanningParameters(int complexity, int depth)
{
    scanning_complexity_value = std::min(4, std::max(0, complexity));
    scanning_depth_value = std::max(0, depth);

    scanned_by_faction.clear();
}

bool SpaceObject::isEnemy(P<SpaceObject> obj)
{
    if (obj)
    {
        return factionInfo[faction_id]->states[obj->faction_id] == FVF_Enemy;
    } else {
        return false;
    }
}

bool SpaceObject::isFriendly(P<SpaceObject> obj)
{
    if (obj)
    {
        return factionInfo[faction_id]->states[obj->faction_id] == FVF_Friendly;
    } else {
        return false;
    }
}

void SpaceObject::damageArea(sf::Vector2f position, float blast_range, float min_damage, float max_damage, DamageInfo info, float min_range)
{
    PVector<Collisionable> hitList = CollisionManager::queryArea(position - sf::Vector2f(blast_range, blast_range), position + sf::Vector2f(blast_range, blast_range));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj)
        {
            float dist = sf::length(position - obj->getPosition()) - obj->getRadius() - min_range;
            if (dist < 0) dist = 0;
            if (dist < blast_range - min_range)
            {
                obj->takeDamage(max_damage - (max_damage - min_damage) * dist / (blast_range - min_range), info);
            }
        }
    }
}

bool SpaceObject::areEnemiesInRange(float range)
{
    PVector<Collisionable> hitList = CollisionManager::queryArea(getPosition() - sf::Vector2f(range, range), getPosition() + sf::Vector2f(range, range));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj && isEnemy(obj))
        {
            if (getPosition() - obj->getPosition() < range + obj->getRadius())
                return true;
        }
    }
    return false;
}

PVector<SpaceObject> SpaceObject::getObjectsInRange(float range)
{
    PVector<SpaceObject> ret;
    PVector<Collisionable> hitList = CollisionManager::queryArea(getPosition() - sf::Vector2f(range, range), getPosition() + sf::Vector2f(range, range));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj && getPosition() - obj->getPosition() < range + obj->getRadius())
        {
            ret.push_back(obj);
        }
    }
    return ret;
}

void SpaceObject::setReputationPoints(float amount)
{
    if (gameGlobalInfo->reputation_points.size() < faction_id)
        return;
    gameGlobalInfo->reputation_points[faction_id] = amount;
}

int SpaceObject::getReputationPoints()
{
    if (gameGlobalInfo->reputation_points.size() < faction_id)
        return 0;
    return gameGlobalInfo->reputation_points[faction_id];
}

bool SpaceObject::takeReputationPoints(float amount)
{
    if (gameGlobalInfo->reputation_points.size() < faction_id)
        return false;
     if (gameGlobalInfo->reputation_points[faction_id] < amount)
        return false;
    gameGlobalInfo->reputation_points[faction_id] -= amount;
    return true;
}

void SpaceObject::removeReputationPoints(float amount)
{
    addReputationPoints(-amount);
}

void SpaceObject::addReputationPoints(float amount)
{
    if (gameGlobalInfo->reputation_points.size() < faction_id)
        return;
    gameGlobalInfo->reputation_points[faction_id] += amount;
    if (gameGlobalInfo->reputation_points[faction_id] < 0.0)
        gameGlobalInfo->reputation_points[faction_id] = 0.0;
}

string SpaceObject::getSectorName()
{
    return ::getSectorName(getPosition());
}

bool SpaceObject::openCommsTo(P<PlayerSpaceship> target)
{
    return sendCommsMessage(target, "");
}

bool SpaceObject::sendCommsMessage(P<PlayerSpaceship> target, string message)
{
    if (!target)
        return false;

    bool result = target->hailByObject(this, message);
    if (!result && message != "")
    {
        target->addToShipLogBy(message, this);
    }
    return result;
}

// Define a script conversion function for the DamageInfo structure.
template<> void convert<DamageInfo>::param(lua_State* L, int& idx, DamageInfo& di)
{
    if (!lua_isstring(L, idx))
        return;
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "energy")
        di.type = DT_Energy;
    else if (str == "kinetic")
        di.type = DT_Kinetic;
    else if (str == "emp")
        di.type = DT_EMP;

    if (!lua_isnumber(L, idx))
        return;

    di.location.x = luaL_checknumber(L, idx++);
    di.location.y = luaL_checknumber(L, idx++);

    if (lua_isnil(L, idx))
        idx++;
    else if (!lua_isnumber(L, idx))
        return;
    else
        di.frequency = luaL_checkinteger(L, idx++);

    if (!lua_isstring(L, idx))
        return;

    convert<ESystem>::param(L, idx, di.system_target);
}

template<> void convert<EScannedState>::param(lua_State* L, int& idx, EScannedState& ss)
{
    ss = SS_NotScanned;
    if (!lua_isstring(L, idx))
        return;
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "notscanned" || str == "not")
        ss = SS_NotScanned;
    else if (str == "friendorfoeidentified")
        ss = SS_FriendOrFoeIdentified;
    else if (str == "simple" || str == "simplescan")
        ss = SS_SimpleScan;
    else if (str == "full" || str == "fullscan")
        ss = SS_FullScan;
}

template<> int convert<EDamageType>::returnType(lua_State* L, EDamageType es)
{
    switch(es)
    {
    case DT_Kinetic:
        lua_pushstring(L, "kinetic");
        return 1;
    case DT_EMP:
        lua_pushstring(L, "emp");
        return 1;
    case DT_Energy:
        lua_pushstring(L, "energy");
        return 1;
    default:
        return 0;
    }
}
