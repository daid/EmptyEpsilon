#ifndef COMMS_OVERLAY_H
#define COMMS_OVERLAY_H

#include "gui/gui2_element.h"

class GuiPanel;
class GuiProgressbar;
class GuiButton;
class GuiToggleButton;
class GuiLabel;
class GuiScrollText;
class GuiListbox;
class GuiTextEntry;

class GuiCommsOverlay : public GuiElement
{
private:
    GuiPanel* opening_box;
    GuiProgressbar* opening_progress;
    GuiButton* opening_cancel;

    GuiPanel* hailed_box;
    GuiLabel* hailed_label;
    GuiButton* hailed_answer;
    GuiButton* hailed_ignore;

    GuiPanel* no_response_box;
    GuiPanel* broken_box;
    GuiPanel* closed_box;

    GuiToggleButton* comms_restore_button;

    GuiPanel* comms_dialog_box;
    GuiLabel* comms_dialog_title_label;
    GuiScrollText* comms_dialog_text;
    GuiTextEntry* chat_comms_message_entry;
    GuiButton* chat_comms_send_button;
    GuiListbox* script_comms_options;

    bool chat_open_last_update = false;
    bool comms_minimized = false;
    bool comms_has_unread = false;
    string last_incoming_message;
public:
    GuiCommsOverlay(GuiContainer* owner);

    virtual void onUpdate() override;
    void clearElements();
};

#endif//COMMS_OVERLAY_H
