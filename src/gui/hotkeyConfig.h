#ifndef HOTKEY_CONFIG_H
#define HOTKEY_CONFIG_H

#include <SFML/Window/Event.hpp>
#include "stringImproved.h"

class HotkeyConfigItem
{
public:
    string key;
    string name;
    sf::Event::KeyEvent hotkey;
    
    HotkeyConfigItem(string key, string name);
    
    void load(string key_config);
};

class HotkeyConfigCategory
{
public:
    string key;
    string name;
    std::vector<HotkeyConfigItem> hotkeys;
};

class HotkeyResult
{
public:
    string category;
    string hotkey;
};

class HotkeyConfig
{
public:
    HotkeyConfig();

    void load();
    
    HotkeyResult getHotkey(sf::Event::KeyEvent key);
private:
    std::vector<HotkeyConfigCategory> categories;
    
    void newCategory(string key, string name);
    void newKey(string key, string name);
};

extern HotkeyConfig hotkeys;

#endif//HOTKEY_CONFIG_H
