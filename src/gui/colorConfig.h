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
    
    WidgetColorSet button;
    WidgetColorSet label;
    WidgetColorSet text_entry;
    WidgetColorSet slider;
    
    void load();
};
extern ColorConfig colorConfig;

#endif//COLOR_CONFIG_H
