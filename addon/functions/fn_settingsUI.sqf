/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(settingsUI)
#define DISPLAY_NAME VAR(displaySettings)

#include "_macros.inc"
#include "_defines.inc"

#define DIALOG_W 150
#define DIALOG_H 104

#define IDC_BUTTON_SAVE_SETTINGS 			1
#define IDC_EDIT_COMMAND_PREFIX				2
#define IDC_COMBO_MAX_SAVED_LOGS 			3
#define IDC_COMBO_MAX_PRINTED_LOGS			4
#define IDC_COMBO_PRINTED_LOG_TTL			5
#define IDC_LABEL_TEXT_FONT					6
#define IDC_COMBO_TEXT_FONT					7
#define IDC_LABEL_TEXT_SIZE					8
#define IDC_SLIDER_TEXT_SIZE				9
#define IDC_LABEL_TEXT_COLOR				10
#define IDC_LABEL_FEED_BACKGROUND_COLOR		11
#define IDC_CB_LOG_CONNECT					13
#define IDC_CB_LOG_DISCONNECT				14
#define IDC_CB_LOG_KILLED					15
#define IDC_CB_CHANNEL_UNSUPPORTED_MISSION	16
#define IDC_CB_CHANNEL_GLOBAL				17
#define IDC_CB_CHANNEL_SIDE					18
#define IDC_CB_CHANNEL_COMMAND				19
#define IDC_CB_CHANNEL_GROUP				20
#define IDC_CB_CHANNEL_VEHICLE				21
#define IDC_CB_CHANNEL_DIRECT				22
#define IDC_CB_CHANNEL_CUSTOM				23

disableSerialization;
SWITCH_SYS_PARAMS;

switch _mode do {
	case "init":{
		USE_DISPLAY(findDisplay 49 createDisplay "RscDisplayEmpty");
		uiNamespace setVariable [QUOTE(DISPLAY_NAME),_display];

		{
			_x params ["_type","_idc","_position",["_init",{}]];
			private _ctrl = _display ctrlCreate [_type,_idc];
			_ctrl ctrlSetPosition _position;
			call _init;
			_ctrl ctrlCommit 0;
		} count [

		// ~~ Main Controls
			[// dummy ctrl because creating certain controls hides the first ctrl, thanks arma
				"ctrlStatic",-1,[0,0,0,0]
			],
			[
				"ctrlStaticBackgroundDisableTiles",-1,[
					getNumber(configFile >> "ctrlStaticBackgroundDisableTiles" >> "x"),
					getNumber(configFile >> "ctrlStaticBackgroundDisableTiles" >> "y"),
					getNumber(configFile >> "ctrlStaticBackgroundDisableTiles" >> "w"),
					getNumber(configFile >> "ctrlStaticBackgroundDisableTiles" >> "h")
				]
			],
			[
				"ctrlStaticBackground",-1,[
					CENTER_XA(DIALOG_W),
					CENTER_YA(DIALOG_H),
					PX_WA(DIALOG_W),
					PX_HA(DIALOG_H)
				]
			],
			[
				"ctrlStaticTitle",-1,[
					CENTER_XA(DIALOG_W),
					CENTER_YA(DIALOG_H),
					PX_WA(DIALOG_W),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_title";
				}
			],
			[
				"ctrlStaticFooter",-1,[
					CENTER_XA(DIALOG_W),
					CENTER_YA(DIALOG_H) + PX_HA(DIALOG_H) - PX_HA((SIZE_M + 2)),
					PX_WA(DIALOG_W),
					PX_HA((SIZE_M + 2))
				]
			],
			[
				"ctrlButtonClose",-1,[
					CENTER_XA(DIALOG_W) + PX_WA(DIALOG_W) - PX_WA(((SIZE_M * 5) + 1)),
					CENTER_YA(DIALOG_H) + PX_HA(DIALOG_H) - PX_HA((SIZE_M + 1)),
					PX_WA((SIZE_M * 5)),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlButton,IDC_BUTTON_SAVE_SETTINGS);
						if (ctrlEnabled _ctrlButton) then {
							[
								localize "STR_CAU_xChat_settings_pending_changes",
								localize "STR_CAU_xChat_settings_title",{
									if _confirmed then {
										USE_DISPLAY(THIS_DISPLAY);
										_display closeDisplay 2;
									};
								},"Discard","",_display
							] call CAU_UserInputMenus_fnc_guiMessage;
						} else {
							_display closeDisplay 2
						};
					}];
				}
			],
			[
				"ctrlButton",IDC_BUTTON_SAVE_SETTINGS,[
					CENTER_XA(DIALOG_W) + PX_WA(DIALOG_W) - PX_WA(((SIZE_M * 5) * 2)) - PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(DIALOG_H) - PX_HA((SIZE_M + 1)),
					PX_WA((SIZE_M * 5)),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_save_button";
					_ctrl ctrlEnable false;
					_ctrl ctrlAddEventHandler ["ButtonClick",{["ButtonSaveClicked"] call THIS_FUNC}];
				}
			],

		// ~~ Configuration 
			[
				"ctrlStaticBackground",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(DIALOG_H) - PX_HS(4) - PX_HA(SIZE_M) - PX_HA((SIZE_M + 2))
				],
				{
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.2];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_title";
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.4];
				}
			],
			[
				"ctrlStaticFrame",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(DIALOG_H) - PX_HS(4) - PX_HA(SIZE_M) - PX_HA((SIZE_M + 2))
				]
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA(SIZE_M),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_command_prefix_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_command_prefix_desc";
				}
			],
			[
				"RscEdit",IDC_EDIT_COMMAND_PREFIX,[
					CENTER_XA(DIALOG_W) + PX_WS(4),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(2) + PX_HA((SIZE_M*2)),
					PX_WA((DIALOG_W/2)) - PX_WS(7),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetFont FONT_NORMAL;
					_ctrl ctrlSetFontHeight PX_HS(4.32);
					_ctrl ctrlSetBackgroundColor [COLOR_TAB_RGBA];

					_ctrl ctrlSetText (["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["Char",{["EditChar"] call THIS_FUNC}];
					_ctrl ctrlAddEventHandler ["IMEChar",{["EditChar"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(3) + PX_HA((SIZE_M*3)),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_message_history_limit_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_message_history_limit_desc";
				}
			],
			[
				"ctrlCombo",IDC_COMBO_MAX_SAVED_LOGS,[
					CENTER_XA(DIALOG_W) + PX_WS(4),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(3) + PX_HA((SIZE_M*4)),
					PX_WA((DIALOG_W/2)) - PX_WS(7),
					PX_HA(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_INDEX_MAX_SAVED] call FUNC(settings);

					{
						_ctrl lbAdd format[localize "STR_CAU_xChat_settings_configuration_message_history_limit_option",_x];
						_ctrl lbSetValue [_forEachIndex,_x];
						if (_x == _setting) then {
							_ctrl lbSetCurSel _forEachIndex;
						};
					} forEach [2000,1500,1000,750,500,400,300,200,100];

					if (lbCurSel _ctrl == -1) then {
						_ctrl lbSetCurSel 4;
					};

					_ctrl ctrlAddEventHandler ["LBSelChanged",{["LBSelChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(4) + PX_HA((SIZE_M*5)),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_message_feed_limit_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_message_feed_limit_desc";
				}
			],
			[
				"ctrlCombo",IDC_COMBO_MAX_PRINTED_LOGS,[
					CENTER_XA(DIALOG_W) + PX_WS(4),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(4) + PX_HA((SIZE_M*6)),
					PX_WA((DIALOG_W/2)) - PX_WS(7),
					PX_HA(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_INDEX_MAX_PRINTED] call FUNC(settings);

					{
						_ctrl lbAdd format[localize "STR_CAU_xChat_settings_configuration_message_feed_limit_option",_x];
						_ctrl lbSetValue [_forEachIndex,_x];
						if (_x == _setting) then {
							_ctrl lbSetCurSel _forEachIndex;
						};
					} forEach [50,45,40,35,30,25,20,15,10,5];

					if (lbCurSel _ctrl == -1) then {
						_ctrl lbSetCurSel 8;
					};

					_ctrl ctrlAddEventHandler ["LBSelChanged",{["LBSelChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(5) + PX_HA((SIZE_M*7)),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_message_ttl_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_message_ttl_desc";
				}
			],
			[
				"ctrlCombo",IDC_COMBO_PRINTED_LOG_TTL,[
					CENTER_XA(DIALOG_W) + PX_WS(4),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(5) + PX_HA((SIZE_M*8)),
					PX_WA((DIALOG_W/2)) - PX_WS(7),
					PX_HA(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_INDEX_TTL_PRINTED] call FUNC(settings);

					{
						_ctrl lbAdd format[localize "STR_CAU_xChat_settings_configuration_message_ttl_option",_x];
						_ctrl lbSetValue [_forEachIndex,_x];
						if (_x == _setting) then {
							_ctrl lbSetCurSel _forEachIndex;
						};
					} forEach [180,120,90,60,45,30,15];

					if (lbCurSel _ctrl == -1) then {
						_ctrl lbSetCurSel 4;
					};

					_ctrl ctrlAddEventHandler ["LBSelChanged",{["LBSelChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_TEXT_FONT,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(6) + PX_HA((SIZE_M*9)),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_text_font_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_text_font_desc";
					_ctrl ctrlSetFont (["get",VAL_SETTINGS_INDEX_TEXT_FONT] call FUNC(settings));
				}
			],
			[
				"ctrlCombo",IDC_COMBO_TEXT_FONT,[
					CENTER_XA(DIALOG_W) + PX_WS(4),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(6) + PX_HA((SIZE_M*10)),
					PX_WA((DIALOG_W/2)) - PX_WS(7),
					PX_HA(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_INDEX_TEXT_FONT] call FUNC(settings);

					{
						_ctrl lbAdd configname _x;
						if (configname _x == _setting) then {
							_ctrl lbSetCurSel _forEachIndex;
						};
					} forEach ("true" configClasses (configFile >> "CfgFontFamilies"));
					lbSort _ctrl;
					_ctrl lbAdd ""; // add extra entry because for some reason the last entry is not visible when you scroll down
					_ctrl ctrlAddEventHandler ["LBSelChanged",{
						params ["_ctrl","_index"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_TEXT_FONT);
						private _setting = _ctrl lbText _index;
						if (_setting != "") then {
							_ctrlLabel ctrlSetFont (_ctrl lbText _index);
							["LBSelChanged"] call THIS_FUNC;
						};
					}];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_TEXT_SIZE,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(7) + PX_HA((SIZE_M*11)),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText format[localize "STR_CAU_xChat_settings_configuration_text_size_label",["get",VAL_SETTINGS_INDEX_TEXT_SIZE] call FUNC(settings)];
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_text_size_desc";
				}
			],
			[
				"ctrlXSliderH",IDC_SLIDER_TEXT_SIZE,[
					CENTER_XA(DIALOG_W) + PX_WS(4),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(7) + PX_HA((SIZE_M*12)),
					PX_WA((DIALOG_W/2)) - PX_WS(7),
					PX_HA(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_INDEX_TEXT_SIZE] call FUNC(settings);

					_ctrl sliderSetRange [0.1,5];
					_ctrl sliderSetSpeed [0.5,0.1];
					_ctrl sliderSetPosition _setting;

					_ctrl ctrlAddEventHandler ["SliderPosChanged",{
						params ["_ctrl","_position"];
						_position = parseNumber(_position toFixed 1);
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_TEXT_SIZE);
						_ctrlLabel ctrlSetText format[localize "STR_CAU_xChat_settings_configuration_text_size_label",_position];
						["SliderPosChanged"] call THIS_FUNC;
					}];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_TEXT_COLOR,[
					CENTER_XA(DIALOG_W) + PX_WS(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(9) + PX_HA((SIZE_M*13)),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_text_color_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_text_color_desc";
					
					private _setting = ["get",VAL_SETTINGS_INDEX_TEXT_COLOR] call FUNC(settings);
					_ctrl ctrlSetTextColor _setting;
					_ctrl setVariable ["setting",_setting];
				}
			],
			[
				"ctrlButton",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2) + (PX_WA((DIALOG_W/2)) - PX_WS(3)) - PX_WA(22),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(9) + PX_HA((SIZE_M*13)),
					PX_WA(20),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_TEXT_COLOR);
						[
							_ctrlLabel getVariable ["setting",[]],
							"Message text color selection",
							{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlLabel,IDC_LABEL_TEXT_COLOR);
									_ctrlLabel ctrlSetTextColor _colorRGBA1;
									_ctrlLabel setVariable ["setting",_colorRGBA1];
									["ColorSelected"] call THIS_FUNC;
								};
							},"","",_display
						] call CAU_UserInputMenus_fnc_colorPicker;
					}];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_FEED_BACKGROUND_COLOR,[
					CENTER_XA(DIALOG_W) + PX_WS(2.5),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(11) + PX_HA((SIZE_M*14)),
					PX_WA((DIALOG_W/2)) - PX_WS(25.5),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_feed_bg_color_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_feed_bg_color_desc";
					
					private _setting = ["get",VAL_SETTINGS_INDEX_FEED_BG_COLOR] call FUNC(settings);
					_ctrl ctrlSetBackgroundColor _setting;
					_ctrl setVariable ["setting",_setting];
				}
			],
			[
				"ctrlButton",-1,[
					CENTER_XA(DIALOG_W) + PX_WS(2) + (PX_WA((DIALOG_W/2)) - PX_WS(3)) - PX_WA(22),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(11) + PX_HA((SIZE_M*14)),
					PX_WA(20),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_FEED_BACKGROUND_COLOR);
						[
							_ctrlLabel getVariable ["setting",[]],
							"Message background color selection",
							{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlLabel,IDC_LABEL_FEED_BACKGROUND_COLOR);
									_ctrlLabel ctrlSetBackgroundColor _colorRGBA1;
									_ctrlLabel setVariable ["setting",_colorRGBA1];
									["ColorSelected"] call THIS_FUNC;
								};
							},"","",_display
						] call CAU_UserInputMenus_fnc_colorPicker;
					}];
				}
			],

		// ~~ Filters 
			[
				"ctrlStaticBackground",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WS(1),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(DIALOG_H) - PX_HS(4) - PX_HA(SIZE_M) - PX_HA((SIZE_M + 2))
				],
				{
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.2];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WS(1),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_title";
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.4];
				}
			],
			[
				"ctrlStaticFrame",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WS(1),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(DIALOG_H) - PX_HS(4) - PX_HA(SIZE_M) - PX_HA((SIZE_M + 2))
				]
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_CONNECT,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA(SIZE_M),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_CONNECTED] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA(SIZE_M),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_connect_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_connect_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_DISCONNECT,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA((SIZE_M*2)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_DISCONNECTED] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA((SIZE_M*2)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_disconnect_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_disconnect_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_KILLED,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA((SIZE_M*3)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_KILL] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA((SIZE_M*3)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_kill_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_kill_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_UNSUPPORTED_MISSION,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA((SIZE_M*4)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA(1) + PX_HA((SIZE_M*4)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_unsupported_mission_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_unsupported_mission_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_GLOBAL,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*6)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_GLOBAL] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*6)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					private _channelID = 0;
					private _channelName = ["ChannelName",_channelID] call FUNC(commonTask);
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
					_ctrl ctrlSetTextColor (["ChannelColour",_channelID] call FUNC(commonTask));
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_SIDE,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*7)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_SIDE] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*7)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					private _channelID = 1;
					private _channelName = ["ChannelName",_channelID] call FUNC(commonTask);
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
					_ctrl ctrlSetTextColor (["ChannelColour",_channelID] call FUNC(commonTask));
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_COMMAND,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*8)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_COMMAND] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*8)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					private _channelID = 2;
					private _channelName = ["ChannelName",_channelID] call FUNC(commonTask);
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
					_ctrl ctrlSetTextColor (["ChannelColour",_channelID] call FUNC(commonTask));
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_GROUP,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*9)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_GROUP] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*9)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					private _channelID = 3;
					private _channelName = ["ChannelName",_channelID] call FUNC(commonTask);
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
					_ctrl ctrlSetTextColor (["ChannelColour",_channelID] call FUNC(commonTask));
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_VEHICLE,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*10)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_VEHICLE] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*10)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					private _channelID = 4;
					private _channelName = ["ChannelName",_channelID] call FUNC(commonTask);
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
					_ctrl ctrlSetTextColor (["ChannelColour",_channelID] call FUNC(commonTask));
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_DIRECT,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*11)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_DIRECT] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*11)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					private _channelID = 5;
					private _channelName = ["ChannelName",_channelID] call FUNC(commonTask);
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
					_ctrl ctrlSetTextColor (["ChannelColour",_channelID] call FUNC(commonTask));
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_CUSTOM,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*12)),
					PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_CUSTOM] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WA(2) + PX_WA(SIZE_M) ,
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2) + PX_HA((SIZE_M*12)),
					PX_WA((DIALOG_W/2)) - PX_WS(4) - PX_WA(SIZE_M),
					PX_HA(SIZE_M)
				],
				{
					private _channelID = 6;
					private _channelName = ["ChannelName",_channelID] call FUNC(commonTask);
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
					_ctrl ctrlSetTextColor (["ChannelColour",_channelID] call FUNC(commonTask));
				}
			]
		];
	};

	case "EditChar";
	case "CBCheckedChanged";
	case "SliderPosChanged";
	case "ColorSelected";
	case "LBSelChanged":{
		USE_DISPLAY(THIS_DISPLAY);

		USE_CTRL(_ctrlButtonSave,IDC_BUTTON_SAVE_SETTINGS);
		_ctrlButtonSave ctrlEnable true;
	};
	case "ButtonSaveClicked":{
		USE_DISPLAY(THIS_DISPLAY);

		USE_CTRL(_ctrlButtonSave,IDC_BUTTON_SAVE_SETTINGS);
		USE_CTRL(_ctrlEditCommandPrefix,IDC_EDIT_COMMAND_PREFIX);
		USE_CTRL(_ctrlComboMaxSavedLogs,IDC_COMBO_MAX_SAVED_LOGS);
		USE_CTRL(_ctrlComboMaxPrintedLogs,IDC_COMBO_MAX_PRINTED_LOGS);
		USE_CTRL(_ctrlComboPrintedLogTTL,IDC_COMBO_PRINTED_LOG_TTL);
		USE_CTRL(_ctrlComboTextFont,IDC_COMBO_TEXT_FONT);
		USE_CTRL(_ctrlSliderTextSize,IDC_SLIDER_TEXT_SIZE);
		USE_CTRL(_ctrlLabelTextColor,IDC_LABEL_TEXT_COLOR);
		USE_CTRL(_ctrlLabelBGColor,IDC_LABEL_FEED_BACKGROUND_COLOR);
		USE_CTRL(_ctrlCBLogConnect,IDC_CB_LOG_CONNECT);
		USE_CTRL(_ctrlCBLogDisconnect,IDC_CB_LOG_DISCONNECT);
		USE_CTRL(_ctrlCBLogKilled,IDC_CB_LOG_KILLED);
		USE_CTRL(_ctrlCBLogUnsupportedMission,IDC_CB_CHANNEL_UNSUPPORTED_MISSION);
		USE_CTRL(_ctrlCBShowGlobal,IDC_CB_CHANNEL_GLOBAL);
		USE_CTRL(_ctrlCBShowSide,IDC_CB_CHANNEL_SIDE);
		USE_CTRL(_ctrlCBShowCommand,IDC_CB_CHANNEL_COMMAND);
		USE_CTRL(_ctrlCBShowGroup,IDC_CB_CHANNEL_GROUP);
		USE_CTRL(_ctrlCBShowVehicle,IDC_CB_CHANNEL_VEHICLE);
		USE_CTRL(_ctrlCBShowDirect,IDC_CB_CHANNEL_DIRECT);
		USE_CTRL(_ctrlCBShowCustom,IDC_CB_CHANNEL_CUSTOM);

		_ctrlButtonSave ctrlEnable false;

		private _commandPrefix = ctrlText _ctrlEditCommandPrefix;
		[
			"set",
			[
				VAL_SETTINGS_INDEX_COMMAND_PREFIX,
				[_commandPrefix,nil] select (_commandPrefix in ["","<","&"])
			]
		] call FUNC(settings);
		_ctrlEditCommandPrefix ctrlSetText (["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call FUNC(settings));

		["set",[VAL_SETTINGS_INDEX_MAX_SAVED,_ctrlComboMaxSavedLogs lbValue (lbCurSel _ctrlComboMaxSavedLogs)]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_MAX_PRINTED,_ctrlComboMaxPrintedLogs lbValue (lbCurSel _ctrlComboMaxPrintedLogs)]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_TTL_PRINTED,_ctrlComboPrintedLogTTL lbValue (lbCurSel _ctrlComboPrintedLogTTL)]] call FUNC(settings);

		["set",[VAL_SETTINGS_INDEX_TEXT_FONT,_ctrlComboTextFont lbText (lbCurSel _ctrlComboTextFont)]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_TEXT_SIZE,parseNumber(sliderPosition _ctrlSliderTextSize toFixed 1)]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_TEXT_COLOR,_ctrlLabelTextColor getVariable ["setting",[]]]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_FEED_BG_COLOR,_ctrlLabelBGColor getVariable ["setting",[]]]] call FUNC(settings);

		["set",[VAL_SETTINGS_INDEX_PRINT_CONNECTED,cbChecked _ctrlCBLogConnect]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_DISCONNECTED,cbChecked _ctrlCBLogDisconnect]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_KILL,cbChecked _ctrlCBLogKilled]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION,cbChecked _ctrlCBLogUnsupportedMission]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_GLOBAL,cbChecked _ctrlCBShowGlobal]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_SIDE,cbChecked _ctrlCBShowSide]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_COMMAND,cbChecked _ctrlCBShowCommand]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_GROUP,cbChecked _ctrlCBShowGroup]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_VEHICLE,cbChecked _ctrlCBShowVehicle]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_DIRECT,cbChecked _ctrlCBShowDirect]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_CUSTOM,cbChecked _ctrlCBShowCustom]] call FUNC(settings);

		saveProfileNamespace;

		["systemChat",[format["Extended Chat: %1",localize "STR_CAU_xChat_settings_saved_alert"]]] call FUNC(sendMessage);

		true
	};

};
