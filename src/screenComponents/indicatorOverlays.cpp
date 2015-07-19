#include "indicatorOverlays.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "main.h"

GuiIndicatorOverlays::GuiIndicatorOverlays(GuiContainer* owner)
: GuiElement(owner, "INDICATOR_OVERLAYS")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    
    shield_hit_overlay = new GuiOverlay(this, "SHIELD_HIT", sf::Color(64, 64, 128, 0));
    hull_hit_overlay = new GuiOverlay(this, "HULL_HIT", sf::Color(255, 0, 0, 0));
    shield_low_warning_overlay = new GuiOverlay(this, "SHIELD_LOW", sf::Color(255, 0, 0, 0));
    jumping_overlay = new GuiOverlay(this, "JUMPING", sf::Color(0, 0, 0, 0));
    pause_overlay = new GuiOverlay(this, "PAUSE", sf::Color(0, 0, 0, 128));
    (new GuiBox(pause_overlay, "PAUSE_BOX"))->fill()->setPosition(0, 0, ACenter)->setSize(500, 100);
    (new GuiLabel(pause_overlay, "PAUSE_LABEL", "Game Paused", 70))->setPosition(0, 0, ACenter)->setSize(500, 100);
    if (game_server)
    {
        (new GuiButton(pause_overlay, "PAUSE_RESUME", "Unpause", []() {
            engine->setGameSpeed(1.0);
        }))->setPosition(0, 75, ACenter)->setSize(500, 50);
    }
    
    victory_overlay = new GuiOverlay(this, "VICTORY", sf::Color(0, 0, 0, 128));
    (new GuiBox(victory_overlay, "VICTORY_BOX"))->setPosition(0, 0, ACenter)->setSize(500, 100);
    victory_label = new GuiLabel(victory_overlay, "VICTORY_LABEL", "...", 70);
    victory_label->setPosition(0, 0, ACenter)->setSize(500, 100);
}

GuiIndicatorOverlays::~GuiIndicatorOverlays()
{
    warpPostProcessor->enabled = false;
    glitchPostProcessor->enabled = false;
}

void GuiIndicatorOverlays::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        float shield_hit = (std::max(my_spaceship->front_shield_hit_effect, my_spaceship->rear_shield_hit_effect) - 0.5) / 0.5;
        shield_hit_overlay->setAlpha(32 * shield_hit);
        
        if (my_spaceship->front_shield < my_spaceship->front_shield_max / 10.0 || my_spaceship->rear_shield < my_spaceship->rear_shield_max / 10.0)
        {
            shield_low_warning_overlay->setAlpha(16 + 32 * fabsf(fmodf(engine->getElapsedTime() * 2.0, 2.0) - 1.0));
        }else{
            shield_low_warning_overlay->setAlpha(0);
        }
        
        hull_hit_overlay->setAlpha(128 * (my_spaceship->hull_damage_indicator / 1.5));
    }else{
        shield_hit_overlay->setAlpha(0);
        shield_low_warning_overlay->setAlpha(0);
        hull_hit_overlay->setAlpha(0);
    }

    if (my_spaceship)
    {
        if (my_spaceship->jump_indicator > 0.0)
        {
            glitchPostProcessor->enabled = true;
            glitchPostProcessor->setUniform("magtitude", my_spaceship->jump_indicator * 10.0);
            glitchPostProcessor->setUniform("delta", random(0, 360));
        }else{
            glitchPostProcessor->enabled = false;
        }
        if (my_spaceship->current_warp > 0.0)
        {
            warpPostProcessor->enabled = true;
            warpPostProcessor->setUniform("amount", my_spaceship->current_warp * 0.01);
        }else if (my_spaceship->jump_delay > 0.0 && my_spaceship->jump_delay < 2.0)
        {
            warpPostProcessor->enabled = true;
            warpPostProcessor->setUniform("amount", (2.0 - my_spaceship->jump_delay) * 0.1);
        }else{
            warpPostProcessor->enabled = false;
        }
    }else{
        warpPostProcessor->enabled = false;
        glitchPostProcessor->enabled = false;
    }
    
    if (engine->getGameSpeed() == 0.0)
    {
        if (gameGlobalInfo->getVictoryFactionId() < 0)
        {
            pause_overlay->show();
            victory_overlay->hide();
        }else{
            pause_overlay->hide();
            victory_overlay->show();
            if (my_spaceship)
            {
                if (factionInfo[gameGlobalInfo->getVictoryFactionId()]->states[my_spaceship->getFactionId()] == FVF_Enemy)
                    victory_label->setText("Defeat!");
                else
                    victory_label->setText("Victory!");
            }else{
                victory_label->setText(factionInfo[gameGlobalInfo->getVictoryFactionId()]->getName() + " wins");
            }
        }
    }else{
        pause_overlay->hide();
        victory_overlay->hide();
    }
}

bool GuiIndicatorOverlays::onMouseDown(sf::Vector2f position)
{
    if (pause_overlay->isVisible() || victory_overlay->isVisible())
        return true;
    return false;
}
