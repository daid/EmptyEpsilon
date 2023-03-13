#ifndef GUI2_IMAGE_H
#define GUI2_IMAGE_H

#include "gui2_element.h"

class GuiImage : public GuiElement
{
private:
    glm::u8vec4 color{255,255,255,255};
    string texture_name;
    float angle;
public:
    GuiImage(GuiContainer* owner, string id, string texture_name);

    virtual void onDraw(sp::RenderTarget& renderer) override;

    GuiImage* setColor(glm::u8vec4 color) { this->color = color; return this; }
    GuiImage* setAngle(float angle) { this->angle = angle; return this; }
};

#endif//GUI2_IMAGE_H
