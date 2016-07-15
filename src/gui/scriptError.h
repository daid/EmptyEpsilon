#ifndef SCRIPT_ERROR_H
#define SCRIPT_ERROR_H

#include "engine.h"

class ScriptErrorRenderer : public Renderable
{
public:
    ScriptErrorRenderer();

    virtual void render(sf::RenderTarget& window);
};

#endif//SCRIPT_ERROR_H
