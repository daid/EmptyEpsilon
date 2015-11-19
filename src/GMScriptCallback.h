#ifndef GM_SCRIPT_CALLBACK_H
#define GM_SCRIPT_CALLBACK_H

#include "engine.h"

class GMScriptCallback : public ScriptCallback
{
public:
    string name;
    
    GMScriptCallback(string name);
};

#endif//GM_SCRIPT_CALLBACK_H
