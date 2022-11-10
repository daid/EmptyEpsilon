#include "alertLevelButton.h"
#include "gui/gui2_togglebutton.h"
#include "spaceObjects/playerSpaceship.h"


GuiAlertLevelSelect::GuiAlertLevelSelect(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    // Alert level buttons.
    auto alert_level_button = new GuiToggleButton(this, "", tr("Alert level"), [this](bool value)
    {
        for(GuiButton* button : alert_level_buttons)
            button->setVisible(value);
    });
    alert_level_button->setValue(false);
    alert_level_button->setSize(GuiElement::GuiSizeMax, 50);

    for(int level=AL_Normal; level < AL_MAX; level++)
    {
        GuiButton* alert_button = new GuiButton(this, "", alertLevelToLocaleString(EAlertLevel(level)), [this, level, alert_level_button]()
        {
            if (my_spaceship)
                my_spaceship->commandSetAlertLevel(EAlertLevel(level));
            for(GuiButton* button : alert_level_buttons)
                button->setVisible(false);
            alert_level_button->setValue(false);
        });
        alert_button->setVisible(false);
        alert_button->setSize(GuiElement::GuiSizeMax, 50);
        alert_level_buttons.push_back(alert_button);
    }
}

void GuiAlertLevelSelect::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        if (keys.relay_alert_level_none.getDown())
            my_spaceship->commandSetAlertLevel(AL_Normal);
        if (keys.relay_alert_level_yellow.getDown())
            my_spaceship->commandSetAlertLevel(AL_YellowAlert);
        if (keys.relay_alert_level_red.getDown())
            my_spaceship->commandSetAlertLevel(AL_RedAlert);
    }
}