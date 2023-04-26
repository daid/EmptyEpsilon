#include <i18n.h>
#include "indicatorOverlays.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "main.h"
#include "random.h"
#include "preferenceManager.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/shields.h"
#include "components/hull.h"

#include "gui/gui2_overlay.h"
#include "gui/gui2_label.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_button.h"

GuiIndicatorOverlays::GuiIndicatorOverlays(GuiContainer* owner)
: GuiElement(owner, "INDICATOR_OVERLAYS")
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    shield_hit_overlay = new GuiOverlay(this, "SHIELD_HIT", glm::u8vec4(64, 64, 128, 0));
    hull_hit_overlay = new GuiOverlay(this, "HULL_HIT", glm::u8vec4(255, 0, 0, 0));
    shield_low_warning_overlay = new GuiOverlay(this, "SHIELD_LOW", glm::u8vec4(255, 0, 0, 0));
    pause_overlay = new GuiOverlay(this, "PAUSE", glm::u8vec4(0, 0, 0, 128));
    (new GuiPanel(pause_overlay, "PAUSE_BOX"))->setPosition(0, 0, sp::Alignment::Center)->setSize(500, 100);
    (new GuiLabel(pause_overlay, "PAUSE_LABEL", tr("Game Paused"), 70))->setPosition(0, 0, sp::Alignment::Center)->setSize(500, 100);
    if (game_server)
    {
        (new GuiButton(pause_overlay, "PAUSE_RESUME", tr("Unpause"), []() {
            engine->setGameSpeed(1.0);
        }))->setPosition(0, 75, sp::Alignment::Center)->setSize(500, 50);
    }

    victory_overlay = new GuiOverlay(this, "VICTORY", glm::u8vec4(0, 0, 0, 128));
    victory_panel = new GuiPanel(victory_overlay, "VICTORY_BOX");
    victory_panel->setPosition(0, 0, sp::Alignment::Center)->setSize(500, 100);
    victory_label = new GuiLabel(victory_panel, "VICTORY_LABEL", "...", 70);
    victory_label->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiSizeMax, GuiSizeMax);
}

GuiIndicatorOverlays::~GuiIndicatorOverlays()
{
    warpPostProcessor->enabled = false;
    glitchPostProcessor->enabled = false;
}

static float glow(float min, float max, float time)
{
    return min + (max - min) * std::abs(fmodf(engine->getElapsedTime() / time, 2.0f) - 1.0f);
}

void GuiIndicatorOverlays::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        drawAlertLevel(renderer);

        float shield_hit = 0.0;
        bool low_shields = false;
        auto shields = my_spaceship.getComponent<Shields>();
        if (shields) {
            for(auto& shield : shields->entries)
            {
                shield_hit = std::max(shield_hit, shield.hit_effect);
                if (shield.level < shield.max / 10.0f)
                    low_shields = true;
            }
        }
        shield_hit = (shield_hit - 0.5f) / 0.5f;
        shield_hit_overlay->setAlpha(32 * shield_hit);

        if (low_shields)
        {
            shield_low_warning_overlay->setAlpha(glow(16, 48, 0.5));
        }else{
            shield_low_warning_overlay->setAlpha(0);
        }

        if (auto hull = my_spaceship.getComponent<Hull>())
            hull_hit_overlay->setAlpha(128 * (hull->damage_indicator / 1.5f));
    }else{
        shield_hit_overlay->setAlpha(0);
        shield_low_warning_overlay->setAlpha(0);
        hull_hit_overlay->setAlpha(0);
    }

    if (my_spaceship)
    {
        auto jump = my_spaceship.getComponent<JumpDrive>();
        auto warp = my_spaceship.getComponent<WarpDrive>();
        if (jump && jump->just_jumped > 0.0f)
        {
            glitchPostProcessor->enabled = true;
            glitchPostProcessor->setUniform("magtitude", jump->just_jumped * 10.0f);
            glitchPostProcessor->setUniform("delta", random(0, 360));
        }else{
            glitchPostProcessor->enabled = false;
        }
        if (warp && warp->current > 0.0f && PreferencesManager::get("warp_post_processor_disable").toInt() != 1)
        {
            warpPostProcessor->enabled = true;
            warpPostProcessor->setUniform("amount", warp->current * 0.01f);
        }else if (jump && jump->delay > 0.0f && jump->delay < 2.0f && PreferencesManager::get("warp_post_processor_disable").toInt() != 1)
        {
            warpPostProcessor->enabled = true;
            warpPostProcessor->setUniform("amount", (2.0f - jump->delay) * 0.1f);
        }else{
            warpPostProcessor->enabled = false;
        }
    }else{
        warpPostProcessor->enabled = false;
        glitchPostProcessor->enabled = false;
    }

    if (engine->getGameSpeed() == 0.0f)
    {
        warpPostProcessor->enabled = false;
        glitchPostProcessor->enabled = false;

        if (!gameGlobalInfo->getVictoryFaction())
        {
            pause_overlay->show();
            victory_overlay->hide();
        }else{
            pause_overlay->hide();
            victory_overlay->show();
            if (gameGlobalInfo->global_message_timeout > 0.0f && has_global_message) {
                victory_panel->setPosition(0, 30, sp::Alignment::TopCenter);
            } else {
                victory_panel->setPosition(0, 0, sp::Alignment::Center);
            }

            auto fvf_state = FactionRelation::Neutral;
            if (my_spaceship)
            {
                auto my_faction = my_spaceship.getComponent<Faction>();
                if (my_faction)
                    fvf_state = gameGlobalInfo->getVictoryFaction()->getRelation(my_faction->entity);
            }
            switch(fvf_state)
            {
            case FactionRelation::Enemy:
                victory_label->setText(tr("Defeat!"));
                break;
            case FactionRelation::Friendly:
                victory_label->setText(tr("Victory!"));
                break;
            case FactionRelation::Neutral:
                victory_label->setText(tr("{faction} wins").format({{"faction", gameGlobalInfo->getVictoryFaction()->locale_name}}));
                break;
            }
        }
    }else{
        pause_overlay->hide();
        victory_overlay->hide();
    }
}

bool GuiIndicatorOverlays::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    if (pause_overlay->isVisible() || victory_overlay->isVisible())
        return true;
    return false;
}

void GuiIndicatorOverlays::drawAlertLevel(sp::RenderTarget& renderer)
{
    glm::u8vec4 multiply_color{255,255,255,255};

    auto pc = my_spaceship.getComponent<PlayerControl>();
    if (!pc) return;

    switch(pc->alert_level)
    {
    case AlertLevel::RedAlert:
        multiply_color = glm::u8vec4(255, 192, 192, 255);
        break;
    case AlertLevel::YellowAlert:
        multiply_color = glm::u8vec4(255, 255, 192, 255);
        break;
    case AlertLevel::Normal:
    default:
        return;
    }

    renderer.drawRectColorMultiply(rect, multiply_color);
}
