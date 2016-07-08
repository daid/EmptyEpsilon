#include "hotkeyConfig.h"
#include "preferenceManager.h"

static std::vector<std::pair<string, sf::Keyboard::Key> > sfml_key_names = {
    {"A", sf::Keyboard::A},
    {"B", sf::Keyboard::B},
    {"C", sf::Keyboard::C},
    {"D", sf::Keyboard::D},
    {"E", sf::Keyboard::E},
    {"F", sf::Keyboard::F},
    {"G", sf::Keyboard::G},
    {"H", sf::Keyboard::H},
    {"I", sf::Keyboard::I},
    {"J", sf::Keyboard::J},
    {"K", sf::Keyboard::K},
    {"L", sf::Keyboard::L},
    {"M", sf::Keyboard::M},
    {"N", sf::Keyboard::N},
    {"O", sf::Keyboard::O},
    {"P", sf::Keyboard::P},
    {"Q", sf::Keyboard::Q},
    {"R", sf::Keyboard::R},
    {"S", sf::Keyboard::S},
    {"T", sf::Keyboard::T},
    {"U", sf::Keyboard::U},
    {"V", sf::Keyboard::V},
    {"W", sf::Keyboard::W},
    {"X", sf::Keyboard::X},
    {"Y", sf::Keyboard::Y},
    {"Z", sf::Keyboard::Z},
    {"Num0", sf::Keyboard::Num0},
    {"Num1", sf::Keyboard::Num1},
    {"Num2", sf::Keyboard::Num2},
    {"Num3", sf::Keyboard::Num3},
    {"Num4", sf::Keyboard::Num4},
    {"Num5", sf::Keyboard::Num5},
    {"Num6", sf::Keyboard::Num6},
    {"Num7", sf::Keyboard::Num7},
    {"Num8", sf::Keyboard::Num8},
    {"Num9", sf::Keyboard::Num9},
    {"Escape", sf::Keyboard::Escape},
    {"LControl", sf::Keyboard::LControl},
    {"LShift", sf::Keyboard::LShift},
    {"LAlt", sf::Keyboard::LAlt},
    {"LSystem", sf::Keyboard::LSystem},
    {"RControl", sf::Keyboard::RControl},
    {"RShift", sf::Keyboard::RShift},
    {"RAlt", sf::Keyboard::RAlt},
    {"RSystem", sf::Keyboard::RSystem},
    {"Menu", sf::Keyboard::Menu},
    {"LBracket", sf::Keyboard::LBracket},
    {"RBracket", sf::Keyboard::RBracket},
    {"SemiColon", sf::Keyboard::SemiColon},
    {"Comma", sf::Keyboard::Comma},
    {"Period", sf::Keyboard::Period},
    {"Quote", sf::Keyboard::Quote},
    {"Slash", sf::Keyboard::Slash},
    {"BackSlash", sf::Keyboard::BackSlash},
    {"Tilde", sf::Keyboard::Tilde},
    {"Equal", sf::Keyboard::Equal},
    {"Dash", sf::Keyboard::Dash},
    {"Space", sf::Keyboard::Space},
    {"Return", sf::Keyboard::Return},
    {"BackSpace", sf::Keyboard::BackSpace},
    {"Tab", sf::Keyboard::Tab},
    {"PageUp", sf::Keyboard::PageUp},
    {"PageDown", sf::Keyboard::PageDown},
    {"End", sf::Keyboard::End},
    {"Home", sf::Keyboard::Home},
    {"Insert", sf::Keyboard::Insert},
    {"Delete", sf::Keyboard::Delete},
    {"Add", sf::Keyboard::Add},
    {"Subtract", sf::Keyboard::Subtract},
    {"Multiply", sf::Keyboard::Multiply},
    {"Divide", sf::Keyboard::Divide},
    {"Left", sf::Keyboard::Left},
    {"Right", sf::Keyboard::Right},
    {"Up", sf::Keyboard::Up},
    {"Down", sf::Keyboard::Down},
    {"Numpad0", sf::Keyboard::Numpad0},
    {"Numpad1", sf::Keyboard::Numpad1},
    {"Numpad2", sf::Keyboard::Numpad2},
    {"Numpad3", sf::Keyboard::Numpad3},
    {"Numpad4", sf::Keyboard::Numpad4},
    {"Numpad5", sf::Keyboard::Numpad5},
    {"Numpad6", sf::Keyboard::Numpad6},
    {"Numpad7", sf::Keyboard::Numpad7},
    {"Numpad8", sf::Keyboard::Numpad8},
    {"Numpad9", sf::Keyboard::Numpad9},
    {"F1", sf::Keyboard::F1},
    {"F2", sf::Keyboard::F2},
    {"F3", sf::Keyboard::F3},
    {"F4", sf::Keyboard::F4},
    {"F5", sf::Keyboard::F5},
    {"F6", sf::Keyboard::F6},
    {"F7", sf::Keyboard::F7},
    {"F8", sf::Keyboard::F8},
    {"F9", sf::Keyboard::F9},
    {"F10", sf::Keyboard::F10},
    {"F11", sf::Keyboard::F11},
    {"F12", sf::Keyboard::F12},
    {"F13", sf::Keyboard::F13},
    {"F14", sf::Keyboard::F14},
    {"F15", sf::Keyboard::F15},
    {"Pause", sf::Keyboard::Pause},
};

HotkeyConfig hotkeys;

HotkeyConfig::HotkeyConfig()
{
    newCategory("GENERAL", "General");
    newKey("NEXT_STATION", "Switch to next crew station");
    newKey("PREV_STATION", "Switch to previous crew station");
    newKey("STATION_HELMS", "Switch to helms station");
    newKey("STATION_WEAPONS", "Switch to weapons station");
    newKey("STATION_ENGINEERING", "Switch to engineering station");
    newKey("STATION_SCIENCE", "Switch to science station");
    newKey("STATION_RELAY", "Switch to relay station");
    
    newCategory("HELMS", "Helms");
    newKey("INC_IMPULSE", "Increase impulse");
    newKey("DEC_IMPULSE", "Decrease impulse");
    newKey("ZERO_IMPULSE", "Zero impulse");
    newKey("MAX_IMPULSE", "Max impulse");
    newKey("MIN_IMPULSE", "Max reverse impulse");
    newKey("TURN_LEFT", "Turn left");
    newKey("TURN_RIGHT", "Turn right");
    newKey("WARP_0", "Warp off");
    newKey("WARP_1", "Warp 1");
    newKey("WARP_2", "Warp 2");
    newKey("WARP_3", "Warp 3");
    newKey("WARP_4", "Warp 4");
    newKey("DOCK_ACTION", "Dock request/abort/undock");
    newKey("DOCK_REQUEST", "Initiate docking");
    newKey("DOCK_ABORT", "Abort docking");
    newKey("UNDOCK", "Undock");
    newKey("INC_JUMP", "Increase jump distance");
    newKey("DEC_JUMP", "Decrease jump distance");
    newKey("JUMP", "Initiate jump");
    newKey("COMBAT_LEFT", "Combat maneuver left");
    newKey("COMBAT_RIGHT", "Combat maneuver right");
    newKey("COMBAT_BOOST", "Combat maneuver boost");

}

void HotkeyConfig::load()
{
    for(HotkeyConfigCategory& cat : categories)
    {
        for(HotkeyConfigItem& item : cat.hotkeys)
        {
            string key_config = PreferencesManager::get("HOTKEY." + cat.key + "." + item.key);
            item.load(key_config);
        }
    }
}

HotkeyResult HotkeyConfig::getHotkey(sf::Event::KeyEvent key)
{
    HotkeyResult result;
    for(HotkeyConfigCategory& cat : categories)
    {
        for(HotkeyConfigItem& item : cat.hotkeys)
        {
            if (item.hotkey.code == key.code && item.hotkey.alt == key.alt && item.hotkey.control == key.control && item.hotkey.shift == key.shift && item.hotkey.system == key.system)
            {
                result.category = cat.key;
                result.hotkey = item.key;
                return result;
            }
        }
    }
    return result;
}

void HotkeyConfig::newCategory(string key, string name)
{
    categories.emplace_back();
    categories.back().key = key;
    categories.back().name = name;
}

void HotkeyConfig::newKey(string key, string name)
{
    categories.back().hotkeys.emplace_back(key, name);
}

HotkeyConfigItem::HotkeyConfigItem(string key, string name)
{
    this->key = key;
    this->name = name;
    hotkey.code = sf::Keyboard::KeyCount;
    hotkey.alt = false;
    hotkey.control = false;
    hotkey.shift = false;
    hotkey.system = false;
}

void HotkeyConfigItem::load(string key_config)
{
    for(const string& config : key_config.split(";"))
    {
        if (config == "[alt]")
            hotkey.alt = true;
        else if (config == "[control]")
            hotkey.control = true;
        else if (config == "[shift]")
            hotkey.shift = true;
        else if (config == "[system]")
            hotkey.system = true;
        else
        {
            for(auto key_name : sfml_key_names)
            {
                if (key_name.first == config)
                {
                    hotkey.code = key_name.second;
                    break;
                }
            }
        }
    }
}
