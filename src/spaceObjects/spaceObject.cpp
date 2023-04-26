#include "spaceObject.h"
#include "factionInfo.h"
#include "gameGlobalInfo.h"
#include "preferenceManager.h"
#include "components/collision.h"
#include "systems/collision.h"
#include "systems/comms.h"
#include "ecs/query.h"

#include <glm/ext/matrix_transform.hpp>

#include "scriptInterface.h"

/// SpaceObject is the base class for every object in the game universe.
/// Scripts can't create SpaceObjects directly, but all objects of SpaceObject subclasses can also access these core functions.
/// Each object has a position, rotation, and collision shape.
/// The Collisionable class is provided by SeriousProton.
REGISTER_SCRIPT_CLASS_NO_CREATE(SpaceObject)
{
    /// Sets this SpaceObject's position on the map, in meters from the origin.
    /// Example: obj:setPosition(x,y)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setPosition);
    /// Returns this object's position on the map.
    /// Example: x,y = obj:getPosition()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getPosition);
    /// Sets this SpaceObject's absolute rotation, in degrees.
    /// Unlike SpaceObject:setHeading(), a value of 0 points to the right of the map ("east").
    /// The value can also be unbounded; it can be negative, or greater than 360 degrees.
    /// SpaceObject:setHeading() and SpaceObject:setRotation() do not change the helm's target heading on PlayerSpaceships. To do that, use PlayerSpaceship:commandTargetRotation().
    /// Example: obj:setRotation(270)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setRotation);
    /// Returns this SpaceObject's absolute rotation, in degrees.
    /// Example: local rotation = obj:getRotation()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getRotation);
    /// Sets this SpaceObject's heading, in degrees ranging from 0 to 360.
    /// Unlike SpaceObject:setRotation(), a value of 0 points to the top of the map ("north").
    /// Values that are negative or greater than 360 are converted to values within that range.
    /// SpaceObject:setHeading() and SpaceObject:setRotation() do not change the helm's target heading on PlayerSpaceships. To do that, use PlayerSpaceship:commandTargetRotation().
    /// Example: obj:setHeading(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setHeading);
    /// Returns this SpaceObject's heading, in degrees ranging from 0 to 360.
    /// Example: heading = obj:getHeading(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getHeading);
    /// Returns this SpaceObject's directional velocity within 2D space as an x/y vector.
    /// The values are relative x/y coordinates from the SpaceObject's current position (a 2D velocity vector).
    /// Example: vx,vy = obj:getVelocity()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getVelocity);
    /// Returns this SpaceObject's rotational velocity within 2D space, in degrees per second.
    /// Example: obj:getAngularVelocity()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getAngularVelocity);
    /// Sets the faction to which this SpaceObject belongs, by faction name.
    /// Factions are defined by the FactionInfo class, and default factions are defined in scripts/factionInfo.lua.
    /// Requires a faction name string.
    /// Example: obj:setFaction("Human Navy")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFaction);
    /// Returns the name of the faction to which this SpaceObject belongs.
    /// Example: obj:getFaction()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getFaction);
    /// Returns the localized name of the faction to which this SpaceObject belongs.
    /// Example: obj:getLocaleFaction()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getLocaleFaction);
    /// Returns the faction to which this SpaceObject belongs, by the faction's index in the faction list.
    /// Use with SpaceObject:getFactionId() to ensure that two objects belong to the same faction.
    /// Example: local faction_id = obj:getFactionId()
    //TODO: REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setFactionId);
    /// Returns the faction list index for the faction to which this SpaceObject belongs.
    /// Use with SpaceObject:setFactionId() to ensure that two objects belong to the same faction.
    /// Example: obj:setFactionId(target:getFactionId())
    //TODO: REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getFactionId);
    /// Returns the friend-or-foe status of the given faction relative to this SpaceObject's faction.
    /// Returns true if the given SpaceObject's faction is hostile to this object's.
    /// Example: obj:isEnemy(target)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isEnemy);
    /// Returns the friend-or-foe status of the given faction relative to this SpaceObject's faction.
    /// Returns true if the given SpaceObject's faction is friendly to this object's.
    /// If an object is neither friendly nor enemy, it is neutral.
    /// Example: obj:isFriendly(target)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isFriendly);
    /// Sets the communications script used when this SpaceObject is hailed.
    /// Accepts the filename of a Lua script relative to the scripts/ directory.
    /// If set to an empty string, comms with this object are disabled.
    /// The globals comms_source (PlayerSpaceship) and comms_target (SpaceObject) are made available in the scenario script.
    /// Subclasses set their own default comms scripts.
    /// For object types without defaults, or when creating custom comms scripts, use setCommsMessage() to define the message and addCommsReply() to provide player response options.
    /// See also SpaceObject:setCommsFunction().
    /// Examples:
    /// obj:setCommsScript("comms_custom_script.lua") -- sets scripts/comms_custom_script.lua as this object's comms script
    /// obj:setCommsScript("") -- disables comms with this object
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCommsScript);
    /// Defines a function to call when this SpaceObject is hailed, in lieu of any current or default comms script.
    /// For a detailed example, see scripts/scenario_53_escape.lua.
    /// TODO: Confirm this: The globals comms_source (PlayerSpaceship) and comms_target (SpaceObject) are made available in the scenario script.
    /// They remain as globals. As usual, such globals are not accessible in required files.
    /// Instead of using the globals, the callback can optionally take two equivalent parameters.
    /// See also SpaceObject:setCommsScript().
    /// Examples:
    /// obj:setCommsFunction(function(comms_source, comms_target) ... end)
    /// Example: obj:setCommsFunction(commsStation) -- where commsStation is a function that calls setCommsMessage() at least once, and uses addCommsReply() to let players respond
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCommsFunction);
    /// Sets this SpaceObject's callsign.
    /// EmptyEpsilon generates random callsigns for objects upon creation, and this function overrides that default.
    /// Example: obj:setCallSign("Epsilon")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setCallSign);
    /// Hails a PlayerSpaceship from this SpaceObject.
    /// The PlayerSpaceship's comms position is notified and can accept or refuse the hail.
    /// If the PlayerSpaceship accepts the hail, this displays the given message.
    /// Returns true when the hail is accepted.
    /// Returns false if the hail is refused, or when the target player cannot be hailed right now, for example because it's already communicating with something else.
    /// This logs a message in the target's comms log. To avoid logging, use SpaceObject:sendCommsMessageNoLog().
    /// Requires a target PlayerShip and message, though the message can be an empty string.
    /// Example: obj:sendCommsMessage(player, "Prepare to die")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, sendCommsMessage);
    /// As SpaceObject:sendCommsMessage(), but does not log a failed hail to the target ship's comms log.
    /// Example: obj:sendCommsMessageNoLog(player, "Prepare to die")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, sendCommsMessageNoLog);
    /// As SpaceObject:sendCommsMessage(), but sends an empty string as the message.
    /// This calls the SpaceObject's comms function.
    /// Example: obj:openCommsTo(player)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, openCommsTo);
    /// Returns this SpaceObject's callsign.
    /// Example: obj:getCallSign()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getCallSign);
    /// Returns whether any SpaceObject from a hostile faction are within a given radius of this SpaceObject, in (unit?).
    /// Example: obj:areEnemiesInRange(5000) -- returns true if hostiles are within 5U of this object
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, areEnemiesInRange);
    /// Returns any SpaceObject within a specific radius, in (unit?), of this SpaceObject.
    /// Returns a list of all SpaceObjects within range.
    /// Example: obj:getObjectsInRange(5000) -- returns all objects within 5U of this SpaceObject.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getObjectsInRange);
    /// Returns this SpaceObject's faction reputation points.
    /// Example: obj:getReputationPoints()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getReputationPoints);
    /// Sets this SpaceObject's faction reputation points to the given amount.
    /// Example: obj:setReputationPoints(1000)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setReputationPoints);
    /// Deducts a given number of faction reputation points from this SpaceObject.
    /// Returns true if there are enough points to deduct the specified amount, then does so.
    /// Returns false if there are not enough points, then does not deduct any.
    /// Example: obj:takeReputationPoints(1000) -- returns false if `obj` has fewer than 1000 reputation points, otherwise returns true and deducts the points
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, takeReputationPoints);
    /// Adds a given number of faction reputation points to this SpaceObject.
    /// Example: obj:addReputationPoints(1000)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, addReputationPoints);
    /// Returns the name of the map sector, such as "A4", where this SpaceObject is located.
    /// Example: obj:getSectorName()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getSectorName);
    /// Deals a specific amount of a specific type of damage to this SpaceObject.
    /// Requires a numeric value for the damage amount, and accepts an optional DamageInfo type.
    /// The optional DamageInfo parameter can be empty, which deals "energy" damage, or a string that indicates which type of damage to deal.
    /// Valid damage types are "energy", "kinetic", and "emp".
    /// If you specify a damage type, you can also optionally specify the location of the damage's origin, for instance to damage a specific shield segment on the target.
    /// SpaceObjects by default do not implement damage, instead leaving it to be overridden by specialized subclasses.
    /// Examples:
    /// obj:takeDamage(20, "emp", 1000, 0) -- deals 20 EMP damage as if it had originated from coordinates 1000,0
    /// obj:takeDamage(20) -- deals 20 energy damage
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, takeDamage);
    /// Sets this SpaceObject's description in unscanned and scanned states.
    /// The science screen displays these descriptions when targeting a scanned object.
    /// Requires two string values, one for the descriptions when unscanned and another for when it has been scanned.
    /// Example:
    ///   obj:setDescriptions("A refitted Atlantis X23...", "It's a trap!")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setDescriptions);
    /// As setDescriptions, but sets the same description for both unscanned and scanned states.
    /// Example: obj:setDescription("A refitted Atlantis X23 for more ...")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setDescription);
    /// Sets a description for a given EScannedState on this SpaceObject.
    /// Only SpaceShip objects are created in an unscanned state. Other SpaceObjects are created as fully scanned.
    /// - "notscanned" or "not": The object has not been scanned.
    /// - "friendorfoeidentified": The object has been identified as hostile or friendly, but has not been scanned.
    /// - "simplescan" or "simple": The object has been scanned once under default server settings, displaying only basic information about the object.
    /// - "fullscan" or "full": The object is fully scanned.
    /// Example: obj:setDescriptionForScanState("friendorfoeidentified", "A refitted...")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setDescriptionForScanState);
    /// Returns this SpaceObject's description for the given EScannedState.
    /// Accepts an optional string-equivalent EScannedState, which determines which description to return.
    /// Defaults to returning the "fullscan" description.
    /// Examples:
    /// obj:getDescription() -- returns the "fullscan" description
    /// obj:getDescription("friendorfoeidentified") -- returns the "friendorfoeidentified" description
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getDescription);
    /// Sets this SpaceObject's radar signature, which creates noise on the science screen's raw radar signal ring.
    /// The raw signal ring contains red, green, and blue bands of waveform noise.
    /// Certain SpaceObject subclasses might set their own defaults or dynamically modify their signatures using this value as a baseline.
    /// Requires numeric values ranging from 0.0 to 1.0 for the gravitational, electrical, and biological radar bands, in that order.
    /// Larger and negative values are possible, but currently have no visual effect on the bands.
    /// - Gravitational signatures amplify noise on all bands, particularly the green and blue bands.
    /// - Electrical signatures amplify noise on the red and blue bands.
    /// - Biological signatures amplify noise on the red and green bands.
    /// Example: obj:setRadarSignatureInfo(0.0, 0.5, 1.0) -- a radar signature of 0 gravitational, 0.5 electrical, and 1.0 biological
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setRadarSignatureInfo);
    /// Returns this SpaceObject's gravitational radar signature value.
    /// Example: obj:getRadarSignatureGravity()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getRadarSignatureGravity);
    /// Returns this SpaceObject's electical radar signature value.
    /// Example: obj:getRadarSignatureElectrical()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getRadarSignatureElectrical);
    /// Returns this SpaceObject's biological radar signature value.
    /// Example: obj:getRadarSignatureBiological()
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, getRadarSignatureBiological);
    /// Sets this SpaceObject's scanning complexity (number of bars in the scanning minigame) and depth (number of scanning minigames to complete until fully scanned), respectively.
    /// Setting this also clears the object's scanned state.
    /// Example: obj:setScanningParameters(2, 3)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setScanningParameters);
    /// Returns the scanning complexity for the given SpaceObject.
    /// Example: obj:scanningComplexity(obj)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, scanningComplexity);
    /// Returns the maximum scanning depth for the given SpaceObject.
    /// Example: obj:scanningChannelDepth(obj)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, scanningChannelDepth);
    /// Defines whether all factions consider this SpaceObject as having been scanned.
    /// Only SpaceShip objects are created in an unscanned state. Other SpaceObjects are created as fully scanned.
    /// If false, all factions treat this object as unscanned.
    /// If true, all factions treat this object as fully scanned.
    /// Example: obj:setScanned(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setScanned);
    /// [DEPRECATED]
    /// Returns whether this SpaceObject has been scanned.
    /// Use SpaceObject:isScannedBy() or SpaceObject:isScannedByFaction() instead.
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isScanned);
    /// Returns whether the given SpaceObject has successfully scanned this SpaceObject.
    /// Example: obj:isScannedBy(other)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isScannedBy);
    /// Defines whether a given faction considers this SpaceObject as having been scanned.
    /// Requires a faction name string value as defined by its FactionInfo, and a Boolean value.
    /// Example: obj:setScannedByFaction("Human Navy", false)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, setScannedByFaction);
    /// Returns whether the given faction has successfully scanned this SpaceObject.
    /// Requires a faction name string value as defined by its FactionInfo.
    /// Example: obj:isScannedByFaction("Human Navy")
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, isScannedByFaction);
    /// Defines a function to call when this SpaceObject is destroyed by any means.
    /// Example:
    /// -- Prints to the console window or logging file when this SpaceObject is destroyed
    /// obj:onDestroyed(function() print("Object destroyed!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceObject, onDestroyed);
}

PVector<SpaceObject> space_object_list;

SpaceObject::SpaceObject(float collision_range, string multiplayer_name, float multiplayer_significant_range)
: MultiplayerObject(multiplayer_name)
{
    if (isServer()) {
        entity = sp::ecs::Entity::create();
        //TODO: multiplayer_significant_range
        entity.addComponent<sp::Transform>();
        entity.addComponent<sp::Physics>().setCircle(sp::Physics::Type::Sensor, collision_range);
    }

    space_object_list.push_back(this);

    registerMemberReplication(&entity);
}

SpaceObject::~SpaceObject()
{
    entity.destroy();
}

void SpaceObject::draw3D()
{
}

void SpaceObject::drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool longRange)
{
}

void SpaceObject::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool longRange)
{
}

void SpaceObject::destroy()
{
    on_destroyed.call<void>(P<SpaceObject>(this));
    MultiplayerObject::destroy();
}

bool SpaceObject::canBeTargetedBy(sp::ecs::Entity other)
{
    return false;
}

bool SpaceObject::canBeSelectedBy(sp::ecs::Entity other)
{
    if (getDescriptionFor(other).length() > 0)
        return true;
    if (canBeScannedBy(other))
        return true;
    if (canBeTargetedBy(other))
        return true;
    return false;
}

bool SpaceObject::canBeScannedBy(sp::ecs::Entity other)
{
    auto scanstate = entity.getComponent<ScanState>();
    if (scanstate) {
        if (getScannedStateFor(other) == ScanState::State::FullScan)
            return false;
        return true;
    }
    return false;
}

void SpaceObject::hackFinished(sp::ecs::Entity source, ShipSystem::Type target)
{
}

ScanState::State SpaceObject::getScannedStateFor(sp::ecs::Entity other)
{
    if (!other)
        return ScanState::State::NotScanned;
    auto f = other.getComponent<Faction>();
    if (!f)
        return ScanState::State::NotScanned;
    return getScannedStateForFaction(f->entity);
}

void SpaceObject::setScannedStateFor(P<SpaceObject> other, ScanState::State state)
{
    if (!other)
    {
        LOG(ERROR) << "setScannedStateFor called with no other";
        return;
    }
    auto f = other->entity.getComponent<Faction>();
    if (f)
        setScannedStateForFaction(f->entity, state);
    else
        setScannedStateForFaction({}, state);
}

ScanState::State SpaceObject::getScannedStateForFaction(sp::ecs::Entity faction_entity)
{
    auto scanstate = entity.getComponent<ScanState>();
    if (!scanstate) return ScanState::State::FullScan;

    for(auto& it : scanstate->per_faction) {
        if (it.first == faction_entity)
            return it.second;
    }
    return ScanState::State::NotScanned;
}

void SpaceObject::setScannedStateForFaction(sp::ecs::Entity faction_entity, ScanState::State state)
{
    auto scanstate = entity.getComponent<ScanState>();
    if (!scanstate) return;

    for(auto& it : scanstate->per_faction) {
        if (it.first == faction_entity) {
            it.second = state;
            return;
        }
    }
    scanstate->per_faction.push_back({faction_entity, state});
}

bool SpaceObject::isScanned()
{
    LOG(WARNING) << "Depricated \"isScanned\" function called, use isScannedBy or isScannedByFaction.";

    auto scanstate = entity.getComponent<ScanState>();
    if (!scanstate) return true;
    for(auto& it : scanstate->per_faction) {
        if (it.second > ScanState::State::FriendOrFoeIdentified)
            return true;
    }
    return false;
}

void SpaceObject::setScanned(bool scanned)
{
    for(auto [entity, faction_info] : sp::ecs::Query<FactionInfo>()) {
        if (!scanned)
            setScannedStateForFaction(entity, ScanState::State::NotScanned);
        else
            setScannedStateForFaction(entity, ScanState::State::FullScan);
    }
}

void SpaceObject::setScannedByFaction(string faction_name, bool scanned)
{
    if (!scanned)
        setScannedStateForFaction(Faction::find(faction_name), ScanState::State::NotScanned);
    else
        setScannedStateForFaction(Faction::find(faction_name), ScanState::State::FullScan);
}

bool SpaceObject::isScannedBy(P<SpaceObject> obj)
{
    return getScannedStateFor(obj->entity) > ScanState::State::FriendOrFoeIdentified;
}

bool SpaceObject::isScannedByFaction(string faction_name)
{
    auto faction_id = Faction::find(faction_name);
    return getScannedStateForFaction(faction_id) > ScanState::State::FriendOrFoeIdentified;
}

void SpaceObject::setScanningParameters(int complexity, int depth)
{
    auto& scanstate = entity.getOrAddComponent<ScanState>();
    scanstate.complexity = std::min(4, std::max(0, complexity));
    scanstate.depth = std::max(0, depth);
    scanstate.per_faction.clear();
}

bool SpaceObject::isEnemy(P<SpaceObject> obj)
{
    if (obj)
    {
        return Faction::getRelation(entity, obj->entity) == FactionRelation::Enemy;
    } else {
        return false;
    }
}

bool SpaceObject::isFriendly(P<SpaceObject> obj)
{
    if (obj)
    {
        return Faction::getRelation(entity, obj->entity) == FactionRelation::Friendly;
    } else {
        return false;
    }
}

void SpaceObject::setFaction(string faction_name)
{
    auto faction = Faction::find(faction_name);
    if (faction)
        entity.addComponent<Faction>(faction);
    else
        entity.removeComponent<Faction>();
}

bool SpaceObject::areEnemiesInRange(float range)
{
    for(auto entity : sp::CollisionSystem::queryArea(getPosition() - glm::vec2(range, range), getPosition() + glm::vec2(range, range)))
    {
        auto ptr = entity.getComponent<SpaceObject*>();
        if (!ptr) continue;
        auto pos = entity.getComponent<sp::Transform>();
        if (!pos) continue;
        P<SpaceObject> obj = *ptr;
        if (obj && isEnemy(obj))
        {
            auto r = range;
            auto physics = entity.getComponent<sp::Physics>();
            if (physics) r += physics->getSize().x;
            if (glm::length2(getPosition() - obj->getPosition()) < r*r)
                return true;
        }
    }
    return false;
}

PVector<SpaceObject> SpaceObject::getObjectsInRange(float range)
{
    PVector<SpaceObject> ret;
    for(auto entity : sp::CollisionSystem::queryArea(getPosition() - glm::vec2(range, range), getPosition() + glm::vec2(range, range)))
    {
        auto ptr = entity.getComponent<SpaceObject*>();
        if (!ptr) continue;
        auto pos = entity.getComponent<sp::Transform>();
        if (!pos) continue;
        P<SpaceObject> obj = *ptr;
        auto r = range;
        auto physics = entity.getComponent<sp::Physics>();
        if (physics) r += physics->getSize().x;
        if (obj && glm::length2(getPosition() - obj->getPosition()) < r*r)
        {
            ret.push_back(obj);
        }
    }
    return ret;
}

void SpaceObject::setReputationPoints(float amount)
{
    auto faction = Faction::getInfo(entity);
    faction.reputation_points = amount;
}

int SpaceObject::getReputationPoints()
{
    auto faction = Faction::getInfo(entity);
    return faction.reputation_points;
}

bool SpaceObject::takeReputationPoints(float amount)
{
    auto faction = Faction::getInfo(entity);
    if (faction.reputation_points < amount)
        return false;
    faction.reputation_points -= amount;
    return true;
}

void SpaceObject::removeReputationPoints(float amount)
{
    addReputationPoints(-amount);
}

void SpaceObject::addReputationPoints(float amount)
{
    auto faction = Faction::getInfo(entity);
    if (faction.reputation_points < amount)
        return;
    faction.reputation_points = std::max(0.0f, faction.reputation_points + amount);
}

void SpaceObject::setCommsScript(string script_name)
{
    /*TODO
    this->comms_script_name = script_name;
    if (script_name != "")
        i18n::load("locale/" + script_name.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));
    this->comms_script_callback.clear();
    */
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

    bool result = CommsSystem::hailByObject(target->entity, entity, message);
    if (!result && message != "")
    {
        target->addToShipLogBy(message, this);
    }
    return result;
}

bool SpaceObject::sendCommsMessageNoLog(P<PlayerSpaceship> target, string message)
{
    if (!target)
        return false;

    return CommsSystem::hailByObject(target->entity, entity, message);
}

glm::vec2 SpaceObject::getPosition() const
{
    if (!entity) return {};
    const auto position = entity.getComponent<sp::Transform>();
    if (!position) return {};
    return position->getPosition();
}

void SpaceObject::setPosition(glm::vec2 p)
{
    if (!entity) return;
    auto position = entity.getComponent<sp::Transform>();
    if (!position) return;
    position->setPosition(p);
}

float SpaceObject::getRotation() const
{
    if (!entity) return {};
    auto position = entity.getComponent<sp::Transform>();
    if (!position) return {};
    return position->getRotation();
}

void SpaceObject::setRotation(float a)
{
    if (!entity) return;
    auto position = entity.getComponent<sp::Transform>();
    if (!position) return;
    position->setRotation(a);
}

glm::vec2 SpaceObject::getVelocity() const
{
    if (!entity) return {};
    auto physics = entity.getComponent<sp::Physics>();
    if (!physics) return {};
    return physics->getVelocity();
}

float SpaceObject::getAngularVelocity() const
{
    if (!entity) return 0.0;
    auto physics = entity.getComponent<sp::Physics>();
    if (!physics) return 0.0;
    return physics->getAngularVelocity();
}


glm::mat4 SpaceObject::getModelMatrix() const
{
    auto position = getPosition();
    auto rotation = getRotation();
    auto model_matrix = glm::translate(glm::identity<glm::mat4>(), glm::vec3{ position.x, position.y, 0.f });
    return glm::rotate(model_matrix, glm::radians(rotation), glm::vec3{ 0.f, 0.f, 1.f });
}

template<> void convert<DamageType>::param(lua_State* L, int& idx, DamageType& dt)
{
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "energy")
        dt = DamageType::Energy;
    else if (str == "kinetic")
        dt = DamageType::Kinetic;
    else if (str == "emp")
        dt = DamageType::EMP;
}

// Define a script conversion function for the DamageInfo structure.
template<> void convert<DamageInfo>::param(lua_State* L, int& idx, DamageInfo& di)
{
    if (!lua_isstring(L, idx))
        return;
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "energy")
        di.type = DamageType::Energy;
    else if (str == "kinetic")
        di.type = DamageType::Kinetic;
    else if (str == "emp")
        di.type = DamageType::EMP;

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

    convert<ShipSystem::Type>::param(L, idx, di.system_target);
}

template<> void convert<ScanState::State>::param(lua_State* L, int& idx, ScanState::State& ss)
{
    ss = ScanState::State::NotScanned;
    if (!lua_isstring(L, idx))
        return;
    string str = string(luaL_checkstring(L, idx++)).lower();
    if (str == "notscanned" || str == "not")
        ss = ScanState::State::NotScanned;
    else if (str == "friendorfoeidentified")
        ss = ScanState::State::FriendOrFoeIdentified;
    else if (str == "simple" || str == "simplescan")
        ss = ScanState::State::SimpleScan;
    else if (str == "full" || str == "fullscan")
        ss = ScanState::State::FullScan;
}
