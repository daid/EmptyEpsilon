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

void GuiSignalQualityIndicator::onDraw(sp::RenderTarget& renderer)
{
    renderer.drawStretchedHV(rect, 25.0f, "gui/widget/PanelBackground.png");

    int point_count = rect.size.x / 4 - 1;
    std::vector<glm::vec2> r;
    std::vector<glm::vec2> g;
    std::vector<glm::vec2> b;
    float amp = rect.size.y / 2.0 - 10.0;
    float phase[3];
    float freq[3];
    float noise[3] = {error_noise, error_noise, error_noise};
    for(int n=0; n<3; n++)
    {
        phase[n] = clock.get() * (2.0f + error_phase * (100.0f + n * 45.0f));
        phase[n] = clock.get() + error_phase * (100.0f + n * 45.0f);
        freq[n] = 2.0f * float(M_PI) / float(point_count) * target_period * (1.0 + (error_period * (0.0 + n * 2.2)));
    }
    for(unsigned int n=0; n<point_count; n++)
    {
        float f;

        f = sin(float(n) * freq[0] + phase[0]);
        f = (1.0 - noise[0]) * f + noise[0] * random(-1.0, 1.0);
        r.emplace_back(rect.position.x + 4.0 + n * 4, rect.position.y + rect.size.y / 2.0 + f * amp);

        f = sin(float(n) * freq[1] + phase[1]);
        f = (1.0 - noise[1]) * f + noise[1] * random(-1.0, 1.0);
        g.emplace_back(rect.position.x + 4.0 + n * 4, rect.position.y + rect.size.y / 2.0 + f * amp);

        f = sin(float(n) * freq[2] + phase[2]);
        f = (1.0 - noise[2]) * f + noise[2] * random(-1.0, 1.0);
        b.emplace_back(rect.position.x + 4.0 + n * 4, rect.position.y + rect.size.y / 2.0 + f * amp);
    }
    renderer.drawLineBlendAdd(r, glm::u8vec4(255, 0, 0, 255));
    renderer.drawLineBlendAdd(g, glm::u8vec4(0, 255, 0, 255));
    renderer.drawLineBlendAdd(b, glm::u8vec4(0, 0, 255, 255));
}
