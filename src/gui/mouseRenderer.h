#ifndef MOUSE_RENDERER_H
#define MOUSE_RENDERER_H

#include "engine.h"

class MouseRenderer : public Renderable
{
public:
    bool visible;

    MouseRenderer();

    virtual void render(sp::RenderTarget& window) override;
    virtual bool onPointerMove(glm::vec2 position, int id) override;
    virtual void onPointerLeave(int id) override;
    virtual void onPointerDrag(glm::vec2 position, int id) override;

private:
    glm::vec2 position;
};

#endif//MOUSE_RENDERER_H
