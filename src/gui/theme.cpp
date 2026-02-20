#include "gui/theme.h"
#include "resources.h"
#include <io/keyValueTreeLoader.h>
#include <graphics/freetypefont.h>
#include <logging.h>


static std::unordered_map<string, sp::Font*> fonts;
std::unordered_map<string, GuiTheme*> GuiTheme::themes;
string GuiTheme::current_theme = "default";

glm::u8vec4 GuiTheme::toColor(const string& s)
{
    if (s.startswith("#"))
    {
        if (s.length() == 7)
            return {s.substr(1, 3).toInt(16), s.substr(3, 5).toInt(16), s.substr(5, 7).toInt(16), 255};
        if (s.length() == 9)
            return {s.substr(1, 3).toInt(16), s.substr(3, 5).toInt(16), s.substr(5, 7).toInt(16), s.substr(7, 9).toInt(16)};
    }
    LOG(Error, "Failed to parse color string ", s);
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
        LOG(Debug, "Failed to load font resource ", s);
        fonts[s] = nullptr;
        return nullptr;
    }
    auto result = new sp::FreetypeFont(s, font_stream);
    fonts[s] = result;
    LOG(Debug, "Loaded font ", s);
    return result;
}

// Flatten and cache the theme tree into a temporary nested map.
static std::map<string, std::map<string, string>>* getFlattenedTheme(const string& name, std::unordered_map<string, std::map<string, std::map<string, string>>>& session_cache)
{
    auto it = session_cache.find(name);
    if (it != session_cache.end())
        return &it->second;

    string resource_name = "gui/" + name + ".theme.txt";
    auto tree = sp::io::KeyValueTreeLoader::load(resource_name);
    if (!tree)
    {
        LOG(Debug, "Failed to load theme file for flattening: ", resource_name);
        return nullptr;
    }

    session_cache[name] = tree->getFlattenNodesByIds();
    LOG(Debug, "Flattened theme ", name, " with ", session_cache[name].size(), " elements");
    return &session_cache[name];
}

// Merge flattened themes into a nested map.
// Later/child values override those defined earlier.
static void mergeFlattenedData(std::map<string, std::map<string, string>>& dest, const std::map<string, std::map<string, string>>& source)
{
    for (const auto& [element_name, properties] : source)
        for (const auto& [key, value] : properties) dest[element_name][key] = value;
}

const GuiThemeStyle* GuiTheme::getStyle(const string& element)
{
    auto it = styles.find(element);
    if (it != styles.end())
    {
        // Capture the font that will be applied for the Normal state.
        const auto& normal_state = it->second.states[int(GuiElement::State::Normal)];
        if (normal_state.font)
        {
            // Find the font name from the fonts cache.
            string font_name = "unknown";
            for (auto font_it = fonts.begin(); font_it != fonts.end(); ++font_it)
            {
                if (font_it->second == normal_state.font)
                {
                    font_name = font_it->first;
                    break;
                }
            }
        }
        return &it->second;
    }

    int n = element.rfind(".");
    if (n == -1)
    {
        LOG(Warning, "Can't find ", element, " in theme ", name, ". Falling back to 'fallback' style.");
        return getStyle("fallback");
    }
    string parent_element = element.substr(0, n);
    return getStyle(parent_element);
}

GuiTheme* GuiTheme::getTheme(const string& name)
{
    auto it = themes.find(name);
    if (it != themes.end()) return it->second;

    if (name == "default")
    {
        LOG(Error, "Default theme not found. Most likely crashing now.");
        return nullptr;
    }
    LOG(Warning, "Theme ", name, " not found. Falling back to Default theme.");
    return getTheme("default");
}

void GuiTheme::setCurrentTheme(const string &theme_name)
{
    if (themes.find(theme_name) != themes.end())
    {
        LOG(Info, "Theme set to ", theme_name);
        GuiTheme::current_theme = theme_name;
    }
}

GuiTheme* GuiTheme::getCurrentTheme()
{
    return GuiTheme::getTheme(GuiTheme::current_theme);
}

bool GuiTheme::loadTheme(const string& name, const string& resource_name)
{
    LOG(Debug, "Loading theme ", name, " from ", resource_name);
    GuiTheme* theme = new GuiTheme(name);

    auto tree = sp::io::KeyValueTreeLoader::load(resource_name);
    if (!tree)
    {
        LOG(Debug, "Failed to load theme file: ", resource_name);
        delete theme;
        return false;
    }

    // Get current theme's flattened data.
    auto current_data = tree->getFlattenNodesByIds();

    // Parse `inherit` directive from `base` node.
    std::vector<string> parent_names;
    auto base_node = current_data.find("base");
    if (base_node != current_data.end())
    {
        std::map<string, string>& base_input = base_node->second;
        if (base_input.find("inherit") != base_input.end())
        {
            // Parse comma-separated list of inheritances.
            // (i.e. "corners, custom-palette")
            const string inherit_str = base_input["inherit"];
            size_t pos = 0;

            while (pos < inherit_str.length())
            {
                size_t comma = inherit_str.find(',', pos);
                if (comma == string::npos) comma = inherit_str.length();
                string parent = inherit_str.substr(pos, comma - pos).strip();
                if (!parent.empty()) parent_names.push_back(parent);
                pos = comma + 1;
            }
        }
    }

    // Always inherit from default at lowest precedence.
    if (name != "default")
    {
        if (std::find(parent_names.begin(), parent_names.end(), "default") == parent_names.end())
            parent_names.insert(parent_names.begin(), "default");
        else
            LOG(Debug, "Theme ", name, " already explicitly inherits from 'default', skipping implicit addition");
    }

    // Check for circular dependencies.
    std::unordered_set<string> loading_chain = {name};
    for (const string& parent_name : parent_names)
    {
        if (loading_chain.find(parent_name) != loading_chain.end())
        {
            LOG(Error, "Circular theme inheritance detected: ", parent_name);
            delete theme;
            return false;
        }
    }

    // Cache flattened theme data.
    std::unordered_map<string, std::map<string, std::map<string, string>>> session_cache;

    // Merged flattened data from all parent themes, from lowest to highest
    // precedence.
    std::map<string, std::map<string, string>> merged_data;

    for (const string& parent_name : parent_names)
    {
        if (auto* parent_data = getFlattenedTheme(parent_name, session_cache))
        {
            mergeFlattenedData(merged_data, *parent_data);
            theme->parent_themes.push_back(parent_name);
        }
        else
            LOG(Warning, "Parent theme ", parent_name, " not found for theme ", name);
    }

    // Active theme's definitions override parents' on merge.
    std::unordered_set<string> current_theme_elements;
    for (const auto& [element_name, properties] : current_data)
        current_theme_elements.insert(element_name);

    mergeFlattenedData(merged_data, current_data);

    // Active theme inherits base properties for all undefined elements.
    // This ensures that a child theme can override global font defaults.
    if (merged_data.find("base") != merged_data.end())
    {
        const auto& base_properties = merged_data["base"];
        for (auto& [element_name, properties] : merged_data)
        {
            // Skip everything but undefined elements in the active theme.
            if (element_name == "base") continue;
            if (current_theme_elements.find(element_name) != current_theme_elements.end()) continue;

            // For other undefined elements, apply this theme's base properties,
            // overriding any base properties defined in the parent.
            for (const auto& [key, value] : base_properties)
                properties[key] = value;
        }
    }

    // Process the merged data into GuiThemeStyle objects
    for (auto& [element_name, input] : merged_data)
    {
        GuiThemeStyle style;

        // Initialize all states with defaults
        for (int n = 0; n < int(GuiElement::State::COUNT); n++)
        {
            style.states[n].color = {255, 255, 255, 255};
            style.states[n].size = 30.0f;
            style.states[n].font = nullptr;
            // TODO: style.states[n].font_offset = 0.0f;
            style.states[n].texture = "";
            style.states[n].sound = "";
        }

        // Create global_style with defaults for properties that apply to all states
        GuiThemeStyle::StateStyle global_style;
        global_style.color = {255, 255, 255, 255};
        global_style.size = 30.0f;
        global_style.font = nullptr;
        // TODO: global_style.font_offset = 0.0f;
        global_style.texture = "";
        global_style.sound = "";

        // Override global properties if specified in this theme.
        if (input.find("image") != input.end())
            global_style.texture = input["image"];
        if (input.find("color") != input.end())
            global_style.color = toColor(input["color"]);
        else
            global_style.color = {255, 255, 255, 255};
        if (input.find("font") != input.end())
        {
            string font_path = input["font"];
            global_style.font = getFont(font_path);
            // Fallback if font failed to load.
            if (!global_style.font)
            {
                LOG(Debug, "Font ", font_path, " failed to load for element ", element_name, " in theme ", name, ". Using fallback font.");
                global_style.font = theme->styles["fallback"].states[0].font;
            }
        }
        /* TODO: 
        if (input.find("font_offset") != input.end())
            global_style.font_offset = input["font_offset"].toFloat();
        */
        if (input.find("size") != input.end())
            global_style.size = input["size"].toFloat();
        if (input.find("sound") != input.end())
            global_style.sound = input["sound"];

        // Apply global_style to all states.
        for(unsigned int n = 0; n < int(GuiElement::State::COUNT); n++)
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

            // Merge global_style into this state; override only if specified.
            if (input.find("image") != input.end())
                style.states[n].texture = global_style.texture;
            if (input.find("color") != input.end())
                style.states[n].color = global_style.color;
            if (input.find("font") != input.end() && global_style.font)
                style.states[n].font = global_style.font;
            /* TODO:
            if (input.find("font_offset") != input.end())
                style.states[n].font_offset = global_style.font_offset;
            */
            if (input.find("size") != input.end())
                style.states[n].size = global_style.size;
            if (input.find("sound") != input.end())
                style.states[n].sound = global_style.sound;

            // State-specific (hover, etc.) overrides
            if (input.find("image." + postfix) != input.end())
                style.states[n].texture = input["image." + postfix];
            if (input.find("color." + postfix) != input.end())
                style.states[n].color = toColor(input["color." + postfix]);
            if (input.find("font." + postfix) != input.end())
            {
                string state_font_path = input["font." + postfix];
                style.states[n].font = getFont(state_font_path);
                if (!style.states[n].font)
                    LOG(Debug, "State-specific font '", state_font_path, "' failed to load for element ", element_name, " state ", postfix, " in theme ", name);
            }
            if (input.find("size." + postfix) != input.end())
                style.states[n].size = input["size." + postfix].toFloat();
            if (input.find("sound." + postfix) != input.end())
                style.states[n].sound = input["sound." + postfix];
        }

        theme->styles[element_name] = style;
    }

    LOG(Debug, "Successfully loaded theme: ", name, " with ", theme->styles.size(), " total styles");
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
    // TODO: fallback_state.offset = 0.0f;
    std::vector<string> fonts = findResources("gui/fonts/*.ttf");
    if(fonts.size() > 0)
    {
        fallback_state.font = getFont(fonts[0]);
    }
    fallback_state.texture = "";
    GuiThemeStyle fallback;
    for(unsigned int n=0; n<int(GuiElement::State::COUNT); n++)
        fallback.states[n] = fallback_state;
    styles["fallback"] = fallback;
}

GuiTheme::~GuiTheme()
{
}
