#include "scanningDialog.h"
#include "spaceObjects/playerSpaceship.h"
#include "playerInfo.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/gui2_button.h"

GuiScanningDialog::GuiScanningDialog(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    locked = false;
    lock_start_time = 0;
    scan_depth = 0;

    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    box = new GuiPanel(this, id + "_BOX");
    box->setSize(500, 545)->setPosition(0, 0, ACenter);

    signal_label = new GuiLabel(box, id + "_LABEL", tr("scanning", "Electric signature"), 30);
    signal_label->addBackground()->setPosition(0, 20, ATopCenter)->setSize(450, 50);

    signal_quality = new GuiSignalQualityIndicator(box, id + "_SIGNAL");
    signal_quality->setPosition(0, 80, ATopCenter)->setSize(450, 100);

    locked_label = new GuiLabel(signal_quality, id + "_LOCK_LABEL", tr("scanning", "LOCKED"), 50);
    locked_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    for(int n=0; n<max_sliders; n++)
    {
        sliders[n] = new GuiSlider(box, id + "_SLIDER_" + string(n), 0.0, 1.0, 0.0, nullptr);
        sliders[n]->setPosition(0, 200 + n * 70, ATopCenter)->setSize(450, 50);
    }
    cancel_button = new GuiButton(box, id + "_CANCEL", tr("button", "Cancel"), []() {
        if (my_spaceship)
            my_spaceship->commandScanCancel();
    });
    cancel_button->setPosition(0, -20, ABottomCenter)->setSize(300, 50);

    setupParameters();
}

void GuiScanningDialog::onDraw(sf::RenderTarget& window)
{
    updateSignal();

    if (my_spaceship)
    {
        if (my_spaceship->scanning_delay > 0.0 && my_spaceship->scanning_complexity > 0)
        {
            if (!box->isVisible())
            {
                box->show();
                scan_depth = 0;
                setupParameters();
            }

            if (locked && engine->getElapsedTime() - lock_start_time > lock_delay)
            {
                scan_depth += 1;
                if (scan_depth >= my_spaceship->scanning_depth)
                {
                    my_spaceship->commandScanDone();
                    lock_start_time = engine->getElapsedTime() - 1.0f;
                }else{
                    setupParameters();
                }
            }

            if (locked && engine->getElapsedTime() - lock_start_time > lock_delay / 2.0f)
            {
                locked_label->show();
            }else{
                locked_label->hide();
            }
        }else{
            box->hide();
        }
    }
}
bool GuiScanningDialog::onJoystickAxis(const AxisAction& axisAction){
    if(my_spaceship){
        if (axisAction.category == "SCIENCE"){
            for(int n=0; n<max_sliders; n++) {
                if (axisAction.action == std::string("SCAN_PARAM_") + string(n+1)){
                    sliders[n]->setValue((axisAction.value + 1) / 2.0);
                    updateSignal();
                    return true;
                }
            }
        }
    }
    return false;
}

void GuiScanningDialog::setupParameters()
{
    if (!my_spaceship)
        return;

    for(int n=0; n<max_sliders; n++)
    {
        if (n < my_spaceship->scanning_complexity)
            sliders[n]->show();
        else
            sliders[n]->hide();
    }
    box->setSize(500, 265 + 70 * my_spaceship->scanning_complexity);

    for(int n=0; n<max_sliders; n++)
    {
        target[n] = random(0.0, 1.0);
        sliders[n]->setValue(random(0.0, 1.0));
        while(fabsf(target[n] - sliders[n]->getValue()) < 0.2)
            sliders[n]->setValue(random(0.0, 1.0));
    }
    updateSignal();

    string label = "[" + string(scan_depth + 1) + "/" + string(my_spaceship->scanning_depth) + "] ";
    switch(irandom(0, 10))
    {
    default:
    case 0: label += "Electric signature"; break;
    case 1: label += "Biomass frequency"; break;
    case 2: label += "Gravity well signature"; break;
    case 3: label += "Radiation halftime"; break;
    case 4: label += "Radio profile"; break;
    case 5: label += "Ionic phase shift"; break;
    case 6: label += "Infra-red color shift"; break;
    case 7: label += "Doppler stability"; break;
    case 8: label += "Raspberry jam prevention"; break;
    case 9: label += "Infinity impropability"; break;
    case 10: label += "Zerospace audio frequency"; break;
    }
    signal_label->setText(label);
}

void GuiScanningDialog::updateSignal()
{
    float noise = 0.0;
    float period = 0.0;
    float phase = 0.0;

    for(int n=0; n<max_sliders; n++)
    {
        if (sliders[n]->isVisible())
        {
            noise += fabsf(target[n] - sliders[n]->getValue());
            period += fabsf(target[n] - sliders[n]->getValue());
            phase += fabsf(target[n] - sliders[n]->getValue());
        }
    }
    if (noise < 0.05f && period < 0.05f && phase < 0.05f)
    {
        if (!locked)
        {
            lock_start_time = engine->getElapsedTime();
            locked = true;
        }
        if (engine->getElapsedTime() - lock_start_time > lock_delay / 2.0f)
        {
            noise = period = phase = 0.0f;
        }else{
            float f = 1.0f - (engine->getElapsedTime() - lock_start_time) / (lock_delay / 2.0f);
            noise *= f;
            period *= f;
            phase *= f;
        }
    }else{
        locked = false;
    }

    signal_quality->setNoiseError(noise);
    signal_quality->setPeriodError(period);
    signal_quality->setPhaseError(phase);
}
