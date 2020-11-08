// ~ Variables
#define VAR_HISTORY VAR(messageHistory)
#define VAR_NEW_MESSAGE_PENDING VAR(newMessagePending)
#define VAR_MESSAGE_FEED_CTRLS VAR(messageFeedCtrls)
#define VAR_MESSAGE_FEED_DISPLAY VAR(messageFeedDisplay)
#define VAR_MESSAGE_FEED_POS VAR(messageFeedPos)
#define VAR_MESSAGE_FEED_POS_X VAR(messageFeedPosX)
#define VAR_MESSAGE_FEED_SHOWN VAR(messageFeedShown)
#define VAR_MESSAGE_FEED_INSTANT_COMMIT VAR(messageFeedInstantCommit)
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
#define UNIT_OID(unit) unit getVariable [QUOTE(VAR_UNIT_OWNER_ID),-1]

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
#define VAL_SETTINGS_KEY_VERSION                           "version"
#define VAL_SETTINGS_KEY_COMMAND_PREFIX                    "command_prefix"
#define VAL_SETTINGS_KEY_MAX_SAVED                         "max_saved"
#define VAL_SETTINGS_KEY_MAX_PRINTED                       "max_printed"
#define VAL_SETTINGS_KEY_TTL_PRINTED                       "ttl_printed"
#define VAL_SETTINGS_KEY_AUTOCOMPLETE_KEYBIND              "autocomplete_keybind"
#define VAL_SETTINGS_KEY_TOGGLE_CHAT_FEED_KEYBIND          "toggle_chat_feed_keybind"
#define VAL_SETTINGS_KEY_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE  "hide_chat_feed_onload_streamsafe"
#define VAL_SETTINGS_KEY_TEXT_FONT                         "text_font"
#define VAL_SETTINGS_KEY_TEXT_SIZE                         "text_size"
#define VAL_SETTINGS_KEY_TEXT_COLOR                        "text_color"
#define VAL_SETTINGS_KEY_FEED_BG_COLOR                     "feed_bg_color"
#define VAL_SETTINGS_KEY_TEXT_MENTION_COLOR                "text_mention_color"
#define VAL_SETTINGS_KEY_FEED_MENTION_BG_COLOR             "feed_mention_bg_color"
#define VAL_SETTINGS_KEY_PRINT_CONNECTED                   "print_connected"
#define VAL_SETTINGS_KEY_PRINT_DISCONNECTED                "print_disconnected"
#define VAL_SETTINGS_KEY_PRINT_BATTLEYE_KICK               "print_battleye_kick"
#define VAL_SETTINGS_KEY_PRINT_DEATH                       "print_death"
#define VAL_SETTINGS_KEY_PRINT_GLOBAL                      "print_global"
#define VAL_SETTINGS_KEY_PRINT_SIDE                        "print_side"
#define VAL_SETTINGS_KEY_PRINT_COMMAND                     "print_command"
#define VAL_SETTINGS_KEY_PRINT_GROUP                       "print_group"
#define VAL_SETTINGS_KEY_PRINT_VEHICLE                     "print_vehicle"
#define VAL_SETTINGS_KEY_PRINT_DIRECT                      "print_direct"
#define VAL_SETTINGS_KEY_PRINT_CUSTOM                      "print_custom"
#define VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER               "bad_language_filter"
#define VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER_TERMS         "bad_language_filter_terms"
#define VAL_SETTINGS_KEY_WEBSITE_WHITELIST                 "website_whitelist"
#define VAL_SETTINGS_KEY_WEBSITE_WHITELIST_TERMS           "website_whitelist_terms"
#define VAL_SETTINGS_KEY_MUTED_PLAYERS                     "muted_players"
