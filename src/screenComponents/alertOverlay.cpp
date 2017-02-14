#include "alertOverlay.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

AlertLevelOverlay::AlertLevelOverlay(GuiContainer* owner)
: GuiElement(owner, "")
{
}

void AlertLevelOverlay::onDraw(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;
    
    sf::Color color;
    string text;
    float text_size;
    
    switch(my_spaceship->alert_level)
    {
    case AL_RedAlert:
        color = sf::Color(255, 0, 0);
        text = "";
        text_size = 70;
        break;
    case AL_YellowAlert:
        color = sf::Color(255, 255, 0);
        text = "";
        text_size = 60;
        break;
    case AL_Normal:
    default:
        return;
    }

    sf::Sprite alert;
    textureManager.setTexture(alert, "alert_overlay.png");
    alert.setColor(color);
    alert.setPosition(window.getView().getSize() / 2.0f);
    window.draw(alert);
    sf::Text alert_text(text, *main_font, text_size);
    alert_text.setColor(color);
    alert_text.setOrigin(sf::Vector2f(alert_text.getLocalBounds().width / 2.0f, alert_text.getLocalBounds().height / 2.0f + alert_text.getLocalBounds().top));
    alert_text.setPosition(window.getView().getSize() / 2.0f - sf::Vector2f(0, 300));
    window.draw(alert_text);
}
