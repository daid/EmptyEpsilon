#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "shipsLogControl.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_advancedscrolltext.h"

ShipsLog::ShipsLog(GuiContainer* owner)
: GuiElement(owner, "")
{
    setPosition(0, 0, ABottomCenter);
    setSize(GuiElement::GuiSizeMax, 50);
    setMargins(20, 0);
    
    open = false;
    
    log_text = new GuiAdvancedScrollText(this, "");
    log_text->enableAutoScrollDown();
    log_text->setMargins(15, 15, 15, 0)->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void ShipsLog::onDraw(sf::RenderTarget& window)
{
    drawStretchedHV(window, sf::FloatRect(rect.left, rect.top, rect.width, rect.height + 100), 25.0f, "gui/PanelBackground");

    if (!my_spaceship)
        return;

    const std::vector<PlayerSpaceship::ShipLogEntry>& logs = my_spaceship->getShipsLog();
    
    if (open)
    {
        const std::vector<PlayerSpaceship::ShipLogEntry>& logs = my_spaceship->getShipsLog();
        if (log_text->getEntryCount() > 0 && logs.size() == 0)
            log_text->clearEntries();

        while(log_text->getEntryCount() > logs.size())
        {
            log_text->removeEntry(0);
        }
        
        if (log_text->getEntryCount() > 0 && logs.size() > 0 && log_text->getEntryText(0) != logs[0].text)
        {
            bool updated = false;
            for(unsigned int n=1; n<log_text->getEntryCount(); n++)
            {
                if (log_text->getEntryText(n) == logs[0].text)
                {
                    for(unsigned int m=0; m<n; m++)
                        log_text->removeEntry(0);
                    updated = true;
                    break;
                }
            }
            if (!updated)
                log_text->clearEntries();
        }
        
        while(log_text->getEntryCount() < logs.size())
        {
            int n = log_text->getEntryCount();
            log_text->addEntry(logs[n].prefix, logs[n].text, logs[n].color);
        }
    }else{
        if (log_text->getEntryCount() > 0 && logs.size() == 0)
            log_text->clearEntries();
        if (log_text->getEntryCount() > 0 && logs.size() > 0)
        {
            if (log_text->getEntryText(0) != logs.back().text)
                log_text->clearEntries();
        }
        if (log_text->getEntryCount() == 0 && logs.size() > 0)
            log_text->addEntry(logs.back().prefix, logs.back().text, logs.back().color);
    }
}

bool ShipsLog::onMouseDown(sf::Vector2f position)
{
    open = !open;
    if (open)
        setSize(getSize().x, 800);
    else
        setSize(getSize().x, 50);
    return true;
}
