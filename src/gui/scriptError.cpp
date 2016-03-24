#include "scriptError.h"
#include "main.h"

ScriptErrorRenderer::ScriptErrorRenderer()
: Renderable(mouseLayer)
{
}

void ScriptErrorRenderer::render(sf::RenderTarget& window)
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
        sf::Text textElement(error, *bold_font, 25);
        textElement.setColor(sf::Color::Red);
        textElement.setPosition(0, 0);
        window.draw(textElement);
    }
}
