#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "shipsLogInternControl.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_advancedscrolltext.h"

ShipsLogIntern::ShipsLogIntern(GuiContainer* owner)
: GuiElement(owner, "")
{
    setPosition(0, 0, ABottomCenter);
    setSize(GuiElement::GuiSizeMax, 50);
    setMargins(10, 0);
    
    open = false;
    
    logIntern_text = new GuiAdvancedScrollText(this, "");
    logIntern_text->enableAutoScrollDown();
    logIntern_text->setMargins(15, 15, 15, 0)->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void ShipsLogIntern::onDraw(sf::RenderTarget& window)
{
    drawStretchedHV(window, sf::FloatRect(rect.left, rect.top, rect.width, rect.height + 100), 25.0f, "gui/PanelBackground");

    if (!my_spaceship)
        return;

    const std::vector<PlayerSpaceship::ShipLogInternEntry>& logsIntern = my_spaceship->getShipsLogIntern();
    
    if (open)
    {
        const std::vector<PlayerSpaceship::ShipLogInternEntry>& logsIntern = my_spaceship->getShipsLogIntern();
        if (logIntern_text->getEntryCount() > 0 && logsIntern.size() == 0)
            logIntern_text->clearEntries();

        while(logIntern_text->getEntryCount() > logsIntern.size())
        {
            logIntern_text->removeEntry(0);
        }
        
        if (logIntern_text->getEntryCount() > 0 && logsIntern.size() > 0 && logIntern_text->getEntryText(0) != logsIntern[0].text)
        {
            bool updated = false;
            for(unsigned int n=1; n<logIntern_text->getEntryCount(); n++)
            {
                if (logIntern_text->getEntryText(n) == logsIntern[0].text)
                {
                    for(unsigned int m=0; m<n; m++)
                        logIntern_text->removeEntry(0);
                    updated = true;
                    break;
                }
            }
            if (!updated)
                logIntern_text->clearEntries();
        }
        
        while(logIntern_text->getEntryCount() < logsIntern.size())
        {
            int n = logIntern_text->getEntryCount();
            logIntern_text->addEntry(logsIntern[n].prefix, logsIntern[n].text, logsIntern[n].color);
        }
    }else{
        if (logIntern_text->getEntryCount() > 0 && logsIntern.size() == 0)
            logIntern_text->clearEntries();
        if (logIntern_text->getEntryCount() > 0 && logsIntern.size() > 0)
        {
            if (logIntern_text->getEntryText(0) != logsIntern.back().text)
                logIntern_text->clearEntries();
        }
        if (logIntern_text->getEntryCount() == 0 && logsIntern.size() > 0)
            logIntern_text->addEntry(logsIntern.back().prefix, logsIntern.back().text, logsIntern.back().color);
    }
}

bool ShipsLogIntern::onMouseDown(sf::Vector2f position)
{
    open = !open;
    if (open)
        setSize(getSize().x, 800);
    else
        setSize(getSize().x, 50);
    return true;
}
