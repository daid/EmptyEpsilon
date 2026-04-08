#include "playerInfo.h"
#include "i18n.h"
#include "commsOverlay.h"
#include "gui/gui2_canvas.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_button.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_label.h"
#include "gui/gui2_scrolltext.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_textentry.h"
#include "components/comms.h"
#include "systems/comms.h"
#include "engine.h"

#include "onScreenKeyboard.h"

GuiCommsOverlay::GuiCommsOverlay(GuiContainer* owner)
: GuiElement(owner, "COMMS_OVERLAY")
{
    // Panel for reporting outgoing hails.
    opening_box = new GuiPanel(this, "COMMS_OPENING_BOX");
    opening_box
        ->setSize(800.0f, 100.0f)
        ->setPosition(0.0f, -250.0f, sp::Alignment::BottomCenter)
        ->hide();

    (new GuiLabel(opening_box, "COMMS_OPENING_LABEL", tr("Opening communications..."), 40.0f))
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopCenter);

    opening_progress = new GuiProgressbar(opening_box, "COMMS_OPENING_PROGRESS", CommsSystem::channel_open_time, 0.0f, 0.0f);
    opening_progress
        ->setSize(500.0f, 40.0f)
        ->setPosition(50.0f, -10.0f, sp::Alignment::BottomLeft);

    // Cancel button closes the communication.
    opening_cancel = new GuiButton(opening_box, "COMMS_OPENING_CANCEL", tr("button", "Cancel"),
        []()
        {
            if (my_spaceship) my_player_info->commandCloseTextComm();
        }
    );
    opening_cancel
        ->setSize(200.0f, 40.0f)
        ->setPosition(-50.0f, -10.0f, sp::Alignment::BottomRight);

    (new GuiButton(opening_box, "COMMS_OPENING_MINIMIZE", "",
        [this]()
        {
            comms_minimized = true;
        }
    ))->setIcon("gui/widget/IndicatorArrow.png", sp::Alignment::Center, -90.0f)
        ->setPosition(-5.0f, 5.0f, sp::Alignment::TopRight)
        ->setSize(50.0f, 50.0f);

    // Panel for reporting incoming hails.
    hailed_box = new GuiPanel(this, "COMMS_BEING_HAILED_BOX");
    hailed_box
        ->setSize(800.0f, 140.0f)
        ->setPosition(0.0f, -250.0f, sp::Alignment::BottomCenter)
        ->hide();
    hailed_label = new GuiLabel(hailed_box, "COMMS_BEING_HAILED_LABEL", "..", 40);
    hailed_label
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setPosition(0.0f, 20.0f, sp::Alignment::TopCenter);

    // Buttons to answer or ignore hails.
    hailed_answer = new GuiButton(hailed_box, "COMMS_BEING_HAILED_ANSWER", tr("Answer"),
        []()
        {
            if (my_spaceship) my_player_info->commandAnswerCommHail(true);
        }
    );
    hailed_answer
        ->setSize(300.0f, 50.0f)
        ->setPosition(20.0f, -20.0f, sp::Alignment::BottomLeft);

    hailed_ignore = new GuiButton(hailed_box, "COMMS_BEING_HAILED_IGNORE", tr("Ignore"),
        []()
        {
            if (my_spaceship) my_player_info->commandAnswerCommHail(false);
        }
    );
    hailed_ignore
        ->setSize(300.0f, 50.0f)
        ->setPosition(-20.0f, -20.0f, sp::Alignment::BottomRight);

    (new GuiButton(hailed_box, "COMMS_HAILED_MINIMIZE", "",
        [this]()
        {
            comms_minimized = true;
        }
    ))->setIcon("gui/widget/IndicatorArrow.png", sp::Alignment::Center, -90.0f)
        ->setPosition(-5.0f, 5.0f, sp::Alignment::TopRight)
        ->setSize(50.0f, 50.0f);

    // Panel for unresponsive hails.
    no_response_box = new GuiPanel(this, "COMMS_OPENING_BOX");
    no_response_box
        ->setSize(800.0f, 70.0f)
        ->setPosition(0.0f, -250.0f, sp::Alignment::BottomCenter)
        ->hide();
    (new GuiLabel(no_response_box, "COMMS_NO_REPONSE_LABEL", tr("No reply..."), 40.0f))
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft);

    // Button to acknowledge unresponsive hails.
    (new GuiButton(no_response_box, "COMMS_NO_REPLY_OK", "Ok",
        []()
        {
            if (my_spaceship) my_player_info->commandCloseTextComm();
        }
    ))->setSize(100.0f, 50.0f)
        ->setPosition(-20.0f, -10.0f, sp::Alignment::BottomRight);

    // Panel for broken communications.
    broken_box = new GuiPanel(this, "COMMS_BROKEN_BOX");
    broken_box
        ->setSize(800.0f, 70.0f)
        ->setPosition(0.0f, -250.0f, sp::Alignment::BottomCenter)
        ->hide();

    (new GuiLabel(broken_box, "COMMS_BROKEN_LABEL", tr("Communications were suddenly cut"), 40.0f))
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft);

    // Button to acknowledge broken communications.
    (new GuiButton(broken_box, "COMMS_BROKEN_OK", "Ok",
        []()
        {
            if (my_spaceship) my_player_info->commandCloseTextComm();
        }
    ))->setSize(100.0f, 50.0f)
        ->setPosition(-20.0f, -10.0f, sp::Alignment::BottomRight);

    // Panel for communications closed by the other object.
    closed_box = new GuiPanel(this, "COMMS_CLOSED_BOX");
    closed_box
        ->setSize(800.0f, 70.0f)
        ->setPosition(0.0f, -250.0f, sp::Alignment::BottomCenter)
        ->hide();

    (new GuiLabel(closed_box, "COMMS_BROKEN_LABEL", tr("Communications channel closed"), 40.0f))
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setPosition(0.0f, 0.0f, sp::Alignment::TopLeft);

    // Button to acknowledge closed communications.
    (new GuiButton(closed_box, "COMMS_CLOSED_OK", "Ok",
        []()
        {
            if (my_spaceship) my_player_info->commandCloseTextComm();
        }
    ))->setSize(100.0f, 50.0f)
        ->setPosition(-20.0f, -10.0f, sp::Alignment::BottomRight);

    // Panel for chat with GMs/other players and scripted comms with objects.
    comms_dialog_box = new GuiPanel(this, "COMMS_DIALOG_BOX");
    comms_dialog_box
        ->setSize(800.0f, 600.0f)
        ->setPosition(0.0f, -100.0f, sp::Alignment::BottomCenter)
        ->hide()
        ->setAttribute("layout", "vertical");

    // Title bar for comms panels.
    GuiElement* comms_dialog_title_bar = new GuiElement(comms_dialog_box, "");
    comms_dialog_title_bar
        ->setMargins(20.0f, 0.0f, 0.0f, 0.0f)
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setAttribute("layout", "horizontal");

    // Title label showing the comms target's name.
    comms_dialog_title_label = new GuiLabel(comms_dialog_title_bar, "COMMS_DIALOG_TITLE", "", 30.0f);
    comms_dialog_title_label
        ->addBackground()
        ->setSize(GuiElement::GuiSizeMax, 50.0f);

    // Minimize button collapses the panel to a restore button without closing comms.
    (new GuiButton(comms_dialog_title_bar, "COMMS_DIALOG_MINIMIZE", "",
        [this]()
        {
            comms_minimized = true;
        }
    ))->setIcon("gui/widget/IndicatorArrow.png", sp::Alignment::Center, -90.0f)
        ->setMargins(20.0f, 0.0f, 0.0f, 0.0f)
        ->setSize(50.0f, GuiElement::GuiSizeMax);

    // Button to close comms.
    (new GuiButton(comms_dialog_title_bar, "COMMS_DIALOG_CLOSE", "X",
        [this]()
        {
            script_comms_options->setOptions({});
            if (my_spaceship) my_player_info->commandCloseTextComm();
        }
    ))->setTextSize(30.0f)
        ->setSize(50.0f, 50.0f);

    // Floating restore button shown when any comms panel is minimized.
    comms_restore_button = new GuiToggleButton(this, "COMMS_RESTORE", "",
        [this](bool)
        {
            comms_minimized = false;
            comms_has_unread = false;
        }
    );
    comms_restore_button
        ->setIcon("gui/widget/IndicatorArrow.png", sp::Alignment::CenterLeft, 90.0f)
        ->setPosition(0.0f, -70.0f, sp::Alignment::BottomCenter)
        ->setSize(400.0f, 50.0f)
        ->hide();

    // Text area shared by both chat and scripted comms.
    comms_dialog_text = new GuiScrollFormattedText(comms_dialog_box, "COMMS_DIALOG_TEXT", "");
    comms_dialog_text
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->setMargins(20.0f);

    // Chat comms free-text message entry.
    GuiElement* chat_comms_message_row = new GuiElement(comms_dialog_box, "COMMS_CHAT_MESSAGE_ROW");
    chat_comms_message_row
        ->setMargins(20.0f)
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setAttribute("layout", "horizontal");

    chat_comms_message_entry = new GuiTextEntry(chat_comms_message_row, "COMMS_CHAT_MESSAGE_ENTRY", "");
    chat_comms_message_entry
        ->enterCallback([this](string text)
            {
                if (my_spaceship)
                    my_player_info->commandSendCommPlayer(chat_comms_message_entry->getText());
                chat_comms_message_entry->setText("");
            }
        )
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    // Chat comms send button.
    chat_comms_send_button = new GuiButton(chat_comms_message_row, "COMMS_CHAT_SEND", tr("button", "Send"),
        [this]()
        {
            if (my_spaceship)
                my_player_info->commandSendCommPlayer(chat_comms_message_entry->getText());
            chat_comms_message_entry->setText("");
        }
    );
    chat_comms_send_button
        ->setSize(120.0f, GuiElement::GuiSizeMax);

    // Script comms response options listbox.
    script_comms_options = new GuiListbox(comms_dialog_box, "COMMS_SCRIPT_OPTIONS",
        [this](int index, string value)
        {
            script_comms_options->setOptions({});
            my_player_info->commandSendComm(index);
        }
    );
    script_comms_options
        ->setSize(GuiElement::GuiSizeMax, 200.0f)
        ->setMargins(20.0f)
        ->hide();

    // If using a touchscreen, add an on-screen keyboard.
    if (!engine->getObject("mouseRenderer"))
    {
        OnScreenKeyboardControl* keyboard = new OnScreenKeyboardControl(comms_dialog_box, chat_comms_message_entry);
        keyboard
            ->setSize(760.0f, 200.0f)
            ->setPosition(20.0f, -20.0f, sp::Alignment::BottomLeft);
        chat_comms_message_entry
            ->setPosition(20.0f, -220.0f, sp::Alignment::BottomLeft);
        chat_comms_send_button
            ->setPosition(-20.0f, -220.0f, sp::Alignment::BottomRight);
        comms_dialog_text
            ->setSize(comms_dialog_text->getSize().x, comms_dialog_text->getSize().y - 200.0f);
    }
}

void GuiCommsOverlay::onUpdate()
{
    // If we're on a ship, show comms activity on draw.
    if (auto transmitter = my_spaceship.getComponent<CommsTransmitter>())
    {
        opening_progress->setValue(transmitter->open_delay);
        hailed_label->setText(tr("Hailed by {name}").format({{"name", transmitter->target_name}}));

        no_response_box->setVisible(transmitter->state == CommsTransmitter::State::ChannelFailed);
        broken_box->setVisible(transmitter->state == CommsTransmitter::State::ChannelBroken);
        closed_box->setVisible(transmitter->state == CommsTransmitter::State::ChannelClosed);

        const bool is_opening = transmitter->state == CommsTransmitter::State::OpeningChannel;
        const bool is_hailed = transmitter->state == CommsTransmitter::State::BeingHailed || transmitter->state == CommsTransmitter::State::BeingHailedByGM;
        const bool is_open = transmitter->state == CommsTransmitter::State::ChannelOpenGM || transmitter->state == CommsTransmitter::State::ChannelOpenPlayer;
        const bool is_script = transmitter->state == CommsTransmitter::State::ChannelOpen;
        const bool any_minimizable = is_opening || is_hailed || is_open || is_script;

        if (!any_minimizable)
        {
            comms_minimized = false;
            comms_has_unread = false;
        }

        opening_box->setVisible(is_opening && !comms_minimized);
        hailed_box->setVisible(is_hailed && !comms_minimized);
        comms_dialog_box->setVisible((is_open || is_script) && !comms_minimized);
        chat_comms_message_entry->setVisible(is_open);
        chat_comms_send_button->setVisible(is_open);
        if (is_open)
            comms_dialog_text->enableAutoScrollDown();
        else
            comms_dialog_text->disableAutoScrollDown();

        string restore_text;
        if (is_opening)
            restore_text = tr("Opening comms with {name}").format({{"name", transmitter->target_name}});
        else if (is_hailed)
            restore_text = tr("Hailed by {name}").format({{"name", transmitter->target_name}});
        else
            restore_text = tr("Comms open with {name}").format({{"name", transmitter->target_name}});

        if (comms_minimized && transmitter->incomming_message != last_incoming_message)
            comms_has_unread = true;
        last_incoming_message = transmitter->incomming_message;

        comms_restore_button
            ->setValue(comms_has_unread)
            ->setText(restore_text)
            ->setVisible(comms_minimized && any_minimizable);

        comms_dialog_title_label->setText(transmitter->target_name);
        comms_dialog_text->setText(transmitter->incomming_message);

        // Chat window has just opened, let's auto-focus the text input.
        if (is_open && !chat_open_last_update)
        {
            if (auto canvas = dynamic_cast<GuiCanvas*>(getTopLevelContainer()))
                canvas->focus(chat_comms_message_entry);
        }
        chat_open_last_update = is_open;

        // Show scripted comms options, if any. If they've changed, update the
        // list.
        const int transmitter_replies_count = static_cast<int>(transmitter->script_replies.size());
        script_comms_options->setVisible(transmitter_replies_count);
        bool changed = script_comms_options->entryCount() != transmitter_replies_count;
        if (!changed && transmitter_replies_count > 0)
        {
            for (auto i = 0u; !changed && i < static_cast<unsigned int>(transmitter_replies_count); i++)
               changed = transmitter->script_replies[i].message != script_comms_options->getEntryName(i);
        }

        if (changed)
        {
            // Repopulate the comms options with the transmitter's.
            script_comms_options->setOptions({});
            for (const auto& reply : transmitter->script_replies)
                script_comms_options->addEntry(reply.message, reply.message);
            script_comms_options->setSelectionIndex(-1);

            // Resize displayed options list to show at most 5 entries.
            const int display_options_count = std::min(5, script_comms_options->entryCount());
            script_comms_options->setSize(GuiElement::GuiSizeMax, display_options_count * 50.0f);
        }
    }
}

void GuiCommsOverlay::clearElements()
{
    // Force all panels to hide, in case hiding the overlay doesn't hide its
    // contents on draw.
    opening_box->hide();
    hailed_box->hide();
    no_response_box->hide();
    broken_box->hide();
    closed_box->hide();
    comms_dialog_box->hide();
    comms_restore_button->hide();
    comms_minimized = false;
    comms_has_unread = false;
}
