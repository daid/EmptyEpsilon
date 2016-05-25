#ifndef GAME_STATE_LOGGER_H
#define GAME_STATE_LOGGER_H

#include "engine.h"

class SpaceObject;
class SpaceShip;
class SpaceStation;
class JSONGenerator;
/*
 * The GameStateLogger logs the current state of the game to a log file.
 * It does this every X seconds.
 * This logged data can be used to analize the game afterwards.
 *
 * The resulting log contains 2 types of records:
 * 1) Periodic game data, update of all the objects in the game with all states.
 * 2) Events fired by certain actions. Missile firing, beams firing, damage, destruction of certain objects.
 */
class GameStateLogger : public Updatable
{
public:
    GameStateLogger();
    virtual ~GameStateLogger();
    
    void start();
    void stop();
    
    virtual void update(float delta);

private:
    FILE* log_file;
    float logging_interval;
    float logging_delay;
    float start_time;
    std::map<int, sf::Vector2f> static_objects;

    void logGameState();
    bool isStatic(P<SpaceObject> obj);
    void writeObjectEntry(JSONGenerator& json, P<SpaceObject> obj);
    void writeShipEntry(JSONGenerator& json, P<SpaceShip> obj);
    void writeStationEntry(JSONGenerator& json, P<SpaceStation> obj);
};

#endif//GAME_STATE_LOGGER_H
