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
    draw_offset += update_clock.restart() * scroll_speed_per_second;

    if (!gameGlobalInfo || gameGlobalInfo->banner_string == "")
    {
        draw_offset = 0;
        return;
    }
    auto banner = banner_style->get(getState());
    renderer.drawStretchedHV(rect, banner.size, banner.texture);

    {
        auto font = banner.font;
        // Fall back to bold_font if theme font is invalid.
        if (!font) font = bold_font;

        auto prepared = font->prepare(gameGlobalInfo->banner_string, 32, rect.size.y, banner.color, rect.size, sp::Alignment::CenterLeft);
        if (draw_offset > std::max(prepared.getUsedAreaSize().x, rect.size.x) + black_area)
            draw_offset -= std::max(prepared.getUsedAreaSize().x, rect.size.x) + black_area;
        for(auto& g : prepared.data)
        {
            g.position.x -= draw_offset;
        }

        renderer.drawText(rect, prepared, sp::Font::FlagClip);
    }
}
