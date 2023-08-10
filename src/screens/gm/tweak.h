#ifndef SCREEN_GM_TWEAK_H
#define SCREEN_GM_TWEAK_H

#include "gui/gui2_panel.h"
#include "ecs/entity.h"


class GuiButton;
class GuiTweakPage : public GuiElement
{
public:
    GuiTweakPage(GuiContainer* owner);

    void open(sp::ecs::Entity);
    virtual void onDraw(sp::RenderTarget& target) override;

    std::function<bool(sp::ecs::Entity)> has_component;
    std::function<void(sp::ecs::Entity)> add_component;
    std::function<void(sp::ecs::Entity)> remove_component;

    GuiButton* add_remove_button;
    GuiElement* left;
    GuiElement* right;

    sp::ecs::Entity entity;
};

class GuiEntityTweak : public GuiPanel
{
public:
    GuiEntityTweak(GuiContainer* owner);

    void open(sp::ecs::Entity target);

private:
    sp::ecs::Entity entity;
    std::vector<GuiTweakPage*> pages;
};

#endif//SCREEN_GM_TWEAK_H
