#pragma once

#include "gui/gui2_element.h"
#include <i18n.h>
#include <unordered_set>

class GuiCanvas;
class GuiLabel;
class GuiPanel;
class GuiScrollFormattedText;

class GuiHelpOverlay : public GuiElement
{
protected:
    GuiLabel* title;
    GuiScrollFormattedText* text;
    GuiLabel* footer;

    string help_title = "";
    string help_text = "";
    string help_footer = "";
public:
    GuiHelpOverlay(GuiContainer* owner, string help_title = "", string help_text = "", string help_footer = "");
    GuiPanel* frame;

    GuiHelpOverlay* setTitle(string new_title);
    GuiHelpOverlay* setText(string new_text);
    GuiHelpOverlay* setFooter(string new_footer);
    void toggle();

    virtual void onDraw(sp::RenderTarget& target) override;
};

class GuiHotkeyHelpOverlay : public GuiHelpOverlay
{
private:
    std::vector<string> categories;
    void updateText();

    const std::unordered_set<std::string> shield_labels = {
        tr("hotkey_Weapons", "Toggle shields"),
        tr("hotkey_Weapons", "Enable shields"),
        tr("hotkey_Weapons", "Disable shields"),
        tr("hotkey_Weapons", "Decrease shield frequency target"),
        tr("hotkey_Weapons", "Increase shield frequency target"),
        tr("hotkey_Weapons", "Start shield calibration")
    };

public:
    GuiHotkeyHelpOverlay(GuiContainer* owner, std::vector<string> categories, string help_text = "");
    GuiHotkeyHelpOverlay* setCategories(std::vector<string> new_categories);
    GuiHotkeyHelpOverlay* addCategory(string new_category);
    GuiHotkeyHelpOverlay* removeCategory(string removed_category);

    virtual void onDraw(sp::RenderTarget& target) override;
};
