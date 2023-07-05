#ifndef GM_SCRIPT_CALLBACK_H
#define GM_SCRIPT_CALLBACK_H

#include "script/callback.h"

class GMScriptCallback
{
public:
    string name;
    sp::script::Callback callback;

    GMScriptCallback(string name);
};

#endif//GM_SCRIPT_CALLBACK_H
