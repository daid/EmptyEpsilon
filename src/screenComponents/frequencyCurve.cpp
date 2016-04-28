#include "frequencyCurve.h"
#include "spaceObjects/spaceship.h"
#include "spaceObjects/playerSpaceship.h"
#include "playerInfo.h"

GuiFrequencyCurve::GuiFrequencyCurve(GuiContainer* owner, string id, bool frequency_is_beam, bool more_damage_is_positive)
: GuiPanel(owner, id), frequency_is_beam(frequency_is_beam), more_damage_is_positive(more_damage_is_positive)
{
    frequency = -1;
}

void GuiFrequencyCurve::onDraw(sf::RenderTarget& window)
{
    GuiPanel::onDraw(window);

    if (frequency >= 0 && frequency <= SpaceShip::max_frequency)
    {
        float w = (rect.width - 40) / (SpaceShip::max_frequency + 1);
        for(int n=0; n<=SpaceShip::max_frequency; n++)
        {
            float x = rect.left + 20 + w * n;
            float f;
            if (frequency_is_beam)
                f = frequencyVsFrequencyDamageFactor(frequency, n);
            else
                f = frequencyVsFrequencyDamageFactor(n, frequency);
            f = Tween<float>::linear(f, 0.5, 1.5, 0.1, 1.0);
            float h = (rect.height - 40) * f;
            sf::RectangleShape bar(sf::Vector2f(w * 0.8, h));
            bar.setPosition(x, rect.top + rect.height - 10 - h);
            if (more_damage_is_positive)
                bar.setFillColor(sf::Color(255 * (1.0 - f), 255 * f, 0));
            else
                bar.setFillColor(sf::Color(255 * f, 255 * (1.0 - f), 0));
            window.draw(bar);
            
            if (my_spaceship && ((frequency_is_beam && n == my_spaceship->getShieldsFrequency()) || (!frequency_is_beam && n == my_spaceship->beam_frequency)))
            {
                sf::Sprite image;
                textureManager.setTexture(image, "gui/SelectorArrow");
                image.setPosition(x + w / 2.0, rect.top + rect.height - 20 - h);
                image.setRotation(-90);
                image.setScale(0.2, 0.2);
                window.draw(image);
            }
        }
        
        int mouse_freq_nr = int((InputHandler::getMousePos().x - rect.left - 20) / w);

        string text = "";
        if (rect.contains(InputHandler::getMousePos()) && mouse_freq_nr >= 0 && mouse_freq_nr <= SpaceShip::max_frequency)
        {
            if (frequency_is_beam)
                text = frequencyToString(mouse_freq_nr) + " " + string(int(frequencyVsFrequencyDamageFactor(frequency, mouse_freq_nr) * 100)) + "% dmg";
            else
                text = frequencyToString(mouse_freq_nr) + " " + string(int(frequencyVsFrequencyDamageFactor(mouse_freq_nr, frequency) * 100)) + "% dmg";
        }else{
            if (more_damage_is_positive)
                text = "Damage with your beams";
            else
                text = "Damage on your shields";
        }
        drawText(window, sf::FloatRect(rect.left, rect.top, rect.width, 40), text, ACenter, 20);
    }else{
        drawText(window, rect, "No data", ACenter, 35);
    }
}
