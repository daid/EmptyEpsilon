#pragma once
#include "script/environment.h"
#include "script/callback.h"


class GMScriptCallback
{
public:
    string name;
    sp::script::Callback callback;

    GMScriptCallback(string name) : name(name) {}
};

void registerScriptGMFunctions(sp::script::Environment& env);