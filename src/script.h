#ifndef SCRIPT_H
#define SCRIPT_H

#include "scriptInterface.h"
#include "script/environment.h"

void setupScriptEnvironment(sp::script::Environment& env);

/*!
* Script object which gets registered with the global game info, so it can get destroyed when the game is destroyed.
*/
class Script : public ScriptObjectLegacy
{
public:
    Script();
    virtual ~Script() = default;

    bool run(string filename);
};

#endif//SCRIPT_H
