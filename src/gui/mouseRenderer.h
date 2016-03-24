#ifndef MOUSE_RENDERER_H
#define MOUSE_RENDERER_H

#include "engine.h"

class MouseRenderer : public Renderable
{
public:
    bool visible;

    MouseRenderer();

    virtual void render(sf::RenderTarget& window);
};

#endif//MOUSE_RENDERER_H
