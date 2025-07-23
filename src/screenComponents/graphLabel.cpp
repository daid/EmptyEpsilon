#include "screenComponents/graphLabel.h" 
#include "playerInfo.h"
#include "main.h"

GuiGraphLabel::GuiGraphLabel(GuiContainer* owner, string id)
    : GuiElement(owner, id), text_size(20.0f)
{
}

void GuiGraphLabel::onDraw(sp::RenderTarget& renderer) 
{

    
    int major_ticks_start = ceil(start / major_tick_size);
    int major_ticks_stop = floor(stop / major_tick_size);
    int minor_tick_size = floor(major_tick_size / (minor_tick_number + 1));

    float major_tick_Y_size = 1.0f;
    float minor_tick_Y_size = 0.5f;
    if (display_label_text)
    {
        major_tick_Y_size = 0.5f * major_tick_Y_size;
        minor_tick_Y_size = 0.5f * minor_tick_Y_size;
    }

    // Draw major and minor ticks
    auto major_color = glm::uvec4(255,255,255,255);
    auto minor_color = glm::uvec4(255,255,255,100);
    for(int i = major_ticks_start; i <= major_ticks_stop; i++)
    {
        float major_tick_pos = (i * major_tick_size);
        std::vector<glm::vec2> temp = 
        {
            glm::vec2(rect.position.x +  rect.size.x * (major_tick_pos - start)/(stop-start), rect.position.y),
            glm::vec2(rect.position.x +  rect.size.x * (major_tick_pos - start)/(stop-start), rect.position.y + rect.size.y * major_tick_Y_size),
        };
        renderer.drawLineBlendAdd(temp, major_color);

        if(display_label_text)
        {
            auto text_box_position = glm::vec2(
                rect.position.x +  rect.size.x * (major_tick_pos - major_tick_size / 2 - start)/(stop-start),
                rect.position.y + rect.size.y * major_tick_Y_size
            );
            auto text_box_size = glm::vec2(
                rect.size.x * major_tick_size / (stop-start),
                rect.size.y * (1 - major_tick_Y_size)
            );

            auto text_box = sp::Rect(
                text_box_position,
                text_box_size
            );

            string text;
            if(modulo > 0)
            {
                float temp = fmodf(major_tick_pos, modulo);
                if(temp < 0)
                    temp += modulo;
                text = string(int(temp));
            }
            else
                text = string(int(major_tick_pos));

            renderer.drawText(
                text_box,
                text,
                sp::Alignment::Center,
                text_size,
                main_font,
                major_color
            );
        }
          
        for(int j = 0; j < minor_tick_number; j++)
        {
            float minor_tick_pos = major_tick_pos + (j + 1) * minor_tick_size;
            std::vector<glm::vec2> temp = 
            {
                glm::vec2(rect.position.x +  rect.size.x * (minor_tick_pos - start)/(stop-start), rect.position.y),
                glm::vec2(rect.position.x +  rect.size.x * (minor_tick_pos - start)/(stop-start), rect.position.y + rect.size.y * minor_tick_Y_size),
            };
            renderer.drawLineBlendAdd(temp, minor_color);

        }
    }
}
