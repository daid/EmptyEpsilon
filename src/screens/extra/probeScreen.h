#ifndef PROBE_SCREEN_H
#define PROBE_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"

class GuiViewport3D;

class WindowScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    float angle;
	float rotatetime;
public:
    WindowScreen();
    
    virtual void update(float delta) override;

};

#endif//PROBE_SCREEN_H
