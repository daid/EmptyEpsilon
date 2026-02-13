#include "scrollingBanner.h"
#include "gameGlobalInfo.h"
#include "main.h"

GuiScrollingBanner::GuiScrollingBanner(GuiContainer* owner)
: GuiElement(owner, "")
{
}

void GuiScrollingBanner::onDraw(sp::RenderTarget& renderer)
{
    // Exit if there's no game or banner string.
    if (!gameGlobalInfo || gameGlobalInfo->banner_string == "")
    {
        draw_offset = 0.0f;
        return;
    }

    // Draw the banner background.
    renderer.drawStretched(rect, "gui/widget/LabelBackground.png");

    // Scroll the text left by incrementing the draw_offset.
    draw_offset += update_clock.restart() * scroll_speed_per_second;

    {
        // Prepare scrolling text.
        auto prepared = bold_font->prepare(gameGlobalInfo->banner_string, 32, rect.size.y * 0.67f, {255, 255, 255, 255}, rect.size, sp::Alignment::CenterLeft);
        auto threshold = std::max(prepared.getUsedAreaSize().x, rect.size.x);

        // Start text partially visible on first run.
        if (!has_scrolling_started)
        {
            draw_offset = -threshold * 0.5f;
            has_scrolling_started = true;
        }
        // When the text scrolls off the banner, reset it to a point off the
        // banner's opposite end.
        else if (draw_offset > std::min(prepared.getUsedAreaSize().x, threshold)) draw_offset -= threshold * 2.0f;

        // Position and draw the offset text.
        for (auto& g : prepared.data) g.position.x -= draw_offset;
        renderer.drawText(rect, prepared, sp::Font::FlagClip);
    }
}
