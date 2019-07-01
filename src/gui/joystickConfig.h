#ifndef JOYSTICK_CONFIG_H
#define JOYSTICK_CONFIG_H

#include <tuple>
#include <SFML/Window/Event.hpp>
#include "stringImproved.h"
#include "input.h"


class AxisConfigItem
{
public:
    string key;
    std::tuple<string, string> value;
    unsigned int joystickId;
    sf::Joystick::Axis axis;
    bool reversed;
    bool defined;
    
    AxisConfigItem(string key, std::tuple<string, string>);
    
    void load(string key_config);
};

class JoystickConfigCategory
{
public:
    string key;
    string name;
    std::vector<AxisConfigItem> axes;
};

class AxisAction
{
public:
    AxisAction(string category, string action, float value) : category(category), action(action), value(value) {}

    string category;
    string action;
    float value;
};

class JoystickConfig
{
public:
    JoystickConfig();

    void load();
    std::vector<string> getCategories();
    std::vector<std::pair<string, string>> listJoystickByCategory(string hotkey_category);
    
    std::vector<AxisAction> getAxisAction(unsigned int joystickId, sf::Joystick::Axis axis, float position);
private:
    std::vector<JoystickConfigCategory> categories;
    
    void newCategory(string key, string name);
    void newAxis(string key, std::tuple<string, string>);
};

extern JoystickConfig joystick;

class JoystickMappable : private JoystickEventHandler 
{
    virtual void handleJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axis, float position) override;
    virtual void handleJoystickButton(unsigned int joystickId, unsigned int button, bool state) override;

    virtual void onJoystickAxis(AxisAction& axisAction) = 0;
};

#endif//JOYSTICK_CONFIG_H
