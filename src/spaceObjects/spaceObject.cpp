#include "spaceObject.h"
#include "gameGlobalInfo.h"
#include "preferenceManager.h"
#include "components/collision.h"
#include "systems/collision.h"
#include "systems/comms.h"
#include "playerSpaceship.h"
#include "ecs/query.h"

#include <glm/ext/matrix_transform.hpp>


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
    //TODO: on_destroyed.call<void>(P<SpaceObject>(this));
    MultiplayerObject::destroy();
}

bool SpaceObject::canBeTargetedBy(sp::ecs::Entity other)
{
    return false;
}

bool SpaceObject::canBeSelectedBy(sp::ecs::Entity other)
{
    //if (getDescriptionFor(other).length() > 0)
    //    return true;
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
        if (it.faction == faction_entity)
            return it.state;
    }
    return ScanState::State::NotScanned;
}

void SpaceObject::setScannedStateForFaction(sp::ecs::Entity faction_entity, ScanState::State state)
{
    auto scanstate = entity.getComponent<ScanState>();
    if (!scanstate) return;

    for(auto& it : scanstate->per_faction) {
        if (it.faction == faction_entity) {
            it.state = state;
            return;
        }
    }
    scanstate->per_faction.push_back({faction_entity, state});
    scanstate->per_faction_dirty = true;
}

bool SpaceObject::isScanned()
{
    LOG(WARNING) << "Depricated \"isScanned\" function called, use isScannedBy or isScannedByFaction.";

    auto scanstate = entity.getComponent<ScanState>();
    if (!scanstate) return true;
    for(auto& it : scanstate->per_faction) {
        if (it.state > ScanState::State::FriendOrFoeIdentified)
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
    scanstate.per_faction_dirty = true;
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

/*TODO
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
*/