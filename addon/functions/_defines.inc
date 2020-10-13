// ~ Variables
#define VAR_HISTORY VAR(messageHistory)
#define VAR_NEW_MESSAGE_PENDING VAR(newMessagePending)
#define VAR_MESSAGE_FEED_CTRLS VAR(messageFeedCtrls)
#define VAR_MESSAGE_FEED_DISPLAY VAR(messageFeedDisplay)
#define VAR_MESSAGE_FEED_POS VAR(messageFeedPos)
#define VAR_MESSAGE_FEED_SHOWN VAR(messageFeedShown)
#define VAR_COMMANDS_ARRAY VAR(commands)
#define VAR_VON_SPEAKERS_CTRL VAR(ctrlVonSpeakers)
#define VAR_UNIT_NAME VAR(unitName)
#define VAR_UNIT_OWNER_ID VAR(unitOwnerID)
#define VAR_CHAT_OVERLAY_DISPLAY VAR(chatOverlayDisplay)
#define VAR_HANDLE_MESSAGE_PRINT_CONDITION VAR(handleChatMessage_printCondition)

#define VAR_ENABLE_EMOJIS VAR(enableEmojis)
#define VAR_ENABLE_LOGGING VAR(enableLogging)
#define VAR_ENABLE_VON_CTRL VAR(enableVonCtrl)

// ~ Operations
#define QUOTE(a) #a

#define SWITCH_SYS_PARAMS params[["_mode","",[""]],["_params",[]]]

#define UNIT_NAME(unit) unit getVariable [QUOTE(VAR_UNIT_NAME),name unit]

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
    #define PXW(n) (n*GRID_W)
    #define PXH(n) (n*GRID_H)
    #define PXCX(n) (CENTER_X-(0.5*PXW(n)))
    #define PXCY(n) (CENTER_Y-(0.5*PXH(n)))
#endif

// ~ Settings
#define VAR_SETTINGS QUOTE(VAR(settings))
#define VAL_SETTINGS_INDEX_COMMAND_PREFIX               1
#define VAL_SETTINGS_INDEX_MAX_SAVED                    2
#define VAL_SETTINGS_INDEX_MAX_PRINTED                  3
#define VAL_SETTINGS_INDEX_TTL_PRINTED                  4
#define VAL_SETTINGS_INDEX_TEXT_FONT                    5
#define VAL_SETTINGS_INDEX_TEXT_SIZE                    6
#define VAL_SETTINGS_INDEX_TEXT_COLOR                   7
#define VAL_SETTINGS_INDEX_FEED_BG_COLOR                8
#define VAL_SETTINGS_INDEX_PRINT_CONNECTED              9
#define VAL_SETTINGS_INDEX_PRINT_DISCONNECTED           10
#define VAL_SETTINGS_INDEX_PRINT_KILL                   11
#define VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION    12
#define VAL_SETTINGS_INDEX_PRINT_GLOBAL                 13
#define VAL_SETTINGS_INDEX_PRINT_SIDE                   14
#define VAL_SETTINGS_INDEX_PRINT_COMMAND                15
#define VAL_SETTINGS_INDEX_PRINT_GROUP                  16
#define VAL_SETTINGS_INDEX_PRINT_VEHICLE                17
#define VAL_SETTINGS_INDEX_PRINT_DIRECT                 18
#define VAL_SETTINGS_INDEX_PRINT_CUSTOM                 19
