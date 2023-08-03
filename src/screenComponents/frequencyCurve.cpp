#include "frequencyCurve.h"
#include "playerInfo.h"
#include "i18n.h"
#include "tween.h"
#include "components/beamweapon.h"
#include "components/shields.h"


GuiFrequencyCurve::GuiFrequencyCurve(GuiContainer* owner, string id, bool frequency_is_beam, bool more_damage_is_positive)
: GuiPanel(owner, id), frequency_is_beam(frequency_is_beam), more_damage_is_positive(more_damage_is_positive)
{
    frequency = -1;
}

void GuiFrequencyCurve::onDraw(sp::RenderTarget& renderer)
{
    GuiPanel::onDraw(renderer);

    if (frequency >= 0 && frequency <= BeamWeaponSys::max_frequency)
    {
        if (enemy_has_equipment) {
            float w = (rect.size.x - 40) / (BeamWeaponSys::max_frequency + 1);
            int arrow_index = -1;
            if (frequency_is_beam)
            {
                if (auto shields = my_spaceship.getComponent<Shields>())
                    arrow_index = shields->frequency;
            } else if (my_spaceship) {
                auto beamsystem = my_spaceship.getComponent<BeamWeaponSys>();
                if (beamsystem)
                    arrow_index = beamsystem->frequency;
            }

            for(int n=0; n<=BeamWeaponSys::max_frequency; n++)
            {
                float x = rect.position.x + 20 + w * n;
                float f;
                if (frequency_is_beam)
                    f = frequencyVsFrequencyDamageFactor(frequency, n);
                else
                    f = frequencyVsFrequencyDamageFactor(n, frequency);
                f = Tween<float>::linear(f, 0.5, 1.5, 0.1, 1.0);
                float h = (rect.size.y - 50) * f;
                sp::Rect bar_rect(x, rect.position.y + rect.size.y - 10 - h, w * 0.8f, h);
                if (more_damage_is_positive)
                    renderer.fillRect(bar_rect, glm::u8vec4(255 * (1.0f - f), 255 * f, 0, 255));
                else
                    renderer.fillRect(bar_rect, glm::u8vec4(255 * f, 255 * (1.0f - f), 0, 255));

                if (n == arrow_index)
                    renderer.drawRotatedSprite("gui/widget/IndicatorArrow.png", glm::vec2(x + w * 0.5f, rect.position.y + rect.size.y - 20 - h), w, -90);
            }

            int mouse_freq_nr = int((mouse_position.x - rect.position.x - 20) / w);

            string text = "";
            if (rect.contains(mouse_position) && mouse_freq_nr >= 0 && mouse_freq_nr <= BeamWeaponSys::max_frequency)
            {
                if (frequency_is_beam)
                    text = frequencyToString(mouse_freq_nr) + " " + string(int(frequencyVsFrequencyDamageFactor(frequency, mouse_freq_nr) * 100)) + "% dmg";
                else
                    text = frequencyToString(mouse_freq_nr) + " " + string(int(frequencyVsFrequencyDamageFactor(mouse_freq_nr, frequency) * 100)) + "% dmg";
            }else{
                if (more_damage_is_positive)
                    text = tr("scienceFrequencyGraph", "Damage with your beams");
                else
                    text = tr("scienceFrequencyGraph", "Damage on your shields");
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
        renderer.drawText(rect, tr("scienceFrequencyGraph", "No data"), sp::Alignment::Center, 35);
    }
}

void GuiFrequencyCurve::drawElements(glm::vec2 mouse_position, sp::Rect parent_rect, sp::RenderTarget& window)
{
    this->mouse_position = mouse_position;
    GuiContainer::drawElements(mouse_position, parent_rect, window);
}