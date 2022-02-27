#include "gui/theme.h"
#include <io/keyValueTreeLoader.h>
#include <graphics/freetypefont.h>
#include <logging.h>


static std::unordered_map<string, sp::Font*> fonts;
std::unordered_map<string, GuiTheme*> GuiTheme::themes;

static glm::u8vec4 toColor(const string& s)
{
    if (s.startswith("#"))
    {
        if (s.length() == 7)
            return {s.substr(1, 3).toInt(16), s.substr(3, 5).toInt(16), s.substr(5, 7).toInt(16), 255};
        if (s.length() == 9)
            return {s.substr(1, 3).toInt(16), s.substr(3, 5).toInt(16), s.substr(5, 7).toInt(16), s.substr(7, 9).toInt(16)};
    }
    LOG(Error, "Failed to parse color string", s);
    return {255, 255, 255, 255};
}

static sp::Font* getFont(const string& s)
{
    auto it = fonts.find(s);
    if (it != fonts.end())
        return it->second;
    P<ResourceStream> font_stream = getResourceStream(s);
    if (!font_stream)
    {
        fonts[s] = nullptr;
        return nullptr;
    }
    auto result = new sp::FreetypeFont(s, font_stream);
    fonts[s] = result;
    return result;
}

const GuiThemeStyle* GuiTheme::getStyle(const string& element)
{
    auto it = styles.find(element);
    if (it != styles.end())
        return &it->second;
    int n = element.rfind(".");
    if (n == -1)
    {
        LOG(Warning, "Cannot find", element, "in theme", name);
        return getStyle("fallback");
    }
    return getStyle(element.substr(0, n));
}

GuiTheme* GuiTheme::getTheme(const string& name)
{
    auto it = themes.find(name);
    if (it != themes.end())
        return it->second;
    if (name == "default")
    {
        LOG(Error, "Default theme not found. Most likely crashing now.");
        return nullptr;
    }
    LOG(Warning, "Theme", name, "not found. Falling back to [default] theme.");
    return getTheme("default");
}

bool GuiTheme::loadTheme(const string& name, const string& resource_name)
{
    GuiTheme* theme = new GuiTheme(name);

    auto tree = sp::io::KeyValueTreeLoader::load(resource_name);
    if (!tree)
        return false;
    for(auto& it : tree->getFlattenNodesByIds())
    {
        std::map<string, string>& input = it.second;
        GuiThemeStyle::StateStyle global_style;
        GuiThemeStyle style;

        global_style.texture = input["image"];
        if (input.find("color") != input.end())
            global_style.color = toColor(input["color"]);
        else
            global_style.color = {255, 255, 255, 255};
        global_style.font = getFont(input["font"]);
        global_style.size = input["size"].toFloat();
        global_style.sound = input["sound"];
        for(unsigned int n=0; n<int(GuiElement::State::COUNT); n++)
        {
            string postfix = "?";
            switch(GuiElement::State(n))
            {
            case GuiElement::State::Normal:
                postfix = "normal";
                break;
            case GuiElement::State::Disabled:
                postfix = "disabled";
                break;
            case GuiElement::State::Focus:
                postfix = "focus";
                break;
            case GuiElement::State::Hover:
                postfix = "hover";
                break;
            case GuiElement::State::COUNT:
                break;
            }
            style.states[n] = global_style;

            if (input.find("image." + postfix) != input.end())
                style.states[n].texture = input["image." + postfix];
            if (input.find("color." + postfix) != input.end())
                style.states[n].color = toColor(input["color." + postfix]);
            if (input.find("font." + postfix) != input.end())
                style.states[n].font = getFont(input["font." + postfix]);
            if (input.find("size." + postfix) != input.end())
                style.states[n].size = input["size." + postfix].toFloat();
            if (input.find("sound." + postfix) != input.end())
                style.states[n].sound = input["sound." + postfix];
        }

        theme->styles[it.first] = style;
    }
    return true;
}

GuiTheme::GuiTheme(const string& name)
: name(name)
{
    themes[name] = this;

    GuiThemeStyle::StateStyle fallback_state;
    fallback_state.color = {255, 255, 255, 255};
    fallback_state.size = 12;
    fallback_state.font = nullptr;
    fallback_state.texture = "";
    GuiThemeStyle fallback;
    for(unsigned int n=0; n<int(GuiElement::State::COUNT); n++)
        fallback.states[n] = fallback_state;
    styles["fallback"] = fallback;
}

GuiTheme::~GuiTheme()
{
}
