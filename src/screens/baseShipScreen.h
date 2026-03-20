#pragma once

#include "gui/gui2_overlay.h"

class BaseShipScreen : public GuiOverlay
{
public:
	glm::ivec4 bg_default;
	glm::ivec4 bg_yellow;
	glm::ivec4 bg_red;

	GuiOverlay* background_crosses;

	BaseShipScreen(GuiContainer* owner, string id);

	virtual void onUpdate() override;
};
