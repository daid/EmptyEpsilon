#ifndef GUI_SCRIPT_ERROR_H
#define GUI_SCRIPT_ERROR_H

#include "engine.h"

class ScriptErrorRenderer : public Renderable
{
public:
    ScriptErrorRenderer();

    virtual void render(sf::RenderTarget& window);
};


#endif//GUI_SCRIPT_ERROR_H
