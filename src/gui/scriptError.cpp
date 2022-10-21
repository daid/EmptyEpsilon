#include "scriptError.h"
#include "scriptInterface.h"
#include "engine.h"


ScriptErrorRenderer::ScriptErrorRenderer(RenderLayer* renderLayer)
: Renderable(renderLayer)
{
}

void ScriptErrorRenderer::render(sp::RenderTarget& renderer)
{
    P<ScriptObject> script = engine->getObject("scenario");
    if (!script)
    {
        destroy();
        return;
    }

    string error = script->getError();
    if (error != "")
    {
        renderer.drawText(sp::Rect(0, 0, 0, 0), error, sp::Alignment::TopLeft, 25, nullptr, glm::u8vec4(255,0,0,255));
    }
}
