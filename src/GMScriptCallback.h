#ifndef GM_SCRIPT_CALLBACK_H
#define GM_SCRIPT_CALLBACK_H

#include "scriptInterface.h"

class GMScriptCallback
{
public:
    string name;
    ScriptSimpleCallback callback;

    GMScriptCallback(string name);
};

#endif//GM_SCRIPT_CALLBACK_H
