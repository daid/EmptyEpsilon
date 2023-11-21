#pragma once

#include "script/environment.h"
#include "components/hull.h"
#include "components/collision.h"
#include "components/faction.h"
#include "components/ai.h"
#include "components/scanning.h"
#include "components/comms.h"
#include "missileWeaponData.h"


namespace sp::script {
template<> struct Convert<DamageType> {
    static int toLua(lua_State* L, DamageType value) {
        switch(value) {
        case DamageType::Energy: lua_pushstring(L, "energy"); break;
        case DamageType::Kinetic: lua_pushstring(L, "kinetic"); break;
        case DamageType::EMP: lua_pushstring(L, "emp"); break;
        }
        return 1;
    }
    static DamageType fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "energy")
            return DamageType::Energy;
        else if (str == "kinetic")
            return DamageType::Kinetic;
        else if (str == "emp")
            return DamageType::EMP;
        luaL_error(L, "Unknown damage type: %s", str.c_str());
        return DamageType::Energy;
    }
};
template<> struct Convert<sp::Physics::Type> {
    static int toLua(lua_State* L, sp::Physics::Type value) {
        switch(value) {
        case sp::Physics::Type::Sensor: lua_pushstring(L, "sensor"); break;
        case sp::Physics::Type::Dynamic: lua_pushstring(L, "dynamic"); break;
        case sp::Physics::Type::Static: lua_pushstring(L, "static"); break;
        }
        return 1;
    }
    static sp::Physics::Type fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "sensor")
            return sp::Physics::Type::Sensor;
        else if (str == "dynamic")
            return sp::Physics::Type::Dynamic;
        else if (str == "static")
            return sp::Physics::Type::Static;
        luaL_error(L, "Unknown physics type: %s", str.c_str());
        return sp::Physics::Type::Sensor;
    }
};
template<> struct Convert<FactionRelation> {
    static int toLua(lua_State* L, FactionRelation value) {
        switch(value) {
        case FactionRelation::Friendly: lua_pushstring(L, "friendly"); break;
        case FactionRelation::Neutral: lua_pushstring(L, "neutral"); break;
        case FactionRelation::Enemy: lua_pushstring(L, "enemy"); break;
        }
        return 1;
    }
    static FactionRelation fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "friendly")
            return FactionRelation::Friendly;
        else if (str == "neutral")
            return FactionRelation::Neutral;
        else if (str == "enemy")
            return FactionRelation::Enemy;
        luaL_error(L, "Unknown relation type: %s", str.c_str());
        return FactionRelation::Neutral;
    }
};
template<> struct Convert<ScanState::State> {
    static int toLua(lua_State* L, ScanState::State value) {
        switch(value) {
        case ScanState::State::NotScanned: lua_pushstring(L, "none"); break;
        case ScanState::State::FriendOrFoeIdentified: lua_pushstring(L, "fof"); break;
        case ScanState::State::SimpleScan: lua_pushstring(L, "simple"); break;
        case ScanState::State::FullScan: lua_pushstring(L, "full"); break;
        }
        return 1;
    }
    static ScanState::State fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "none")
            return ScanState::State::NotScanned;
        else if (str == "fof")
            return ScanState::State::FriendOrFoeIdentified;
        else if (str == "simple")
            return ScanState::State::SimpleScan;
        else if (str == "full")
            return ScanState::State::FullScan;
        luaL_error(L, "Unknown scan state type: %s", str.c_str());
        return ScanState::State::NotScanned;
    }
};
template<> struct Convert<AIOrder> {
    static int toLua(lua_State* L, AIOrder value) {
        switch(value) {
        case AIOrder::Idle: lua_pushstring(L, "idle"); break;
        case AIOrder::Roaming: lua_pushstring(L, "roaming"); break;
        case AIOrder::Retreat: lua_pushstring(L, "retreat"); break;
        case AIOrder::StandGround: lua_pushstring(L, "standground"); break;
        case AIOrder::DefendLocation: lua_pushstring(L, "defendlocation"); break;
        case AIOrder::DefendTarget: lua_pushstring(L, "defendtarget"); break;
        case AIOrder::FlyFormation: lua_pushstring(L, "flyformation"); break;
        case AIOrder::FlyTowards: lua_pushstring(L, "flytowards"); break;
        case AIOrder::FlyTowardsBlind: lua_pushstring(L, "flytowardsblind"); break;
        case AIOrder::Dock: lua_pushstring(L, "dock"); break;
        case AIOrder::Attack: lua_pushstring(L, "attack"); break;
        }
        return 1;
    }
    static AIOrder fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "idle")
            return AIOrder::Idle;
        else if (str == "roaming")
            return AIOrder::Roaming;
        else if (str == "retreat")
            return AIOrder::Retreat;
        else if (str == "standground")
            return AIOrder::StandGround;
        else if (str == "defendlocation")
            return AIOrder::DefendLocation;
        else if (str == "defendtarget")
            return AIOrder::DefendTarget;
        else if (str == "flyformation")
            return AIOrder::FlyFormation;
        else if (str == "flytowards")
            return AIOrder::FlyTowards;
        else if (str == "flytowardsblind")
            return AIOrder::FlyTowardsBlind;
        else if (str == "dock")
            return AIOrder::Dock;
        else if (str == "attack")
            return AIOrder::Attack;
        luaL_error(L, "Unknown AIOrder type: %s", str.c_str());
        return AIOrder::Idle;
    }
};
template<> struct Convert<EMissileWeapons> {
    static int toLua(lua_State* L, EMissileWeapons value) {
        switch(value) {
        case EMissileWeapons::MW_None: lua_pushstring(L, "none"); break;
        case EMissileWeapons::MW_Homing: lua_pushstring(L, "homing"); break;
        case EMissileWeapons::MW_Nuke: lua_pushstring(L, "nuke"); break;
        case EMissileWeapons::MW_Mine: lua_pushstring(L, "mine"); break;
        case EMissileWeapons::MW_EMP: lua_pushstring(L, "emp"); break;
        case EMissileWeapons::MW_HVLI: lua_pushstring(L, "hvli"); break;
        case EMissileWeapons::MW_Count: lua_pushstring(L, "none"); break;
        }
        return 1;
    }
    static EMissileWeapons fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "none")
            return EMissileWeapons::MW_None;
        else if (str == "homing")
            return EMissileWeapons::MW_Homing;
        else if (str == "nuke")
            return EMissileWeapons::MW_Nuke;
        else if (str == "mine")
            return EMissileWeapons::MW_Mine;
        else if (str == "emp")
            return EMissileWeapons::MW_EMP;
        else if (str == "hvli")
            return EMissileWeapons::MW_HVLI;
        luaL_error(L, "Unknown EMissileWeapons type: %s", str.c_str());
        return EMissileWeapons::MW_None;
    }
};
template<> struct Convert<ShipSystem::Type> {
    static int toLua(lua_State* L, ShipSystem::Type value) {
        switch(value) {
        case ShipSystem::Type::Reactor: lua_pushstring(L, "reactor"); break;
        case ShipSystem::Type::BeamWeapons: lua_pushstring(L, "beamweapons"); break;
        case ShipSystem::Type::MissileSystem: lua_pushstring(L, "missilesystem"); break;
        case ShipSystem::Type::Maneuver: lua_pushstring(L, "maneuver"); break;
        case ShipSystem::Type::Impulse: lua_pushstring(L, "impulse"); break;
        case ShipSystem::Type::Warp: lua_pushstring(L, "warp"); break;
        case ShipSystem::Type::JumpDrive: lua_pushstring(L, "jumpdrive"); break;
        case ShipSystem::Type::FrontShield: lua_pushstring(L, "frontshield"); break;
        case ShipSystem::Type::RearShield: lua_pushstring(L, "rearshield"); break;
        default: lua_pushstring(L, "none"); break;
        }
        return 1;
    }
    static ShipSystem::Type fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "none")
            return ShipSystem::Type::None;
        else if (str == "reactor")
            return ShipSystem::Type::Reactor;
        else if (str == "beamweapons")
            return ShipSystem::Type::BeamWeapons;
        else if (str == "missilesystem")
            return ShipSystem::Type::MissileSystem;
        else if (str == "maneuver")
            return ShipSystem::Type::Maneuver;
        else if (str == "impulse")
            return ShipSystem::Type::Impulse;
        else if (str == "warp")
            return ShipSystem::Type::Warp;
        else if (str == "jumpdrive")
            return ShipSystem::Type::JumpDrive;
        else if (str == "frontshield")
            return ShipSystem::Type::FrontShield;
        else if (str == "rearshield")
            return ShipSystem::Type::RearShield;
        luaL_error(L, "Unknown ShipSystem::Type: %s", str.c_str());
        return ShipSystem::Type::None;
    }
};
template<> struct Convert<EMissileSizes> {
    static int toLua(lua_State* L, EMissileSizes value) {
        switch(value) {
        case EMissileSizes::MS_Small: lua_pushstring(L, "small"); break;
        case EMissileSizes::MS_Medium: lua_pushstring(L, "medium"); break;
        case EMissileSizes::MS_Large: lua_pushstring(L, "large"); break;
        default: lua_pushstring(L, "none"); break;
        }
        return 1;
    }
    static EMissileSizes fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "small")
            return EMissileSizes::MS_Small;
        else if (str == "medium")
            return EMissileSizes::MS_Medium;
        else if (str == "large")
            return EMissileSizes::MS_Large;
        luaL_error(L, "Unknown EMissileSizes: %s", str.c_str());
        return EMissileSizes::MS_Medium;
    }
};
template<> struct Convert<CommsTransmitter::State> {
    static int toLua(lua_State* L, CommsTransmitter::State value) {
        switch(value) {
        case CommsTransmitter::State::Inactive: lua_pushstring(L, "inactive"); break;
        case CommsTransmitter::State::OpeningChannel: lua_pushstring(L, "opening"); break;
        case CommsTransmitter::State::BeingHailed: lua_pushstring(L, "hailed"); break;
        case CommsTransmitter::State::BeingHailedByGM: lua_pushstring(L, "hailed_gm"); break;
        case CommsTransmitter::State::ChannelOpen: lua_pushstring(L, "open"); break;
        case CommsTransmitter::State::ChannelOpenPlayer: lua_pushstring(L, "open_player"); break;
        case CommsTransmitter::State::ChannelOpenGM: lua_pushstring(L, "open_gm"); break;
        case CommsTransmitter::State::ChannelFailed: lua_pushstring(L, "failed"); break;
        case CommsTransmitter::State::ChannelBroken: lua_pushstring(L, "broken"); break;
        case CommsTransmitter::State::ChannelClosed: lua_pushstring(L, "closed"); break;
        default: lua_pushstring(L, "none"); break;
        }
        return 1;
    }
    static CommsTransmitter::State fromLua(lua_State* L, int idx) {
        string str = string(luaL_checkstring(L, idx)).lower();
        if (str == "inactive")
            return CommsTransmitter::State::Inactive;
        else if (str == "opening")
            return CommsTransmitter::State::OpeningChannel;
        else if (str == "hailed")
            return CommsTransmitter::State::BeingHailed;
        else if (str == "hailed_gm")
            return CommsTransmitter::State::BeingHailedByGM;
        else if (str == "open")
            return CommsTransmitter::State::ChannelOpen;
        else if (str == "open_player")
            return CommsTransmitter::State::ChannelOpenPlayer;
        else if (str == "open_gm")
            return CommsTransmitter::State::ChannelOpenGM;
        else if (str == "failed")
            return CommsTransmitter::State::ChannelFailed;
        else if (str == "broken")
            return CommsTransmitter::State::ChannelBroken;
        else if (str == "closed")
            return CommsTransmitter::State::ChannelClosed;
        luaL_error(L, "Unknown CommsTransmitter::State: %s", str.c_str());
        return CommsTransmitter::State::Inactive;
    }
};
}
