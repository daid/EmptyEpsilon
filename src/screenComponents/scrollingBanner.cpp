#include "scrollingBanner.h"
#include "gameGlobalInfo.h"
#include "main.h"
#include "gui/theme.h"

GuiScrollingBanner::GuiScrollingBanner(GuiContainer* owner)
: GuiElement(owner, "")
{
    banner_style = theme->getStyle("scrollingbanner");
}

void GuiScrollingBanner::onDraw(sp::RenderTarget& renderer)
{
    // Exit if there's no game or banner string.
    if (!gameGlobalInfo || gameGlobalInfo->banner_string == "")
    {
        draw_offset = 0.0f;
        return;
    }
    auto banner = banner_style->get(getState());
    renderer.drawStretchedHV(rect, banner.size, banner.texture);

    // Scroll the text left by incrementing the draw_offset.
    draw_offset += update_clock.restart() * scroll_speed_per_second;

    {
        auto font = banner.font;
        // Fall back to bold_font if theme font is invalid.
        if (!font) font = bold_font;

        auto prepared = font->prepare(gameGlobalInfo->banner_string, 32, rect.size.y, banner.color, rect.size, sp::Alignment::CenterLeft);
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
