#include <i18n.h>
#include "tweak.h"
#include "playerInfo.h"
#include "components/collision.h"
#include "components/name.h"
#include "components/coolant.h"

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
        setSize(GuiElement::GuiSizeMax, 30);
        setTextSize(20);
    }
    virtual void onDraw(sp::RenderTarget& target) override {
        if (!focus) setText(update_func());
        GuiTextEntry::onDraw(target);
    }
    std::function<string()> update_func;
};
class GuiToggleTweak : public GuiToggleButton {
public:
    GuiToggleTweak(GuiContainer* owner, const string& label, GuiToggleButton::func_t callback) : GuiToggleButton(owner, "", label, callback) {
        setSize(GuiElement::GuiSizeMax, 30);
        setTextSize(20);
    }
    virtual void onDraw(sp::RenderTarget& target) override {
        if (update_func) setValue(update_func());
        GuiToggleButton::onDraw(target);
    }
    std::function<bool()> update_func;
};


#define ADD_PAGE(LABEL, COMPONENT) \
    new_page = new GuiTweakPage(this); \
    new_page->has_component = [](sp::ecs::Entity e) { return e.hasComponent<COMPONENT>(); }; \
    new_page->add_component = [](sp::ecs::Entity e) { e.addComponent<COMPONENT>(); }; \
    new_page->remove_component = [](sp::ecs::Entity e) { e.removeComponent<COMPONENT>(); }; \
    pages.push_back(new_page); \
    list->addEntry(LABEL, "");
#define ADD_TEXT_TWEAK(LABEL, COMPONENT, VALUE) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
        auto ui = new GuiTextTweak(row); \
        ui->update_func = [this]() -> string { auto v = entity.getComponent<COMPONENT>(); if (v) return v->VALUE; return ""; }; \
        ui->callback([this](string text) { auto v = entity.getComponent<COMPONENT>(); if (v) v->VALUE = text; }); \
    } while(0)
#define ADD_NUM_TEXT_TWEAK(LABEL, COMPONENT, VALUE) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
        auto ui = new GuiTextTweak(row); \
        ui->update_func = [this]() -> string { auto v = entity.getComponent<COMPONENT>(); if (v) return std::to_string(v->VALUE); return ""; }; \
        ui->callback([this](string text) { auto v = entity.getComponent<COMPONENT>(); if (v) v->VALUE = text.toFloat(); }); \
    } while(0)
#define ADD_BOOL_TWEAK(LABEL, COMPONENT, VALUE) do { \
        auto row = new GuiElement(new_page->contents, ""); \
        row->setSize(GuiElement::GuiSizeMax, 30)->setAttribute("layout", "horizontal"); \
        auto label = new GuiLabel(row, "", LABEL, 20); \
        label->setAlignment(sp::Alignment::CenterRight)->setSize(GuiElement::GuiSizeMax, 30); \
        auto ui = new GuiToggleTweak(row, "", [this](bool value) { auto v = entity.getComponent<COMPONENT>(); if (v) v->VALUE = value; }); \
        ui->update_func = [this]() -> bool { auto v = entity.getComponent<COMPONENT>(); if (v) return v->VALUE; return false; }; \
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
    ADD_TEXT_TWEAK(tr("tweak-text", "Callsign:"), CallSign, callsign);
    ADD_PAGE(tr("tweak-tab", "Typename"), TypeName);
    ADD_TEXT_TWEAK(tr("tweak-text", "TypeName:"), TypeName, type_name);
    ADD_TEXT_TWEAK(tr("tweak-text", "Localized:"), TypeName, localized);
    ADD_PAGE(tr("tweak-tab", "Coolant"), Coolant);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max:"), Coolant, max);
    ADD_NUM_TEXT_TWEAK(tr("tweak-text", "Max per system:"), Coolant, max_coolant_per_system);
    ADD_BOOL_TWEAK(tr("tweak-text", "Auto levels:"), Coolant, auto_levels);

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

    contents = new GuiElement(this, "CONTENT");
    contents->setPosition(0, 75, sp::Alignment::TopLeft)->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)->setAttribute("layout", "vertical");
    contents->setMargins(30, 0);
}

void GuiTweakPage::open(sp::ecs::Entity e)
{
    entity = e;
}

void GuiTweakPage::onDraw(sp::RenderTarget& target)
{
    if (has_component(entity)) {
        add_remove_button->setText(tr("tweak-button", "Remove component"));
        contents->show();
    } else {
        add_remove_button->setText(tr("tweak-button", "Create component"));
        contents->hide();
    }
}
