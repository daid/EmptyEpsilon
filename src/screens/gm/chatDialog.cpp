#include "chatDialog.h"
#include "gameGlobalInfo.h"
#include "spaceObjects/playerSpaceship.h"

#include "screenComponents/radarView.h"

#include "gui/gui2_textentry.h"
#include "gui/gui2_scrolltext.h"

GameMasterChatDialog::GameMasterChatDialog(GuiContainer* owner, GuiRadarView* radar, int index)
: GuiResizableDialog(owner, "", "")
{
    this->player_index = index;
    this->radar = radar;

    text_entry = new GuiTextEntry(contents, "", "");
    text_entry->setTextSize(23)->setPosition(0, 0, ABottomLeft)->setSize(GuiElement::GuiSizeMax, 30);
    text_entry->enterCallback([this](string text){
        if (this->player)
        {
            if (this->player->isCommsChatOpenToGM())
                this->player->addCommsIncommingMessage(text_entry->getText());
            else
                this->player->hailCommsByGM(text_entry->getText());
        }
        text_entry->setText("");
    });

    chat_text = new GuiScrollText(contents, "", "");
    chat_text->setTextSize(20)->setPosition(0, -30, ABottomLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    chat_text->enableAutoScrollDown()->setScrollbarWidth(30);

    min_size.y += 100;

    notification = false;
}

void GameMasterChatDialog::onDraw(sf::RenderTarget& window)
{
    GuiResizableDialog::onDraw(window);
    if (!player)
        player = gameGlobalInfo->getPlayerShip(player_index);

    if (!player)
    {
        disableComms(tr("chatGM", "Target - Destroyed"));
        return;
    }

    if (!isMinimized())
        notification = false;

    switch(player->getCommsState())
    {
    case CS_Inactive:
    case CS_ChannelFailed:
    case CS_ChannelBroken:
    case CS_ChannelClosed:
        chat_text->setText(tr("chatGM", "Channel not open, enter name to hail as to hail target."));
        disableComms(tr("chatGM", "{callsign} - Inactive").format({{"callsign", player->getCallSign()}}));
        break;
    case CS_OpeningChannel:
    case CS_BeingHailed:
        disableComms(tr("chatGM", "{callsign} - Opening communications with {target}").format({{"callsign", player->getCallSign()}, {"target", player->getCommsTargetName()}}));
        break;
    case CS_BeingHailedByGM:
        disableComms(tr("chatGM", "{callsign} - Hailing as {target}").format({{"callsign", player->getCallSign()}, {"target", player->getCommsTargetName()}}));
        break;
    case CS_ChannelOpen:
    case CS_ChannelOpenPlayer:
        disableComms(tr("chatGM", "{callsign} - Communicating with {target}").format({{"callsign", player->getCallSign()}, {"target", player->getCommsTargetName()}}));
        break;
    case CS_ChannelOpenGM:
        if (notification)
            setTitle(tr("chatGM", "**{callsign} - Communicating as {target}**").format({{"callsign", player->getCallSign()}, {"target", player->getCommsTargetName()}}));
        else
            setTitle(tr("chatGM", "{callsign} - Communicating as {target}").format({{"callsign", player->getCallSign()}, {"target", player->getCommsTargetName()}}));
        chat_text->enable();
        text_entry->enable();
        if (chat_text->getText() != player->getCommsIncommingMessage())
        {
            chat_text->setText(player->getCommsIncommingMessage());
            notification = true;
        }
        if (player->getCommsTarget())
            drawLine(window, radar->worldToScreen(player->getCommsTarget()->getPosition()));
        break;
    }
    drawLine(window, radar->worldToScreen(player->getPosition()));
}

void GameMasterChatDialog::disableComms(string title)
{
    if (notification)
        title = "**" + title + "**";
    setTitle(title);
    chat_text->disable();
    text_entry->enable();
}

void GameMasterChatDialog::onClose()
{
    if (player && (player->isCommsChatOpenToGM() || player->isCommsBeingHailedByGM()))
    {
        player->closeComms();
    }
    hide();
}

void GameMasterChatDialog::drawLine(sf::RenderTarget& window, sf::Vector2f target)
{
    sf::VertexArray a(sf::LinesStrip, 2);
    a[0].position = getCenterPoint();
    a[1].position = target;
    a[0].color = sf::Color(128,255,128,128);
    a[1].color = a[0].color;
    window.draw(a);
}
