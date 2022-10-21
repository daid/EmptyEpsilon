#ifndef SCRIPT_ERROR_H
#define SCRIPT_ERROR_H

#include "Renderable.h"

class ScriptErrorRenderer : public Renderable
{
public:
    ScriptErrorRenderer(RenderLayer* renderLayer);

    virtual void render(sp::RenderTarget& target) override;
};

#endif//SCRIPT_ERROR_H
