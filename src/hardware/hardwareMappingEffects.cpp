#include "hardwareMappingEffects.h"
#include "logging.h"
#include "tween.h"
#include "hardwareController.h"

#define REQ_SETTING(key, variable, effect_name) \
    if (settings.find(key) == settings.end()) { LOG(ERROR) << "[" << key << "] not set for " << effect_name << " effect"; return false; } \
    variable = convertOutput(settings[key]);
#define OPT_SETTING(key, variable, effect_name, default) \
    if (settings.find(key) == settings.end()) { variable = default; } else { variable = convertOutput(settings[key]); }

float HardwareMappingEffect::convertOutput(string number)
{
    if (number.startswith("$"))
        return float(number.substr(1).toInt(16)) / 255;
    if (number.startswith("[") && number.endswith("]"))
        return float(number.substr(1, -1).toInt()) / 255;
    return number.toFloat();
}

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
    timer.repeat(time);
    back = false;
    return true;
}

float HardwareMappingEffectGlow::onActive()
{
    if (timer.isExpired())
        back = !back;
    float f = timer.getProgress();
    if (back)
        return min_value * (f - 1.0) + max_value * (2.0 - f);
    else
        return min_value * (1.0 - f) + max_value * (f);
}

void HardwareMappingEffectGlow::onInactive()
{
    timer.repeat(time);
}

bool HardwareMappingEffectBlink::configure(std::unordered_map<string, string> settings)
{
    OPT_SETTING("on_value", on_value, "blink", 1.0);
    OPT_SETTING("off_value", off_value, "blink", 0.0);
    REQ_SETTING("on_time", on_time, "blink");
    REQ_SETTING("off_time", off_time, "blink");
    on = true;
    timer.start(on_time);
    return true;
}

float HardwareMappingEffectBlink::onActive()
{
    if (timer.isExpired())
    {
        on = !on;
        timer.start(on ? on_time : off_time);
    }
    if (on)
        return off_value;
    else
        return on_value;
}

void HardwareMappingEffectBlink::onInactive()
{
    on = true;
    timer.start(on_time);
}

HardwareMappingEffectVariable::HardwareMappingEffectVariable(HardwareController* controller)
: controller(controller)
{
}

bool HardwareMappingEffectVariable::configure(std::unordered_map<string, string> settings)
{
    if (settings.find("condition") != settings.end())
    {
        variable_name = settings["condition"];
        if (variable_name.find("<") >= 0) variable_name = variable_name.substr(0, variable_name.find("<")).strip();
        if (variable_name.find(">") >= 0) variable_name = variable_name.substr(0, variable_name.find(">")).strip();
        if (variable_name.find("==") >= 0) variable_name = variable_name.substr(0, variable_name.find("==")).strip();
        if (variable_name.find("!=") >= 0) variable_name = variable_name.substr(0, variable_name.find("!=")).strip();
    }
    if (settings.find("trigger") != settings.end())
    {
        variable_name = settings["trigger"];
        if (variable_name.startswith("<"))
        {
            variable_name = variable_name.substr(1).strip();
        }
        if (variable_name.startswith(">"))
        {
            variable_name = variable_name.substr(1).strip();
        }
    }
    if (settings.find("input") != settings.end())
    {
        variable_name = settings["input"];
    }
    OPT_SETTING("min_input", min_input, "value", 0.0);
    OPT_SETTING("max_input", max_input, "value", 1.0);
    OPT_SETTING("min_output", min_output, "value", 0.0);
    OPT_SETTING("max_output", max_output, "value", 1.0);
    return variable_name != "";
}

float HardwareMappingEffectVariable::onActive()
{
    float input = 0.0;
    controller->getVariableValue(variable_name, input);
    input = std::min(max_input, std::max(min_input, input));
    return Tween<float>::linear(input, min_input, max_input, min_output, max_output);
}

bool HardwareMappingEffectNoise::configure(std::unordered_map<string, string> settings)
{
    OPT_SETTING("min_value", min_value, "noise", 0.0);
    OPT_SETTING("max_value", max_value, "noise", 1.0);
    OPT_SETTING("smoothness", smoothness, "noise", 0.0);
    start_value = random(0.0, 1.0);
    target_value = random(0.0, 1.0);
    if (smoothness > 0)
        timer.repeat(smoothness);
    return true;
}

float HardwareMappingEffectNoise::onActive()
{
    if (!timer.isRunning())
        return Tween<float>::linear(random(0, 1), 0, 1, min_value, max_value);
    if (timer.isExpired())
    {
        start_value = target_value;
        target_value = random(0, 1);
    }
    float f = timer.getProgress();
    f = Tween<float>::linear(f, 0, smoothness, start_value, target_value);
    return Tween<float>::linear(f, 0, 1, min_value, max_value);
}

void HardwareMappingEffectNoise::onInactive()
{
    if (smoothness > 0)
        timer.repeat(smoothness);
}
