#include "powerManagement.h"

#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"

#include "gui/gui2_autolayout.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_progressbar.h"

PowerManagementScreen::PowerManagementScreen(GuiContainer* owner)
: GuiOverlay(owner, "POWER_MANAGEMENT_SCREEN", colorConfig.background)
{
    GuiAutoLayout* layout = new GuiAutoLayout(this, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
    layout->setPosition(20, 50, ATopLeft)->setSize(GuiElement::GuiSizeMax, 400);
    for(int n=0; n<SYS_COUNT; n++)
    {
        if (n == 4)
        {
            //Start the 2nd row after 4 elements.
            layout = new GuiAutoLayout(this, "", GuiAutoLayout::LayoutHorizontalLeftToRight);
            layout->setPosition(20, 450, ATopLeft)->setSize(GuiElement::GuiSizeMax, 400);
        }

        GuiPanel* box = new GuiPanel(layout, "");
        systems[n].box = box;
        box->setSize(290, 400);

        (new GuiLabel(box, "", getSystemName(ESystem(n)), 30))->addBackground()->setAlignment(ACenter)->setPosition(0, 0, ATopLeft)->setSize(290, 50);
        (new GuiLabel(box, "", "Power", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(20, 50, ATopLeft)->setSize(30, 340);
        (new GuiLabel(box, "", "Coolant", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(100, 50, ATopLeft)->setSize(30, 340);
        (new GuiLabel(box, "", "Heat", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(180, 50, ATopLeft)->setSize(30, 340);

        systems[n].power_bar = new GuiProgressbar(box, "", 0.0, 3.0, 1.0);
        systems[n].power_bar->setDrawBackground(false)->setPosition(52.5, 60, ATopLeft)->setSize(50, 320);

        systems[n].power_slider = new GuiSlider(box, "", 3.0, 0.0, 1.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemPowerRequest(ESystem(n), value);
        });
        systems[n].power_slider->addSnapValue(1.0, 0.1)->setPosition(50, 50, ATopLeft)->setSize(55, 340);

        systems[n].coolant_bar = new GuiProgressbar(box, "", 0.0, 10.0, 0.0);
        systems[n].coolant_bar->setDrawBackground(false)->setPosition(132.5, 60, ATopLeft)->setSize(50, 320);

        systems[n].coolant_slider = new GuiSlider(box, "", 10.0, 0.0, 0.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemCoolantRequest(ESystem(n), value);
        });
        systems[n].coolant_slider->setPosition(130, 50, ATopLeft)->setSize(55, 340);

        systems[n].heat_bar = new GuiProgressbar(box, "", 0.0, 1.0, 0.0);
        systems[n].heat_bar->setPosition(210, 60, ATopLeft)->setSize(50, 320);


    }
}

void PowerManagementScreen::onDraw(sf::RenderTarget& window)
{
    GuiOverlay::onDraw(window);
    if (my_spaceship)
    {
        for(int n=0; n<SYS_COUNT; n++)
        {
            systems[n].box->setVisible(my_spaceship->hasSystem(ESystem(n)));
            systems[n].power_slider->setValue(my_spaceship->systems[n].power_request);
            systems[n].coolant_slider->setValue(my_spaceship->systems[n].coolant_request);

            float heat = my_spaceship->systems[n].heat_level;
            float power = my_spaceship->systems[n].power_level;
            float coolant = my_spaceship->systems[n].coolant_level;
            systems[n].heat_bar->setValue(heat)->setColor(sf::Color(128, 128 * (1.0 - heat), 0));
            systems[n].power_bar->setValue(power)->setColor(sf::Color(255, 255, 0));
            systems[n].coolant_bar->setValue(coolant)->setColor(sf::Color(0,128,255));
        }
    }
}

void PowerManagementScreen::onHotkey(const HotkeyResult& key)
{
	if (key.category == "POWER_MANAGEMENT" && my_spaceship)
    {
		if (my_spaceship)
		{		
			for(int n=0; n<SYS_COUNT; n++)
			{
				if (key.hotkey == getSystemName(ESystem(n))+ string("_POWER_UP"))
				{
					my_spaceship->commandSetSystemPowerRequest(ESystem(n), my_spaceship->systems[n].power_request + 0.5f);
				}
				if (key.hotkey == getSystemName(ESystem(n))+ string("_POWER_DOWN"))
				{
					my_spaceship->commandSetSystemPowerRequest(ESystem(n), my_spaceship->systems[n].power_request - 0.5f);
				}
				if (key.hotkey == getSystemName(ESystem(n))+ string("_COOLANT_UP"))
				{
					my_spaceship->commandSetSystemCoolantRequest(ESystem(n), my_spaceship->systems[n].coolant_request + 0.5f);
				}	
				if (key.hotkey == getSystemName(ESystem(n))+ string("_COOLANT_DOWN"))
				{
					my_spaceship->commandSetSystemCoolantRequest(ESystem(n), my_spaceship->systems[n].coolant_request - 0.5f);
				}
			}
		}
	}
}

