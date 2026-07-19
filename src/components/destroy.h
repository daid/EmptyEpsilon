#pragma once

#include "script/callback.h"

// Entity should have this callback invoked when about to be destroyed
class OnDestroyed
{
public:
    sp::script::Callback callback;
};

// Entity has had its OnDestroyed callback invoked already
class Destroyed
{
};
