#ifndef CREW_UI_H
#define CREW_UI_H

#include "gui/mainUIBase.h"
#include "playerInfo.h"
#include "spaceObjects/spaceship.h"
#include "repairCrew.h"

class CrewUI : public MainUIBase
{
public:
    CrewUI();

    virtual void onGui();
    virtual void onCrewUI();

    /**!
     * \brief Draw a freqency curve.
     * \param rect Rectangle
     * \param text_size
     */
    void drawImpulseSlider(sf::FloatRect rect, float text_size);

    /**!
     * \brief Draw the slider for warp drive.
     * \param rect Rectangle
     * \param text_size
     */
    void drawWarpSlider(sf::FloatRect rect, float text_size);

    /**!
     * \brief Draw the slider for jump drive.
     * \param jump_distance
     * \param rect Rectangle
     * \param text_size
     */
    void drawJumpSlider(float& jump_distance, sf::FloatRect rect, float text_size);

    /**!
     * \brief Draw activation button for jump drive.
     * \param jump_distance
     * \param rect Rectangle
     * \param text_size
     */
    void drawJumpButton(float jump_distance, sf::FloatRect rect, float text_size);

    /**!
     * \brief Draw activation button for docking.
     * \param rect Rectangle
     * \param text_size
     */
    void drawDockingButton(sf::FloatRect rect, float text_size);

    /**!
     * \brief Draw a weapon tube.
     * \param rect Rectangle
     * \param text_size
     */
    void drawWeaponTube(EMissileWeapons load_type, int n, float missile_target_angle, sf::FloatRect load_rect, sf::FloatRect fire_rect, float text_size);

    /**!
     * \brief Draw a freqency curve.
     * \param more_damage_is_positive True for weapons, false for shielding
     */
    int drawFrequencyCurve(sf::FloatRect rect, bool frequency_is_beam, bool more_damage_is_positive, int frequency);

    /**!
     * Draw state of system. (Jammed, no power, broken, etc)
     */
    void drawDamagePowerDisplay(sf::FloatRect rect, ESystem system, float text_size);

    /**!
     * Draw on screen keyboard.
     */
    string drawOnScreenKeyboard();
};

#endif//CREW_UI_H
