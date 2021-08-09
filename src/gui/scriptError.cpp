#include "scriptError.h"
#include "main.h"

ScriptErrorRenderer::ScriptErrorRenderer()
: Renderable(mouseLayer)
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
        renderer.drawText(sp::Rect(0, 0, 0, 0), error, sp::Alignment::TopLeft, 25, bold_font, sf::Color::Red);
    }
}
