#ifndef COLOR_CONFIG_H
#define COLOR_CONFIG_H

#include <SFML/Graphics/Color.hpp>

class ColorSet
{
public:
    sf::Color normal;
    sf::Color hover;
    sf::Color focus;
    sf::Color disabled;
    sf::Color active;
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
    sf::Color background;
    sf::Color radar_outline;
    
    sf::Color log_generic;
    sf::Color log_send;
    sf::Color log_receive_friendly;
    sf::Color log_receive_enemy;
    sf::Color log_receive_neutral;
    
    WidgetColorSet button;
    WidgetColorSet label;
    WidgetColorSet text_entry;
    WidgetColorSet slider;
    WidgetColorSet textbox;

    sf::Color overlay_damaged;
    sf::Color overlay_jammed;
    sf::Color overlay_no_power;
    sf::Color overlay_low_energy;
    sf::Color overlay_low_power;
    sf::Color overlay_overheating;
    
    sf::Color ship_waypoint_background;
    sf::Color ship_waypoint_text;
    
    void load();
};
extern ColorConfig colorConfig;

#endif//COLOR_CONFIG_H
