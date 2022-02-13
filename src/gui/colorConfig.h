#ifndef COLOR_CONFIG_H
#define COLOR_CONFIG_H

#include <glm/gtc/type_precision.hpp>

class ColorSet
{
public:
    glm::u8vec4 normal;
    glm::u8vec4 hover;
    glm::u8vec4 focus;
    glm::u8vec4 disabled;
    glm::u8vec4 active;
};
class WidgetColorSet
{
public:
    ColorSet background;
    ColorSet forground;
};

class ColorConfig
{
public:
    glm::u8vec4 background;
    glm::u8vec4 radar_outline;

    glm::u8vec4 log_generic;
    glm::u8vec4 log_send;
    glm::u8vec4 log_receive_friendly;
    glm::u8vec4 log_receive_enemy;
    glm::u8vec4 log_receive_neutral;

    WidgetColorSet textbox;

    glm::u8vec4 overlay_damaged;
    glm::u8vec4 overlay_jammed;
    glm::u8vec4 overlay_hacked;
    glm::u8vec4 overlay_no_power;
    glm::u8vec4 overlay_low_energy;
    glm::u8vec4 overlay_low_power;
    glm::u8vec4 overlay_overheating;

    glm::u8vec4 ship_waypoint_background;
    glm::u8vec4 ship_waypoint_text;

    void load();
};
extern ColorConfig colorConfig;

#endif//COLOR_CONFIG_H
