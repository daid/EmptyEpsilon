
#ifndef GLOBAL_MESSAGE_ENTRY_VIEW
#define GLOBAL_MESSAGE_ENTRY_VIEW

#include "gui/gui2_overlay.h"

class GuiTextEntry;
class GuiContainer;

class GuiGlobalMessageEntryView : public GuiOverlay
{
private:
    GuiTextEntry* message_entry;
public:
    GuiGlobalMessageEntryView(GuiContainer* owner);

    virtual bool onMouseDown(glm::vec2 position) override;
};

#endif//GLOBAL_MESSAGE_ENTRY_VIEW
