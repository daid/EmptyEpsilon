#pragma once

#include "scriptInterface.h"

class ScanProbeLauncher
{
public:
    int max = 8;
    int stock = 8;
    float recharge = 0.0;
    float charge_time = 10.0f;
    ScriptSimpleCallback on_launch;
};
