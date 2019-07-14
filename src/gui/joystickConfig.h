
#ifndef JOYSTICK_CONFIG_H
#define JOYSTICK_CONFIG_H

#include <tuple>
#include <SFML/Window/Event.hpp>
#include "stringImproved.h"
#include "input.h"
#include "hotkeyConfig.h"

class ButtonConfigItem
{
public:
    string key;
    std::tuple<string, string> value;
    unsigned int joystickId;
    unsigned int button;
    
    ButtonConfigItem(string key, std::tuple<string, string> value);
    
    void load(string key_config);
};

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
    std::vector<ButtonConfigItem> buttons;
};

class ButtonAction
{
public:
    ButtonAction(string category, string action) : category(category), action(action){}

    string category;
    string action;
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
    std::vector<HotkeyResult> getButtonAction(unsigned int joystickId, unsigned int button);

private:
    std::vector<JoystickConfigCategory> categories;
    
    void newCategory(string key, string name);
    JoystickConfigCategory& getCategory(string key, string name);
    void newAxis(string key, std::tuple<string, string>);
    void newButton(string key, std::tuple<string, string>);
};

extern JoystickConfig joystick;

class JoystickMappable : private JoystickEventHandler, InputEventHandler
{
    virtual void handleJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axis, float position) override;
    virtual void handleJoystickButton(unsigned int joystickId, unsigned int button, bool state) override;
    virtual void handleKeyPress(sf::Event::KeyEvent key, int unicode) override;

    virtual void onJoystickAxis(AxisAction& axisAction) = 0;
    virtual void onHotkey(const HotkeyResult& key) = 0;
};

#endif//JOYSTICK_CONFIG_H