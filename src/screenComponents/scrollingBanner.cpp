#include "scrollingBanner.h"
#include "gameGlobalInfo.h"
#include "main.h"

GuiScrollingBanner::GuiScrollingBanner(GuiContainer* owner)
: GuiElement(owner, "")
{
    draw_offset = 0;
}

void GuiScrollingBanner::onDraw(sp::RenderTarget& renderer)
{
    draw_offset += update_clock.restart() * scroll_speed_per_second;

    if (!gameGlobalInfo || gameGlobalInfo->banner_string == "")
    {
        draw_offset = 0;
        return;
    }
    renderer.drawStretchedHV(rect, 25.0f, "gui/widget/PanelBackground.png");

    {
        float font_size = rect.size.y;
        auto prepared = bold_font->prepare(gameGlobalInfo->banner_string, 32, font_size, rect.size, sp::Alignment::CenterLeft);
        if (draw_offset > std::max(prepared.getUsedAreaSize().x, rect.size.x) + black_area)
            draw_offset -= std::max(prepared.getUsedAreaSize().x, rect.size.x) + black_area;
        for(auto& g : prepared.data)
        {
            g.position.x -= draw_offset;
        }

        renderer.drawText(rect, prepared, font_size, {255, 255, 255, 255}, sp::Font::FlagClip);
    }
}
