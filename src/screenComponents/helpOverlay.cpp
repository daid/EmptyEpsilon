#include "helpOverlay.h"
#include <i18n.h>
#include "playerInfo.h"

#include "gui/gui2_button.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_label.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"


GuiHelpOverlay::GuiHelpOverlay(GuiContainer* owner, string help_title, string help_text, string help_footer)
: GuiElement(owner, "HELP_OVERLAY"), help_title(help_title), help_text(help_text), help_footer(help_footer)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    frame = new GuiPanel(this, "HELP_FRAME");
    frame
        ->setPosition(0.0f, 0.0f, sp::Alignment::Center)
        ->setSize(600.0f, 700.0f)
        ->hide()
        ->setAttribute("layout", "vertical");
    frame
        ->setAttribute("padding", "25");

    title = new GuiLabel(frame, "HELP_LABEL", help_title, 40.0f);
    title
        ->setAlignment(sp::Alignment::Center)
        ->setSize(GuiElement::GuiSizeMax, 40.0f)
        ->setVisible(!help_title.empty());

    text = new GuiScrollFormattedText(frame, "HELP_TEXT", help_text);
    text
        ->setTextSize(30.0f)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setAttribute("margin", "0, 25");
    if (help_text.empty()) LOG(Warning, "GuiHelpOverlay called with empty contents");

    footer = new GuiLabel(frame, "HELP_FOOTER", help_footer, 25.0f);
    footer
        ->setSize(GuiElement::GuiSizeMax, 30.0f)
        ->setVisible(!help_footer.empty())
        ->setAttribute("margin", "0, 0, 0, 25");

    (new GuiButton(frame, "HELP_CLOSE_BUTTON", tr("hotkey_F1", "Close"), [this]() {
        frame->hide();
    }))
        ->setPosition(0.0f, 0.0f, sp::Alignment::BottomCenter)
        ->setSize(300.0f, 50.0f);
}

GuiHelpOverlay* GuiHelpOverlay::setTitle(string new_title)
{
    help_title = new_title;
    return this;
}

GuiHelpOverlay* GuiHelpOverlay::setText(string new_text)
{
    help_text = new_text;
    return this;
}

GuiHelpOverlay* GuiHelpOverlay::setFooter(string new_footer)
{
    help_footer = new_footer;
    return this;
}

void GuiHelpOverlay::toggle()
{
    frame->setVisible(!frame->isVisible());
}

void GuiHelpOverlay::onDraw(sp::RenderTarget& target)
{
    if (frame->isVisible())
    {
        title->setText(help_title);
        text->setText(help_text);
        footer->setText(help_footer);
    }
}

GuiHotkeyHelpOverlay::GuiHotkeyHelpOverlay(GuiContainer* owner, std::vector<string> categories, string help_text)
: GuiHelpOverlay(owner, tr("hotkey_F1", "Controls"), help_text, tr("hotkey_F1", "Configure controls in Options > Interface Options")), categories(categories)
{
    updateText();
}

GuiHotkeyHelpOverlay* GuiHotkeyHelpOverlay::setCategories(std::vector<string> new_categories)
{
    categories = new_categories;
    updateText();
    return this;
}

GuiHotkeyHelpOverlay* GuiHotkeyHelpOverlay::addCategory(string category)
{
    if (std::find(categories.begin(), categories.end(), category) != categories.end())
        return this;

    categories.push_back(category);
    updateText();
    return this;
}

GuiHotkeyHelpOverlay* GuiHotkeyHelpOverlay::removeCategory(string category)
{
    auto new_end = std::remove(categories.begin(), categories.end(), category);
    if (new_end == categories.end())
    {
        LOG(Warning, "Attempted to remove a hotkey category not tracked by GuiHotkeyHelpOverlay");
        return this;
    }

    categories.erase(new_end, categories.end());
    updateText();
    return this;
}

void GuiHotkeyHelpOverlay::updateText()
{
    string unbound_hotkeys = "<color=#FFFFFFA0>";
    help_text = "";

    auto updateCategory = [&](string category, CrewPosition special_position = CrewPosition::MAX)
    {
        for (sp::io::Keybinding* binding : sp::io::Keybinding::listAllByCategory(category))
        {
            const std::string bind_label = binding->getLabel();

            bool include = false;
            if (special_position == CrewPosition::MAX)
                include = true;
            else if (special_position == CrewPosition::tacticalOfficer)
                include = shield_labels.find(bind_label) == shield_labels.end();
            else if (special_position == CrewPosition::engineeringAdvanced)
                include = shield_labels.find(bind_label) != shield_labels.end();

            if (!include) continue;

            if (binding->isBound())
                help_text += tr("hotkey_F1", "{label}: <color=#C0C0FFFF>{button}</>\n").format({{"label", bind_label}, {"button", binding->getHumanReadableKeyName(0)}});
            else
                unbound_hotkeys += tr("hotkey_F1", "{label}\n").format({{"label", bind_label}});
        }
    };

    for (string category : categories)
    {
        if (category == getCrewPositionName(CrewPosition::tacticalOfficer))
        {
            updateCategory(getCrewPositionName(CrewPosition::helmsOfficer));
            updateCategory(getCrewPositionName(CrewPosition::weaponsOfficer), CrewPosition::tacticalOfficer);
        }
        else if (category == getCrewPositionName(CrewPosition::engineeringAdvanced))
        {
            updateCategory(getCrewPositionName(CrewPosition::engineering));
            updateCategory(getCrewPositionName(CrewPosition::weaponsOfficer), CrewPosition::engineeringAdvanced);
        }
        else if (category == getCrewPositionName(CrewPosition::operationsOfficer))
        {
            updateCategory(getCrewPositionName(CrewPosition::scienceOfficer));
            // No Relay hotkeys to manage here yet, but only place/delete
            // waypoint and open comms would be included
            // updateCategory(getCrewPositionName(CrewPosition::relayOfficer), CrewPosition::operationsOfficer);
        }
        else if (category == getCrewPositionName(CrewPosition::singlePilot))
        {
            updateCategory(getCrewPositionName(CrewPosition::helmsOfficer));
            updateCategory(getCrewPositionName(CrewPosition::weaponsOfficer));
        }
        else updateCategory(category);
    }

    help_text += unbound_hotkeys += "</>";
}

void GuiHotkeyHelpOverlay::onDraw(sp::RenderTarget& target)
{
    if (help_text.empty() || help_text == "<color=#FFFFFFA0></>")
    {
        text->hide();
        frame->setSize(600.0f, 200.0f);
    }
    else
    {
        text->show();
        frame->setSize(600.0f, 700.0f);
    }

    GuiHelpOverlay::onDraw(target);
}
