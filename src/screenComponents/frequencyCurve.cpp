#include "frequencyCurve.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include "playerInfo.h"

GuiFrequencyCurve::GuiFrequencyCurve(GuiContainer* owner, string id, bool frequency_is_beam, bool more_damage_is_positive)
: GuiPanel(owner, id), frequency_is_beam(frequency_is_beam), more_damage_is_positive(more_damage_is_positive)
{
    frequency = -1;
}

void GuiFrequencyCurve::onDraw(sp::RenderTarget& renderer)
{
    GuiPanel::onDraw(renderer);

    if (frequency >= 0 && frequency <= SpaceShip::max_frequency)
    {
        if (enemy_has_equipment) {
            float w = (rect.size.x - 40) / (SpaceShip::max_frequency + 1);
            for(int n=0; n<=SpaceShip::max_frequency; n++)
            {
                float x = rect.position.x + 20 + w * n;
                float f;
                if (frequency_is_beam)
                    f = frequencyVsFrequencyDamageFactor(frequency, n);
                else
                    f = frequencyVsFrequencyDamageFactor(n, frequency);
                f = Tween<float>::linear(f, 0.5, 1.5, 0.1, 1.0);
                float h = (rect.size.y - 50) * f;
                sp::Rect bar_rect(x, rect.position.y + rect.size.y - 10 - h, w * 0.8, h);
                if (more_damage_is_positive)
                    renderer.fillRect(bar_rect, glm::u8vec4(255 * (1.0 - f), 255 * f, 0, 255));
                else
                    renderer.fillRect(bar_rect, glm::u8vec4(255 * f, 255 * (1.0 - f), 0, 255));

                if (my_spaceship && ((frequency_is_beam && n == my_spaceship->getShieldsFrequency()) || (!frequency_is_beam && n == my_spaceship->beam_frequency)))
                {
                    renderer.drawRotatedSprite("gui/widget/SelectorArrow.png", glm::vec2(x + w * 0.5, rect.position.y + rect.size.y - 20 - h), w, -90);
                }
            }

            int mouse_freq_nr = int((InputHandler::getMousePos().x - rect.position.x - 20) / w);

            string text = "";
            if (rect.contains(InputHandler::getMousePos()) && mouse_freq_nr >= 0 && mouse_freq_nr <= SpaceShip::max_frequency)
            {
                if (frequency_is_beam)
                    text = frequencyToString(mouse_freq_nr) + " " + string(int(frequencyVsFrequencyDamageFactor(frequency, mouse_freq_nr) * 100)) + "% dmg";
                else
                    text = frequencyToString(mouse_freq_nr) + " " + string(int(frequencyVsFrequencyDamageFactor(mouse_freq_nr, frequency) * 100)) + "% dmg";
            }else{
                if (more_damage_is_positive)
                    text = tr("Damage with your beams");
                else
                    text = tr("Damage on your shields");
            }
            renderer.drawText(sp::Rect(rect.position.x, rect.position.y, rect.size.x, 40), text, sp::Alignment::Center, 20);
        } // end if enemy_has_equipment
        else {
            if (frequency_is_beam)
                renderer.drawText(rect, tr("scienceFrequencyGraph", "No enemy beams"), sp::Alignment::Center, 35);
            else
                renderer.drawText(rect, tr("scienceFrequencyGraph", "No enemy shields"), sp::Alignment::Center, 35);
        }
    }else{
        renderer.drawText(rect, "No data", sp::Alignment::Center, 35);
    }
}
