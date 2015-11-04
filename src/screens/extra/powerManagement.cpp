#include "powerManagement.h"

#include "playerInfo.h"

PowerManagementScreen::PowerManagementScreen(GuiContainer* owner)
: GuiOverlay(owner, "POWER_MANAGEMENT_SCREEN", sf::Color::Black)
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
        
        (new GuiLabel(box, "", "Power", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(20, 20, ATopLeft)->setSize(30, 360);
        (new GuiLabel(box, "", "Coolant", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(100, 20, ATopLeft)->setSize(30, 360);
        (new GuiLabel(box, "", "Heat", 30))->setVertical()->setAlignment(ACenterLeft)->setPosition(180, 20, ATopLeft)->setSize(30, 360);
        systems[n].power_slider = new GuiSlider(box, "", 3.0, 0.0, 1.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemPower(ESystem(n), value);
        });
        systems[n].power_slider->setSnapValue(1.0, 0.1)->setPosition(50, 20, ATopLeft)->setSize(55, 360);
        systems[n].coolant_slider = new GuiSlider(box, "", 10.0, 0.0, 0.0, [n](float value) {
            if (my_spaceship)
                my_spaceship->commandSetSystemCoolant(ESystem(n), value);
        });
        systems[n].coolant_slider->setPosition(130, 20, ATopLeft)->setSize(55, 360);
        systems[n].heat_bar = new GuiProgressbar(box, "", 0.0, 1.0, 0.0);
        systems[n].heat_bar->setPosition(210, 20, ATopLeft)->setSize(50, 360);
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
