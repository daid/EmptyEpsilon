#pragma once

#include "script/callback.h"

class ScanProbeLauncher
{
public:
    int max = 8;
    int stock = 8;
    float recharge = 0.0;
    float charge_time = 10.0f;
    sp::script::Callback on_launch;
};
