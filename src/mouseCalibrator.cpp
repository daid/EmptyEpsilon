#include "mouseCalibrator.h"

MouseCalibrator::MouseCalibrator(string filename)
: filename(filename)
{
    state = 0;
    InputHandler::mouse_transform = sf::Transform();
}

void MouseCalibrator::onGui()
{
    drawText(sf::FloatRect(0, 100, getWindowSize().x, 300), "Touch Calibration", AlignCenter, 50);

    switch(state)
    {
    case 0:
        drawBox(sf::FloatRect(50, 50, 50, 50));
        if (InputHandler::mouseIsReleased(sf::Mouse::Left))
        {
            screen_point[0] = sf::Vector2f(75, 75);
            mouse_point[0] = InputHandler::getMousePos();
            state = 1;
        }
        break;
    case 1:
        drawBox(sf::FloatRect(getWindowSize().x - 100, 50, 50, 50));
        if (InputHandler::mouseIsReleased(sf::Mouse::Left))
        {
            screen_point[1] = sf::Vector2f(getWindowSize().x - 75, 75);
            mouse_point[1] = InputHandler::getMousePos();
            state = 2;
        }
        break;
    case 2:
        drawBox(sf::FloatRect(50, getWindowSize().y - 100, 50, 50));
        if (InputHandler::mouseIsReleased(sf::Mouse::Left))
        {
            screen_point[2] = sf::Vector2f(75, getWindowSize().y - 75);
            mouse_point[2] = InputHandler::getMousePos();
            state = 3;
            calculateMatrix();
        }
        break;
    case 3:
        break;
    }

    {
        sf::Vector2f pos = InputHandler::getMousePos();
        drawText(sf::FloatRect(0, 300, getWindowSize().x, 300), string(pos.x) + " " + string(pos.y), AlignCenter, 50);
    }
}

void MouseCalibrator::calculateMatrix()
{
    float Q = ((mouse_point[0].x - mouse_point[2].x) * (mouse_point[1].y - mouse_point[2].y)) - ((mouse_point[1].x - mouse_point[2].x) * (mouse_point[0].y - mouse_point[2].y));

    if( Q == 0.0 )
        return;
    float A = ((screen_point[0].x - screen_point[2].x) * (mouse_point[1].y - mouse_point[2].y)) - ((screen_point[1].x - screen_point[2].x) * (mouse_point[0].y - mouse_point[2].y));
    float B = ((mouse_point[0].x - mouse_point[2].x) * (screen_point[1].x - screen_point[2].x)) - ((screen_point[0].x - screen_point[2].x) * (mouse_point[1].x - mouse_point[2].x));
    float C = (mouse_point[2].x * screen_point[1].x - mouse_point[1].x * screen_point[2].x) * mouse_point[0].y + (mouse_point[0].x * screen_point[2].x - mouse_point[2].x * screen_point[0].x) * mouse_point[1].y + (mouse_point[1].x * screen_point[0].x - mouse_point[0].x * screen_point[1].x) * mouse_point[2].y;
    float D = ((screen_point[0].y - screen_point[2].y) * (mouse_point[1].y - mouse_point[2].y)) - ((screen_point[1].y - screen_point[2].y) * (mouse_point[0].y - mouse_point[2].y));
    float E = ((mouse_point[0].x - mouse_point[2].x) * (screen_point[1].y - screen_point[2].y)) - ((screen_point[0].y - screen_point[2].y) * (mouse_point[1].x - mouse_point[2].x));
    float F = (mouse_point[2].x * screen_point[1].y - mouse_point[1].x * screen_point[2].y) * mouse_point[0].y + (mouse_point[0].x * screen_point[2].y - mouse_point[2].x * screen_point[0].y) * mouse_point[1].y + (mouse_point[1].x * screen_point[0].y - mouse_point[0].x * screen_point[1].y) * mouse_point[2].y;

    InputHandler::mouse_transform = sf::Transform(A/Q, B/Q, C/Q, D/Q, E/Q, F/Q, 0, 0, 1);
    FILE* f = fopen(filename.c_str(), "w");
    fprintf(f, "%f %f %f %f %f %f\n", A/Q, B/Q, C/Q, D/Q, E/Q, F/Q);
    fclose(f);
}
