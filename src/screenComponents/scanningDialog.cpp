#include "scanningDialog.h"
#include "i18n.h"
#include "playerInfo.h"
#include "random.h"
#include "components/scanning.h"
#include "engine.h"
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
    box->setSize(500, 545)->setPosition(0, 0, sp::Alignment::Center);

    signal_label = new GuiLabel(box, id + "_LABEL", tr("scanning", "Electric signature"), 30);
    signal_label->addBackground()->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(450, 50);

    signal_quality = new GuiSignalQualityIndicator(box, id + "_SIGNAL");
    signal_quality->setPosition(0, 80, sp::Alignment::TopCenter)->setSize(450, 100);

    locked_label = new GuiLabel(signal_quality, id + "_LOCK_LABEL", tr("scanning", "LOCKED"), 50);
    locked_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    for(int n=0; n<max_sliders; n++)
    {
        sliders[n] = new GuiSlider(box, id + "_SLIDER_" + string(n), 0.0, 1.0, 0.0, nullptr);
        sliders[n]->setPosition(0, 200 + n * 70, sp::Alignment::TopCenter)->setSize(450, 50);
    }
    cancel_button = new GuiButton(box, id + "_CANCEL", tr("button", "Cancel"), []() {
        if (my_spaceship)
            my_player_info->commandScanCancel();
    });
    cancel_button->setPosition(0, -20, sp::Alignment::BottomCenter)->setSize(300, 50);

    setupParameters();
}

void GuiScanningDialog::onDraw(sp::RenderTarget& target)
{
    updateSignal();

    auto [complexity, depth] = getScanComplexityDepth();
    if (complexity > 0 && depth > 0)
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
            if (scan_depth >= depth)
            {
                my_player_info->commandScanDone();
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

void GuiScanningDialog::onUpdate()
{
    if(my_spaceship && isVisible())
    {
        for(int n=0; n<max_sliders; n++)
        {
            float adjust = (keys.science_scan_param_increase[n].getValue() - keys.science_scan_param_decrease[n].getValue()) * 0.01f;
            if (adjust != 0.0f)
            {
                sliders[n]->setValue(sliders[n]->getValue() + adjust);
                updateSignal();
            }

            float set_value = keys.science_scan_param_set[n].getValue();
            if (set_value != sliders[n]->getValue() && (set_value != 0.0f || set_active[n]))
            {
                sliders[n]->setValue(set_value);
                updateSignal();
                set_active[n] = set_value != 0.0f; //Make sure the next update is send, even if it is back to zero.
            }
        }
    }
}

void GuiScanningDialog::setupParameters()
{
    auto [complexity, depth] = getScanComplexityDepth();

    for(int n=0; n<max_sliders; n++)
    {
        if (n < complexity)
            sliders[n]->show();
        else
            sliders[n]->hide();
    }
    box->setSize(500, 265 + 70 * complexity);

    for(int n=0; n<max_sliders; n++)
    {
        target[n] = random(0.0, 1.0);
        sliders[n]->setValue(random(0.0, 1.0));
        while(fabsf(target[n] - sliders[n]->getValue()) < 0.2f)
            sliders[n]->setValue(random(0.0, 1.0));
    }
    updateSignal();

    string label = "[" + string(scan_depth + 1) + "/" + string(depth) + "] ";
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

std::pair<int, int> GuiScanningDialog::getScanComplexityDepth()
{
    auto ss = my_spaceship.getComponent<ScienceScanner>();
    if (!ss)
        return {0, 0};
    if (!ss->target)
        return {0, 0};
    auto scanstate = ss->target.getComponent<ScanState>();
    if (!scanstate)
        return {0, 0};
    auto complexity = scanstate->complexity;
    auto depth = scanstate->depth;
    if (complexity < 0) {
        switch(gameGlobalInfo->scanning_complexity) {
        case SC_None:
            complexity = 0;
            break;
        case SC_Simple:
            complexity = 1;
            break;
        case SC_Normal:
            if (scanstate->getStateFor(my_spaceship) == ScanState::State::SimpleScan)
                complexity = 2;
            else
                complexity = 1;
            break;
        case SC_Advanced:
            if (scanstate->getStateFor(my_spaceship) == ScanState::State::SimpleScan)
                complexity = 3;
            else
                complexity = 2;
            break;
        }
    }
    if (depth < 0) {
        switch(gameGlobalInfo->scanning_complexity) {
        case SC_None:
        case SC_Simple:
            depth = 1;
            break;
        case SC_Normal:
        case SC_Advanced:
            depth = 2;
            break;
        }
    }
    return {complexity, depth};
}
