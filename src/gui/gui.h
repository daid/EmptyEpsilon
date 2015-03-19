#ifndef GUI_H
#define GUI_H

#include "engine.h"

enum EAlign
{
    AlignLeft,
    AlignRight,
    AlignCenter,
    AlignTopLeft,
    AlignTopRight,
    AlignTopCenter
};
/*!
 * In order to reduce the overhead somewhat, the draw functions also return the state of the element
 * (eg; button returns true / false when pressed).
 */
class GUI: public Renderable
{
    static sf::RenderTarget* renderTarget;
    static sf::Vector2f mousePosition;
    static sf::Vector2f windowSize;
    static int mouseClick;
    static int mouseDown;
    bool init;
    static PVector<GUI> gui_stack;
public:
    GUI();

    virtual void render(sf::RenderTarget& window);

    virtual void onGui() = 0;

    bool isActive();

    /*!
     * Draw a certain text on the screen with horizontal orientation.
     * \param rect Area to draw in
     * \param align Alighment of text.
     * \param text_size Size of the text
     * \param color Color of text
     */
    static void drawText(sf::FloatRect rect, string text, EAlign align = AlignLeft, float text_size = 30, sf::Color color=sf::Color::White);

    /*!
     * Draw a certain text on the screen with vertical orientation
     * \param rect Area to draw in
     * \param align Alighment of text.
     * \param text_size Size of the text
     * \param color Color of text
     */
    static void drawVerticalText(sf::FloatRect rect, string text, EAlign align = AlignLeft, float text_size = 30, sf::Color color=sf::Color::White);

    /*!
     * Draw a horizontal progress bar.
     * \param rect Area to draw in
     * \param value Current value of the progress bar.
     * \param min_value The value at which the bar is at 0%
     * \param max_value The value at which the bar is at 100%
     * \param color Color of the progress bar.
     */
    static void drawProgressBar(sf::FloatRect rect, float value, float min_value = 0.0, float max_value = 1.0, sf::Color color=sf::Color(192, 192, 192));

    /*!
     * Draw a vertical progress bar.
     * \param rect Area to draw in
     * \param value Current value of the progress bar.
     * \param min_value The value at which the bar is at 0%
     * \param max_value The value at which the bar is at 100%
     * \param color Color of the progress bar.
     */
    static void drawVerticalProgressBar(sf::FloatRect rect, float value, float min_value = 0.0, float max_value = 1.0, sf::Color color=sf::Color(192, 192, 192));

    /*!
     * Draw a button and check the state.
     * \param rect Area to draw in
     * \param text Text on the button
     * \param text_size Size of text
     * \return bool True if button is pressed, false if not.
     */
    static bool drawButton(sf::FloatRect rect, string text, float text_size = 30);

    /*!
     * Draw a disabled button
     * \param rect Area to draw in
     * \param text Text on the button
     * \param text_size Size of text
     */
    static void drawDisabledButton(sf::FloatRect rect, string text, float text_size = 30);

    /*!
     * Draw a toggle button
     * \param rect Area to draw in
     * \param active Is button active
     * \param text Text on the button
     * \param text_size Size of text
     * \return bool True if button is pressed, false if not.
     */
    static bool drawToggleButton(sf::FloatRect rect, bool active, string text_value, float font_size = 30);

    /*!
     * Draw a horizontal slider
     * \param rect Area to draw in
     * \param value Current value of slider
     * \param min_value The value at which the bar is at 0%
     * \param max_value The value at which the bar is at 100%
     * \param normal_value 'base value', bar snaps a bit to this state.
     * \return value after user input.
     */
    static float drawHorizontalSlider(sf::FloatRect rect, float value, float min_value, float max_value, float normal_value = 0.0);

    /*!
     * Draw a vertical slider
     * \param rect Area to draw in
     * \param value Current value of slider
     * \param min_value The value at which the bar is at 0%
     * \param max_value The value at which the bar is at 100%
     * \param normal_value 'base value', bar snaps a bit to this state.
     * \return value after user input.
     */
    static float drawVerticalSlider(sf::FloatRect rect, float value, float min_value, float max_value, float normal_value = 0.0);

    /*!
     * Draw a slector object; two arrows, one left, other right
     * \param rect Area to draw in
     * \param text Text on the selector
     * \param text_size Size of text
     * \return -1 if left button is pressed, 1 if right is pressed, 0 if none.
     */
    static int drawSelector(sf::FloatRect rect, string text, float text_size = 30);

    /*!
     * Draw a disabled slector object; two arrows, one left, other right
     * \param rect Area to draw in
     * \param text Text on the selector
     * \param text_size Size of text
     */
    static void drawDisabledSelector(sf::FloatRect rect, string text, float text_size = 30);

    /*!
     * Draw a box with border
     * \param rect Area to draw in
     * \param border_color Color of border
     */
    static void drawBox(sf::FloatRect rect, sf::Color border_color=sf::Color::White);

    /*!
     * Draw a box with background
     * \param rect Area to draw in
     * \param border_color Color of border
     * \param background_color Color of background
     */
    static void drawBoxWithBackground(sf::FloatRect rect, sf::Color border_color=sf::Color::White, sf::Color backround_color=sf::Color::Black);

    /*!
     * Draw a box with text in it
     * \param rect Area to draw in
     * \param color Color of the text
     */
    static void drawTextBox(sf::FloatRect rect, string text, EAlign align = AlignTopLeft, float text_size = 30, sf::Color color=sf::Color::White);

    /*!
     * Draw a box with background with text in it
     * \param rect Area to draw in
     * \param color Color of the text
     */
    static void drawTextBoxWithBackground(sf::FloatRect rect, string text, EAlign align = AlignTopLeft, float text_size = 30, sf::Color color=sf::Color::White, sf::Color bg_color=sf::Color::Black);

    /*!
     * Draw a scrollable textbox.
     */
    static int drawScrollableTextBox(sf::FloatRect rect, string text, int start_line_nr, EAlign align = AlignTopLeft, float text_size = 30, sf::Color color=sf::Color::White);

    /*!
     * Draw a field where user can enter text.
     * Note that this component can not have focus. If there are multiple, all input will go to both!
     * \return string text in field.
     */
    static string drawTextEntry(sf::FloatRect rect, string value, float font_size = 30);

    /*!
     * Draw a key value pair display. Used a lot for science UI.
     */
    static void drawKeyValueDisplay(sf::FloatRect, float div_distance, string key, string value, float text_size = 30.0f);

    static sf::RenderTarget* getRenderTarget() { return renderTarget; }
    static sf::Vector2f getWindowSize() { return windowSize; }

private:
    static void draw9Cut(sf::FloatRect rect, string texture, sf::Color color=sf::Color::White, float width_factor = 1.0);
    static bool drawArrow(sf::FloatRect rect, bool disabled=false, float rotation=0.0);
};

class MouseRenderer : public Renderable
{
public:
    bool visible;

    MouseRenderer();

    virtual void render(sf::RenderTarget& window);
};

#endif//GUI_H
