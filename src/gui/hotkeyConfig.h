#ifndef HOTKEY_CONFIG_H
#define HOTKEY_CONFIG_H

#include <tuple>
#include <array>
#include <SDL.h>
#include <io/keybinding.h>
#include "stringImproved.h"

class Keys
{
public:
    Keys();
    void init();

    //Basic
    sp::io::Keybinding pause;
    sp::io::Keybinding help;
    sp::io::Keybinding escape;
    sp::io::Keybinding zoom_in;
    sp::io::Keybinding zoom_out;
    sp::io::Keybinding voice_all;
    sp::io::Keybinding voice_ship;

    //General
    sp::io::Keybinding next_station;
    sp::io::Keybinding prev_station;
    sp::io::Keybinding station_helms;
    sp::io::Keybinding station_weapons;
    sp::io::Keybinding station_engineering;
    sp::io::Keybinding station_science;
    sp::io::Keybinding station_relay;

    //Main screen
    sp::io::Keybinding mainscreen_forward;
    sp::io::Keybinding mainscreen_left;
    sp::io::Keybinding mainscreen_right;
    sp::io::Keybinding mainscreen_back;
    sp::io::Keybinding mainscreen_target;
    sp::io::Keybinding mainscreen_tactical_radar;
    sp::io::Keybinding mainscreen_long_range_radar;
    sp::io::Keybinding mainscreen_first_person;

    //helms
    sp::io::Keybinding helms_increase_impulse;
    sp::io::Keybinding helms_decrease_impulse;
    sp::io::Keybinding helms_set_impulse;
    sp::io::Keybinding helms_zero_impulse;
    sp::io::Keybinding helms_max_impulse;
    sp::io::Keybinding helms_min_impulse;
    sp::io::Keybinding helms_turn_left;
    sp::io::Keybinding helms_turn_right;
    sp::io::Keybinding helms_warp0;
    sp::io::Keybinding helms_warp1;
    sp::io::Keybinding helms_warp2;
    sp::io::Keybinding helms_warp3;
    sp::io::Keybinding helms_warp4;
    sp::io::Keybinding helms_increase_warp;
    sp::io::Keybinding helms_decrease_warp;
    sp::io::Keybinding helms_dock_action;
    sp::io::Keybinding helms_dock_request;
    sp::io::Keybinding helms_dock_abort;
    sp::io::Keybinding helms_undock;
    sp::io::Keybinding helms_increase_jump_distance;
    sp::io::Keybinding helms_decrease_jump_distance;
    sp::io::Keybinding helms_execute_jump;
    sp::io::Keybinding helms_combat_left;
    sp::io::Keybinding helms_combat_right;
    sp::io::Keybinding helms_combat_boost;

    //weapons
    sp::io::Keybinding weapons_select_homing;
    sp::io::Keybinding weapons_select_nuke;
    sp::io::Keybinding weapons_select_mine;
    sp::io::Keybinding weapons_select_emp;
    sp::io::Keybinding weapons_select_hvli;
    std::array<sp::io::Keybinding, 16> weapons_load_tube;
    std::array<sp::io::Keybinding, 16> weapons_unload_tube;
    std::array<sp::io::Keybinding, 16> weapons_fire_tube;
    sp::io::Keybinding weapons_enemy_next_target;
    sp::io::Keybinding weapons_next_target;
    sp::io::Keybinding weapons_toggle_shields;
    sp::io::Keybinding weapons_enable_shields;
    sp::io::Keybinding weapons_disable_shields;
    sp::io::Keybinding weapons_shield_calibration_increase;
    sp::io::Keybinding weapons_shield_calibration_decrease;
    sp::io::Keybinding weapons_shield_calibration_start;
    sp::io::Keybinding weapons_beam_subsystem_target_next;
    sp::io::Keybinding weapons_beam_subsystem_target_previous;
    sp::io::Keybinding weapons_beam_frequence_increase;
    sp::io::Keybinding weapons_beam_frequence_decrease;
    sp::io::Keybinding weapons_toggle_aim_lock;
    sp::io::Keybinding weapons_enable_aim_lock;
    sp::io::Keybinding weapons_disable_aim_lock;
    sp::io::Keybinding weapons_aim_left;
    sp::io::Keybinding weapons_aim_right;

    //Science
    sp::io::Keybinding science_scan_object;
    sp::io::Keybinding science_select_next_scannable;
    std::array<sp::io::Keybinding, 4> science_scan_param_increase;
    std::array<sp::io::Keybinding, 4> science_scan_param_decrease;

    //Engineering
    sp::io::Keybinding engineering_select_reactor;
    sp::io::Keybinding engineering_select_beam_weapons;
    sp::io::Keybinding engineering_select_missile_system;
    sp::io::Keybinding engineering_select_maneuvering_system;
    sp::io::Keybinding engineering_select_impulse_system;
    sp::io::Keybinding engineering_select_warp_system;
    sp::io::Keybinding engineering_select_jump_drive_system;
    sp::io::Keybinding engineering_select_front_shield_system;
    sp::io::Keybinding engineering_select_rear_shield_system;
    sp::io::Keybinding engineering_set_power_000;
    sp::io::Keybinding engineering_set_power_030;
    sp::io::Keybinding engineering_set_power_050;
    sp::io::Keybinding engineering_set_power_100;
    sp::io::Keybinding engineering_set_power_150;
    sp::io::Keybinding engineering_set_power_200;
    sp::io::Keybinding engineering_set_power_250;
    sp::io::Keybinding engineering_set_power_300;
    sp::io::Keybinding engineering_increase_power;
    sp::io::Keybinding engineering_decrease_power;
    sp::io::Keybinding engineering_increase_coolant;
    sp::io::Keybinding engineering_decrease_coolant;
    sp::io::Keybinding engineering_next_repair_crew;
    sp::io::Keybinding engineering_repair_crew_up;
    sp::io::Keybinding engineering_repair_crew_down;
    sp::io::Keybinding engineering_repair_crew_left;
    sp::io::Keybinding engineering_repair_crew_right;
    sp::io::Keybinding engineering_self_destruct_start;
    sp::io::Keybinding engineering_self_destruct_confirm;
    sp::io::Keybinding engineering_self_destruct_cancel;

    //Relay
    sp::io::Keybinding relay_alert_level_none;
    sp::io::Keybinding relay_alert_level_yellow;
    sp::io::Keybinding relay_alert_level_red;

    // Cinematic View
    struct CinematicKeys {
        CinematicKeys();
        void init();
        sp::io::Keybinding toggle_ui;
        sp::io::Keybinding lock_camera;
        sp::io::Keybinding cycle_camera;
        sp::io::Keybinding previous_player_ship;
        sp::io::Keybinding next_player_ship;
        sp::io::Keybinding move_forward;
        sp::io::Keybinding move_backward;
        sp::io::Keybinding strafe_left;
        sp::io::Keybinding strafe_right;
        sp::io::Keybinding move_up;
        sp::io::Keybinding move_down;
        sp::io::Keybinding rotate_left;
        sp::io::Keybinding rotate_right;
        sp::io::Keybinding tilt_down;
        sp::io::Keybinding tilt_up;
    } cinematic;

    // Top-down View
    struct TopDownKeys {
        TopDownKeys();
        void init();
        sp::io::Keybinding toggle_ui;
        sp::io::Keybinding lock_camera;
        sp::io::Keybinding previous_player_ship;
        sp::io::Keybinding next_player_ship;
        sp::io::Keybinding pan_up;
        sp::io::Keybinding pan_down;
        sp::io::Keybinding pan_left;
        sp::io::Keybinding pan_right;
    } topdown;
   

    //GM
    sp::io::Keybinding gm_delete;
    sp::io::Keybinding gm_clipboardcopy;

    //Various
    sp::io::Keybinding spectator_show_callsigns;

    //Debug
    sp::io::Keybinding debug_show_fps;
    sp::io::Keybinding debug_show_timing;
};
extern Keys keys;

#endif//HOTKEY_CONFIG_H
