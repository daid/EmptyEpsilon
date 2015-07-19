#include "hardwareMappingEffects.h"
#include "logging.h"

#define REQ_SETTING(key, variable, effect_name) \
    if (settings.find(key) == settings.end()) { LOG(ERROR) << "[" << key << "] not set for " << effect_name << " effect"; return false; } \
    variable = settings[key].toFloat();
#define OPT_SETTING(key, variable, effect_name, default) \
    if (settings.find(key) == settings.end()) { variable = default; } else { variable = settings[key].toFloat(); }

bool HardwareMappingEffectStatic::configure(std::unordered_map<string, string> settings)
{
    REQ_SETTING("value", value, "static");
    return true;
}

float HardwareMappingEffectStatic::onActive()
{
    return value;
}

bool HardwareMappingEffectGlow::configure(std::unordered_map<string, string> settings)
{
    OPT_SETTING("min_value", min_value, "glow", 0.0);
    OPT_SETTING("max_value", max_value, "glow", 1.0);
    REQ_SETTING("time", time, "glow");
    clock.restart();
    return true;
}

float HardwareMappingEffectGlow::onActive()
{
    if (clock.getElapsedTime().asSeconds() > time * 2.0)
        clock.restart();
    float f = clock.getElapsedTime().asSeconds() / time;
    if (f > 1.0)
        return min_value * (f - 1.0) + max_value * (2.0 - f);
    else
        return min_value * (1.0 - f) + max_value * (f);
}

void HardwareMappingEffectGlow::onInactive()
{
    clock.restart();
}

bool HardwareMappingEffectBlink::configure(std::unordered_map<string, string> settings)
{
    OPT_SETTING("off_value", off_value, "blink", 0.0);
    OPT_SETTING("on_value", off_value, "blink", 1.0);
    REQ_SETTING("on_time", on_time, "blink");
    REQ_SETTING("off_time", off_time, "blink");
    clock.restart();
    return true;
}

float HardwareMappingEffectBlink::onActive()
{
    if (clock.getElapsedTime().asSeconds() > on_time + off_time)
        clock.restart();
    if (clock.getElapsedTime().asSeconds() > on_time)
        return off_value;
    else
        return on_value;
}

void HardwareMappingEffectBlink::onInactive()
{
    clock.restart();
}
