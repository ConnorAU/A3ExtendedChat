/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

// ~ Variables 
#define VAR_HISTORY VAR(message_history)
#define VAR_NEW_MESSAGE_PENDING VAR(new_message_pending)
#define VAR_MESSAGE_FEED_CTRLS VAR(message_feed_ctrls)
#define VAR_MESSAGE_FEED_DISPLAY VAR(message_feed_display)
#define VAR_MESSAGE_FEED_POS VAR(message_feed_pos)
#define VAR_MESSAGE_FEED_SHOWN VAR(message_feed_shown)
#define VAR_COMMAND_CODE_PREFIX VAR(_command_)
#define VAR_VON_SPEAKERS_CTRL VAR(ctrl_von_speakers)
#define VAR_UNIT_NAME VAR(unit_name)
#define VAR_MESSAGE_SENT_COOLDOWN VAR(message_sent_cooldown)

#define VAR_ENABLE_EMOJIS VAR(enable_emojis)
#define VAR_ENABLE_LOGGING VAR(enable_logging)
#define VAR_ENABLE_VON_CTRL VAR(enable_von_ctrl)

// ~ Operations
#define QUOTE(a) #a

#define SWITCH_SYS_PARAMS params[["_mode","",[""]],["_params",[]]]

#define UNIT_NAME(unit) unit getVariable [QUOTE(VAR_UNIT_NAME),"Error: No name"]

#ifdef DISPLAY_NAME
    #define THIS_DISPLAY DISPLAY(DISPLAY_NAME)
#endif
#define DISPLAY(name) uiNamespace getVariable [QUOTE(name),displayNull]
#define USE_DISPLAY(display) private _display = display
#define USE_CTRL(ctrl,idc) private ctrl = _display displayCtrl idc

// ~ Functions
#define FUNC_PREFIX CAU_xChat
#define FUNC(suffix) FUNC_PREFIX##_fnc_##suffix
#define VAR(suffix) FUNC_PREFIX##_##suffix

#ifdef THIS_FUNC
    #define FUNC_SUBVAR(suffix) THIS_FUNC##_##suffix
#endif

// ~ UI Positioning
#ifdef pixelScale
    // Mission UIs were built using small UI scale.
    // These values are used to properly scale UIs for different sizes.
    #define GRID_W_SCALE (0.00126263 * 8 * 0.50)
    #define GRID_H_SCALE (0.0016835 * 8 * 0.50)

    #define PX_WA(n) n*GRID_W
    #define PX_HA(n) n*GRID_H
    #define CENTER_XA(n) (CENTER_X)-(0.5*(PX_WA(n)))
    #define CENTER_YA(n) (CENTER_Y)-(0.5*(PX_HA(n)))

    #define PX_WS(n) n*(GRID_W*(GRID_W_SCALE/GRID_W))
    #define PX_HS(n) n*(GRID_H*(GRID_H_SCALE/GRID_H))
    #define CENTER_XS(n) (CENTER_X)-(0.5*(PX_WS(n)))
    #define CENTER_YS(n) (CENTER_Y)-(0.5*(PX_HS(n)))
#endif

// ~ Settings
#define VAR_SETTINGS QUOTE(VAR(settings))
#define VAL_SETTINGS_INDEX_COMMAND_PREFIX               1
#define VAL_SETTINGS_INDEX_MAX_SAVED                    2
#define VAL_SETTINGS_INDEX_MAX_PRINTED                  3
#define VAL_SETTINGS_INDEX_TTL_PRINTED                  4
#define VAL_SETTINGS_INDEX_PRINT_CONNECTED              5
#define VAL_SETTINGS_INDEX_PRINT_DISCONNECTED           6
#define VAL_SETTINGS_INDEX_PRINT_KILL                   7
#define VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION    8
#define VAL_SETTINGS_INDEX_PRINT_GLOBAL                 9
#define VAL_SETTINGS_INDEX_PRINT_SIDE                   10
#define VAL_SETTINGS_INDEX_PRINT_COMMAND                11
#define VAL_SETTINGS_INDEX_PRINT_GROUP                  12
#define VAL_SETTINGS_INDEX_PRINT_VEHICLE                13
#define VAL_SETTINGS_INDEX_PRINT_DIRECT                 14
#define VAL_SETTINGS_INDEX_PRINT_CUSTOM                 15