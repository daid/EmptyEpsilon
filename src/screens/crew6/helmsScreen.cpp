#include <i18n.h>
#include "playerInfo.h"
#include "helmsScreen.h"
#include "preferenceManager.h"
#include "featureDefs.h"

#include "components/reactor.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/collision.h"
#include "components/maneuveringthrusters.h"
#include "components/docking.h"

#include "screenComponents/combatManeuver.h"
#include "screenComponents/radarView.h"
#include "screenComponents/impulseControls.h"
#include "screenComponents/warpControls.h"
#include "screenComponents/jumpControls.h"
#include "screenComponents/dockingButton.h"
#include "screenComponents/alertOverlay.h"
#include "screenComponents/customShipFunctions.h"

#include "gui/gui2_label.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_image.h"

HelmsScreen::HelmsScreen(GuiContainer* owner)
: GuiOverlay(owner, "HELMS_SCREEN", colorConfig.background)
{
    // Render the radar shadow and background decorations.
    (new GuiImage(this, "BACKGROUND_GRADIENT", "gui/background/gradient.png"))->setPosition(glm::vec2(0, 0), sp::Alignment::Center)->setSize(1200, 900);
    
    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiled("gui/background/crosses.png");

    // Render the alert level color overlay.
    (new AlertLevelOverlay(this));

    GuiRadarView* radar = new GuiRadarView(this, "HELMS_RADAR", nullptr);

    combat_maneuver = new GuiCombatManeuver(this, "COMBAT_MANEUVER");
    combat_maneuver->setPosition(-20, -20, sp::Alignment::BottomRight)->setSize(280, 215)->setVisible(my_spaceship.hasComponent<CombatManeuveringThrusters>());

    radar->setPosition(0, 0, sp::Alignment::Center)->setSize(GuiElement::GuiSizeMatchHeight, 800);
    radar->setRangeIndicatorStepSize(1000.0)->shortRange()->enableGhostDots()->enableWaypoints()->enableCallsigns()->enableHeadingIndicators()->setStyle(GuiRadarView::Circular);
    radar->enableMissileTubeIndicators();
    radar->setCallbacks(
        [radar, this](sp::io::Pointer::Button button, glm::vec2 position) {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
            {
                auto r = radar->getRect();
                float angle = vec2ToAngle(position - transform->getPosition());
                auto draw_position = rect.center() + (position - transform->getPosition()) / radar->getDistance() * std::min(r.size.x, r.size.y) * 0.5f;
                heading_hint->setText(string(fmodf(angle + 90.f + 360.f, 360.f), 1))->setPosition(draw_position - rect.position - glm::vec2(0, 50))->show();
                my_player_info->commandTargetRotation(angle);
            }
        },
        [radar, this](glm::vec2 position) {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
            {
                auto r = radar->getRect();
                float angle = vec2ToAngle(position - transform->getPosition());
                auto draw_position = rect.center() + (position - transform->getPosition()) / radar->getDistance() * std::min(r.size.x, r.size.y) * 0.5f;
                heading_hint->setText(string(fmodf(angle + 90.f + 360.f, 360.f), 1))->setPosition(draw_position - rect.position - glm::vec2(0, 50))->show();
                my_player_info->commandTargetRotation(angle);
            }
        },
        [this](glm::vec2 position) {
            if (auto transform = my_spaceship.getComponent<sp::Transform>())
                my_player_info->commandTargetRotation(vec2ToAngle(position - transform->getPosition()));
            heading_hint->hide();
        }
    );
    radar->setAutoRotating(PreferencesManager::get("helms_radar_lock","0")=="1");

    heading_hint = new GuiLabel(this, "HEADING_HINT", "", 30);
    heading_hint->setAlignment(sp::Alignment::Center)->setSize(0, 0);

    energy_display = new GuiKeyValueDisplay(this, "ENERGY_DISPLAY", 0.45, tr("Energy"), "");
    energy_display->setIcon("gui/icons/energy")->setTextSize(20)->setPosition(20, 100, sp::Alignment::TopLeft)->setSize(240, 40);
    heading_display = new GuiKeyValueDisplay(this, "HEADING_DISPLAY", 0.45, tr("Heading"), "");
    heading_display->setIcon("gui/icons/heading")->setTextSize(20)->setPosition(20, 140, sp::Alignment::TopLeft)->setSize(240, 40);
    velocity_display = new GuiKeyValueDisplay(this, "VELOCITY_DISPLAY", 0.45, tr("Speed"), "");
    velocity_display->setIcon("gui/icons/speed")->setTextSize(20)->setPosition(20, 180, sp::Alignment::TopLeft)->setSize(240, 40);

    GuiElement* engine_layout = new GuiElement(this, "ENGINE_LAYOUT");
    engine_layout->setPosition(20, -100, sp::Alignment::BottomLeft)->setSize(GuiElement::GuiSizeMax, 300)->setAttribute("layout", "horizontal");
    (new GuiImpulseControls(engine_layout, "IMPULSE"))->setSize(100, GuiElement::GuiSizeMax);
    warp_controls = (new GuiWarpControls(engine_layout, "WARP"))->setSize(100, GuiElement::GuiSizeMax);
    jump_controls = (new GuiJumpControls(engine_layout, "JUMP"))->setSize(100, GuiElement::GuiSizeMax);

    docking_button = new GuiDockingButton(this, "DOCKING");
    docking_button->setPosition(20, -20, sp::Alignment::BottomLeft)->setSize(280, 50)->setVisible(my_spaceship.hasComponent<DockingPort>());

    (new GuiCustomShipFunctions(this, CrewPosition::helmsOfficer, ""))->setPosition(-20, 120, sp::Alignment::TopRight)->setSize(250, GuiElement::GuiSizeMax);
}

void HelmsScreen::onDraw(sp::RenderTarget& renderer)
{
    if (my_spaceship)
    {
        auto reactor = my_spaceship.getComponent<Reactor>();
        energy_display->setVisible(reactor);
        if (reactor)
            energy_display->setValue(string(int(reactor->energy)));
        if (auto transform = my_spaceship.getComponent<sp::Transform>())
            heading_display->setValue(string(transform->getRotation() - 270.0f, 1));
        if (auto physics = my_spaceship.getComponent<sp::Physics>()) {
            float velocity = glm::length(physics->getVelocity()) / 1000 * 60;
            velocity_display->setValue(tr("{value} {unit}/min").format({{"value", string(velocity, 1)}, {"unit", DISTANCE_UNIT_1K}}));
        }

        warp_controls->setVisible(my_spaceship.hasComponent<WarpDrive>());
        jump_controls->setVisible(my_spaceship.hasComponent<JumpDrive>());
    }
    GuiOverlay::onDraw(renderer);
}

void HelmsScreen::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        auto angle = (keys.helms_turn_right.getValue() - keys.helms_turn_left.getValue()) * 5.0f;
        if (angle != 0.0f)
        {
            auto transform = my_spaceship.getComponent<sp::Transform>();
            if (transform)
                my_player_info->commandTargetRotation(transform->getRotation() + angle);
        }
    }
}
