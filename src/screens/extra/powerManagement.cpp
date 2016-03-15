#include "powerManagement.h"

#include "playerInfo.h"

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
        
        GuiBox* box = new GuiBox(layout, "");
        systems[n].box = box;
        box->setSize(290, 400);
        
        (new GuiLabel(box, "", getSystemName(ESystem(n)), 30))->addBackground()->setAlignment(ACenter)->setPosition(0, 0, ATopLeft)->setSize(290, 50);
        (new GuiLabel(box, "", "Power", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(20, 50, ATopLeft)->setSize(30, 340);
        (new GuiLabel(box, "", "Coolant", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(100, 50, ATopLeft)->setSize(30, 340);
        (new GuiLabel(box, "", "Heat", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(180, 50, ATopLeft)->setSize(30, 340);
        systems[n].power_slider = new GuiSlider(box, "", 3.0, 0.0, 1.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemPower(ESystem(n), value);
        });
        systems[n].power_slider->addSnapValue(1.0, 0.1)->setPosition(50, 50, ATopLeft)->setSize(55, 340);
        systems[n].coolant_slider = new GuiSlider(box, "", 10.0, 0.0, 0.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemCoolant(ESystem(n), value);
        });
        systems[n].coolant_slider->setPosition(130, 50, ATopLeft)->setSize(55, 340);
        systems[n].heat_bar = new GuiProgressbar(box, "", 0.0, 1.0, 0.0);
        systems[n].heat_bar->setPosition(210, 50, ATopLeft)->setSize(50, 340);
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
            systems[n].power_slider->setValue(my_spaceship->systems[n].power_level);
            systems[n].coolant_slider->setValue(my_spaceship->systems[n].coolant_level);

            float heat = my_spaceship->systems[n].heat_level;
            systems[n].heat_bar->setValue(heat)->setColor(sf::Color(128, 128 * (1.0 - heat), 0));
        }
    }
}
