#include "screens/baseShipScreen.h"
#include "components/player.h"
#include "gui/theme.h"
#include "playerInfo.h"
#include "screenComponents/alertOverlay.h"

BaseShipScreen::BaseShipScreen(GuiContainer* owner, string id)
: GuiOverlay(owner, id, GuiTheme::getColor("background")),
	bg_default(GuiTheme::getColor("background")),
	bg_yellow(GuiTheme::getColor("background.yellow_alert")),
	bg_red(GuiTheme::getColor("background.red_alert"))
{
    background_crosses = new GuiOverlay(this, "BACKGROUND_CROSSES", glm::u8vec4{255,255,255,255});
    background_crosses->setTextureTiledThemed("background.crosses");

	new AlertLevelOverlay(this);
}

void BaseShipScreen::onUpdate() {
	auto level = AlertLevel::Normal;

	if (my_spaceship)
		if (auto pc = my_spaceship.getComponent<PlayerControl>())
			level = pc->alert_level;

	switch (level) {
	case AlertLevel::RedAlert:
		setColor(bg_red);
		break;
	case AlertLevel::YellowAlert:
		setColor(bg_yellow);
		break;
	default:
		setColor(bg_default);
		break;
	}
}
