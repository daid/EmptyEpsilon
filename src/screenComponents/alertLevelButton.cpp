#include "alertLevelButton.h"
#include "i18n.h"
#include "components/player.h"
#include "playerInfo.h"
#include "gui/gui2_togglebutton.h"

string styleForLevel(AlertLevel level) {
    switch (level) {
    case AlertLevel::YellowAlert:
        return "button.yellow_alert";
    case AlertLevel::RedAlert:
        return "button.red_alert";
    default:
        return "button";
    }
}

GuiAlertLevelSelect::GuiAlertLevelSelect(GuiContainer* owner, string id)
: GuiElement(owner, id), last_level(AlertLevel::Normal)
{
    // Alert level buttons.
    alert_level_button = new GuiToggleButton(this, "", tr("Alert level"), [this](bool value)
    {
        for(GuiButton* button : alert_level_buttons)
            button->setVisible(value);
    });
    alert_level_button->setValue(false);
    alert_level_button->setStyle(styleForLevel(AlertLevel::Normal));
    alert_level_button->setSize(GuiElement::GuiSizeMax, 50);

    for(int level=int(AlertLevel::Normal); level < int(AlertLevel::MAX); level++)
    {
        auto text = alertLevelToLocaleString(AlertLevel(level));
        auto mainText = AlertLevel(level) == AlertLevel::Normal ? tr("Alert level") : text;
        auto style = styleForLevel(AlertLevel(level));

        GuiButton* alert_button = new GuiButton(this, "", text, [this, level, mainText, style]()
        {
            if (my_spaceship)
                my_player_info->commandSetAlertLevel(AlertLevel(level));
            for(GuiButton* button : alert_level_buttons)
                button->setVisible(false);
            alert_level_button->setValue(false);
            alert_level_button->setText(mainText);
            alert_level_button->setStyle(style);
        });
        alert_button->setVisible(false);
        alert_button->setSize(GuiElement::GuiSizeMax, 50);
        alert_button->setStyle(style);
        alert_level_buttons.push_back(alert_button);
    }
}

void GuiAlertLevelSelect::onUpdate()
{
    if (my_spaceship && isVisible())
    {
        if (keys.relay_alert_level_none.getDown())
            my_player_info->commandSetAlertLevel(AlertLevel::Normal);
        if (keys.relay_alert_level_yellow.getDown())
            my_player_info->commandSetAlertLevel(AlertLevel::YellowAlert);
        if (keys.relay_alert_level_red.getDown())
            my_player_info->commandSetAlertLevel(AlertLevel::RedAlert);

        if (auto pc = my_spaceship.getComponent<PlayerControl>()) {
            if (last_level != pc->alert_level) {
                last_level = pc->alert_level;

                alert_level_button->setStyle(styleForLevel(pc->alert_level));
                alert_level_button->setText(
                    pc->alert_level == AlertLevel::Normal
                        ? tr("Alert level")
                        : alertLevelToLocaleString(pc->alert_level)
                );
            }
        }
    }
}
