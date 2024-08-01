#include "customShipFunctions.h"
#include "playerInfo.h"
#include "gui/gui2_button.h"
#include "gui/gui2_label.h"
#include "components/customshipfunction.h"


GuiCustomShipFunctions::GuiCustomShipFunctions(GuiContainer* owner, CrewPosition position, string id)
: GuiElement(owner, id), position(position)
{
    setAttribute("layout", "vertical");
}

void GuiCustomShipFunctions::onUpdate()
{
    if (!my_spaceship)
        return;
    checkEntries();
}

void GuiCustomShipFunctions::checkEntries()
{
    auto csf = my_spaceship.getComponent<CustomShipFunctions>();
    if (!csf) return;

    if (csf->functions.size() != entries.size())
    {
        createEntries();
        return;
    }
    for(unsigned int n=0; n<entries.size(); n++)
    {
        string caption = csf->functions[n].caption;
        if (entries[n].name != csf->functions[n].name)
        {
            createEntries();
            return;
        }
        else if (csf->functions[n].type == CustomShipFunctions::Function::Type::Button)
        {
            GuiButton* button = dynamic_cast<GuiButton*>(entries[n].element);
            if (button && button->getText() != caption)
            {
                button->setText(caption);
            }
        }
        else if (csf->functions[n].type == CustomShipFunctions::Function::Type::Info)
        {
            GuiLabel* label = dynamic_cast<GuiLabel*>(entries[n].element);
            if (label && label->getText() != caption)
            {
                label->setText(caption);
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
    auto csf = my_spaceship.getComponent<CustomShipFunctions>();
    if (!csf) return;
    for(auto& f : csf->functions)
    {
        entries.emplace_back();
        Entry& e = entries.back();
        e.name = f.name;
        e.element = nullptr;
        if (f.crew_positions.has(position))
        {
            if (f.type == CustomShipFunctions::Function::Type::Button)
            {
                string name = e.name;
                e.element = new GuiButton(this, "", f.caption, [name]()
                {
                    if (my_spaceship)
                        my_player_info->commandCustomFunction(name);
                });
                e.element->setSize(GuiElement::GuiSizeMax, 50);
            }
            if (f.type == CustomShipFunctions::Function::Type::Info)
            {
                string name = e.name;
                e.element = (new GuiLabel(this, "", f.caption, 25))->addBackground();
                e.element->setSize(GuiElement::GuiSizeMax, 50);
            }
        }
    }
}
