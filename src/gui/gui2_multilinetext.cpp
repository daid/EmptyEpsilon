#include "gui2_multilinetext.h"
#include "theme.h"

GuiMultilineText::GuiMultilineText(GuiContainer* owner, string id, string text)
: GuiElement(owner, id), text(text)
{
    text_theme = theme->getStyle("textbox.front");
}

GuiMultilineText* GuiMultilineText::setText(string text)
{
    this->text = text;
    return this;
}

string GuiMultilineText::getText() const
{
    return text;
}

void GuiMultilineText::onDraw(sp::RenderTarget& renderer)
{
    const auto& text_style = text_theme->get(getState());
    // Prepare the text in one batch.
    auto prepared = sp::RenderTarget::getDefaultFont()->prepare(
        this->text,
        32,
        text_size,
        text_style.color,
        rect.size,
        sp::Alignment::TopLeft,
        sp::Font::FlagLineWrap
    );

    // Set the element size to match the text size, plus a buffer for
    // descenders.
    setSize(GuiElement::GuiSizeMax, prepared.getUsedAreaSize().y + text_size * 0.33f);
    // Never resize this element to fill height. We always want the specified
    // size. Since setSize resets fill_height to true, we have to flap it here.
    layout.fill_height = false;

    // Draw the text in the rect with line wrapping.
    renderer.drawText(rect, prepared, sp::Font::FlagLineWrap);
}

GuiMultilineFormattedText::GuiMultilineFormattedText(GuiContainer* owner, string id, string text)
: GuiMultilineText(owner, id, text)
{
}

void GuiMultilineFormattedText::onDraw(sp::RenderTarget& renderer)
{
    const auto& text_style = text_theme->get(getState());
    auto main_color = text_style.color;
    auto current_color = main_color;
    // Each piece of tagged text needs formatting, so prepare incrementally
    // instead of all at once.
    auto prepared = sp::RenderTarget::getDefaultFont()->start(
        32,
        rect.size,
        sp::Alignment::TopLeft,
        sp::Font::FlagLineWrap
    );
    int last_end = 0;
    float size_mod = 1.0f;

    // Prepare each substring and append it.
    for (auto tag_start = text.find('<'); tag_start >= 0; tag_start = text.find('<', tag_start + 1))
    {
        prepared.append(text.substr(last_end, tag_start), text_size * size_mod, current_color);
        auto tag_end = text.find('>', tag_start + 1);

        if (tag_end != -1)
        {
            last_end = tag_end + 1;
            auto tag = text.substr(tag_start + 1, tag_end);

            // Parse and apply tags.
            if (tag == "/")
            {
                size_mod = 1.0f;
                current_color = main_color;
            }
            else if (tag == "h1") size_mod = 2.0f;
            else if (tag == "h2") size_mod = 1.5f;
            else if (tag == "h3") size_mod = 1.17f;
            else if (tag == "h4") size_mod = 1.0f;
            else if (tag == "h5") size_mod = 0.83f;
            else if (tag == "h6") size_mod = 0.67f;
            else if (tag == "small") size_mod = 0.89f;
            else if (tag == "large") size_mod = 1.2f;
            else if (tag.startswith("color="))
                current_color = GuiTheme::toColor(tag.substr(6));
            else last_end = tag_start;
        }
        else last_end = tag_start;
    }

    prepared.append(text.substr(last_end), text_size * size_mod, current_color);
    prepared.finish();

    // Set the element size to match the text size, plus a buffer for
    // descenders.
    setSize(GuiElement::GuiSizeMax, prepared.getUsedAreaSize().y + text_size * 0.33f);
    // Never resize this element to fill height. We always want the specified
    // size. Since setSize resets fill_height to true, we have to flap it here.
    layout.fill_height = false;

    // Draw the text in the rect with line wrapping.
    renderer.drawText(rect, prepared, sp::Font::FlagLineWrap);
}
