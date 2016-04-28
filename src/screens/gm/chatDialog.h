#ifndef GAME_MASTER_CHAT_DIALOG_H
#define GAME_MASTER_CHAT_DIALOG_H

#include "gui/gui2_resizabledialog.h"

class PlayerSpaceship;
class GuiTextEntry;
class GuiScrollText;

class GameMasterChatDialog : public GuiResizableDialog
{
public:
    GameMasterChatDialog(GuiContainer* owner, P<PlayerSpaceship> player);

    virtual void onDraw(sf::RenderTarget& window) override;
private:
    P<PlayerSpaceship> player;

    bool notification;

    GuiTextEntry* text_entry;
    GuiScrollText* chat_text;
    
    void disableComms(string title);
    
    void onClose();
};

#endif//GAME_MASTER_CHAT_DIALOG_H
