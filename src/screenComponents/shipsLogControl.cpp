#include "playerInfo.h"
#include "components/shiplog.h"
#include "shipsLogControl.h"

#include "gui/theme.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_advancedscrolltext.h"

ShipsLog::ShipsLog(GuiContainer* owner)
: GuiElement(owner, "")
{
    // Start closed and at the bottom center.
    setPosition(0.0f, 0.0f, sp::Alignment::BottomCenter);
    setSize(GuiElement::GuiSizeMax, 50.0f);
    setMargins(20.0f, 0.0f);

    open = false;

    log_text = new GuiAdvancedScrollText(this, "");
    log_text
        ->enableAutoScrollDown()
        ->setMode(GuiScrollContainer::ScrollMode::None)
        ->setMargins(SIDE_MARGINS, 0.0f)
        ->setPosition(0.0f, 0.0f)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
}

void ShipsLog::onDraw(sp::RenderTarget& renderer)
{
    renderer.drawStretchedHV(sp::Rect(rect.position.x, rect.position.y, rect.size.x, rect.size.y + 100), 25.0f, theme->getStyle("panel")->get(getState()).texture);

    auto logs = my_spaceship.getComponent<ShipLog>();
    if (!logs) return;

    // If the log is now empty, clear any displayed entries.
    if (log_text->getEntryCount() > 0 && logs->size() == 0)
        log_text->clearEntries();

    // If the log screen is open, display all entries in the log.
    if (open)
    {
        // Add a top margin to log text in order to prevent it from visually
        // overflowing the top of GuiPanel while scrolling.
        log_text->setMargins(SIDE_MARGINS, 5.0f);

        // Clear displayed entries until the list of displayed entries isn't
        // longer than the log.
        while (log_text->getEntryCount() > logs->size())
            log_text->removeEntry(0);

        // If the log is longer than the list of displayed entries, and the last
        // entry isn't the same in both the log and the displayed list, check
        // for updates and flag if so.
        if (log_text->getEntryCount() > 0
            && logs->size() > 0
            && log_text->getEntryText(0) != logs->get(0).text)
        {
            bool updated = false;
            for (unsigned int n = 1; n < log_text->getEntryCount(); n++)
            {
                if (log_text->getEntryText(n) == logs->get(0).text)
                {
                    for (unsigned int m = 0; m < n; m++) log_text->removeEntry(0);
                    updated = true;
                    break;
                }
            }

            // If no updates, clear the displayed list.
            if (!updated) log_text->clearEntries();
        }

        // Display new entries until the list of displayed entries is no longer
        // smaller than the log.
        while (log_text->getEntryCount() < logs->size())
        {
            int n = log_text->getEntryCount();
            log_text->addEntry(logs->get(n).prefix, logs->get(n).text, logs->get(n).color, 0);
        }
    }
    // Otherwise, display only the last entry.
    else
    {
        // Remove top margin from log text while closed to prevent bottom of
        // text from being clipped by the screen edge.
        log_text->setMargins(SIDE_MARGINS, 0.0f);
        // Lock offset to top.
        log_text->scrollToOffset(0.0f);

        // Clear displayed entries unless the last entry hasn't changed.
        if (log_text->getEntryCount() > 0
            && logs->size() > 0
            && log_text->getEntryText(0) != logs->get(logs->size() - 1).text
        )
            log_text->clearEntries();

        // If the log has changed, display the last one.
        if (log_text->getEntryCount() == 0 && logs->size() > 0)
        {
            const auto& back = logs->get(logs->size() - 1);
            log_text->addEntry(back.prefix, back.text, back.color, 0);
        }
    }
}

bool ShipsLog::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    // Toggle the open state on click.
    open = !open;

    // If the log's now open, expand it.
    if (open)
    {
        setSize(getSize().x, 800.0f);
        // Show scrollbar, scroll to bottom.
        log_text->setMode(GuiScrollContainer::ScrollMode::Scroll);
        log_text->scrollToFraction(1.0f);
    }
    // If the log's now closed, contract it to one line.
    else
    {
        // Hide scrollbar.
        setSize(getSize().x, 50.0f);
        log_text->setMode(GuiScrollContainer::ScrollMode::None);
    }

    return true;
}
