#pragma once

#include <array>
#include "stringImproved.h"
#include "crewPosition.h"


enum class MainScreenSetting
{
    Front = 0,
    Back,
    Left,
    Right,
    Target,
    Tactical,
    LongRange,
    Strategic
};

enum class MainScreenOverlay
{
    HideComms = 0,
    ShowComms
};

enum class AlertLevel
{
    Normal,      // No alert state
    YellowAlert, // Yellow
    RedAlert,    // Red
    MAX          // ?
};


class PlayerControl
{
public:
    // Main screen content
    MainScreenSetting main_screen_setting = MainScreenSetting::Front;
    // Content overlaid on the main screen, such as comms
    MainScreenOverlay main_screen_overlay = MainScreenOverlay::HideComms;

    AlertLevel alert_level = AlertLevel::Normal;

    // Password to join a ship. Default is empty.
    string control_code;

    CrewPositions allowed_positions = CrewPositions::all();
};

class Waypoints
{
public:
    static constexpr int MAX_SETS = 4;
    bool dirty = true;
    // IDs are 1-9 within sets 1-4
    struct Point {
        int id;
        int set_id;
        glm::vec2 position;
    };
    std::vector<Point> waypoints;
    std::array<bool, MAX_SETS> is_route{};

    int addNew(glm::vec2 position, int set_id = 1);
    void move(int id, glm::vec2 position, int set_id = 1);
    void remove(int id, int set_id = 1);
    std::optional<glm::vec2> get(int id, int set_id = 1);
    void setRoute(bool value, int set_id = 1);
};

string alertLevelToString(AlertLevel level);
string alertLevelToLocaleString(AlertLevel level);
