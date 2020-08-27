#include "signalQualityIndicator.h"
#include "engine.h"

GuiSignalQualityIndicator::GuiSignalQualityIndicator(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    target_period = random(2.0, 5.0);
    error_noise = 0.0;
    error_phase = 0.0;
    error_period = 0.0;
}

void GuiSignalQualityIndicator::onDraw(sf::RenderTarget& window)
{
    drawStretchedHV(window, rect, 25.0f, "gui/PanelBackground");

    sf::VertexArray r(sf::LinesStrip, rect.width / 4 - 1);
    sf::VertexArray g(sf::LinesStrip, rect.width / 4 - 1);
    sf::VertexArray b(sf::LinesStrip, rect.width / 4 - 1);
    float amp = rect.height / 2.0 - 10.0;
    float phase[3];
    float freq[3];
    float noise[3] = {error_noise, error_noise, error_noise};
    for(int n=0; n<3; n++)
    {
        phase[n] = clock.getElapsedTime().asSeconds() * (2.0f + error_phase * (100.0f + n * 45.0f));
        phase[n] = clock.getElapsedTime().asSeconds() + error_phase * (100.0f + n * 45.0f);
        freq[n] = 2.0f * float(M_PI) / float(r.getVertexCount()) * target_period * (1.0 + (error_period * (0.0 + n * 2.2)));
    }
    for(unsigned int n=0; n<r.getVertexCount(); n++)
    {
        float f;

        f = sin(float(n) * freq[0] + phase[0]);
        f = (1.0 - noise[0]) * f + noise[0] * random(-1.0, 1.0);
        r[n].position.x = rect.left + 4.0 + n * 4;
        r[n].position.y = rect.top + rect.height / 2.0 + f * amp;
        r[n].color = sf::Color::Red;

        f = sin(float(n) * freq[1] + phase[1]);
        f = (1.0 - noise[1]) * f + noise[1] * random(-1.0, 1.0);
        g[n].position.x = rect.left + 4.0 + n * 4;
        g[n].position.y = rect.top + rect.height / 2.0 + f * amp;
        g[n].color = sf::Color::Green;

        f = sin(float(n) * freq[2] + phase[2]);
        f = (1.0 - noise[2]) * f + noise[2] * random(-1.0, 1.0);
        b[n].position.x = rect.left + 4.0 + n * 4;
        b[n].position.y = rect.top + rect.height / 2.0 + f * amp;
        b[n].color = sf::Color::Blue;
    }
    window.draw(r, sf::RenderStates(sf::BlendAdd));
    window.draw(g, sf::RenderStates(sf::BlendAdd));
    window.draw(b, sf::RenderStates(sf::BlendAdd));
}
