#include "missileWeaponData.h"
#include "i18n.h"
#include "gui/theme.h"

MissileWeaponData::MissileWeaponData(float speed, float turnrate, float lifetime, glm::u8vec4 color, float homing_range, string fire_sound, string radar_trace)
: speed(speed), turnrate(turnrate), lifetime(lifetime), color(color), homing_range(homing_range), fire_sound(fire_sound), radar_trace(radar_trace)
{
}

MissileWeaponData* MissileWeaponData::getMissileDataArray()
{
    static MissileWeaponData missile_data[MW_Count] =
    {
        // MW_Homing
        MissileWeaponData(
            200.0f, 10.f, 27.0f,                       // speed, turnrate, lifetime
            GuiTheme::getColor("missile_data.homing"), // color
            1200.0,                                    // homing_range
            GuiTheme::getSound("missile_data.homing"), // fire_sound
            GuiTheme::getImage("missile_data.homing")  // radar_trace
        ),
        // MW_Nuke
        MissileWeaponData(
            200.0f, 10.f, 27.0f,                     // speed, turnrate, lifetime
            GuiTheme::getColor("missile_data.nuke"), // color
            500.0,                                   // homing_range
            GuiTheme::getSound("missile_data.nuke"), // fire_sound
            GuiTheme::getImage("missile_data.nuke")  // radar_trace
        ),
        // MW_Mine
        MissileWeaponData(
            // Lifetime is used at time which the mine is ejecting from the ship
            100.0f,  0.f, 10.0f,                     // speed, turnrate, lifetime
            GuiTheme::getColor("missile_data.mine"), // color
            0.0,                                     // homing_range
            GuiTheme::getSound("missile_data.mine"), // fire_sound
            GuiTheme::getImage("missile_data.mine")  // radar_trace
        ),
        // MW_EMP
        MissileWeaponData(
            200.0f, 10.f, 27.0f,                    // speed, turnrate, lifetime
            GuiTheme::getColor("missile_data.emp"), // color
            500.0,                                  // homing_range
            GuiTheme::getSound("missile_data.emp"), // fire_sound
            GuiTheme::getImage("missile_data.emp")  // radar_trace
        ),
        // MW_HVLI
        MissileWeaponData(
            500.0f,  0.f, 13.5f,                     // speed, turnrate, lifetime
            GuiTheme::getColor("missile_data.hvli"), // color
            0.0,                                     // homing_range
            GuiTheme::getSound("missile_data.hvli"), // fire_sound
            GuiTheme::getImage("missile_data.hvli")  // radar_trace
        ),
    };
    return missile_data;
}

const MissileWeaponData& MissileWeaponData::getDataFor(EMissileWeapons type)
{
    auto* missile_data = getMissileDataArray();
    if (type == MW_None)
        return missile_data[0];
    return missile_data[type];
}

string getMissileSizeString(EMissileSizes size)
{
    switch (size)
    {
        case MS_Small:
            return "small";
        case MS_Medium:
            return "medium";
        case MS_Large:
            return "large";
        default:
            return string("unknown size:") + string(size);
    }
}

string getMissileWeaponName(EMissileWeapons missile)
{
    switch(missile)
    {
    case MW_None:
        return "-";
    case MW_Homing:
        return "Homing";
    case MW_Nuke:
        return "Nuke";
    case MW_Mine:
        return "Mine";
    case MW_EMP:
        return "EMP";
    case MW_HVLI:
        return "HVLI";
    default:
        return "UNK: " + string(int(missile));
    }
}

string getLocaleMissileWeaponName(EMissileWeapons missile)
{
    switch(missile)
    {
    case MW_None:
        return "-";
    case MW_Homing:
        return tr("missile","Homing");
    case MW_Nuke:
        return tr("missile","Nuke");
    case MW_Mine:
        return tr("missile","Mine");
    case MW_EMP:
        return tr("missile","EMP");
    case MW_HVLI:
        return tr("missile","HVLI");
    default:
        return "UNK: " + string(int(missile));
    }
}

float MissileWeaponData::convertSizeToCategoryModifier(EMissileSizes size)
{
    switch(size)
    {
        case MS_Small:
            return 0.5;
        case MS_Medium:
            return 1.0;
        case MS_Large:
            return 2.0;
        default:
            return 1.0;
    }
}

EMissileSizes MissileWeaponData::convertCategoryModifierToSize(float size)
{
    if (std::abs(size - 0.5f) < 0.1f)
        return MS_Small;
    if (std::abs(size - 1.0f) < 0.1f)
        return MS_Medium;
    if (std::abs(size - 2.0f) < 0.1f)
        return MS_Large;
    return MS_Medium;
}
