#pragma once

#include "script/callback.h"

class LifeTime
{
public:
    float maximum = 1.0;
    float alive_for = 0.0;
    sp::script::Callback on_expire;
};
