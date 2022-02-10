#ifndef GUI_LAYOUT_H
#define GUI_LAYOUT_H

#include <nonCopyable.h>
#include <stringImproved.h>
#include <rect.h>


class GuiContainer;
class GuiElement;
class GuiLayout : sp::NonCopyable
{
public:
    virtual ~GuiLayout() {}
    void updateLoop(GuiContainer& container, const sp::Rect& rect);
    virtual void update(GuiContainer& container, const sp::Rect& rect);

protected:
    virtual void basicLayout(const sp::Rect& rect, GuiElement& widget);

private:
    bool require_repeat = false;
};

class GuiLayoutClassRegistry : sp::NonCopyable
{
public:
    static GuiLayoutClassRegistry* first;
    
    GuiLayoutClassRegistry* next;
    string name;
    std::function<std::unique_ptr<GuiLayout>()> creation_function;
    
    GuiLayoutClassRegistry(const string& name, std::function<std::unique_ptr<GuiLayout>()> creation_function)
    : name(name), creation_function(creation_function)
    {
        next = first;
        first = this;
    }
};

#define GUI_REGISTER_LAYOUT(name, class_name) \
    GuiLayoutClassRegistry layout_class_registry ## class_name (name, []() { return std::make_unique<class_name>(); });

#endif//GUI_LAYOUT_H
