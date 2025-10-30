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

string alertLevelToString(AlertLevel level);
string alertLevelToLocaleString(AlertLevel level);
