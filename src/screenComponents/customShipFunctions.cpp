#include "customShipFunctions.h"
#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "gui/gui2_button.h"
#include "gui/gui2_label.h"

GuiCustomShipFunctions::GuiCustomShipFunctions(GuiContainer* owner, ECrewPosition position, string id)
: GuiAutoLayout(owner, id, GuiAutoLayout::LayoutVerticalTopToBottom), position(position)
{
}

void GuiCustomShipFunctions::onDraw(sf::RenderTarget& window)
{
    if (!my_spaceship)
        return;
    checkEntries();
}

void GuiCustomShipFunctions::checkEntries()
{
    if (my_spaceship->custom_functions.size() != entries.size())
    {
        createEntries();
        return;
    }
    for(unsigned int n=0; n<entries.size(); n++)
    {
        if (entries[n].name != my_spaceship->custom_functions[n].name)
        {
            createEntries();
            return;
        }
        else if (entries[n].element->getText() != my_spaceship->custom_functions[n].caption)
        {
            if (my_spaceship->custom_functions[n].type == PlayerSpaceship::CustomShipFunction::Type::Button)
            {
              ((GuiButton*) entries[n].element)->setText(my_spaceship->custom_functions[n].caption);
            }
            else if (my_spaceship->custom_functions[n].type == PlayerSpaceship::CustomShipFunction::Type::Info)
            {
              ((GuiButton*) entries[n].element)->setText(my_spaceship->custom_functions[n].caption);
            }
        }
    }
}

bool GuiCustomShipFunctions::hasEntries()
{
    checkEntries();
    for(Entry& e : entries)
    {
        if (e.element)
            return true;
    }
    return false;
}

void GuiCustomShipFunctions::createEntries()
{
    for(Entry& e : entries)
    {
        if (e.element)
            e.element->destroy();
    }
    entries.clear();
    for(PlayerSpaceship::CustomShipFunction& csf : my_spaceship->custom_functions)
    {
        entries.emplace_back();
        Entry& e = entries.back();
        e.name = csf.name;
        e.element = nullptr;
        if (csf.crew_position == position)
        {
            if (csf.type == PlayerSpaceship::CustomShipFunction::Type::Button)
            {
                string name = e.name;
                e.element = new GuiButton(this, "", csf.caption, [name]()
                {
                    if (my_spaceship)
                        my_spaceship->commandCustomFunction(name);
                });
                e.element->setSize(GuiElement::GuiSizeMax, 50);
            }
            if (csf.type == PlayerSpaceship::CustomShipFunction::Type::Info)
            {
                string name = e.name;
                e.element = (new GuiLabel(this, "", csf.caption, 25))->addBackground();
                e.element->setSize(GuiElement::GuiSizeMax, 50);
            }
        }
    }
}
