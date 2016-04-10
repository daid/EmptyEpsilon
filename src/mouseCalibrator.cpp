#include "mouseCalibrator.h"
#include "main.h"

MouseCalibrator::MouseCalibrator(string filename)
: filename(filename)
{
    state = 0;
    InputHandler::mouse_transform = sf::Transform();
    
    (new GuiLabel(this, "MAIN_LABEL", "Touch Calibration", 50))->setPosition(0, 100, ATopCenter)->setSize(0, 300);
    screen_box[0] = new GuiPanel(this, "BOX_0");
    screen_box[0]->setPosition(50, 50, ATopLeft)->setSize(50, 50);
    screen_box[1] = new GuiPanel(this, "BOX_1");
    screen_box[1]->setPosition(-50, 50, ATopRight)->setSize(50, 50);
    screen_box[2] = new GuiPanel(this, "BOX_2");
    screen_box[2]->setPosition(-50, -50, ABottomRight)->setSize(50, 50);
    ready_button = new GuiButton(this, "READY_BUTTON", "Finished", [this]() {
        destroy();
        returnToMainMenu();
    });
    ready_button->setPosition(0, -100, ABottomCenter)->setSize(300, 100)->hide();

    test_box = new GuiImage(this, "TEST", "gui/PanelBackground");
    test_box->setPosition(0, 0, ATopLeft)->setSize(50, 50);
    
    screen_box[1]->hide();
    screen_box[2]->hide();
    test_box->hide();
}

void MouseCalibrator::update(float delta)
{
    if (InputHandler::mouseIsReleased(sf::Mouse::Left))
    {
        if (state < 3)
        {
            mouse_point[state] = InputHandler::getMousePos();
            screen_box[state]->hide();
            state ++;
            if (state < 3)
            {
                screen_box[state]->show();
            }else{
                ready_button->show();
                calculateMatrix();
            }
        }
    }
    if (state > 2)
    {
        if (InputHandler::getMousePos().x >= 0.0)
        {
            test_box->setPosition(InputHandler::getMousePos() - sf::Vector2f(25, 25));
            test_box->show();
        }else{
            test_box->hide();
        }
    }
}

void MouseCalibrator::calculateMatrix()
{
    sf::Vector2f screen_point[3];
    for(int n=0; n<3; n++)
    {
        screen_point[n] = screen_box[n]->getCenterPoint();
    }
    
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
    if (f)
    {
        fprintf(f, "%f %f %f %f %f %f\n", A/Q, B/Q, C/Q, D/Q, E/Q, F/Q);
        fclose(f);
    }
}
