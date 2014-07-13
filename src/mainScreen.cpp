#include "mainScreen.h"
#include "shipSelectionScreen.h"
#include "main.h"

MainScreenUI::MainScreenUI()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    if (mouseRenderer) mouseRenderer->visible = false;
}

void MainScreenUI::onGui()
{
    if (mySpaceship)
    {
        switch(mySpaceship->mainScreenSetting)
        {
        case MSS_Front:
        case MSS_Back:
        case MSS_Left:
        case MSS_Right:
            draw3Dworld();
            break;
        case MSS_Tactical:
            renderTactical(*getRenderTarget());
            break;
        case MSS_LongRange:
            renderLongRange(*getRenderTarget());
            break;
        }
    }else{
        draw3Dworld();
    }
    
    MainUIBase::onGui();
}

void MainScreenUI::destroy()
{
    P<MouseRenderer> mouseRenderer = engine->getObject("mouseRenderer");
    if (mouseRenderer) mouseRenderer->visible = true;
    MainUIBase::destroy();
}

void MainScreenUI::renderTactical(sf::RenderTarget& window)
{
    drawRadar(sf::Vector2f(800, 450), 400, 5000, false, mySpaceship->getTarget());
}

void MainScreenUI::renderLongRange(sf::RenderTarget& window)
{
    drawRadar(sf::Vector2f(800, 450), 400, 50000, true, NULL);
}
