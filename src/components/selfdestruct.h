#pragma once

#include "crewPosition.h"


class SelfDestruct
{
public:
    // Maximum number of self-destruction confirmation codes
    constexpr static int max_codes = 3;

    bool active = false;
    uint32_t code[max_codes] = {0, 0, 0};
    bool confirmed[max_codes] = {false, false, false};
    CrewPosition entry_position[max_codes] = {CrewPosition::helmsOfficer, CrewPosition::helmsOfficer, CrewPosition::helmsOfficer};
    CrewPosition show_position[max_codes] = {CrewPosition::helmsOfficer, CrewPosition::helmsOfficer, CrewPosition::helmsOfficer};
    float countdown = 0.0f;
    float damage = 150.0f;
    float size = 1500.0f;
};
