#include "gameGlobalInfo.h"
#include "script.h"

/// Object which can be used to create and run another script.
/// Other scripts have their own lifetime, update and init functions.
/// Scripts can destroy themselves, or be destroyed by the main script.
REGISTER_SCRIPT_CLASS(Script)
{
    /// Run a script with a certain filename
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptObject, run);
    /// Set a global variable in this script instance, this variable can be accessed in the main script.
    REGISTER_SCRIPT_CLASS_FUNCTION(ScriptObject, setVariable);
}

Script::Script()
{
    if (!gameGlobalInfo)
    {
        destroy();
        return;
    }
    
    gameGlobalInfo->addScript(this);
}

Script::~Script()
{
}
