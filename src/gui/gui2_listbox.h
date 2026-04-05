#pragma once

#include "gui2_entrylist.h"

class GuiScrollbar;
class GuiTextEntry;

class GuiListbox : public GuiEntryList
{
public:
    // Text filter search callback function.
    using search_func_t = std::function<void(string)>;
protected:
    float text_size;
    float button_height;
    sp::Alignment text_alignment;
    GuiScrollbar* scroll;
    sp::Rect last_rect;
    int mouse_scroll_steps;

    const GuiThemeStyle* back_style;
    const GuiThemeStyle* front_style;
    const GuiThemeStyle* back_selected_style;
    const GuiThemeStyle* front_selected_style;

    // Text entry field for text filter search.
    GuiTextEntry* search_entry = nullptr;
    // Callback run when text is entered in the text filter search.
    search_func_t search_callback;
    // Master list of all entries, used to rebuild the visible list on each filter change.
    std::vector<GuiEntry> all_entries;
    // Boolean indicator of whether filtering is active.
    bool search_filtering = false;
    // Text entered into the text filter search, to be matched against entries.
    string search_text;
public:
    GuiListbox(GuiContainer* owner, string id, func_t func);

    GuiListbox* setTextSize(float size);
    GuiListbox* setButtonHeight(float height);

    GuiListbox* scrollTo(int index);
    // Adds the text filter search field. Takes an optional callback that
    // receives the lowercased search text and runs each time the field is
    // edited. When no callback is provided, the listbox filters itself.
    // Has no effect if called more than once.
    GuiListbox* addSearch(search_func_t search_callback = nullptr);
    // Clears the search field. For the built-in filter, also resets the
    // visible list to all entries.
    GuiListbox* clearSearch();

    // Returns the current text in the search field, or "" if no search field exists.
    string getSearchText() const;

    virtual int addEntry(string name, string value) override;
    virtual void clear() override;
    virtual void setEntryName(int index, string name) override;
    virtual void setEntryValue(int index, string value) override;
    virtual void setEntryIcon(int index, string icon_name) override;
    virtual void setEntry(int index, string name, string value) override;
    virtual void removeEntry(int index) override;

    virtual void onDraw(sp::RenderTarget& renderer) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual void onMouseUp(glm::vec2 position, sp::io::Pointer::ID id) override;
    virtual bool onMouseWheelScroll(glm::vec2 position, float value) override;
private:
    // Default search filter callback. Builds an entry list from matches.
    void applyFilter();

    static constexpr float search_bar_height = 30.0f;
};
