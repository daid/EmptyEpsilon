#ifndef FACTIONS_H
#define FACTIONS_H

#include "gui/gui2_overlay.h"

class GuiLabel;
class GuiPanel;
class GuiTextEntry;
class GuiSelector;
class GuiButton;

class GuiFactions : public GuiOverlay
{
  private:
    unsigned int faction_a;
    unsigned int faction_b;
    std::vector<GuiLabel *> h_labels;
    std::vector<GuiLabel *> v_labels;
    std::vector<GuiButton *> buttons;

    GuiElement *editPanel;
    GuiLabel *faction_a_edit_label;
    GuiLabel *faction_b_edit_label;
    GuiSelector *edit_selector;

  public:
    GuiFactions(GuiContainer *owner);

    virtual void onDraw(sf::RenderTarget &window) override;
    void onClose();
    void deSelectFactions();
    void onSelectFactions(unsigned int i, unsigned int j);
};

#endif //FACTIONS_H
