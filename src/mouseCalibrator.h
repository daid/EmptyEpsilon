#ifndef MOUSE_CALIBRATOR_H
#define MOUSE_CALIBRATOR_H

#include "gui/gui.h"

class MouseCalibrator : public GUI
{
    string filename;
    int state;
    sf::Vector2f screen_point[3];
    sf::Vector2f mouse_point[3];
public:
    MouseCalibrator(string filename);

    virtual void onGui();
    
    void calculateMatrix();
};

#endif//MOUSE_CALIBRATOR_H
