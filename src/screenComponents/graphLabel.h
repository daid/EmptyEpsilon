#ifndef GRAPH_LABEL_H
#define GRAPH_LABEL_H

#include "gui/gui2_element.h"


class GuiGraphLabel : public GuiElement
{
private:
    float start;
    float stop;

    float major_tick_size;
    int minor_tick_number;

    bool display_label_text;
    float text_size;

    // this is to allow show bearings easily
    float modulo;

public:
    GuiGraphLabel(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;

    GuiGraphLabel* setStart(float value) { start = value; return this;}
    GuiGraphLabel* setStop(float value) { stop = value; return this;}
    GuiGraphLabel* setMajorTickSize(float value) { major_tick_size = value; return this;}
    GuiGraphLabel* setMinorTickNumber(int value) { minor_tick_number = value; return this;}
    GuiGraphLabel* setModulo(float value) { modulo = value; return this;}
    GuiGraphLabel* setDisplayLabelText(bool value) { display_label_text = value; return this;}
};;

#endif//GRAPH_LABEL_H
