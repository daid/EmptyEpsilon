#ifndef CHAT_DIALOG_H
#define CHAT_DIALOG_H

#include "gui/gui2_resizabledialog.h"
#include "ecs/entity.h"

class GuiTextEntry;
class GuiScrollText;
class GuiRadarView;

class GameMasterChatDialog : public GuiResizableDialog
{
public:
    GameMasterChatDialog(GuiContainer* owner, GuiRadarView* radar, sp::ecs::Entity player);

    virtual void onDraw(sp::RenderTarget& target) override;

    sp::ecs::Entity player;
private:
    GuiRadarView* radar;

    bool notification;

    GuiTextEntry* text_entry;
    GuiScrollText* chat_text;

    void disableComms(string title);

    void onClose() override;
};

#endif//CHAT_DIALOG_H
