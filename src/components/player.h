#pragma once

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
    LongRange
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

    float gravity_alpha = 0.0f; //[output] used for visual effect going through a wormhole.

    float just_teleported = 0.0f; //[output] used for triggers after going through a wormhole.

    float in_gravity = 0.0f; //[output] used when in a gravity well.
};

class Waypoints
{
public:
    bool dirty = true;
    struct Point {
        int id;
        glm::vec2 position;
    };
    std::vector<Point> waypoints;

    int addNew(glm::vec2 position);
    void move(int id, glm::vec2 position);
    void remove(int id);
    std::optional<glm::vec2> get(int id);
};

string alertLevelToString(AlertLevel level);
string alertLevelToLocaleString(AlertLevel level);
