#pragma once

#include "gui/gui2_keyvaluedisplay.h"

class EnergyInfoDisplay : public GuiKeyValueDisplay
{
public:
    EnergyInfoDisplay(GuiContainer* owner, const string& id, float div_distance, bool show_delta=false);

    void onUpdate() override;
private:
    bool show_delta = false;

    float previous_energy_measurement = 0.0f;
    float previous_energy_level = 0.0f;
    float average_energy_delta = 0.0f;
};

class HeadingInfoDisplay : public GuiKeyValueDisplay
{
public:
    HeadingInfoDisplay(GuiContainer* owner, const string& id, float div_distance);

    void onUpdate() override;
};

class VelocityInfoDisplay : public GuiKeyValueDisplay
{
public:
    VelocityInfoDisplay(GuiContainer* owner, const string& id, float div_distance);

    void onUpdate() override;
};

class HullInfoDisplay : public GuiKeyValueDisplay
{
public:
    HullInfoDisplay(GuiContainer* owner, const string& id, float div_distance);

    void onUpdate() override;
};

class ShieldsInfoDisplay : public GuiKeyValueDisplay
{
public:
    ShieldsInfoDisplay(GuiContainer* owner, const string& id, float div_distance, int shield_index=-1);

    void onUpdate() override;
private:
    int shield_index=0;
};

class CoolantInfoDisplay : public GuiKeyValueDisplay
{
public:
    CoolantInfoDisplay(GuiContainer* owner, const string& id, float div_distance);

    void onUpdate() override;
};
