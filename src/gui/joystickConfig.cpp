#include "joystickConfig.h"
#include "preferenceManager.h"
#include "shipTemplate.h"
#include <regex>
#include <string>

#define ANY_JOYSTICK (unsigned int) -1

std::regex joystickIdExpression ("\\[J([0-7])\\]"); // matches [J0] - [J7] and reference the digit to the first group
std::regex buttonIdExpression ("\\[B([0-9]|[12][0-9]|3[0-1])\\]"); // matches [B0] - [B31] and reference the digit to the first group

JoystickConfig joystick;

JoystickConfig::JoystickConfig()
{  // this list includes all Hotkeys and their standard configuration
    
    newCategory("HELMS", "Helms");
    newAxis("IMPULSE", std::make_tuple("Change impulse", "-Z"));
    newAxis("ROTATE", std::make_tuple("Turn left or right", "R"));
    newAxis("STRAFE", std::make_tuple("Combat maneuver strafe", "X"));
    newAxis("BOOST", std::make_tuple("Combat maneuver boost", "-Y"));

    newCategory("WEAPONS", "Weapons");
    newAxis("AIM_MISSILE", std::make_tuple("Turn missile aim", ""));
    
    newCategory("ENGINEERING", "Engineering");
    newAxis("POWER", std::make_tuple("Change power of selected system", ""));
    newAxis("COOLANT", std::make_tuple("Change coolant of selected system", ""));
    for(int n=0; n<SYS_COUNT; n++)
    {
        newAxis(std::string("POWER_") + getSystemName(ESystem(n)), std::make_tuple(std::string("Change power of ") + getSystemName(ESystem(n)), ""));
        newAxis(std::string("COOLANT_") + getSystemName(ESystem(n)), std::make_tuple(std::string("Change coolant of ") + getSystemName(ESystem(n)), ""));
    }
}

static std::vector<std::pair<string, sf::Joystick::Axis> > sfml_axis_names = {
    {"X", sf::Joystick::X},
    {"Y", sf::Joystick::Y},
    {"Z", sf::Joystick::Z},
    {"R", sf::Joystick::R},
    {"U", sf::Joystick::U},
    {"V", sf::Joystick::V},
    {"PovX", sf::Joystick::PovX},
    {"PovY", sf::Joystick::PovY},
};

void JoystickConfig::load()
{
    for(JoystickConfigCategory& cat : categories)
    {
        for(AxisConfigItem& item : cat.axes)
        {
            string key_config = PreferencesManager::get(std::string("JOYSTICK.AXIS.") + cat.key + "." + item.key, std::get<1>(item.value));
            item.load(key_config);
        }
    }
    for(HotkeyConfigCategory& cat : hotkeys.categories)
    {
        JoystickConfigCategory& categoryToAdd = getCategory(cat.key, cat.name);
        for(HotkeyConfigItem& item : cat.hotkeys)
        {
            ButtonConfigItem buttonConfig(item.key, item.value);
            string key_config = PreferencesManager::get(std::string("HOTKEY.") + cat.key + "." + item.key, std::get<1>(item.value));
            std::smatch matches;
            bool defined = false;
            for(string& config : key_config.split(";"))
            {
                if (std::regex_match(config, matches, joystickIdExpression)) {
                    buttonConfig.joystickId = std::stoi(matches[1]);
                } else if (std::regex_match(config, matches, buttonIdExpression)) {
                    buttonConfig.button = std::stoi(matches[1]);
                    defined = true;
                }
            }
            if (defined){
                categoryToAdd.buttons.emplace_back(buttonConfig);
            }
        }
    }
}

std::vector<AxisAction> JoystickConfig::getAxisAction(unsigned int joystickId, sf::Joystick::Axis axis, float position)
{
    std::vector<AxisAction> actions;
    for(JoystickConfigCategory& cat : categories)
    {
        for(AxisConfigItem& item : cat.axes)
        {
            if ((item.joystickId == joystickId || item.joystickId == ANY_JOYSTICK)&& item.axis == axis)
            {
                float value = item.reversed? position / -100 : position / 100;
                actions.emplace_back(cat.key, item.key, value);
            }
        }
    }
    return actions;
}
std::vector<HotkeyResult> JoystickConfig::getButtonAction(unsigned int joystickId, unsigned int button)
{
    std::vector<HotkeyResult> actions;
    for(JoystickConfigCategory& cat : categories)
    {
        for(ButtonConfigItem& item : cat.buttons)
        {
            if ((item.joystickId == joystickId || item.joystickId == ANY_JOYSTICK)&& item.button == button)
            {
                actions.emplace_back(cat.key, item.key);
            }
        }
    }
    return actions;
}

void JoystickConfig::newCategory(string key, string name)
{
    categories.emplace_back();
    categories.back().key = key;
    categories.back().name = name;
}

JoystickConfigCategory& JoystickConfig::getCategory(string key, string name)
{
    for(JoystickConfigCategory& cat : categories)
    {
        if(cat.key == key && cat.name == name){
            return cat;
        }
    }
    newCategory(key, name);
    return categories.back();
}

void JoystickConfig::newAxis(string key, std::tuple<string, string> value)
{
    categories.back().axes.emplace_back(key, value);
}

std::vector<string> JoystickConfig::getCategories()
{
    // Initialize return value.
    std::vector<string> ret;

    // Add each category to the return value.
    for(JoystickConfigCategory& cat : categories)
    {
        ret.push_back(cat.name);
    }

    return ret;
}

std::vector<std::pair<string, string>> JoystickConfig::listJoystickByCategory(string hotkey_category)
{
    std::vector<std::pair<string, string>> ret;

    for(JoystickConfigCategory& cat : categories)
    {
        if (cat.name == hotkey_category)
        {
            for(AxisConfigItem& item : cat.axes)
            {
                for(auto key_name : sfml_axis_names)
                {
                    if (key_name.second == item.axis)
                        ret.push_back({std::get<0>(item.value), "Joystick axis " + key_name.first});
                }
            }
        }
    }

    return ret;
}

ButtonConfigItem::ButtonConfigItem(string key, std::tuple<string, string> value)
{
    this->key = key;
    this->value = value;
    joystickId = ANY_JOYSTICK;
}

AxisConfigItem::AxisConfigItem(string key, std::tuple<string, string> value)
{
    this->key = key;
    this->value = value;
    defined = false;
    reversed = false;
    joystickId = ANY_JOYSTICK;
}

void AxisConfigItem::load(string key_config)
{    
    std::smatch matches;
    for(string& config : key_config.split(";"))
    {
        if (std::regex_match(config, matches, joystickIdExpression)) {
            joystickId = std::stoi(matches[1]);
        } else {
            if (config.startswith("-")){
                reversed = true;
                config = config.substr(1);
            }
            for(auto key_name : sfml_axis_names) {
                if (key_name.first == config)
                {
                    axis = key_name.second;
                    
                    defined = true;
                    break;
                }
            }
        }
    }
}

void JoystickMappable::handleJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axis, float position){
    for(AxisAction action : joystick.getAxisAction(joystickId, axis, position)){
        onJoystickAxis(action);
    }
}

void JoystickMappable::handleJoystickButton(unsigned int joystickId, unsigned int button, bool state){
    if (state){
        for(HotkeyResult& action : joystick.getButtonAction(joystickId, button)){
            onHotkey(action);
        }
    }
}