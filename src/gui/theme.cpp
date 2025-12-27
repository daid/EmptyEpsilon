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

const GuiThemeStyle* GuiTheme::getStyle(const string& element)
{
    auto it = styles.find(element);
    if (it != styles.end())
    {
        // Log the font that will be applied for the Normal state
        const auto& normal_state = it->second.states[int(GuiElement::State::Normal)];
        if (normal_state.font)
        {
            // Try to find the font name from the fonts cache
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
    // LOG(Debug, "Element ", element, " not found in theme ", name, ", trying parent element: ", parent_element);
    return getStyle(parent_element);
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
    LOG(Warning, "Theme ", name, " not found. Falling back to [default] theme.");
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

// Helper function to recursively load parent themes
// Returns false if circular dependency detected
bool GuiTheme::loadParentThemes(GuiTheme* theme,
                                const std::vector<string>& parent_names,
                                std::unordered_set<string>& loading_chain)
{
    for (const string& parent_name : parent_names)
    {
        // Check if parent already loaded
        if (GuiTheme::themes.find(parent_name) == GuiTheme::themes.end())
        {
            // Circular dependency check
            if (loading_chain.find(parent_name) != loading_chain.end())
            {
                LOG(Error, "Circular theme inheritance detected: ", parent_name);
                LOG(Debug, "Loading chain: ", [&]() {
                    string chain;
                    for (const auto& t : loading_chain) chain += t + " -> ";
                    return chain + parent_name;
                }());
                return false;
            }

            // Load parent theme
            string parent_resource = "gui/" + parent_name + ".theme.txt";
            LOG(Debug, "Loading parent theme: ", parent_name, " from ", parent_resource);
            loading_chain.insert(parent_name);
            if (!GuiTheme::loadTheme(parent_name, parent_resource))
            {
                LOG(Error, "Failed to load parent theme: ", parent_name);
                LOG(Debug, "Could not load resource: ", parent_resource);
                return false;
            }
            loading_chain.erase(parent_name);
            LOG(Debug, "Successfully loaded parent theme: ", parent_name);
        }
        else
        {
            LOG(Debug, "Parent theme ", parent_name, " already loaded, reusing");
        }

        theme->parent_themes.push_back(parent_name);
    }
    return true;
}

// Merge style from all parent themes.
GuiThemeStyle GuiTheme::getMergedParentStyle(GuiTheme* theme, const string& element_name)
{
    GuiThemeStyle merged;

    // Initialize with fallback defaults.
    for (int n = 0; n < int(GuiElement::State::COUNT); n++)
    {
        merged.states[n].color = {255, 255, 255, 255};
        merged.states[n].size = 30.0f;
        merged.states[n].font = nullptr;
        merged.states[n].texture = "";
        merged.states[n].sound = "";
    }

    // Merge from each parent in precedence order.
    for (const string& parent_name : theme->parent_themes)
    {
        GuiTheme* parent = GuiTheme::getTheme(parent_name);
        if (!parent)
        {
            LOG(Debug, "Parent theme ", parent_name, " not found when merging style for ", element_name);
            continue;
        }

        const GuiThemeStyle* parent_style = parent->getStyle(element_name);
        if (!parent_style)
        {
            LOG(Debug, "Style ", element_name, " not found in parent theme ", parent_name);
            continue;
        }

        // Merge each state's properties.
        for (int n = 0; n < int(GuiElement::State::COUNT); n++)
        {
            const GuiThemeStyle::StateStyle& ps = parent_style->states[n];
            GuiThemeStyle::StateStyle& ms = merged.states[n];

            // Override only if parent has non-default value.
            if (ps.texture != "")
                ms.texture = ps.texture;
            if (ps.font != nullptr)
                ms.font = ps.font;
            if (ps.sound != "")
                ms.sound = ps.sound;
            // Always override these (can't detect "default")
            ms.color = ps.color;
            ms.size = ps.size;
        }
    }

    return merged;
}

bool GuiTheme::loadTheme(const string& name, const string& resource_name)
{
    LOG(Debug, "Loading theme: ", name, " from ", resource_name);
    GuiTheme* theme = new GuiTheme(name);

    auto tree = sp::io::KeyValueTreeLoader::load(resource_name);
    if (!tree)
    {
        LOG(Debug, "Failed to load theme file: ", resource_name);
        delete theme;
        return false;
    }

    // Parse `inherit` directive from `base` node.
    std::vector<string> parent_names;
    auto base_node = tree->getFlattenNodesByIds().find("base");
    if (base_node != tree->getFlattenNodesByIds().end())
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

    // Recursively load parent themes.
    std::unordered_set<string> loading_chain = {name};
    if (!loadParentThemes(theme, parent_names, loading_chain))
    {
        delete theme;
        return false;
    }

    // Track this theme's explicitly defined elements.
    std::unordered_set<string> explicitly_defined_elements;

    // Track the default font from the base element.
    sp::Font* base_font = nullptr;

    for (auto& it : tree->getFlattenNodesByIds())
    {
        string element_name = it.first;
        std::map<string, string>& input = it.second;

        explicitly_defined_elements.insert(element_name);

        // Start with merged parent styles.
        GuiThemeStyle style = getMergedParentStyle(theme, element_name);

        // Create global_style from parent's normal state, then override with
        // this theme's values.
        GuiThemeStyle::StateStyle global_style = style.states[int(GuiElement::State::Normal)];

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

            // If this is the base element, store its font as the theme default.
            if (element_name == "base" && global_style.font)
                base_font = global_style.font;
        }
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

    // Copy all parent theme styles that aren't already defined in this theme.
    // Process parents in reverse order, such that higher-precedence parent
    // styles have priority.
    for (auto it = theme->parent_themes.rbegin(); it != theme->parent_themes.rend(); ++it)
    {
        const string& parent_name = *it;
        GuiTheme* parent = GuiTheme::getTheme(parent_name);
        if (!parent)
        {
            LOG(Debug, "Parent theme ", parent_name, " not found, can't copy styles.");
            continue;
        }

        for (const auto& parent_style : parent->styles)
        {
            if (theme->styles.find(parent_style.first) == theme->styles.end())
            {
                GuiThemeStyle copied_style = parent_style.second;

                // If this theme has a base font and this element wasn't
                // explicitly defined in the theme, apply the base font to all
                // states of this copied style.
                if (base_font && explicitly_defined_elements.find(parent_style.first) == explicitly_defined_elements.end())
                {
                    for (size_t n = 0; n < static_cast<size_t>(GuiElement::State::COUNT); n++)
                    {
                        // Override only if no state-specific font is defined.
                        if (copied_style.states[n].font)
                            copied_style.states[n].font = base_font;
                    }
                }

                theme->styles[parent_style.first] = copied_style;
            }
        }
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
