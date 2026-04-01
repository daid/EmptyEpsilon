#include "hotkeyBinder.h"
#include <i18n.h>
#include "theme.h"

#include "gui/gui2_button.h"
#include "gui/gui2_label.h"
#include "gui/gui2_overlay.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_togglebutton.h"

// Returns true for axis input types that support inversion.
static bool isAxisType(sp::io::Keybinding::Type type)
{
    return bool(type & (sp::io::Keybinding::Type::JoystickAxis
                      | sp::io::Keybinding::Type::ControllerAxis
                      | sp::io::Keybinding::Type::MouseMovement
                      | sp::io::Keybinding::Type::MouseWheel));
}

// Track which binder and which key are actively performing a rebind.
static GuiHotkeyBinder* active_rebinder = nullptr;
static sp::io::Keybinding* active_key = nullptr;


GuiHotkeyBinder::GuiHotkeyBinder(GuiContainer* owner, string id, sp::io::Keybinding* key,
    sp::io::Keybinding::Type display_filter, sp::io::Keybinding::Type capture_filter)
: GuiElement(owner, id), key(key), display_filter(display_filter), capture_filter(capture_filter)
{
    front_style = theme->getStyle("textentry.front");
    back_style = theme->getStyle("textentry.back");
    setAttribute("layout", "vertical");

    auto* row1 = new GuiElement(this, "");
    row1
        ->setSize(GuiElement::GuiSizeMax, 50.0f);

    auto* row2 = new GuiElement(this, "");
    row2
        ->setSize(GuiElement::GuiSizeMax, SELECTOR_HEIGHT)
        ->setAttribute("layout", "horizontal");
    interaction_row = row2;

    // Collect supported interactions in display order.
    auto supported_interactions = key->getSupportedInteractions();
    if (supported_interactions & sp::io::Keybinding::Interaction::Discrete)
        interaction_selector_options.push_back(sp::io::Keybinding::Interaction::Discrete);
    if (supported_interactions & sp::io::Keybinding::Interaction::Continuous)
        interaction_selector_options.push_back(sp::io::Keybinding::Interaction::Continuous);
    if (supported_interactions & sp::io::Keybinding::Interaction::Repeating)
        interaction_selector_options.push_back(sp::io::Keybinding::Interaction::Repeating);
    if (supported_interactions & sp::io::Keybinding::Interaction::Axis0)
        interaction_selector_options.push_back(sp::io::Keybinding::Interaction::Axis0);
    if (supported_interactions & sp::io::Keybinding::Interaction::Axis1)
        interaction_selector_options.push_back(sp::io::Keybinding::Interaction::Axis1);

    // Pre-select the first supported interaction.
    if (!interaction_selector_options.empty())
        selected_interaction = interaction_selector_options[0];

    (new GuiButton(row2, "ADD_BIND", "+",
        [this]()
        {
            rebind_dialog->startRebind(this->key, this->capture_filter, this->display_filter, this->key->getLabel());
            return;

            // Delay startUserRebind until onMouseUp so that the triggering
            // mouse click is not immediately captured as the new binding.
            if (this->capture_filter & sp::io::Keybinding::Type::Mouse)
                pending_rebind = true;
            else
            {
                active_rebinder = this;
                active_key = this->key;
                sp::io::Keybinding::setUserRebindCancelKey(&keys.cancel_rebind);
                this->key->startUserRebind(this->capture_filter, selected_interaction);
            }
        }
    ))
        ->setSize(SELECTOR_HEIGHT, GuiElement::GuiSizeMax);

    (new GuiButton(row2, "REMOVE_BIND", "-",
        [this]()
        {
            int count = 0;
            while (this->key->getKeyType(count) != sp::io::Keybinding::Type::None) count++;
            for (int i = count - 1; i >= 0; --i)
            {
                if (this->key->getKeyType(i) & this->display_filter)
                {
                    this->key->removeKey(i);
                    break;
                }
            }
        }
    ))
        ->setSize(SELECTOR_HEIGHT, GuiElement::GuiSizeMax);

    invert_btn = new GuiToggleButton(row2, "INVERT_BIND", tr("button", "Invert"),
        [this](bool active)
        {
            // Toggle the inverted flag on the last matching axis binding.
            int count = 0;
            while (this->key->getKeyType(count) != sp::io::Keybinding::Type::None) count++;
            for (int i = count - 1; i >= 0; --i)
            {
                auto type = this->key->getKeyType(i);
                if ((type & this->display_filter) && isAxisType(type))
                {
                    this->key->setKeyInverted(i, active);
                    break;
                }
            }
        }
    );
    invert_btn
        ->setSize(SELECTOR_HEIGHT * 2, GuiElement::GuiSizeMax)
        ->disable();
}

GuiHotkeyBinder::~GuiHotkeyBinder()
{
    if (active_rebinder == this)
    {
        sp::io::Keybinding::cancelUserRebind();
        active_rebinder = nullptr;
        active_key = nullptr;
    }
}

bool GuiHotkeyBinder::isAnyRebinding()
{
    return active_rebinder != nullptr || GuiRebindDialog::isAnyActive();
}

void GuiHotkeyBinder::setDialog(GuiRebindDialog* dialog)
{
    rebind_dialog = dialog;
}

void GuiHotkeyBinder::clearFilteredKeys()
{
    // Filter binds for this control by their type.
    int count = 0;
    while (key->getKeyType(count) != sp::io::Keybinding::Type::None) count++;
    for (int i = count - 1; i >= 0; --i)
        if (key->getKeyType(i) & display_filter) key->removeKey(i);
}

bool GuiHotkeyBinder::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    // Allow clicks to add/remove buttons to pass through.
    if (interaction_row->isVisible() && position.y >= rect.position.y + 50.0f)
        return false;

    // If this binder is already rebinding, just take the input and skip this.
    // This should allow binding left/middle/right-click without also changing
    // the binder's state at the same time.
    if (active_rebinder == this) return true;

    // In dialog mode, left/middle click opens the dialog instead of rebinding.
    // Right click still removes the last matching bind directly.
    if (button == sp::io::Pointer::Button::Right)
    {
        int count = 0;
        while (key->getKeyType(count) != sp::io::Keybinding::Type::None) count++;
        for (int i = count - 1; i >= 0; --i)
        {
            if (key->getKeyType(i) & display_filter)
            {
                key->removeKey(i);
                break;
            }
        }
    }
    else if (button == sp::io::Pointer::Button::Left || button == sp::io::Pointer::Button::Middle)
        rebind_dialog->startRebind(key, capture_filter, display_filter, key->getLabel());

    return true;

    // Left click: Assign input. Middle click: Add input.
    // Right click: Remove last input. Ignore all other mouse buttons.
    if (button == sp::io::Pointer::Button::Left)
        clearFilteredKeys();
    if (button == sp::io::Pointer::Button::Right)
    {
        int count = 0;
        while (key->getKeyType(count) != sp::io::Keybinding::Type::None) count++;
        for (int i = count - 1; i >= 0; --i)
        {
            if (key->getKeyType(i) & display_filter)
            {
                key->removeKey(i);
                break;
            }
        }
    }

    if (button == sp::io::Pointer::Button::Left || button == sp::io::Pointer::Button::Middle)
    {
        // Delay startUserRebind until onMouseUp so that the triggering
        // mouse click is not immediately captured as the new binding.
        if (capture_filter & sp::io::Keybinding::Type::Mouse)
            pending_rebind = true;
        else
        {
            active_rebinder = this;
            active_key = key;
            sp::io::Keybinding::setUserRebindCancelKey(&keys.cancel_rebind);
            key->startUserRebind(capture_filter, selected_interaction);
        }
    }

    return true;
}

void GuiHotkeyBinder::onMouseUp(glm::vec2 position, sp::io::Pointer::ID id)
{
    // Complete a pending rebind action.
    if (pending_rebind)
    {
        pending_rebind = false;
        active_rebinder = this;
        active_key = key;
        sp::io::Keybinding::setUserRebindCancelKey(&keys.cancel_rebind);
        key->startUserRebind(capture_filter, selected_interaction);
    }
}

void GuiHotkeyBinder::onDraw(sp::RenderTarget& renderer)
{
    // Sync the invert toggle state from the last matching axis binding each frame.
    if (invert_btn)
    {
        int last_axis_idx = -1;
        int count = 0;
        while (key->getKeyType(count) != sp::io::Keybinding::Type::None) count++;
        for (int i = count - 1; i >= 0; --i)
        {
            auto type = key->getKeyType(i);
            if ((type & display_filter) && isAxisType(type))
            {
                last_axis_idx = i;
                break;
            }
        }
        if (last_axis_idx >= 0)
        {
            invert_btn->show()->enable();
            invert_btn->setValue(key->getKeyInverted(last_axis_idx));
        }
        else
        {
            invert_btn->setValue(false);
            invert_btn->hide()-disable();
        }
    }

    // Clear the active rebind indicator only when the tracked key's rebind
    // completes and there is no pending preview capture for it.
    if (active_key != nullptr
        && !active_key->isUserRebinding()
        && !active_key->hasPendingRebind())
    {
        active_rebinder = nullptr;
        active_key = nullptr;
    }

    bool is_my_rebind = (active_rebinder == this);
    focus = is_my_rebind;

    const auto& back = back_style->get(getState());
    const auto& front = front_style->get(getState());

    // When the selector is below, restrict rendering to the binding field portion only.
    const float text_height = interaction_row->isVisible()
        ? rect.size.y - SELECTOR_HEIGHT
        : rect.size.y;
    renderer.drawStretched(sp::Rect(rect.position.x, rect.position.y, rect.size.x, text_height), back.texture, back.color);

    if (is_my_rebind)
    {
        renderer.drawText(sp::Rect(rect.position.x + 16.0f, rect.position.y, rect.size.x, text_height), tr("[New input]"), sp::Alignment::CenterLeft, front.size, front.font, front.color);
    }
    else
    {
        // Collect bindings that match the display filter.
        struct BindingInfo { string name; sp::io::Keybinding::Interaction interaction; };
        std::vector<BindingInfo> bindings;
        for (int n = 0; key->getKeyType(n) != sp::io::Keybinding::Type::None; n++)
        {
            if (key->getKeyType(n) & display_filter)
                bindings.push_back({key->getHumanReadableKeyName(n), key->getInteraction(n)});
        }

        const float icon_size = text_height * 0.7f;
        const float icon_y = rect.position.y + text_height * 0.5f;
        sp::Font* font = front.font ? front.font : sp::RenderTarget::getDefaultFont();
        float x = rect.position.x + 16.0f;

        for (size_t i = 0; i < bindings.size(); i++)
        {
            // Separator between bindings
            if (i > 0)
            {
                auto sep = font->prepare(", ", 32, front.size, front.color, {1600.0f, text_height}, sp::Alignment::CenterLeft, 0);
                float sep_w = sep.getUsedAreaSize().x;
                renderer.drawText({x, rect.position.y, sep_w, text_height}, sep);
                x += sep_w;
            }

            // Key name
            auto& b = bindings[i];
            auto prepared = font->prepare(b.name, 32, front.size, front.color, {1600.0f, text_height}, sp::Alignment::CenterLeft, 0);
            float text_w = prepared.getUsedAreaSize().x;
            renderer.drawText({x, rect.position.y, text_w, text_height}, prepared);
            x += text_w;

            // Show interaction icon only when multiple interactions are
            // supported.
            if (interaction_selector_options.size() > 1)
            {
                string icon = interactionIcon(b.interaction);
                if (!icon.empty())
                {
                    renderer.drawRotatedSprite(icon, glm::vec2(x + icon_size * 0.5f, icon_y), icon_size, 0.0f, front.color);
                    x += icon_size;
                }
            }
        }
    }
}

// Pop-up dialog panel for advanced rebinding
GuiRebindDialog* GuiRebindDialog::active_dialog = nullptr;

GuiRebindDialog::GuiRebindDialog(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    overlay = new GuiOverlay(this, id + "_OVERLAY", glm::u8vec4{0, 0, 0, 100});
    overlay
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    panel = new GuiPanel(this, id + "_PANEL");
    panel
        ->setPosition(0.0f, 0.0f, sp::Alignment::Center)
        ->setSize(1000.0f, 700.0f)
        ->setAttribute("padding", "10");

    auto* content = new GuiElement(panel, id + "_CONTENT");
    content
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setMargins(15.0f)
        ->setAttribute("layout", "vertical");

    action_label = new GuiLabel(content, id + "_ACTION", tr("hotkey_menu", "Rebinding: "), 30.0f);
    action_label
        ->setAlignment(sp::Alignment::Center)
        ->setSize(GuiElement::GuiSizeMax, 40.0f)
        ->setMargins(0.0f, 5.0f);

    input_label = new GuiLabel(content, id + "_INPUT", tr("hotkey_menu", "[Press any key or input...]"), 30.0f);
    input_label
        ->addBackground()
        ->setAlignment(sp::Alignment::Center)
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setMargins(0.0f, 5.0f);

    mouse_panel_btn = new GuiButton(content, id + "_MOUSE_PANEL",
        tr("hotkey_menu", "Click here, then move or click mouse to bind"),
        [this]()
        {
            // Button callback fires on mouse-up, so the triggering click is
            // already consumed. The next click is captured as the new binding.
            startCapture();
        }
    );
    mouse_panel_btn
        ->setSize(GuiElement::GuiSizeMax, 55.0f)
        ->setMargins(0.0f, 5.0f)
        ->hide();

    interaction_row = new GuiElement(content, id + "_INTER_ROW");
    interaction_row
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setMargins(0.0f, 5.0f)
        ->setAttribute("layout", "horizontal");

    (new GuiLabel(interaction_row, id + "_INTER_LABEL", tr("hotkey_menu", "Interaction type:"), 30.0f))
        ->setAlignment(sp::Alignment::CenterRight)
        ->setSize(400.0f, GuiElement::GuiSizeMax);

    interaction_selector = new GuiSelector(interaction_row, id + "_INTERACTION_SELECTOR",
        [this](int index, string /*value*/)
        {
            if (index < 0 || index >= static_cast<int>(interaction_options.size()))
                return;
            selected_interaction = interaction_options[index];
            if (state == State::HasInput && target_key)
                target_key->setPendingRebindInteraction(selected_interaction);
        }
    );
    interaction_selector
        ->setTextSize(30.0f)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    legend_text = new GuiScrollText(content, id + "_LEGEND",
        tr("hotkey_menu",
            "Discrete: Acts only once when pressed. (Buttons, encoders, switches)\n\n"
            "Continuous: Acts every frame for as long as it's held down. (Steering using buttons, smooth sliders)\n\n"
            "Repeating: Acts once, waits, then acts repeatedly. (Keyboard repeating, sliders with stepped values)\n\n"
            "Axis one-way: Control rests at a minimum value and is fully engaged at its maximum. (Triggers, throttles)\n\n"
            "Axis two-way: Control is centered at rest and can be pushed in two directions from there. (Joysticks)"
        )
    );
    legend_text
        ->setTextSize(25.0f)
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setMargins(0.0f, 5.0f);

    auto* btn_row = new GuiElement(content, id + "_BTN_ROW");
    btn_row
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setMargins(0.0f, 5.0f)
        ->setAttribute("layout", "horizontal");

    replace_btn = new GuiButton(btn_row, id + "_REPLACE",
        tr("button", "Set/replace"), [this]() { commitReplace(); });
    replace_btn
        ->setSize(150.0f, GuiElement::GuiSizeMax)
        ->setMargins(0.0f, 0.0f, 5.0f, 0.0f)
        ->disable();

    add_btn = new GuiButton(btn_row, id + "_ADD",
        tr("button", "Add"), [this]() { commitAdd(); });
    add_btn
        ->setSize(150.0f, GuiElement::GuiSizeMax)
        ->setMargins(0.0f, 0.0f, 5.0f, 0.0f)
        ->disable();

    invert_btn = new GuiToggleButton(btn_row, id + "_INVERT",
        tr("button", "Invert"),
        [this](bool active)
        {
            if (!target_key || !target_key->hasPendingRebind()) return;
            target_key->setPendingRebindInverted(active);
        }
    );
    invert_btn
        ->setSize(150.0f, GuiElement::GuiSizeMax)
        ->setMargins(0.0f, 0.0f, 5.0f, 0.0f)
        ->disable();

    (new GuiElement(btn_row, id + "_BTN_SPACER"))
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    back_btn = new GuiButton(btn_row, id + "_BACK",
        tr("button", "Back"),
        [this]()
        {
            if (state == State::HasInput)
            {
                // Discard the pending capture and return to WaitingForInput.
                if (target_key) target_key->discardPendingRebind();

                state = State::WaitingForInput;
                input_label->setText(tr("hotkey_menu", "[Press any key or input...]"));
                replace_btn->disable();
                add_btn->disable();
                invert_btn->setValue(false);
                invert_btn->disable();

                // Restart capture for non-mouse filters.
                if (!(capture_filter & sp::io::Keybinding::Type::Mouse))
                    startCapture();
                else
                {
                    mouse_panel_btn
                        ->setText(tr("hotkey_menu", "Click here, then move or click mouse to bind"))
                        ->enable();
                    input_label->setText("");
                }
            }
            else
            {
                // Cancel any active capture and close.
                sp::io::Keybinding::cancelUserRebind();
                closeDialog();
            }
        }
    );
    back_btn
        ->setSize(150.0f, GuiElement::GuiSizeMax);

    setVisible(false);
}

void GuiRebindDialog::startRebind(sp::io::Keybinding* key,
    sp::io::Keybinding::Type cf,
    sp::io::Keybinding::Type df,
    const string& action_name)
{
    target_key = key;
    capture_filter = cf;
    display_filter = df;
    state = State::WaitingForInput;

    string input_type_label;
    if (cf & sp::io::Keybinding::Type::Keyboard)
        input_type_label = tr("hotkey_menu", "Keyboard");
    else if (cf & (sp::io::Keybinding::Type::Joystick | sp::io::Keybinding::Type::Controller))
        input_type_label = tr("hotkey_menu", "Joystick");
    else if (cf & sp::io::Keybinding::Type::Mouse)
        input_type_label = tr("hotkey_menu", "Mouse");
    else
        input_type_label = tr("hotkey_menu", "Rebinding");
    action_label->setText(input_type_label + ": " + action_name);
    replace_btn->disable();
    add_btn->disable();

    populateInteractionSelector();

    bool has_mouse = static_cast<bool>(capture_filter & sp::io::Keybinding::Type::Mouse);

    mouse_panel_btn->setVisible(has_mouse);
    if (has_mouse)
    {
        mouse_panel_btn
            ->setText(tr("hotkey_menu", "Click here, then move or click mouse to bind"))
            ->enable();
        input_label->setText("");
    }
    else
    {
        mouse_panel_btn->disable();
        input_label->setText(tr("hotkey_menu", "[Press any key or input...]"));
    }

    active_dialog = this;
    setVisible(true);

    // For non-mouse filters, start listening immediately.
    if (!has_mouse) startCapture();
}

void GuiRebindDialog::closeIfOpen()
{
    if (active_dialog == this)
    {
        sp::io::Keybinding::cancelUserRebind();
        closeDialog();
    }
}

bool GuiRebindDialog::isAnyActive()
{
    return active_dialog != nullptr;
}

void GuiRebindDialog::startCapture()
{
    if (!target_key) return;
    target_key->startUserRebindPreview(capture_filter, selected_interaction);
    // Disable the button so releasing any mouse button on it doesn't fire
    // onMouseUp and re-call this function.
    mouse_panel_btn->disable();
}

void GuiRebindDialog::populateInteractionSelector()
{
    interaction_options.clear();
    interaction_selector->clear();

    if (!target_key) return;

    auto supported = target_key->getSupportedInteractions();

    // Associate interaction names with types
    struct {
        sp::io::Keybinding::Interaction inter;
        const char* name;
    } opts[] = {
        {sp::io::Keybinding::Interaction::Discrete, "Discrete"},
        {sp::io::Keybinding::Interaction::Continuous, "Continuous"},
        {sp::io::Keybinding::Interaction::Repeating, "Repeating"},
        {sp::io::Keybinding::Interaction::Axis0, "Axis one-way"},
        {sp::io::Keybinding::Interaction::Axis1, "Axis two-way"},
    };

    for (auto& o : opts)
    {
        if (supported & o.inter)
        {
            interaction_options.push_back(o.inter);
            interaction_selector->setEntryIcon(interaction_selector->addEntry(tr("interaction", o.name), ""), interactionIcon(o.inter));
        }
    }

    if (!interaction_options.empty())
    {
        interaction_selector->setSelectionIndex(0);
        selected_interaction = interaction_options[0];
    }
    else selected_interaction = sp::io::Keybinding::Interaction::None;

    const bool has_interactions = interaction_options.size() > 1;
    interaction_row->setVisible(has_interactions);
    legend_text->setVisible(has_interactions);
    if (has_interactions)
        panel->setSize(1000.0f, 600.0f);
    else
        panel->setSize(700.0f, 220.0f);
}

bool GuiRebindDialog::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    // Block clicks from reaching elements behind the dialog.
    // Children handle their own events through the normal GuiElement dispatch.
    return true;
}

void GuiRebindDialog::onDraw(sp::RenderTarget& renderer)
{
    // Detect transition from WaitingForInput to HasInput when a key is captured.
    if (target_key && target_key->hasPendingRebind() && state == State::WaitingForInput)
    {
        state = State::HasInput;
        input_label->setText(target_key->getPendingRebindKeyName());
        replace_btn->enable();
        add_btn->enable();
        invert_btn->setValue(target_key->getPendingRebindInverted());
        if (isAxisType(target_key->getPendingRebindKeyType()))
            invert_btn->enable();
        else
            invert_btn->disable();
    }
}

void GuiRebindDialog::closeDialog()
{
    target_key = nullptr;
    active_dialog = nullptr;
    setVisible(false);
}

void GuiRebindDialog::commitReplace()
{
    if (!target_key || !target_key->hasPendingRebind()) return;

    target_key->setPendingRebindInteraction(selected_interaction);

    // Remove all existing bindings that match display_filter.
    int count = 0;
    while (target_key->getKeyType(count) != sp::io::Keybinding::Type::None)
        count++;

    for (int i = count - 1; i >= 0; --i)
    {
        if (target_key->getKeyType(i) & display_filter)
            target_key->removeKey(i);
    }

    target_key->commitPendingRebind();
    closeDialog();
}

void GuiRebindDialog::commitAdd()
{
    if (!target_key || !target_key->hasPendingRebind()) return;
    target_key->setPendingRebindInteraction(selected_interaction);
    target_key->commitPendingRebind();
    closeDialog();
}
