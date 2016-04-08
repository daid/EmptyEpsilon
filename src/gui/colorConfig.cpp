#include <unordered_map>
#include "colorConfig.h"
#include "resources.h"

//Lots of simple macros to reduce the amount of typing and place for error when defining extra colors.
#define MAP_COLOR(color_name, color_variable) color_mapping[ string( color_name ).lower() ].push_back(&(color_variable));
#define MAP_COLORSET(color_name, color_variable) do { \
        MAP_COLOR(color_name, color_variable.normal); \
        MAP_COLOR(color_name, color_variable.hover); \
        MAP_COLOR(color_name, color_variable.focus); \
        MAP_COLOR(color_name, color_variable.disabled); \
        MAP_COLOR(color_name, color_variable.active); \
    } while(0)

#define DEF_COLOR(color_name) do { MAP_COLOR( #color_name, color_name); color_name = sf::Color(255, 0, 255); } while(0)
#define DEF_COLORSET(color_name) do { \
        MAP_COLORSET( #color_name, color_name); \
        DEF_COLOR( color_name.normal ); \
        DEF_COLOR( color_name.hover ); \
        DEF_COLOR( color_name.focus ); \
        DEF_COLOR( color_name.disabled ); \
        DEF_COLOR( color_name.active ); \
    } while(0)
#define DEF_WIDGETCOLORSET(color_name) do { \
        MAP_COLORSET( #color_name, color_name.forground); \
        MAP_COLORSET( #color_name, color_name.background); \
        DEF_COLORSET( color_name.forground ); \
        DEF_COLORSET( color_name.background ); \
    } while(0)

ColorConfig colorConfig;

void ColorConfig::load()
{
    std::unordered_map<string, std::vector<sf::Color*>> color_mapping;
    
    DEF_COLOR(background);
    DEF_COLOR(radar_outline);
    DEF_WIDGETCOLORSET(button);
    DEF_WIDGETCOLORSET(label);
    DEF_WIDGETCOLORSET(text_entry);
    DEF_WIDGETCOLORSET(slider);
    DEF_WIDGETCOLORSET(textbox);
    DEF_COLOR(overlay_damaged);
    DEF_COLOR(overlay_jammed);
    DEF_COLOR(overlay_no_power);
    DEF_COLOR(overlay_low_energy);
    DEF_COLOR(overlay_low_power);
    DEF_COLOR(overlay_overheating);

    P<ResourceStream> stream = getResourceStream("gui/colors.ini");
    if(!stream)
        return;
    while(stream->tell() < stream->getSize())
    {
        string line = stream->readLine();
        if (line.find("//") > -1)
            line = line.substr(0, line.find("//")).strip();
        if (line.find("=") > -1)
        {
            string key = line.substr(0, line.find("=")).strip().lower();
            string value = line.substr(line.find("=") + 1).strip();

            sf::Color color = sf::Color(255, 0, 255);
            if (value.startswith("#"))
                value = value.substr(1);

            if (value.length() == 6)
                color = sf::Color((value.toInt(16) << 8) | 0xFF);
            else if (value.length() == 8)
                color = sf::Color(value.substr(0, 4).toInt(16) << 16 | value.substr(4).toInt(16));  //toInt(16) fails with 8 bytes, so split the convertion in 2 sections.
            else
                LOG(WARNING) << "Failed to parse color: " << key << " " << value;

            if (color_mapping.find(key) != color_mapping.end())
            {
                for(sf::Color* ptr : color_mapping[key])
                    *ptr = color;
            }else{
                LOG(WARNING) << "Unknown color definition: " << key;
            }
        }
    }
}
