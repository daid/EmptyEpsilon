#pragma once

#include <stringImproved.h>
#include "gui2_element.h"
#include <unordered_set>

class GuiThemeStyle
{
public:
    class StateStyle
    {
    public:
        string texture;
        glm::u8vec4 color;
        float size; // General size parameter, depends on the widget type what it means.
        sp::Font* font;
        string sound; //Sound effect played by the widget on certain actions.
    };
    StateStyle states[int(GuiElement::State::COUNT)];
    const StateStyle& get(GuiElement::State state) const { return states[int(state)]; }
};

/** The Theme class is used by the GuiElement classes to style themselves.

    Themes are loaded from a text resource, and referenced from GuiElement classes.
    A single theme contains information on how to style different widget elements.
    A theme can inherit one or more parent themes. A child theme overrides only the
    styles it defines.

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
private:
    GuiTheme(const string& name);
    virtual ~GuiTheme();

    static bool loadParentThemes(GuiTheme* theme, const std::vector<string>& parent_names, std::unordered_set<string>& loading_chain);
    static GuiThemeStyle getMergedParentStyle(GuiTheme* theme, const string& element_name);

    string name;
    std::unordered_map<string, GuiThemeStyle> styles;
    std::vector<string> parent_themes;

    static std::unordered_map<string, GuiTheme*> themes;
    static string current_theme;
};

