#ifndef SCRIPT_H
#define SCRIPT_H

#include "engine.h"

/*!
* Script object which gets registered with the global game info, so it can get destroyed when the game is destroyed.
*/
class Script : public ScriptObject
{
public:
    Script();
    virtual ~Script();
};

#endif//SCRIPT_H
