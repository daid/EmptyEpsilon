#ifndef PROBE_SCREEN_H
#define PROBE_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/targetsContainer.h"
#include "gui/gui2_overlay.h"
#include "spaceObjects/scanProbe.h"

class GuiViewport3D;

class ProbeScreen : public GuiCanvas, public Updatable
{
private:
    GuiViewport3D* viewport;
    float angle;
	float rotatetime;
public:
    ProbeScreen();
    
    virtual void update(float delta) override;

};

#endif//PROBE_SCREEN_H
