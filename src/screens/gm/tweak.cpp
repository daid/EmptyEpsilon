#include <i18n.h>
#include "tweak.h"
#include "playerInfo.h"
#include "components/collision.h"
#include "components/name.h"

#include "gui/gui2_listbox.h"
#include "gui/gui2_keyvaluedisplay.h"
#include "gui/gui2_label.h"
#include "gui/gui2_textentry.h"
#include "gui/gui2_selector.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_togglebutton.h"


class GuiTextTweak : public GuiTextEntry {
public:
    GuiTextTweak(GuiContainer* owner) : GuiTextEntry(owner, "", "") {
        setSize(GuiElement::GuiSizeMax, 50);
    }
    virtual void onDraw(sp::RenderTarget& target) override {
        if (!focus) setText(update_func());
        GuiTextEntry::onDraw(target);
    }
    std::function<string()> update_func;
};


#define ADD_PAGE(LABEL, COMPONENT) \
    new_page = new GuiTweakPage(this); \
    new_page->has_component = [](sp::ecs::Entity e) { return e.hasComponent<COMPONENT>(); }; \
    new_page->add_component = [](sp::ecs::Entity e) { e.addComponent<COMPONENT>(); }; \
    new_page->remove_component = [](sp::ecs::Entity e) { e.removeComponent<COMPONENT>(); }; \
    pages.push_back(new_page); \
    list->addEntry(LABEL, "");
#define ADD_TEXT_TWEAK(SIDE, LABEL, COMPONENT, VALUE) do { \
        (new GuiLabel(new_page->SIDE, "", LABEL, 30))->setSize(GuiElement::GuiSizeMax, 50); \
        auto ui = new GuiTextTweak(new_page->SIDE); \
        ui->update_func = [this]() -> string { auto v = entity.getComponent<COMPONENT>(); if (v) return v->VALUE; return ""; }; \
        ui->callback([this](string text) { auto v = entity.getComponent<COMPONENT>(); if (v) v->VALUE = text; }); \
    } while(0)

GuiEntityTweak::GuiEntityTweak(GuiContainer* owner)
: GuiPanel(owner, "GM_TWEAK_DIALOG")
{
    setPosition(0, -100, sp::Alignment::BottomCenter);
    setSize(1000, 700);

    GuiListbox* list = new GuiListbox(this, "", [this](int index, string value)
    {
        for(GuiTweakPage* page : pages)
            page->hide();
        pages[index]->show();
    });

    list->setSize(300, GuiElement::GuiSizeMax);
    list->setPosition(25, 25, sp::Alignment::TopLeft);

    GuiTweakPage* new_page;
    ADD_PAGE(tr("tweak-tab", "Callsign"), CallSign);
    ADD_TEXT_TWEAK(left, tr("tweak-text", "Callsign:"), CallSign, callsign);
    ADD_PAGE(tr("tweak-tab", "Typename"), TypeName);
    ADD_TEXT_TWEAK(left, tr("tweak-text", "TypeName:"), TypeName, type_name);
    ADD_TEXT_TWEAK(left, tr("tweak-text", "Localized:"), TypeName, localized);

    for(GuiTweakPage* page : pages)
    {
        page->setSize(700, 700)->setPosition(0, 0, sp::Alignment::BottomRight)->hide();
    }

    pages[0]->show();
    list->setSelectionIndex(0);

    (new GuiButton(this, "CLOSE_BUTTON", tr("button", "Close"), [this]() {
        hide();
    }))->setTextSize(20)->setPosition(-10, 0, sp::Alignment::TopRight)->setSize(70, 30);
}

void GuiEntityTweak::open(sp::ecs::Entity e)
{
    entity = e;
    for(auto page : pages)
        page->open(e);
    show();
}

GuiTweakPage::GuiTweakPage(GuiContainer* owner)
: GuiElement(owner, "")
{
    add_remove_button = new GuiButton(this, "ADD_REMOVE", "", [this](){
        if (has_component(entity))
            remove_component(entity);
        else
            add_component(entity);
    });
    add_remove_button->setSize(300, 50)->setPosition(0, 15, sp::Alignment::TopCenter);

    left = new GuiElement(this, "LEFT_LAYOUT");
    left->setPosition(50, 75, sp::Alignment::TopLeft)->setSize(300, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");

    right = new GuiElement(this, "RIGHT_LAYOUT");
    right->setPosition(-25, 75, sp::Alignment::TopRight)->setSize(300, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
}

void GuiTweakPage::open(sp::ecs::Entity e)
{
    entity = e;
}

void GuiTweakPage::onDraw(sp::RenderTarget& target)
{
    if (has_component(entity)) {
        add_remove_button->setText(tr("tweak-button", "Remove component"));
        left->show();
        right->show();
    } else {
        add_remove_button->setText(tr("tweak-button", "Create component"));
        left->hide();
        right->hide();
    }
}
