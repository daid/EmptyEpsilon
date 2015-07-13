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
}

void GuiCommsOverlay::onDraw(sf::RenderTarget& window)
{
    if (my_spaceship)
    {
        opening_box->setVisible(my_spaceship->comms_state == CS_OpeningChannel);
        opening_progress->setValue(my_spaceship->comms_open_delay);
        
        hailed_box->setVisible(my_spaceship->comms_state == CS_BeingHailed || my_spaceship->comms_state == CS_BeingHailedByGM);
        hailed_label->setText(my_spaceship->comms_incomming_message);
        
        no_response_box->setVisible(my_spaceship->comms_state == CS_ChannelFailed);
    }
}
