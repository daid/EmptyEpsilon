#ifndef SPECTATOR_SCREEN_H
#define SPECTATOR_SCREEN_H

#include "engine.h"
#include "gui/gui2_canvas.h"
#include "screenComponents/targetsContainer.h"


class GuiRadarView;
class SpectatorScreen : public GuiCanvas, public Updatable
{
private:
    GuiRadarView* main_radar;

    glm::vec2 drag_start_position{};
    glm::vec2 drag_previous_position{};
public:
    SpectatorScreen();
    virtual ~SpectatorScreen() = default;

    virtual void update(float delta);

    void onMouseDown(glm::vec2 position);
    void onMouseDrag(glm::vec2 position);
    void onMouseUp(glm::vec2 position);

    void onKey(sf::Event::KeyEvent key, int unicode);
};


#endif//SPECTATOR_SCREEN_H
