#include "chatDialog.h"
#include "i18n.h"
#include "gameGlobalInfo.h"
#include "components/comms.h"
#include "components/collision.h"
#include "components/name.h"
#include "systems/comms.h"

#include "screenComponents/radarView.h"

#include "gui/gui2_button.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_scrolltext.h"

GameMasterChatDialog::GameMasterChatDialog(GuiContainer* owner, GuiRadarView* radar, sp::ecs::Entity player)
: GuiResizableDialog(owner, "GM_CHAT_DIALOG", ""), player(player)
{
    this->radar = radar;

    chat_text = new GuiScrollText(contents, "GM_CHAT_TEXT", "");
    chat_text->enableAutoScrollDown()->setScrollbarWidth(25)->setTextSize(20)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    text_entry = new GuiTextEntry(contents, "GM_CHAT_ENTRY", "");
    text_entry->setTextSize(20)->setSize(GuiElement::GuiSizeMax, 25.0f)->setMargins(0.0f, 10.0f, 0.0f, 0.0f);
    text_entry->enterCallback(
        [this](string text)
        {
            if (this->player)
            {
                auto transmitter = this->player.getComponent<CommsTransmitter>();
                if (transmitter && transmitter->state == CommsTransmitter::State::ChannelOpenGM)
                    CommsSystem::addCommsIncommingMessage(this->player, text_entry->getText());
                else
                    CommsSystem::hailByGM(this->player, text_entry->getText());
            }
            text_entry->setText("");
        }
    );

    auto status_bar = new GuiElement(contents, "GM_CHAT_STATUS_BAR");
    status_bar->setSize(GuiElement::GuiSizeMax, 25.0f)->setMargins(0.0f, 10.0f, 0.0f, 0.0f);
    status_bar->setAttribute("layout", "horizontalright");

    use_comms_script = new GuiButton(status_bar, "GM_CHAT_SCRIPT", tr("Use comms script"),
        [this]()
        {
            if (this->player)
            {
                // If the player's comms target can successfully open a scripted
                // comms channel with the player, do so immediately and close this
                // GM chat.
                if (auto transmitter = this->player.getComponent<CommsTransmitter>())
                {
                    if (CommsSystem::openChannel(this->player, transmitter->target))
                    {
                        this->disableComms(tr("chatGM", "Target - Using scripted comms"));
                        transmitter->state = CommsTransmitter::State::ChannelOpen;
                        this->onClose();
                    }
                }
            }
        }
    );
    use_comms_script->setTextSize(20.0f)->setSize(135.0f, 25.0f)->setMargins(0.0f, 0.0f, 10.0f, 0.0f)->hide();

    min_size.y += 100;

    notification = false;
}

void GameMasterChatDialog::onDraw(sp::RenderTarget& renderer)
{
    GuiResizableDialog::onDraw(renderer);
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (!player)
    {
        disableComms(tr("chatGM", "Target - Destroyed"));
        return;
    }
    if (!transmitter)
    {
        disableComms(tr("chatGM", "Target - No Transmitter"));
        return;
    }

    if (!isMinimized())
        notification = false;
    auto callsign_comp = player.getComponent<CallSign>();
    auto callsign = callsign_comp ? callsign_comp->callsign : string("");

    switch(transmitter->state)
    {
    case CommsTransmitter::State::Inactive:
    case CommsTransmitter::State::ChannelFailed:
    case CommsTransmitter::State::ChannelBroken:
    case CommsTransmitter::State::ChannelClosed:
        chat_text->setText(tr("chatGM", "Channel not open, enter name to hail as to hail target."));
        disableComms(tr("chatGM", "{callsign} - Inactive").format({{"callsign", callsign}}));
        break;
    case CommsTransmitter::State::OpeningChannel:
    case CommsTransmitter::State::BeingHailed:
        disableComms(tr("chatGM", "{callsign} - Opening communications with {target}").format({{"callsign", callsign}, {"target", transmitter->target_name}}));
        break;
    case CommsTransmitter::State::BeingHailedByGM:
        disableComms(tr("chatGM", "{callsign} - Hailing as {target}").format({{"callsign", callsign}, {"target", transmitter->target_name}}));
        break;
    case CommsTransmitter::State::ChannelOpen:
    case CommsTransmitter::State::ChannelOpenPlayer:
        disableComms(tr("chatGM", "{callsign} - Communicating with {target}").format({{"callsign", callsign}, {"target", transmitter->target_name}}));
        break;
    case CommsTransmitter::State::ChannelOpenGM:
        if (notification)
            setTitle(tr("chatGM", "**{callsign} - Communicating as {target}**").format({{"callsign", callsign}, {"target", transmitter->target_name}}));
        else
            setTitle(tr("chatGM", "{callsign} - Communicating as {target}").format({{"callsign", callsign}, {"target", transmitter->target_name}}));

        chat_text->enable();
        text_entry->enable();

        if (chat_text->getText() != transmitter->incomming_message)
        {
            chat_text->setText(transmitter->incomming_message);
            notification = true;
        }

        if (auto transform = transmitter->target.getComponent<sp::Transform>())
            renderer.drawLine(rect.center(), radar->worldToScreen(transform->getPosition()), glm::u8vec4(128, 255, 128, 128));

        // Hide the use_comms_script button if the comms target can't use it.
        // TODO: Confirm this works if callback is present
        if (auto comms_receiver = transmitter->target.getComponent<CommsReceiver>())
            use_comms_script->setVisible(!comms_receiver->script.empty() || comms_receiver->callback);

        break;
    }

    if (auto transform = player.getComponent<sp::Transform>())
        renderer.drawLine(rect.center(), radar->worldToScreen(transform->getPosition()), glm::u8vec4(128, 255, 128, 128));
}

void GameMasterChatDialog::disableComms(string title)
{
    if (notification) title = "**" + title + "**";
    setTitle(title);
    use_comms_script->hide();
    chat_text->disable();
    text_entry->enable();
}

void GameMasterChatDialog::onClose()
{
    auto transmitter = player.getComponent<CommsTransmitter>();
    if (transmitter && (transmitter->state == CommsTransmitter::State::ChannelOpenGM || transmitter->state == CommsTransmitter::State::BeingHailedByGM))
        CommsSystem::close(player);

    hide();
    minimize(false);
}
