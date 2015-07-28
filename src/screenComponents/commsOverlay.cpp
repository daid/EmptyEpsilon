#include "playerInfo.h"
#include "commsOverlay.h"

GuiCommsOverlay::GuiCommsOverlay(GuiContainer* owner)
: GuiElement(owner, "COMMS_OVERLAY")
{
    opening_box = new GuiBox(owner, "COMMS_OPENING_BOX");
    opening_box->fill()->hide()->setSize(800, 100)->setPosition(0, -250, ABottomCenter);
    (new GuiLabel(opening_box, "COMMS_OPENING_LABEL", "Opening communications...", 40))->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 0, ATopCenter);
    opening_progress = new GuiProgressbar(opening_box, "COMMS_OPENING_PROGRESS", PlayerSpaceship::comms_channel_open_time, 0.0, 0.0);
    opening_progress->setSize(700, 40)->setPosition(0, -10, ABottomCenter);

    hailed_box = new GuiBox(owner, "COMMS_BEING_HAILED_BOX");
    hailed_box->fill()->hide()->setSize(800, 140)->setPosition(0, -250, ABottomCenter);
    hailed_label = new GuiLabel(hailed_box, "COMMS_BEING_HAILED_BOX", "..", 40);
    hailed_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 20, ATopCenter);
    (new GuiButton(hailed_box, "COMMS_BEING_HAILED_ANSWER", "Answer", []() {
        if (my_spaceship)
            my_spaceship->commandAnswerCommHail(true);
    }))->setSize(300, 50)->setPosition(20, -20, ABottomLeft);

    (new GuiButton(hailed_box, "COMMS_BEING_HAILED_ANSWER", "Ignore", []() {
        if (my_spaceship)
            my_spaceship->commandAnswerCommHail(false);
    }))->setSize(300, 50)->setPosition(-20, -20, ABottomRight);
    
    no_response_box = new GuiBox(owner, "COMMS_OPENING_BOX");
    no_response_box->fill()->hide()->setSize(800, 70)->setPosition(0, -250, ABottomCenter);
    (new GuiLabel(no_response_box, "COMMS_NO_REPONSE_LABEL", "No reply...", 40))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopLeft);
    (new GuiButton(no_response_box, "COMMS_NO_REPLY_OK", "Ok", []() {
        if (my_spaceship)
            my_spaceship->commandCloseTextComm();
    }))->setSize(150, 50)->setPosition(-20, -10, ABottomRight);

    broken_box = new GuiBox(owner, "COMMS_BROKEN_BOX");
    broken_box->fill()->hide()->setSize(800, 70)->setPosition(0, -250, ABottomCenter);
    (new GuiLabel(no_response_box, "COMMS_BROKEN_LABEL", "Communications where suddenly cut", 40))->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setPosition(0, 0, ATopLeft);
    (new GuiButton(no_response_box, "COMMS_BROKEN_OK", "Ok", []() {
        if (my_spaceship)
            my_spaceship->commandCloseTextComm();
    }))->setSize(150, 50)->setPosition(-20, -10, ABottomRight);
    
    chat_comms_box = new GuiBox(owner, "COMMS_CHAT_BOX");
    chat_comms_box->fill()->hide()->setSize(800, 600)->setPosition(0, -100, ABottomCenter);

    chat_comms_message_entry = new GuiTextEntry(chat_comms_box, "COMMS_CHAT_MESSAGE_ENTRY", "");
    chat_comms_message_entry->setPosition(20, -20, ABottomLeft)->setSize(640, 50);
    chat_comms_message_entry->enterCallback([this](string text){
        if (my_spaceship)
            my_spaceship->commandSendCommPlayer(chat_comms_message_entry->getText());
        chat_comms_message_entry->setText("");
    });
    
    chat_comms_text = new GuiScrollText(chat_comms_box, "COMMS_CHAT_TEXT", "");
    chat_comms_text->enableAutoScrollDown()->setPosition(20, 30, ATopLeft)->setSize(760, 500);
    
    (new GuiButton(chat_comms_box, "SEND_BUTTON", "Send", [this]() {
        if (my_spaceship)
            my_spaceship->commandSendCommPlayer(chat_comms_message_entry->getText());
        chat_comms_message_entry->setText("");
    }))->setPosition(-20, -20, ABottomRight)->setSize(120, 50);

    (new GuiButton(chat_comms_box, "CLOSE_BUTTON", "Close", [this]() {
        if (my_spaceship)
            my_spaceship->commandCloseTextComm();
    }))->setTextSize(20)->setPosition(-10, 0, ATopRight)->setSize(70, 30);


    script_comms_box = new GuiBox(owner, "COMMS_SCRIPT_BOX");
    script_comms_box->fill()->hide()->setSize(800, 600)->setPosition(0, -100, ABottomCenter);

    script_comms_text = new GuiScrollText(script_comms_box, "COMMS_SCRIPT_TEXT", "");
    script_comms_text->enableAutoScrollDown()->setPosition(20, 30, ATopLeft)->setSize(760, 500);
    
    script_comms_options = new GuiListbox(script_comms_box, "SCRIPT_COMMS_LIST", [this](int index, string value) {
        script_comms_options->setOptions({});
        my_spaceship->comms_reply_message.clear();
        my_spaceship->commandSendComm(index);
    });
    script_comms_options->setPosition(20, -20, ABottomLeft)->setSize(700, 400);
    
    (new GuiButton(script_comms_box, "CLOSE_BUTTON", "Close", [this]() {
        if (my_spaceship)
            my_spaceship->commandCloseTextComm();
    }))->setTextSize(20)->setPosition(-20, -20, ABottomRight)->setSize(150, 50);
}

void GuiCommsOverlay::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        opening_box->setVisible(my_spaceship->comms_state == CS_OpeningChannel);
        opening_progress->setValue(my_spaceship->comms_open_delay);
        
        hailed_box->setVisible(my_spaceship->comms_state == CS_BeingHailed || my_spaceship->comms_state == CS_BeingHailedByGM);
        hailed_label->setText("Hailed by " + my_spaceship->comms_target_name);
        
        no_response_box->setVisible(my_spaceship->comms_state == CS_ChannelFailed);

        broken_box->setVisible(my_spaceship->comms_state == CS_ChannelBroken);
        
        chat_comms_box->setVisible(my_spaceship->comms_state == CS_ChannelOpenPlayer || my_spaceship->comms_state == CS_ChannelOpenGM);
        chat_comms_text->setText(my_spaceship->comms_incomming_message);
        
        script_comms_box->setVisible(my_spaceship->comms_state == CS_ChannelOpen);
        script_comms_text->setText(my_spaceship->comms_incomming_message);
        
        if (script_comms_options->entryCount() != int(my_spaceship->comms_reply_message.size()))
        {
            script_comms_options->setOptions({});
            for(string message : my_spaceship->comms_reply_message)
                script_comms_options->addEntry(message, message);
        }
    }
}
