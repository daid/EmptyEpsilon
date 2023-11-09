#ifndef MOUSE_RENDERER_H
#define MOUSE_RENDERER_H

#include "Renderable.h"

class MouseRenderer : public Renderable
{
public:
    bool visible;

    MouseRenderer(RenderLayer* render_layer);

    virtual void render(sp::RenderTarget& window) override;
    virtual bool onPointerMove(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onPointerLeave(sp::io::Pointer::ID id) override;
    virtual void onPointerDrag(glm::vec2 position, sp::io::Pointer::ID id) override;

private:
    glm::vec2 position;
};

#endif//MOUSE_RENDERER_H
