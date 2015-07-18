#include "preferenceManager.h"

std::unordered_map<string, string> PreferencesManager::preference;

void PreferencesManager::set(string key, string value)
{
    preference[key] = value;
}

string PreferencesManager::get(string key, string default_value)
{
    if (preference.find(key) == preference.end())
        preference[key] = default_value;
    return preference[key];
}

void PreferencesManager::load(string filename)
{
    FILE* f = fopen(filename.c_str(), "r");
    if (f)
    {
        char buffer[1024];
        while(fgets(buffer, sizeof(buffer), f))
        {
            string line = string(buffer).strip();
            if (line.find("=") > -1)
            {
                if(line.find("#") != 0) {
                    string key = line.substr(0, line.find("="));
                    string value = line.substr(line.find("=") + 1);
                    preference[key] = value;
                }

            }
        }
        fclose(f);
    }
}

void PreferencesManager::save(string filename)
{
    FILE* f = fopen(filename.c_str(), "w");
    if (f)
    {
        fprintf(f, "# Empty Epsilon Settings\n# This file will be overwritten by EE.\n\n");
        fprintf(f, "# Include the following line to enable an experimental http server:\n# httpserver=8080\n\n");
        fprintf(f, "# For possible hotkey values check: http://www.sfml-dev.org/documentation/2.3.1/classsf_1_1Keyboard.php#acb4cacd7cc5802dec45724cf3314a142\n\n");
        std::vector<string> keys;
        for(std::unordered_map<string, string>::iterator i = preference.begin(); i != preference.end(); i++)
        {
            keys.push_back(i->first);
        }
        std::sort(keys.begin(), keys.end());
        for(string key : keys)
        {
            fprintf(f, "%s=%s\n", key.c_str(), preference[key].c_str());
        }
        fclose(f);
    }
}

sf::Keyboard::Key PreferencesManager::getKey(string key)
{
    string key_value = get(key, "UNSET");
    
    if (key_value == "A") return sf::Keyboard::A;
    if (key_value == "B") return sf::Keyboard::B;
    if (key_value == "C") return sf::Keyboard::C;
    if (key_value == "D") return sf::Keyboard::D;
    if (key_value == "E") return sf::Keyboard::E;
    if (key_value == "F") return sf::Keyboard::F;
    if (key_value == "G") return sf::Keyboard::G;
    if (key_value == "H") return sf::Keyboard::H;
    if (key_value == "I") return sf::Keyboard::I;
    if (key_value == "J") return sf::Keyboard::J;
    if (key_value == "K") return sf::Keyboard::K;
    if (key_value == "L") return sf::Keyboard::L;
    if (key_value == "M") return sf::Keyboard::M;
    if (key_value == "N") return sf::Keyboard::N;
    if (key_value == "O") return sf::Keyboard::O;
    if (key_value == "P") return sf::Keyboard::P;
    if (key_value == "Q") return sf::Keyboard::Q;
    if (key_value == "R") return sf::Keyboard::R;
    if (key_value == "S") return sf::Keyboard::S;
    if (key_value == "T") return sf::Keyboard::T;
    if (key_value == "U") return sf::Keyboard::U;
    if (key_value == "V") return sf::Keyboard::V;
    if (key_value == "W") return sf::Keyboard::W;
    if (key_value == "X") return sf::Keyboard::X;
    if (key_value == "Y") return sf::Keyboard::Y;
    if (key_value == "Z") return sf::Keyboard::Z;
    if (key_value == "Num0") return sf::Keyboard::Num0;
    if (key_value == "Num1") return sf::Keyboard::Num1;
    if (key_value == "Num2") return sf::Keyboard::Num2;
    if (key_value == "Num3") return sf::Keyboard::Num3;
    if (key_value == "Num4") return sf::Keyboard::Num4;
    if (key_value == "Num5") return sf::Keyboard::Num5;
    if (key_value == "Num6") return sf::Keyboard::Num6;
    if (key_value == "Num7") return sf::Keyboard::Num7;
    if (key_value == "Num8") return sf::Keyboard::Num8;
    if (key_value == "Num9") return sf::Keyboard::Num9;
    if (key_value == "Escape") return sf::Keyboard::Escape;
    if (key_value == "LControl") return sf::Keyboard::LControl;
    if (key_value == "LShift") return sf::Keyboard::LShift;
    if (key_value == "LAlt") return sf::Keyboard::LAlt;
    if (key_value == "LSystem") return sf::Keyboard::LSystem;
    if (key_value == "RControl") return sf::Keyboard::RControl;
    if (key_value == "RShift") return sf::Keyboard::RShift;
    if (key_value == "RAlt") return sf::Keyboard::RAlt;
    if (key_value == "RSystem") return sf::Keyboard::RSystem;
    if (key_value == "Menu") return sf::Keyboard::Menu;
    if (key_value == "LBracket") return sf::Keyboard::LBracket;
    if (key_value == "RBracket") return sf::Keyboard::RBracket;
    if (key_value == "SemiColon") return sf::Keyboard::SemiColon;
    if (key_value == "Comma") return sf::Keyboard::Comma;
    if (key_value == "Period") return sf::Keyboard::Period;
    if (key_value == "Quote") return sf::Keyboard::Quote;
    if (key_value == "Slash") return sf::Keyboard::Slash;
    if (key_value == "BackSlash") return sf::Keyboard::BackSlash;
    if (key_value == "Tilde") return sf::Keyboard::Tilde;
    if (key_value == "Equal") return sf::Keyboard::Equal;
    if (key_value == "Dash") return sf::Keyboard::Dash;
    if (key_value == "Space") return sf::Keyboard::Space;
    if (key_value == "Return") return sf::Keyboard::Return;
    if (key_value == "BackSpace") return sf::Keyboard::BackSpace;
    if (key_value == "Tab") return sf::Keyboard::Tab;
    if (key_value == "PageUp") return sf::Keyboard::PageUp;
    if (key_value == "PageDown") return sf::Keyboard::PageDown;
    if (key_value == "End") return sf::Keyboard::End;
    if (key_value == "Home") return sf::Keyboard::Home;
    if (key_value == "Insert") return sf::Keyboard::Insert;
    if (key_value == "Delete") return sf::Keyboard::Delete;
    if (key_value == "Add") return sf::Keyboard::Add;
    if (key_value == "Subtract") return sf::Keyboard::Subtract;
    if (key_value == "Multiply") return sf::Keyboard::Multiply;
    if (key_value == "Divide") return sf::Keyboard::Divide;
    if (key_value == "Left") return sf::Keyboard::Left;
    if (key_value == "Right") return sf::Keyboard::Right;
    if (key_value == "Up") return sf::Keyboard::Up;
    if (key_value == "Down") return sf::Keyboard::Down;
    if (key_value == "Numpad0") return sf::Keyboard::Numpad0;
    if (key_value == "Numpad1") return sf::Keyboard::Numpad1;
    if (key_value == "Numpad2") return sf::Keyboard::Numpad2;
    if (key_value == "Numpad3") return sf::Keyboard::Numpad3;
    if (key_value == "Numpad4") return sf::Keyboard::Numpad4;
    if (key_value == "Numpad5") return sf::Keyboard::Numpad5;
    if (key_value == "Numpad6") return sf::Keyboard::Numpad6;
    if (key_value == "Numpad7") return sf::Keyboard::Numpad7;
    if (key_value == "Numpad8") return sf::Keyboard::Numpad8;
    if (key_value == "Numpad9") return sf::Keyboard::Numpad9;
    if (key_value == "F1") return sf::Keyboard::F1;
    if (key_value == "F2") return sf::Keyboard::F2;
    if (key_value == "F3") return sf::Keyboard::F3;
    if (key_value == "F4") return sf::Keyboard::F4;
    if (key_value == "F5") return sf::Keyboard::F5;
    if (key_value == "F6") return sf::Keyboard::F6;
    if (key_value == "F7") return sf::Keyboard::F7;
    if (key_value == "F8") return sf::Keyboard::F8;
    if (key_value == "F9") return sf::Keyboard::F9;
    if (key_value == "F10") return sf::Keyboard::F10;
    if (key_value == "F11") return sf::Keyboard::F11;
    if (key_value == "F12") return sf::Keyboard::F12;
    if (key_value == "F13") return sf::Keyboard::F13;
    if (key_value == "F14") return sf::Keyboard::F14;
    if (key_value == "F15") return sf::Keyboard::F15;
    if (key_value == "Pause") return sf::Keyboard::Pause;
    
    return sf::Keyboard::KeyCount;
}
