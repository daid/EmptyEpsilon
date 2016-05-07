#include "uDMXDevice.h"
#include "logging.h"

#ifdef __WIN32__
    #include <windows.h>

    HMODULE UDMX_dll;

    extern "C" {
    bool __stdcall (*UDMX_Configure)();
    bool __stdcall (*UDMX_Connected)();
    bool __stdcall (*UDMX_ChannelSet)(long Channel, long Value);
    bool __stdcall (*UDMX_ChannelsSet)(long ChannelCnt, long Channel, long* Value);
    bool __stdcall (*UDMX_Info)();
    }
#endif

UDMXDevice::UDMXDevice()
{
}

UDMXDevice::~UDMXDevice()
{
}

//Configure the device.
bool UDMXDevice::configure(std::unordered_map<string, string> settings)
{
#ifdef __WIN32__
    UDMX_dll = LoadLibrary("uDMX.dll");
    if (UDMX_dll == NULL)
    {
        LOG(ERROR) << "Failed to load uDMX.dll for uDMX hardware";
        return false;
    }
    UDMX_Configure = (bool __stdcall (*)())GetProcAddress(UDMX_dll, "Configure");
    if (UDMX_Configure == NULL)
    {
        LOG(ERROR) << "Failed to find Configure function in uDMX.dll";
        return false;
    }
    UDMX_Connected = (bool __stdcall (*)())GetProcAddress(UDMX_dll, "Connected");
    if (UDMX_Connected == NULL)
    {
        LOG(ERROR) << "Failed to find Connected function in uDMX.dll";
        return false;
    }
    UDMX_ChannelSet = (bool __stdcall (*)(long Channel, long Value))GetProcAddress(UDMX_dll, "ChannelSet");
    if (UDMX_ChannelSet == NULL)
    {
        LOG(ERROR) << "Failed to find ChannelSet function in uDMX.dll";
        return false;
    }
    UDMX_ChannelsSet = (bool __stdcall (*)(long ChannelCnt, long Channel, long* Value))GetProcAddress(UDMX_dll, "ChannelsSet");
    if (UDMX_ChannelsSet == NULL)
    {
        LOG(ERROR) << "Failed to find ChannelsSet function in uDMX.dll";
        return false;
    }
    UDMX_Info = (bool __stdcall (*)())GetProcAddress(UDMX_dll, "Info");
    if (UDMX_Info == NULL)
    {
        LOG(ERROR) << "Failed to find Info function in uDMX.dll";
        return false;
    }
    
    if (!UDMX_Connected())
    {
        LOG(ERROR) << "uDMX.dll reported device is not connected.";
        return false;
    }
    
    return true;
#else
    LOG(ERROR) << "uDMX hardware not supported on this OS yet.";
    return false;
#endif
}

//Set a hardware channel output. Value is 0.0 to 1.0 for no to max output.
void UDMXDevice::setChannelData(int channel, float value)
{
#ifdef __WIN32__
    UDMX_ChannelSet(channel, value * 255);
#endif
}

int UDMXDevice::getChannelCount()
{
    return 512;
}
