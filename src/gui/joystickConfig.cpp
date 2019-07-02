#include "joystickConfig.h"
#include "preferenceManager.h"
#include "shipTemplate.h"

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
    
    // newCategory("ENGINEERING", "Engineering");
    // newAxis("POWER", std::make_tuple("Change system power", "X"));
    // newAxis("COOLANT", std::make_tuple("Change system coolant", "Y"));
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
}

std::vector<AxisAction> JoystickConfig::getAxisAction(unsigned int joystickId, sf::Joystick::Axis axis, float position)
{
    std::vector<AxisAction> actions;
    for(JoystickConfigCategory& cat : categories)
    {
        for(AxisConfigItem& item : cat.axes)
        {
            if (item.axis == axis)
            {
                float value = item.reversed? position / -100 : position / 100;
                actions.emplace_back(cat.key, item.key, value);
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

AxisConfigItem::AxisConfigItem(string key, std::tuple<string, string> value)
{
    this->key = key;
    this->value = value;
    defined = false;
    reversed = false;
}

void AxisConfigItem::load(string key_config)
{
    if (key_config.startswith("-")){
        reversed = true;
        key_config = key_config.substr(1);
    }
    for(auto key_name : sfml_axis_names) {
        if (key_name.first == key_config)
        {
            axis = key_name.second;
            defined = true;
            break;
        }
    }
}

void JoystickMappable::handleJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axis, float position){
    for(AxisAction action : joystick.getAxisAction(joystickId, axis, position)){
        onJoystickAxis(action);
    }
}
void JoystickMappable::handleJoystickButton(unsigned int joystickId, unsigned int button, bool state){
}