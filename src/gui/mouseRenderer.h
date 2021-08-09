#ifndef MOUSE_RENDERER_H
#define MOUSE_RENDERER_H

#include "engine.h"

class MouseRenderer : public Renderable
{
public:
    bool visible;

    MouseRenderer();

    virtual void render(sp::RenderTarget& window) override;
};

#endif//MOUSE_RENDERER_H
