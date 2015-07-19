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
        for(int n=0; n<device->getChannelCount(); n++)
        {
            sf::RectangleShape rect(sf::Vector2f(32, 32));
            rect.setPosition((n % 35) * 32, (n / 35) * 32);
            rect.setFillColor(sf::Color(255, 255, 255, 255 * device->channel_data[n]));
            window.draw(rect);
        }
    }
};

VirtualOutputDevice::VirtualOutputDevice()
{
    for(int n=0; n<512; n++)
        channel_data[n] = 0;
    renderer = new VirtualOutputRenderer(this);
}

VirtualOutputDevice::~VirtualOutputDevice()
{
    renderer->destroy();
}

bool VirtualOutputDevice::configure(std::unordered_map<string, string> settings)
{
    return true;
}

void VirtualOutputDevice::setChannelData(int channel, float value)
{
    if (channel >= 0 && channel < 512)
        channel_data[channel] = value;
}

//Return the number of output channels supported by this device.
int VirtualOutputDevice::getChannelCount()
{
    return 512;
}
