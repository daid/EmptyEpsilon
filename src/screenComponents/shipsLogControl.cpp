#include "playerInfo.h"
#include "spaceObjects/playerSpaceship.h"
#include "components/shiplog.h"
#include "shipsLogControl.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_advancedscrolltext.h"

ShipsLog::ShipsLog(GuiContainer* owner)
: GuiElement(owner, "")
{
    setPosition(0, 0, sp::Alignment::BottomCenter);
    setSize(GuiElement::GuiSizeMax, 50);
    setMargins(20, 0);

    open = false;

    log_text = new GuiAdvancedScrollText(this, "");
    log_text->enableAutoScrollDown();
    log_text->setMargins(15, 4, 15, 0)->setPosition(0, 0)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void ShipsLog::onDraw(sp::RenderTarget& renderer)
{
    renderer.drawStretchedHV(sp::Rect(rect.position.x, rect.position.y, rect.size.x, rect.size.y + 100), 25.0f, "gui/widget/PanelBackground.png");

    auto logs = my_spaceship.getComponent<ShipLog>();
    if (!logs)
        return;

    if (open)
    {
        if (log_text->getEntryCount() > 0 && logs->entries.size() == 0)
            log_text->clearEntries();

        while(log_text->getEntryCount() > logs->entries.size())
        {
            log_text->removeEntry(0);
        }

        if (log_text->getEntryCount() > 0 && logs->entries.size() > 0 && log_text->getEntryText(0) != logs->entries[0].text)
        {
            bool updated = false;
            for(unsigned int n=1; n<log_text->getEntryCount(); n++)
            {
                if (log_text->getEntryText(n) == logs->entries[0].text)
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

        while(log_text->getEntryCount() < logs->entries.size())
        {
            int n = log_text->getEntryCount();
            log_text->addEntry(logs->entries[n].prefix, logs->entries[n].text, logs->entries[n].color);
        }
    }else{
        if (log_text->getEntryCount() > 0 && logs->entries.size() == 0)
            log_text->clearEntries();
        if (log_text->getEntryCount() > 0 && logs->entries.size() > 0)
        {
            if (log_text->getEntryText(0) != logs->entries.back().text)
                log_text->clearEntries();
        }
        if (log_text->getEntryCount() == 0 && logs->entries.size() > 0)
            log_text->addEntry(logs->entries.back().prefix, logs->entries.back().text, logs->entries.back().color);
    }
}

bool ShipsLog::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    open = !open;
    if (open)
        setSize(getSize().x, 800);
    else
        setSize(getSize().x, 50);
    return true;
}
