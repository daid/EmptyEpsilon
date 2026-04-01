#pragma once

#include "gui2_element.h"
#include "io/keybinding.h"
#include <vector>

class GuiButton;
class GuiLabel;
class GuiToggleButton;
class GuiOverlay;
class GuiPanel;
class GuiScrollText;
class GuiSelector;
class GuiThemeStyle;

// Returns the icon resource path for a keybinding interaction type.
inline string interactionIcon(sp::io::Keybinding::Interaction inter)
{
    switch (inter)
    {
    case sp::io::Keybinding::Interaction::Continuous: return "gui/icons/key_sustained";
    case sp::io::Keybinding::Interaction::Discrete:   return "gui/icons/key_stepped";
    case sp::io::Keybinding::Interaction::Repeating:  return "";
    case sp::io::Keybinding::Interaction::Axis0:      return "gui/icons/axis_0";
    case sp::io::Keybinding::Interaction::Axis1:      return "gui/icons/axis_1";
    default: return "";
    }
}

// Modal overlay dialog used by HotkeyMenu to confirm a rebind before committing
// it. Created once by HotkeyMenu and shared across all GuiHotkeyBinder rows.
class GuiRebindDialog : public GuiElement
{
public:
    GuiRebindDialog(GuiContainer* owner, string id);

    void startRebind(sp::io::Keybinding* key,
        sp::io::Keybinding::Type capture_filter,
        sp::io::Keybinding::Type display_filter,
        const string& action_name);

    // Close the dialog if it is currently open, cancelling any in-progress capture.
    void closeIfOpen();

    static bool isAnyActive();

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onDraw(sp::RenderTarget& renderer) override;

private:
    enum class State { WaitingForInput, HasInput };

    static GuiRebindDialog* active_dialog;

    sp::io::Keybinding* target_key = nullptr;
    sp::io::Keybinding::Type capture_filter = sp::io::Keybinding::Type::None;
    sp::io::Keybinding::Type display_filter = sp::io::Keybinding::Type::None;
    sp::io::Keybinding::Interaction selected_interaction = sp::io::Keybinding::Interaction::None;
    State state = State::WaitingForInput;

    std::vector<sp::io::Keybinding::Interaction> interaction_options;

    GuiOverlay* overlay;
    GuiPanel* panel;
    GuiLabel* action_label;
    GuiLabel* input_label;
    GuiButton* mouse_panel_btn;
    GuiElement* interaction_row;
    GuiSelector* interaction_selector;
    GuiScrollText* legend_text;
    GuiButton* replace_btn;
    GuiButton* add_btn;
    GuiToggleButton* invert_btn;
    GuiButton* back_btn;

    void closeDialog();
    void startCapture();
    void populateInteractionSelector();
    void commitReplace();
    void commitAdd();
};

class GuiHotkeyBinder : public GuiElement
{
private:
    sp::io::Keybinding* key;
    sp::io::Keybinding::Type display_filter;
    sp::io::Keybinding::Type capture_filter;
    bool pending_rebind = false;
    sp::io::Keybinding::Interaction selected_interaction = sp::io::Keybinding::Interaction::None;
    GuiRebindDialog* rebind_dialog = nullptr;

    GuiElement* interaction_row = nullptr;
    GuiToggleButton* invert_btn = nullptr;
    std::vector<sp::io::Keybinding::Interaction> interaction_selector_options;

    const GuiThemeStyle* front_style;
    const GuiThemeStyle* back_style;

    void clearFilteredKeys();
public:
    GuiHotkeyBinder(GuiContainer* owner, string id, sp::io::Keybinding* key, sp::io::Keybinding::Type display_filter = sp::io::Keybinding::Type::Default, sp::io::Keybinding::Type capture_filter = sp::io::Keybinding::Type::Default);
    virtual ~GuiHotkeyBinder();

    // Returns true if any binder is actively rebinding. Used to prevent
    // game-wide binds like escape from being handled while binding a key.
    // The escape control can't be rebound otherwise.
    // Height of the interaction selector row appended below the binding field.
    // The parent container must add this to the row height when the keybinding
    // has more than one supported interaction.
    static constexpr float SELECTOR_HEIGHT = 50.0f;

    static bool isAnyRebinding();

    // Set a rebind dialog to use for this binder. When set, clicking the
    // binder opens the dialog instead of starting a direct rebind. The
    // interaction selector row is hidden in dialog mode. Pass nullptr to
    // revert to direct mode.
    void setDialog(GuiRebindDialog* dialog);

    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onDraw(sp::RenderTarget& renderer) override;
};
