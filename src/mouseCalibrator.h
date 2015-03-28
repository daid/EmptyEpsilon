#ifndef MOUSE_CALIBRATOR_H
#define MOUSE_CALIBRATOR_H

#include "gui/gui.h"
/*!
 * \brief Calibrator used for touch screens.
 * It's possible to use empty epsilon with touch screens, which may or may not be correclty calibrated.
 * This simply sits in between the mouse events and translates them according to its calibration.
 */
class MouseCalibrator : public GUI
{
private:
    string filename;
    int state;
    sf::Vector2f screen_point[3];
    sf::Vector2f mouse_point[3];
public:
    MouseCalibrator(string filename);
    /*!
     * \brief Draw a gui to calibrate.
     */
    virtual void onGui();
    /*!
     * \brief Calculate the transformation matrix
     */
    void calculateMatrix();
};

#endif//MOUSE_CALIBRATOR_H
