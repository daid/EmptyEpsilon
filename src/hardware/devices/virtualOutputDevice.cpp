#include "virtualOutputDevice.h"
#include "main.h"

class VirtualOutputRenderer : public Renderable
{
    VirtualOutputDevice* device;
public:
    VirtualOutputRenderer(VirtualOutputDevice* device)
    : Renderable(mouseLayer), device(device)
    {
    }

    virtual void render(sf::RenderTarget& window)
    {
        device->render(window);
    }
};

VirtualOutputDevice::VirtualOutputDevice()
{
    channel_count = 512;
    for(int n=0; n<512; n++)
    {
        channel_data[n].value = 0;
        channel_data[n].type = White;
        channel_data[n].composition = 1;
    }
    renderer = new VirtualOutputRenderer(this);
}

VirtualOutputDevice::~VirtualOutputDevice()
{
    renderer->destroy();
}

bool VirtualOutputDevice::configure(std::unordered_map<string, string> settings)
{
    if (settings.find("channels") != settings.end())
    {
        channel_count = std::max(1, std::min(512, settings["channels"].toInt()));
    }
    if (settings.find("virtual_types") != settings.end())
    {
        std::vector<string> virtual_types = settings["virtual_types"].split(",");
        unsigned int index = 0;
        for(string type_string : virtual_types)
        {
            type_string = type_string.strip();
            if (type_string.length() < 1)
                type_string = "W";
            if (index + type_string.length() < (unsigned int)(channel_count))
            {
                for(char c : type_string)
                {
                    channel_data[index].composition = type_string.length();
                    switch(c)
                    {
                    case 'R': case 'r': channel_data[index].type = Red; break;
                    case 'G': case 'g': channel_data[index].type = Green; break;
                    case 'B': case 'b': channel_data[index].type = Blue; break;
                    default:
                        channel_data[index].type = White;
                    }
                    LOG(DEBUG) << c << ":" << index << ":" << channel_data[index].type;
                    index++;
                }
            }
        }
    }
    return true;
}

void VirtualOutputDevice::setChannelData(int channel, float value)
{
    if (channel >= 0 && channel < 512)
        channel_data[channel].value = value;
}

//Return the number of output channels supported by this device.
int VirtualOutputDevice::getChannelCount()
{
    return channel_count;
}

void VirtualOutputDevice::render(sf::RenderTarget& window)
{
    int location = 0;
    for(int n=0; n<channel_count; n+=channel_data[n].composition, location++)
    {
        sf::Color color(0, 0, 0, 255);
        for(int offset=0; offset<channel_data[n].composition; offset++)
        {
            ChannelData& data = channel_data[n + offset];
            switch(data.type)
            {
            case White:
                color.r = std::min(255, int(color.r + data.value * 255));
                color.g = std::min(255, int(color.g + data.value * 255));
                color.b = std::min(255, int(color.b + data.value * 255));
                break;
            case Red:
                color.r = std::min(255, int(color.r + data.value * 255));
                break;
            case Green:
                color.g = std::min(255, int(color.g + data.value * 255));
                break;
            case Blue:
                color.b = std::min(255, int(color.b + data.value * 255));
                break;
            }
        }

        sf::RectangleShape rect(sf::Vector2f(32, 32));
        rect.setPosition((location % 32) * 32 + 64, (location / 32) * 32 + 64);
        rect.setFillColor(color);
        window.draw(rect, sf::BlendAdd);
    }
}
