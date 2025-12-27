#pragma once

#include <stringImproved.h>
#include "gui2_element.h"
#include <unordered_map>

class GuiThemeStyle
{
public:
    class StateStyle
    {
    public:
        string texture;
        glm::u8vec4 color;
        float size; //general size parameter, depends on the widget type what it means.
        sp::Font* font;
        string sound;   //Sound effect played by the widget on certain actions.
    };
    StateStyle states[int(GuiElement::State::COUNT)];
    const StateStyle& get(GuiElement::State state) const { return states[int(state)]; }
};

/** The Theme class is used by the GuiElement classes to style themselves.
    
    Themes are loaded from a text resource, and referenced from GuiElement classes.
    A single theme contains information on how to style different widget elements.
    
    Each element describes the following properties:
    - texture
    - color
    - font
    - size
    - sound
   
    With the possibility to distingish with the following states:
    - normal: Default state
    - disabled: When enabled is false
    - focused: When this gui element has keyboard focus (last clicked)
    - hover: When the mouse pointer is on top of it
**/
class GuiTheme
{
public:
    const GuiThemeStyle* getStyle(const string& element);

    static GuiTheme* getTheme(const string& name);
    //Will return default theme if not found
    static GuiTheme* getCurrentTheme();
    static void setCurrentTheme(const string &name); 
    static bool loadTheme(const string& name, const string& resource_name);

    static glm::u8vec4 toColor(const string& s);

    // Returns the path to the element's theme texture (image), with optionally defined state.
    static string getImage(const string& element, GuiElement::State state = GuiElement::State::Normal);
    // Returns the element's theme color, with optionally defined state.
    static glm::u8vec4 getColor(const string& element, GuiElement::State state = GuiElement::State::Normal);
    // Returns the element's theme font, with optionally defined state.
    static sp::Font* getFont(const string& element, GuiElement::State state = GuiElement::State::Normal);
    // Returns the element's theme size, with optionally defined state.
    static float getSize(const string& element, GuiElement::State state = GuiElement::State::Normal);
    // Returns the path to the element's theme sound, with optionally defined state.
    static string getSound(const string& element, GuiElement::State state = GuiElement::State::Normal);
private:
    GuiTheme(const string& name);
    virtual ~GuiTheme();

    string name;
    std::unordered_map<string, GuiThemeStyle> styles;

    static std::unordered_map<string, GuiTheme*> themes;
    static string current_theme;
};
