#include <i18n.h>
#include "menus/luaConsole.h"
#include "gameGlobalInfo.h"
#include "preferenceManager.h"
#include "scenarioInfo.h"
#include "scienceDatabase.h"
#include "multiplayer_client.h"
#include "soundManager.h"
#include "random.h"
#include "config.h"
#include <SDL_assert.h>

P<GameGlobalInfo> gameGlobalInfo;

REGISTER_MULTIPLAYER_CLASS(GameGlobalInfo, "GameGlobalInfo")
GameGlobalInfo::GameGlobalInfo()
: MultiplayerObject("GameGlobalInfo")
{
    SDL_assert(!gameGlobalInfo);

    callsign_counter = 0;
    victory_faction = -1;
    gameGlobalInfo = this;

    for(int n=0; n<max_player_ships; n++)
    {
        playerShipId[n] = -1;
        registerMemberReplication(&playerShipId[n]);
    }

    global_message_timeout = 0.0;
    scanning_complexity = SC_Normal;
    hacking_difficulty = 2;
    hacking_games = HG_All;
    use_beam_shield_frequencies = true;
    use_system_damage = true;
    allow_main_screen_tactical_radar = true;
    allow_main_screen_long_range_radar = true;
    gm_control_code = "";
    elapsed_time = 0.0f;

    intercept_all_comms_to_gm = false;

    registerMemberReplication(&scanning_complexity);
    registerMemberReplication(&hacking_difficulty);
    registerMemberReplication(&hacking_games);
    registerMemberReplication(&global_message);
    registerMemberReplication(&global_message_timeout, 1.0);
    registerMemberReplication(&banner_string);
    registerMemberReplication(&victory_faction);
    registerMemberReplication(&use_beam_shield_frequencies);
    registerMemberReplication(&use_system_damage);
    registerMemberReplication(&allow_main_screen_tactical_radar);
    registerMemberReplication(&allow_main_screen_long_range_radar);
    registerMemberReplication(&gm_control_code);
    registerMemberReplication(&elapsed_time, 0.1);

    for(unsigned int n=0; n<factionInfo.size(); n++)
        reputation_points.push_back(0);
    registerMemberReplication(&reputation_points, 1.0);
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
GameGlobalInfo::~GameGlobalInfo()
{
}

P<PlayerSpaceship> GameGlobalInfo::getPlayerShip(int index)
{
    SDL_assert(index >= 0 && index < max_player_ships);
    if (game_server)
        return game_server->getObjectById(playerShipId[index]);
    return game_client->getObjectById(playerShipId[index]);
}

void GameGlobalInfo::setPlayerShip(int index, P<PlayerSpaceship> ship)
{
    SDL_assert(index >= 0 && index < max_player_ships);
    SDL_assert(game_server);

    if (ship)
        playerShipId[index] = ship->getMultiplayerId();
    else
        playerShipId[index] = -1;
}

int GameGlobalInfo::findPlayerShip(P<PlayerSpaceship> ship)
{
    for(int n=0; n<max_player_ships; n++)
        if (getPlayerShip(n) == ship)
            return n;
    return -1;
}

int GameGlobalInfo::insertPlayerShip(P<PlayerSpaceship> ship)
{
    for(int n=0; n<max_player_ships; n++)
    {
        if (!getPlayerShip(n))
        {
            setPlayerShip(n, ship);
            return n;
        }
    }
    return -1;
}

void GameGlobalInfo::update(float delta)
{
    if (global_message_timeout > 0.0f)
    {
        global_message_timeout -= delta;
    }
    if (my_player_info)
    {
        //Set the my_spaceship variable based on the my_player_info->ship_id
        if ((my_spaceship && my_spaceship->getMultiplayerId() != my_player_info->ship_id) || (my_spaceship && my_player_info->ship_id == -1) || (!my_spaceship && my_player_info->ship_id != -1))
        {
            if (game_server)
                my_spaceship = game_server->getObjectById(my_player_info->ship_id);
            else
                my_spaceship = game_client->getObjectById(my_player_info->ship_id);
        }
    }
    elapsed_time += delta;
}

string GameGlobalInfo::getNextShipCallsign()
{
    callsign_counter += 1;
    switch(irandom(0, 9))
    {
    case 0: return "S" + string(callsign_counter);
    case 1: return "NC" + string(callsign_counter);
    case 2: return "CV" + string(callsign_counter);
    case 3: return "SS" + string(callsign_counter);
    case 4: return "VS" + string(callsign_counter);
    case 5: return "BR" + string(callsign_counter);
    case 6: return "CSS" + string(callsign_counter);
    case 7: return "UTI" + string(callsign_counter);
    case 8: return "VK" + string(callsign_counter);
    case 9: return "CCN" + string(callsign_counter);
    }
    return "SS" + string(callsign_counter);
}

void GameGlobalInfo::addScript(P<Script> script)
{
    script_list.update();
    script_list.push_back(script);
}

void GameGlobalInfo::reset()
{
    if (state_logger)
        state_logger->destroy();

    gm_callback_functions.clear();
    gm_messages.clear();
    on_gm_click = nullptr;

    flushDatabaseData();
    FactionInfo::reset();

    foreach(SpaceObject, o, space_object_list)
        o->destroy();
    if (engine->getObject("scenario"))
        engine->getObject("scenario")->destroy();

    foreach(Script, s, script_list)
    {
        s->destroy();
    }
    for(unsigned int n=0; n<reputation_points.size(); n++)
        reputation_points[n] = 0;
    elapsed_time = 0.0f;
    callsign_counter = 0;
    victory_faction = -1;
    allow_new_player_ships = true;
    global_message = "";
    global_message_timeout = 0.0f;
    banner_string = "";

    //Pause the game
    engine->setGameSpeed(0.0);

    foreach(PlayerInfo, p, player_info_list)
    {
        p->reset();
    }
}

void GameGlobalInfo::setScenarioSettings(const string filename, std::unordered_map<string, string> new_settings)
{
    // Use the parsed scenario metadata.
    ScenarioInfo info(filename);

    // Set the scenario name.
    gameGlobalInfo->scenario = info.name;
    LOG(INFO) << "Configuring settings for scenario " << gameGlobalInfo->scenario;

    // Set each scenario setting to either a matching passed new value, or the
    // default if there's no match (or no new value).
    for(auto& setting : info.settings)
    {
        // Initialize with defaults.
        gameGlobalInfo->scenario_settings[setting.key] = setting.default_option;

        // If new settings were passed ...
        if (!new_settings.empty())
        {
            // ... confirm that this setting key exists in the new settings.
            if (new_settings.find(setting.key) != new_settings.end())
            {
                if (new_settings[setting.key] != "")
                {
                    // If so, override the default with the new value.
                    gameGlobalInfo->scenario_settings[setting.key] = new_settings[setting.key];
                }
            }
        }

        // Log scenario setting confirmation.
        LOG(INFO) << setting.key << " scenario setting set to " << gameGlobalInfo->scenario_settings[setting.key];
    }
}

void GameGlobalInfo::startScenario(string filename, std::unordered_map<string, string> new_settings)
{
    reset();

    i18n::reset();
    i18n::load("locale/main." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/comms_ship." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/comms_station." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/factionInfo." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/science_db." + PreferencesManager::get("language", "en") + ".po");
    i18n::load("locale/" + filename.replace(".lua", "." + PreferencesManager::get("language", "en") + ".po"));

    P<ScriptObject> factionInfoScript = new ScriptObject("factionInfo.lua");
    if (factionInfoScript->getError() != "") exit(1);
    factionInfoScript->destroy();

    fillDefaultDatabaseData();

    P<ScriptObject> scienceInfoScript = new ScriptObject("science_db.lua");
    if (scienceInfoScript->getError() != "") exit(1);
    scienceInfoScript->destroy();

    P<ScriptObject> script = new ScriptObject();
    int max_cycles = PreferencesManager::get("script_cycle_limit", "0").toInt();
    if (max_cycles > 0)
        script->setMaxRunCycles(max_cycles);

    // Initialize scenario settings.
    setScenarioSettings(filename, new_settings);

    script->run(filename);
    engine->registerObject("scenario", script);

    if (PreferencesManager::get("game_logs", "1").toInt())
    {
        state_logger = new GameStateLogger();
        state_logger->start();
    }
}

void GameGlobalInfo::destroy()
{
    reset();
    MultiplayerObject::destroy();
}

string GameGlobalInfo::getMissionTime() {
    unsigned int seconds = gameGlobalInfo->elapsed_time;
    unsigned int minutes = (seconds / 60) % 60;
    unsigned int hours = (seconds / 60 / 60) % 24;
    seconds = seconds % 60;
    char buf[9];
    std::snprintf(buf, 9, "%02d:%02d:%02d", hours, minutes, seconds);
    return string(buf);
}

string getSectorName(glm::vec2 position)
{
    constexpr float sector_size = 20000;
    int sector_x = floorf(position.x / sector_size) + 5;
    int sector_y = floorf(position.y / sector_size) + 5;
    string y;
    string x;
    if (sector_y >= 0)
        if (sector_y < 26)
            y = string(char('A' + (sector_y)));
        else
            y = string(char('A' - 1 + (sector_y / 26))) + string(char('A' + (sector_y % 26)));
    else
        y = string(char('z' + ((sector_y + 1) / 26))) + ((sector_y  % 26) == 0 ? "a" : string(char('z' + 1 + (sector_y  % 26))));
    x = string(sector_x);
    return y + x;
}

int getSectorName(lua_State* L)
{
    float x = luaL_checknumber(L, 1);
    float y = luaL_checknumber(L, 2);
    lua_pushstring(L, getSectorName(glm::vec2(x, y)).c_str());
    return 1;
}
/// string getSectorName(float x, float y)
/// Returns the name of the sector containing the given x/y coordinates.
/// Coordinates 0,0 are the top-left ("northwest") point of sector F5.
/// See also SpaceObject:getSectorName().
/// Example: getSectorName(20000,-40000) -- returns "D6"
REGISTER_SCRIPT_FUNCTION(getSectorName);

glm::vec2 sectorToXY(string sector)
{
    constexpr float sector_size = 20000;
    int x, y, intpart;

    if(sector.length() < 2){
        return glm::vec2(0,0);
    }

    // Y axis is complicated
    if(sector[0] >= char('A') && sector[1] >= char('A')){
        // Case with two letters
        char a1 = sector[0];
        char a2 = sector[1];
        try{
            intpart = stoi(sector.substr(2));
        }
        catch(const std::exception& e){
            return glm::vec2(0,0);
        }
        if(a1 > char('a')){
            // Case with two lowercase letters (zz10) counting down towards the North
            y = (((char('z') - a1) * 26) + (char('z') - a2 + 6)) * -sector_size; // 6 is the offset from F5 to zz5
        }else{
            // Case with two uppercase letters (AB20) counting up towards the South
            y = (((a1 - char('A')) * 26) + (a2 - char('A') + 21)) * sector_size; // 21 is the offset from F5 to AA5
        }
    }else{
        //Case with just one letter (A9/a9 - these are the same sector, as case only matters in the two-letter sectors)
        char alphaPart = toupper(sector[0]);
        try{
            intpart = stoi(sector.substr(1));
        }catch(const std::exception& e){
            return glm::vec2(0,0);
        }
        y = (alphaPart - char('F')) * sector_size;
    }
    // X axis is simple
    x = (intpart - 5) * sector_size; // 5 is the numeric component of the F5 origin
    return glm::vec2(x, y);
}

int sectorToXY(lua_State* L)
{
    glm::vec2 v = sectorToXY(luaL_checklstring(L, 1, NULL));
    lua_pushinteger(L, v.x);
    lua_pushinteger(L, v.y);
    return 2;
}
/// glm::vec2 sectorToXY(string sector_name)
/// Returns the top-left ("northwest") x/y coordinates for the given sector mame.
/// Examples:
/// x,y = sectorToXY("A0") -- x = -100000, y = -100000
/// x,y = sectorToXY("zz-23") -- x = -560000, y = -120000
/// x,y = sectorToXY("BA12") -- x = 140000, y = 940000
REGISTER_SCRIPT_FUNCTION(sectorToXY);

static int victory(lua_State* L)
{
    gameGlobalInfo->setVictory(luaL_checkstring(L, 1));
    if (engine->getObject("scenario"))
        engine->getObject("scenario")->destroy();
    engine->setGameSpeed(0.0);
    return 0;
}
/// void victory(string faction_name)
/// Sets the given faction as the scenario's victor and ends the scenario.
/// (The GM can unpause the game, but the scenario with its update function is destroyed.)
/// Example: victory("Exuari") -- ends the scenario, Exuari win
REGISTER_SCRIPT_FUNCTION(victory);

static int globalMessage(lua_State* L)
{
    gameGlobalInfo->global_message = luaL_checkstring(L, 1);
    gameGlobalInfo->global_message_timeout = luaL_optnumber(L, 2, 5.0);
    return 0;
}
/// void globalMessage(string message, std::optional<float> timeout)
/// Displays a message on the main screens of all active player ships.
/// The message appears for 5 seconds, but new messages immediately replace any displayed message.
/// Example: globalMessage("You will soon die!")
REGISTER_SCRIPT_FUNCTION(globalMessage);

static int setBanner(lua_State* L)
{
    gameGlobalInfo->banner_string = luaL_checkstring(L, 1);
    return 0;
}
/// void setBanner(string banner)
/// Displays a scrolling banner containing the given text on the cinematic and top-down views.
/// Example: setBanner("You will soon die!")
REGISTER_SCRIPT_FUNCTION(setBanner);

static int getScenarioTime(lua_State* L)
{
    lua_pushnumber(L, gameGlobalInfo->elapsed_time);
    return 1;
}
/// float getScenarioTime()
/// Returns the elapsed time of the scenario, in seconds.
/// This timer stops when the game is paused.
/// Example: getScenarioTime() -- after two minutes, returns 120.0
REGISTER_SCRIPT_FUNCTION(getScenarioTime);

static int getPlayerShip(lua_State* L)
{
    int index = luaL_checkinteger(L, 1);
    if (index == -1)
    {
        for(index = 0; index<GameGlobalInfo::max_player_ships; index++)
        {
            P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(index);
            if (ship)
                return convert<P<PlayerSpaceship> >::returnType(L, ship);
        }
        return 0;
    }
    if (index == -2) {
        return convert<P<PlayerSpaceship> >::returnType(L, my_spaceship);
    }
    if (index < 1 || index > GameGlobalInfo::max_player_ships)
        return 0;
    P<PlayerSpaceship> ship = gameGlobalInfo->getPlayerShip(index - 1);
    if (!ship)
        return 0;
    return convert<P<PlayerSpaceship> >::returnType(L, ship);
}
/// P<PlayerSpaceship> getPlayerShip(int index)
/// Returns the PlayerSpaceship with the given index.
/// PlayerSpaceships are 1-indexed.
/// A new ship is assigned the lowest available index, and a destroyed ship leaves its index vacant.
/// Pass -1 to return the first active player ship.
/// Pass -2 to return the current player ship.
/// Example: getPlayerShip(2) -- returns the second-indexed ship, if it exists
REGISTER_SCRIPT_FUNCTION(getPlayerShip);

static int getActivePlayerShips(lua_State* L)
{
    PVector<PlayerSpaceship> ships;
    ships.reserve(GameGlobalInfo::max_player_ships);
    for (auto index = 0; index < GameGlobalInfo::max_player_ships; ++index)
    {
        auto ship = gameGlobalInfo->getPlayerShip(index);
        
        if (ship)
        {
            ships.emplace_back(std::move(ship));
        }
    }

    return convert<PVector<PlayerSpaceship>>::returnType(L, ships);
}
/// PVector<PlayerSpaceship> getActivePlayerShips()
/// Returns a 1-indexed list of active PlayerSpaceships.
/// Unlike getPlayerShip()'s index, destroyed ships don't leave gaps.
/// Example: getActivePlayerShips()[2] -- returns the second-indexed active ship
REGISTER_SCRIPT_FUNCTION(getActivePlayerShips);

static int getObjectsInRadius(lua_State* L)
{
    float x = luaL_checknumber(L, 1);
    float y = luaL_checknumber(L, 2);
    float r = luaL_checknumber(L, 3);

    glm::vec2 position(x, y);

    PVector<SpaceObject> objects;
    PVector<Collisionable> objectList = CollisionManager::queryArea(position - glm::vec2(r, r), position + glm::vec2(r, r));
    foreach(Collisionable, obj, objectList)
    {
        P<SpaceObject> sobj = obj;
        if (sobj && glm::length2(sobj->getPosition() - position) < r*r)
            objects.push_back(sobj);
    }

    return convert<PVector<SpaceObject> >::returnType(L, objects);
}
/// PVector<SpaceObject> getObjectsInRadius(float x, float y, float radius)
/// Returns a list of all SpaceObjects within the given radius of the given x/y coordinates.
/// Example: getObjectsInRadius(0,0,5000) -- returns all objects within 5U of 0,0
REGISTER_SCRIPT_FUNCTION(getObjectsInRadius);

static int getAllObjects(lua_State* L)
{
    return convert<PVector<SpaceObject> >::returnType(L, space_object_list);
}
/// PVector<SpaceObject> getAllObjects()
/// Returns a list of all SpaceObjects.
/// This can return a very long list and could slow down the game if called every tick.
/// Example: getAllObjects()
REGISTER_SCRIPT_FUNCTION(getAllObjects);

static int getScenarioVariation(lua_State* L)
{
    if (gameGlobalInfo->scenario_settings.find("variation") != gameGlobalInfo->scenario_settings.end())
        lua_pushstring(L, gameGlobalInfo->scenario_settings["variation"].c_str());
    else
        lua_pushstring(L, "None");
    return 1;
}
// this returns the "variation" scenario setting for backwards compatibility
/// string getScenarioVariation()
/// [DEPRECATED]
/// As getScenarioSetting("variation").
REGISTER_SCRIPT_FUNCTION(getScenarioVariation);

static int getScenarioSetting(lua_State* L)
{
    auto key = luaL_checkstring(L, 1);
    if (gameGlobalInfo->scenario_settings.find(key) != gameGlobalInfo->scenario_settings.end())
        lua_pushstring(L, gameGlobalInfo->scenario_settings[key].c_str());
    else
        lua_pushstring(L, "");
    return 1;
}
/// string getScenarioSetting(string key)
/// Returns the given scenario setting's value, or an empty string if the setting is not found.
/// Warning: Headless server modes might load scenarios without default setting values.
/// Example: getScenarioSetting("Difficulty") -- if a scenario has Setting[Difficulty], returns its value, such as "Easy" or "Normal"
REGISTER_SCRIPT_FUNCTION(getScenarioSetting);

static int getGameLanguage(lua_State* L)
{
    lua_pushstring(L, PreferencesManager::get("language", "en").c_str());
    return 1;
}
/// string getGameLanguage()
/// Returns the language as the string value of the language key in game preferences.
/// Example: getGameLanguage() -- returns "en" if the game language is set to English
REGISTER_SCRIPT_FUNCTION(getGameLanguage);

/** Short lived object to do a scenario change on the update loop. See "setScenario" for details */
class ScenarioChanger : public Updatable
{
public:
    ScenarioChanger(string script_name, const std::unordered_map<string, string>& settings)
    : script_name(script_name), settings(settings)
    {
    }

    virtual void update(float delta) override
    {
        gameGlobalInfo->startScenario(script_name, settings);
        destroy();
    }
private:
    string script_name;
    std::unordered_map<string, string> settings;
};

static int setScenario(lua_State* L)
{
    string script_name = luaL_checkstring(L, 1);
    string variation = luaL_optstring(L, 2, "");

    // Script filename must not be an empty string.
    if (script_name == "")
    {
        LOG(ERROR) << "setScenario() requires a non-empty value.";
        return 1;
    }

    if (variation != "")
    {
        LOG(WARNING) << "LUA: DEPRECATED setScenario() called with scenario variation. Passing the value as the \"variation\" scenario setting instead.";
        // Start the scenario, passing the "variation" scenario setting.
        new ScenarioChanger(script_name, {{"variation", variation}});
    }
    else
    {
        // Start the scenario with defaults.
        new ScenarioChanger(script_name, {{}});
    }

    // This could be called from a currently active scenario script.
    // Calling GameGlobalInfo::startScenario is unsafe at this point,
    // as this will destroy the lua state that this function is running in.
    // So use the ScenarioChanger object which will do the change in the update loop. Which is safe.
    return 0;
}
/// void setScenario(string script_name, std::optional<string> variation_name)
/// Launches the given scenario, even if another scenario is running.
/// Paths are relative to the scripts/ directory.
/// Example: setScenario("scenario_03_waves.lua") -- launches the scenario at scripts/scenario_03_waves.lua
REGISTER_SCRIPT_FUNCTION(setScenario);

static int shutdownGame(lua_State* L)
{
    engine->shutdown();
    return 0;
}
/// void shutdownGame()
/// Shuts down the server.
/// Use to gracefully shut down a headless server.
/// Example: shutdownGame()
REGISTER_SCRIPT_FUNCTION(shutdownGame);

static int pauseGame(lua_State* L)
{
    engine->setGameSpeed(0.0);
    return 0;
}
/// void pauseGame()
/// Pauses the game.
/// Use to pause a headless server, which doesn't have access to the GM screen.
/// Example: pauseGame()
REGISTER_SCRIPT_FUNCTION(pauseGame);

static int unpauseGame(lua_State* L)
{
    engine->setGameSpeed(1.0);
    return 0;
}
/// void unpauseGame()
/// Unpauses the game.
/// Use to unpause a headless server, which doesn't have access to the GM screen.
/// Example: unpauseGame()
REGISTER_SCRIPT_FUNCTION(unpauseGame);

static int playSoundFile(lua_State* L)
{
    string filename = luaL_checkstring(L, 1);
    int n = filename.rfind(".");
    if (n > -1)
    {
        string filename_with_locale = filename.substr(0, n) + "." + PreferencesManager::get("language", "en") + filename.substr(n);
        if (getResourceStream(filename_with_locale)) {
            soundManager->playSound(filename_with_locale);
            return 0;
        }
    }
    soundManager->playSound(filename);
    return 0;
}
/// void playSoundFile(string filename)
/// Plays the given audio file on the server.
/// Paths are relative to the resources/ directory.
/// Works with any file format supported by SDL, including .wav, .ogg, .flac.
/// The sound is played only on the server, and not on any clients.
/// Example: playSoundFile("sfx/laser.wav")
REGISTER_SCRIPT_FUNCTION(playSoundFile);

template<> int convert<EScanningComplexity>::returnType(lua_State* L, EScanningComplexity complexity)
{
    switch(complexity)
    {
    case SC_None:
        lua_pushstring(L, "none");
        return 1;
    case SC_Simple:
        lua_pushstring(L, "simple");
        return 1;
    case SC_Normal:
        lua_pushstring(L, "normal");
        return 1;
    case SC_Advanced:
        lua_pushstring(L, "advanced");
        return 1;
    default:
        return 0;
    }
}

static int getScanningComplexity(lua_State* L)
{
    return convert<EScanningComplexity>::returnType(L, gameGlobalInfo->scanning_complexity);
}
/// EScanningComplexity getScanningComplexity()
/// Returns the running scenario's scanning complexity setting.
/// Example: getScanningComplexity() -- returns "normal" by default
REGISTER_SCRIPT_FUNCTION(getScanningComplexity);

static int getHackingDifficulty(lua_State* L)
{
    lua_pushinteger(L, gameGlobalInfo->hacking_difficulty);
    return 1;
}
/// int getHackingDifficulty()
/// Returns the running scenario's hacking difficulty setting.
/// The returned value is an integer between 0 and 3:
/// 0 = Simple
/// 1 = Normal
/// 2 = Difficult (default)
/// 3 = Fiendish 
/// Example: getHackingDifficulty() -- returns 2 by default
REGISTER_SCRIPT_FUNCTION(getHackingDifficulty);

template<> int convert<EHackingGames>::returnType(lua_State* L, EHackingGames game)
{
    switch(game)
    {
    case HG_Mine:
        lua_pushstring(L, "mines");
        return 1;
    case HG_Lights:
        lua_pushstring(L, "lights");
        return 1;
    case HG_All:
        lua_pushstring(L, "all");
        return 1;
    default:
        return 0;
    }
}

static int getHackingGames(lua_State* L)
{
    return convert<EHackingGames>::returnType(L, gameGlobalInfo->hacking_games);
}
/// EHackingGames getHackingGames()
/// Returns the running scenario's hacking difficulty setting.
/// Example: getHackingGames() -- returns "all" by default
REGISTER_SCRIPT_FUNCTION(getHackingGames);

static int areBeamShieldFrequenciesUsed(lua_State* L)
{
    lua_pushboolean(L, gameGlobalInfo->use_beam_shield_frequencies);
    return 1;
}
/// bool areBeamShieldFrequenciesUsed()
/// Returns whether the "Beam/Shield Frequencies" setting is enabled in the running scenario.
/// Example: areBeamShieldFrequenciesUsed() -- returns true by default
REGISTER_SCRIPT_FUNCTION(areBeamShieldFrequenciesUsed);

static int isPerSystemDamageUsed(lua_State* L)
{
    lua_pushboolean(L, gameGlobalInfo->use_system_damage);
    return 1;
}
/// bool isPerSystemDamageUsed()
/// Returns whether the "Per-System Damage" setting is enabled in the running scenario.
/// Example: isPerSystemDamageUsed() -- returns true by default
REGISTER_SCRIPT_FUNCTION(isPerSystemDamageUsed);

static int isTacticalRadarAllowed(lua_State* L)
{
    lua_pushboolean(L, gameGlobalInfo->allow_main_screen_tactical_radar);
    return 1;
}
/// bool isTacticalRadarAllowed()
/// Returns whether the "Tactical Radar" setting for main screens is enabled in the running scenario.
/// Example: isTacticalRadarAllowed() -- returns true by default
REGISTER_SCRIPT_FUNCTION(isTacticalRadarAllowed);

static int isLongRangeRadarAllowed(lua_State* L)
{
    lua_pushboolean(L, gameGlobalInfo->allow_main_screen_long_range_radar);
    return 1;
}
/// bool isLongRangeRadarAllowed()
/// Returns whether the "Long Range Radar" setting for main screens is enabled in the running scenario.
/// Example: isLongRangeRadarAllowed() -- returns true by default
REGISTER_SCRIPT_FUNCTION(isLongRangeRadarAllowed);

static int onNewPlayerShip(lua_State* L)
{
    int idx = 1;
    convert<ScriptSimpleCallback>::param(L, idx, gameGlobalInfo->on_new_player_ship);
    return 0;
}
/// void onNewPlayerShip(ScriptSimpleCallback callback)
/// Defines a function to call when a new PlayerSpaceship is created, whether on the ship selection screen or with the constructor in a Lua script.
/// Passes the newly created PlayerSpaceship.
/// Example: onNewPlayerShip(function(player) print(player:getCallSign()) end) -- prints the callsign of new PlayerSpaceships to the console
REGISTER_SCRIPT_FUNCTION(onNewPlayerShip);

static int allowNewPlayerShips(lua_State* L)
{
    gameGlobalInfo->allow_new_player_ships = lua_toboolean(L, 1);
    return 0;
}
/// void allowNewPlayerShips(bool allow)
/// Defines whether the "Spawn player ship" button appears on the ship creation screen.
/// Example: allowNewPlayerShips(false) -- removes the button
REGISTER_SCRIPT_FUNCTION(allowNewPlayerShips);

static int getEEVersion(lua_State* L)
{
    lua_pushinteger(L, VERSION_NUMBER);
    return 1;
}
/// string getEEVersion()
/// Returns a string with the current EmptyEpsilon version number, such as "20221029".
/// Example: getEEVersion() -- returns 20221029 on EE-2022.10.29
REGISTER_SCRIPT_FUNCTION(getEEVersion);

static int luaPrint(lua_State* L)
{
    string message;
    int n = lua_gettop(L);  /* number of arguments */
    for (int i=1; i<=n; i++) {
        if (lua_istable(L, i)) {
            if (i > 1)
                message += " ";
            message += "{";
            lua_pushnil(L);
            bool first = true;
            while(lua_next(L, i)) {
                if (first) first = false; else message += ",";
                auto s = luaL_tolstring(L, -2, nullptr);
                if (s != nullptr) {
                    message += s;
                    message += "=";
                }
                lua_pop(L, 1);
                s = luaL_tolstring(L, -1, nullptr);
                if (s != nullptr) {
                    message += s;
                }
                lua_pop(L, 2);
            }
            message += "}";
        } else {
            auto s = luaL_tolstring(L, i, nullptr);
            if (s != nullptr) {
                if (i > 1)
                    message += " ";
                message += s;
            }
            lua_pop(L, 1);
        }
    }
    LOG(Info, "LUA:", message);
    LuaConsole::addLog(message);
    return 0;
}
REGISTER_SCRIPT_FUNCTION_NAMED(luaPrint, "print");