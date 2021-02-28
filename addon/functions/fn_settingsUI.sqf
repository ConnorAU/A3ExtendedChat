/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_settingsUI

Description:
	Master handler for the settings UI

Parameters:
	_mode   : STRING - The name of the sub-function
	_params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(settingsUI)
#define DISPLAY_NAME VAR(displaySettings)

#include "_macros.inc"
#include "_defines.inc"
#include "_dikcodes.inc"

#define DIALOG_SECTIONS 3
#define DIALOG_SECTION_W 75
#define DIALOG_W (DIALOG_SECTION_W*DIALOG_SECTIONS)
#define DIALOG_H 105


#define IDC_BUTTON_SAVE_SETTINGS                  1
#define IDC_EDIT_COMMAND_PREFIX                   2
#define IDC_COMBO_MAX_SAVED_LOGS                  3
#define IDC_COMBO_MAX_PRINTED_LOGS                4
#define IDC_COMBO_PRINTED_LOG_TTL                 5
#define IDC_LABEL_AUTOCOMPLETE_KEYBIND            6
#define IDC_LABEL_TOGGLE_CHAT_FEED_KEYBIND        7
#define IDC_CB_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE   8

#define IDC_LABEL_TEXT_FONT                       9
#define IDC_COMBO_TEXT_FONT                       10
#define IDC_LABEL_TEXT_SIZE                       11
#define IDC_SLIDER_TEXT_SIZE                      12
#define IDC_LABEL_TEXT_COLOR                      13
#define IDC_LABEL_FEED_BACKGROUND_COLOR           14
#define IDC_LABEL_TEXT_MENTION_COLOR              15
#define IDC_LABEL_FEED_MENTION_BACKGROUND_COLOR   16

#define IDC_CB_LOG_CONNECT                        17
#define IDC_CB_LOG_DISCONNECT                     18
#define IDC_CB_LOG_BATTLEYE_KICK                  19
#define IDC_CB_LOG_KILLED                         20
#define IDC_CB_CHANNEL_GLOBAL                     21
#define IDC_CB_CHANNEL_SIDE                       22
#define IDC_CB_CHANNEL_COMMAND                    23
#define IDC_CB_CHANNEL_GROUP                      24
#define IDC_CB_CHANNEL_VEHICLE                    25
#define IDC_CB_CHANNEL_DIRECT                     26
#define IDC_CB_CHANNEL_CUSTOM                     27
#define IDC_CB_LANGUAGE_FILTER                    28
#define IDC_BUTTON_LANGUAGE_FILTER_ADD            29
#define IDC_BUTTON_LANGUAGE_FILTER_REM            30
#define IDC_CB_WEBSITE_WHITELIST                  31
#define IDC_BUTTON_WEBSITE_WHITELIST_ADD          32
#define IDC_BUTTON_WEBSITE_WHITELIST_REM          33
#define IDC_LABEL_MUTED_PLAYERS                   34
#define IDC_BUTTON_MUTED_PLAYERS_ADD              35
#define IDC_BUTTON_MUTED_PLAYERS_REM              36


disableSerialization;
SWITCH_SYS_PARAMS;

switch _mode do {
	case "init":{
		USE_DISPLAY(_params createDisplay "RscDisplayEmpty");
		uiNamespace setVariable [QUOTE(DISPLAY_NAME),_display];

		_display displayAddEventHandler ["KeyDown",{
			params ["_display","_key"];
			private _block = false;

			if (_key == DIK_ESCAPE) then {
				["closeDisplay",[_display]] call THIS_FUNC;
				_block = true;
			};

			USE_CTRL(_ctrlLabel,IDC_LABEL_AUTOCOMPLETE_KEYBIND);
			private _active = _ctrlLabel getVariable ["active",false];
			if _active then {
				_ctrlLabel setVariable ["setting",_key];
				_ctrlLabel ctrlSetText format[localize "STR_CAU_xChat_settings_configuration_autocomplete_keybind_label",keyName _key];
				["KeyDown"] call THIS_FUNC;
				_block = true;
			};

			USE_CTRL(_ctrlLabel,IDC_LABEL_TOGGLE_CHAT_FEED_KEYBIND);
			private _active = _ctrlLabel getVariable ["active",false];
			if _active then {
				_ctrlLabel setVariable ["setting",_key];
				_ctrlLabel ctrlSetText format[
					localize "STR_CAU_xChat_settings_configuration_toggle_chat_feed_keybind_label",
					if (_key == -1) then {
						localize "str_lib_info_na"
					} else {keyName _key}
				];
				["KeyDown"] call THIS_FUNC;
				_block = true;
			};

			_block
		}];

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
					PXCX(DIALOG_W),
					PXCY(DIALOG_H),
					PXW(DIALOG_W),
					PXH(DIALOG_H)
				]
			],
			[
				"ctrlStaticTitle",-1,[
					PXCX(DIALOG_W),
					PXCY(DIALOG_H),
					PXW(DIALOG_W),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_title";
				}
			],
			[
				"ctrlStaticFooter",-1,[
					PXCX(DIALOG_W),
					PXCY(DIALOG_H) + PXH(DIALOG_H) - PXH((SIZE_M + 2)),
					PXW(DIALOG_W),
					PXH((SIZE_M + 2))
				]
			],
			[
				"ctrlButtonClose",-1,[
					PXCX(DIALOG_W) + PXW(DIALOG_W) - PXW(((SIZE_M * 5) + 1)),
					PXCY(DIALOG_H) + PXH(DIALOG_H) - PXH((SIZE_M + 1)),
					PXW((SIZE_M * 5)),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						["closeDisplay",[_display]] call THIS_FUNC;
					}];
				}
			],
			[
				"ctrlButton",IDC_BUTTON_SAVE_SETTINGS,[
					PXCX(DIALOG_W) + PXW(DIALOG_W) - PXW(((SIZE_M * 5) * 2)) - PXW(2),
					PXCY(DIALOG_H) + PXH(DIALOG_H) - PXH((SIZE_M + 1)),
					PXW((SIZE_M * 5)),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_save_button";
					_ctrl ctrlEnable false;
					_ctrl ctrlAddEventHandler ["ButtonClick",{["ButtonSaveClicked"] call THIS_FUNC}];
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW(1),
					PXCY(DIALOG_H) + PXH(DIALOG_H) - PXH((SIZE_M + 1)),
					PXW((SIZE_M * 5)),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_reset_button";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						[
							[localize "STR_CAU_xChat_settings_reset_confirm"],
							localize "STR_CAU_xChat_settings_title",{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									private _parent = displayParent _display;
									_display closeDisplay 2;
									["reset"] call FUNC(settings);
									systemChat format["Extended Chat: %1",localize "STR_CAU_xChat_settings_reset_alert"];
									// Can't close one display and open another in the same frame
									_parent spawn {
										// execute unscheduled
										isNil {["init",_this] call THIS_FUNC};
									};
								};
							},"Reset","",THIS_DISPLAY
						] call CAU_UserInputMenus_fnc_guiMessage;
					}];
				}
			],

		// ~~ Configuration
			[
				"ctrlStaticBackground",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				],
				{
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.2];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_title";
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.4];
				}
			],
			[
				"ctrlStaticFrame",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				]
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH(SIZE_M),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_command_prefix_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_command_prefix_desc";
				}
			],
			[
				"ctrlEdit",IDC_EDIT_COMMAND_PREFIX,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(2) + PXH((SIZE_M*2)),
					PXW((DIALOG_W/3)) - PXW(6.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText (["get",VAL_SETTINGS_KEY_COMMAND_PREFIX] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["KeyDown",{["KeyDown"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(3) + PXH((SIZE_M*3)),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_message_history_limit_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_message_history_limit_desc";
				}
			],
			[
				"ctrlCombo",IDC_COMBO_MAX_SAVED_LOGS,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(4) + PXH((SIZE_M*4)),
					PXW((DIALOG_W/3)) - PXW(6.5),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_KEY_MAX_SAVED] call FUNC(settings);

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
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(5) + PXH((SIZE_M*5)),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_message_feed_limit_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_message_feed_limit_desc";
				}
			],
			[
				"ctrlCombo",IDC_COMBO_MAX_PRINTED_LOGS,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(6) + PXH((SIZE_M*6)),
					PXW((DIALOG_W/3)) - PXW(6.5),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_KEY_MAX_PRINTED] call FUNC(settings);

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
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(7) + PXH((SIZE_M*7)),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_message_ttl_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_message_ttl_desc";
				}
			],
			[
				"ctrlCombo",IDC_COMBO_PRINTED_LOG_TTL,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(8) + PXH((SIZE_M*8)),
					PXW((DIALOG_W/3)) - PXW(6.5),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_KEY_TTL_PRINTED] call FUNC(settings);

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
				"ctrlStatic",IDC_LABEL_AUTOCOMPLETE_KEYBIND,[
					PXCX(DIALOG_W) + PXW(2.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(10) + PXH((SIZE_M*9)),
					PXW((DIALOG_W/3)) - PXW(25),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_KEY_AUTOCOMPLETE_KEYBIND] call FUNC(settings);
					_ctrl setVariable ["setting",_setting];

					_ctrl ctrlSetText format[localize "STR_CAU_xChat_settings_configuration_autocomplete_keybind_label",keyName _setting];
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_autocomplete_keybind_desc";
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW(2) + (PXW((DIALOG_W/3)) - PXW(2.5)) - PXW(22),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(10) + PXH((SIZE_M*9)),
					PXW(20),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_AUTOCOMPLETE_KEYBIND);

						private _active = _ctrlLabel getVariable ["active",false];
						_active = !_active;
						_ctrlLabel setVariable ["active",_active];

						if _active then {
							_ctrl ctrlSetText localize "str_state_stop";
							_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_autocomplete_keybind_edit_tooltip";
						} else {
							_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
							_ctrl ctrlSetTooltip "";
						};
					}];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_TOGGLE_CHAT_FEED_KEYBIND,[
					PXCX(DIALOG_W) + PXW(2.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(12) + PXH((SIZE_M*10)),
					PXW((DIALOG_W/3)) - PXW(25),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_KEY_TOGGLE_CHAT_FEED_KEYBIND] call FUNC(settings);
					_ctrl setVariable ["setting",_setting];

					_ctrl ctrlSetText format[
						localize "STR_CAU_xChat_settings_configuration_toggle_chat_feed_keybind_label",
						if (_setting == -1) then {
							localize "str_lib_info_na"
						} else {keyName _setting}
					];
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_toggle_chat_feed_keybind_desc";
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW(2) + (PXW((DIALOG_W/3)) - PXW(2.5)) - PXW(22),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(12) + PXH((SIZE_M*10)),
					PXW(20),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_TOGGLE_CHAT_FEED_KEYBIND);

						private _active = _ctrlLabel getVariable ["active",false];
						_active = !_active;
						_ctrlLabel setVariable ["active",_active];

						if _active then {
							_ctrl ctrlSetText localize "str_state_stop";
							_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_toggle_chat_feed_keybind_edit_tooltip";
						} else {
							_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
							_ctrl ctrlSetTooltip "";
						};
					}];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE,[
					PXCX(DIALOG_W) + PXW(2.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(13) + PXH((SIZE_M*11)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW(2.5) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(13) + PXH((SIZE_M*11)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_hide_chat_feed_onload_streamsafe_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_hide_chat_feed_onload_streamsafe_desc";
				}
			],

		// ~~ Appearance
			[
				"ctrlStaticBackground",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(1.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				],
				{
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.2];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(1.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_appearance_title";
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.4];
				}
			],
			[
				"ctrlStaticFrame",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(1.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				]
			],
			[
				"ctrlStatic",IDC_LABEL_TEXT_FONT,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH(SIZE_M),
					PXW((DIALOG_W/3)) - PXW(3),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_appearance_text_font_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_appearance_text_font_desc";
					_ctrl ctrlSetFont (["get",VAL_SETTINGS_KEY_TEXT_FONT] call FUNC(settings));
				}
			],
			[
				"ctrlCombo",IDC_COMBO_TEXT_FONT,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(2) + PXH((SIZE_M*2)),
					PXW((DIALOG_W/3)) - PXW(7),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_KEY_TEXT_FONT] call FUNC(settings);
					private _fonts = ("true" configClasses (configFile >> "CfgFontFamilies")) apply {configName _x};
					_fonts sort true;
					{
						_ctrl lbAdd _x;
						if (_x == _setting) then {
							_ctrl lbSetCurSel _forEachIndex;
						};
					} forEach _fonts;
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(3) + PXH((SIZE_M*3)),
					PXW((DIALOG_W/3)) - PXW(3),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText format[localize "STR_CAU_xChat_settings_appearance_text_size_label",["get",VAL_SETTINGS_KEY_TEXT_SIZE] call FUNC(settings)];
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_appearance_text_size_desc";
				}
			],
			[
				"ctrlXSliderH",IDC_SLIDER_TEXT_SIZE,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(4) + PXH((SIZE_M*4)),
					PXW((DIALOG_W/3)) - PXW(7),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_KEY_TEXT_SIZE] call FUNC(settings);

					_ctrl sliderSetRange [0.1,5];
					_ctrl sliderSetSpeed [0.5,0.1];
					_ctrl sliderSetPosition _setting;

					_ctrl ctrlAddEventHandler ["SliderPosChanged",{
						params ["_ctrl","_position"];
						_position = parseNumber(_position toFixed 1);
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_TEXT_SIZE);
						_ctrlLabel ctrlSetText format[localize "STR_CAU_xChat_settings_appearance_text_size_label",_position];
						["SliderPosChanged"] call THIS_FUNC;
					}];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_TEXT_COLOR,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(6) + PXH((SIZE_M*5)),
					PXW((DIALOG_W/3)) - PXW(25),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_appearance_text_color_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_appearance_text_color_desc";

					private _setting = ["get",VAL_SETTINGS_KEY_TEXT_COLOR] call FUNC(settings);
					_ctrl ctrlSetTextColor _setting;
					_ctrl setVariable ["setting",_setting];
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2) + (PXW((DIALOG_W/3)) - PXW(2.5)) - PXW(22.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(6) + PXH((SIZE_M*5)),
					PXW(20),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_TEXT_COLOR);
						[
							[_ctrlLabel getVariable ["setting",[]]],
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(8) + PXH((SIZE_M*6)),
					PXW((DIALOG_W/3)) - PXW(25),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_appearance_feed_bg_color_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_appearance_feed_bg_color_desc";

					private _setting = ["get",VAL_SETTINGS_KEY_FEED_BG_COLOR] call FUNC(settings);
					_ctrl ctrlSetBackgroundColor _setting;
					_ctrl setVariable ["setting",_setting];
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2) + (PXW((DIALOG_W/3)) - PXW(2.5)) - PXW(22.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(8) + PXH((SIZE_M*6)),
					PXW(20),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_FEED_BACKGROUND_COLOR);
						[
							[_ctrlLabel getVariable ["setting",[]]],
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
			[
				"ctrlStatic",IDC_LABEL_TEXT_MENTION_COLOR,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(10) + PXH((SIZE_M*7)),
					PXW((DIALOG_W/3)) - PXW(25),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_appearance_text_mention_color_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_appearance_text_mention_color_desc";

					private _setting = ["get",VAL_SETTINGS_KEY_TEXT_MENTION_COLOR] call FUNC(settings);
					_ctrl ctrlSetTextColor _setting;
					_ctrl setVariable ["setting",_setting];
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2) + (PXW((DIALOG_W/3)) - PXW(2.5)) - PXW(22.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(10) + PXH((SIZE_M*7)),
					PXW(20),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_TEXT_MENTION_COLOR);
						[
							[_ctrlLabel getVariable ["setting",[]]],
							"Message text color selection",
							{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlLabel,IDC_LABEL_TEXT_MENTION_COLOR);
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
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(12) + PXH((SIZE_M*8)),
					PXW((DIALOG_W/3)) - PXW(25),
					PXH(SIZE_M)
				],
				{
					// BG layer for mention bg color
					_ctrl ctrlSetBackgroundColor [0.1,0.1,0.1,0.5];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_FEED_MENTION_BACKGROUND_COLOR,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(12) + PXH((SIZE_M*8)),
					PXW((DIALOG_W/3)) - PXW(25),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_appearance_feed_mention_bg_color_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_appearance_feed_mention_bg_color_desc";

					private _setting = ["get",VAL_SETTINGS_KEY_FEED_MENTION_BG_COLOR] call FUNC(settings);
					_ctrl ctrlSetBackgroundColor _setting;
					_ctrl setVariable ["setting",_setting];
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3)) + PXW(2) + (PXW((DIALOG_W/3)) - PXW(2.5)) - PXW(22.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(12) + PXH((SIZE_M*8)),
					PXW(20),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "str_3den_display3den_menubar_edit_text";
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_FEED_MENTION_BACKGROUND_COLOR);
						[
							[_ctrlLabel getVariable ["setting",[]]],
							"Message background color selection",
							{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlLabel,IDC_LABEL_FEED_MENTION_BACKGROUND_COLOR);
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(1),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				],
				{
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.2];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(1),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_title";
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.4];
				}
			],
			[
				"ctrlStaticFrame",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(1),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/3)) - PXW(2.5),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				]
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_CONNECT,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH(SIZE_M),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_CONNECTED] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH(SIZE_M),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_connect_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_connect_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_DISCONNECT,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*2)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_DISCONNECTED] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*2)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_disconnect_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_disconnect_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_BATTLEYE_KICK,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*3)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_BATTLEYE_KICK] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*3)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_battleye_kick_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_battleye_kick_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_KILLED,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*4)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_DEATH] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*4)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_kill_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_kill_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_GLOBAL,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*6)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_GLOBAL] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*6)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*7)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_SIDE] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*7)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*8)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_COMMAND] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*8)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*9)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_GROUP] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*9)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*10)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_VEHICLE] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*10)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*11)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_DIRECT] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*11)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*12)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_CUSTOM] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*12)),
					PXW((DIALOG_W/3)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channelName = localize "STR_CAU_xChat_channels_custom";
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LANGUAGE_FILTER,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*14)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _terms = ["get",VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER_TERMS] call FUNC(settings);
					_ctrl setVariable ["setting",_terms];
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{
						params ["_ctrlCheckbox","_checked"];
						_checked = _checked == 1;

						USE_DISPLAY(ctrlParent _ctrlCheckbox);
						USE_CTRL(_ctrlButtonAdd,IDC_BUTTON_LANGUAGE_FILTER_ADD);
						USE_CTRL(_ctrlButtonRem,IDC_BUTTON_LANGUAGE_FILTER_REM);

						_ctrlButtonAdd ctrlEnable _checked;
						_ctrlButtonRem ctrlEnable _checked;

						["CBCheckedChanged"] call THIS_FUNC;
					}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*14)),
					PXW((DIALOG_W/3)) - PXW(5) - PXW(SIZE_M)*3,
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_bad_language_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_bad_language_desc";
				}
			],
			[
				"ctrlButtonPicture",IDC_BUTTON_LANGUAGE_FILTER_ADD,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW((DIALOG_W/3)) - PXW(SIZE_M)*3,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*14)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					USE_CTRL(_ctrlCheckbox,IDC_CB_LANGUAGE_FILTER);
					_ctrl ctrlEnable cbChecked _ctrlCheckbox;

					_ctrl ctrlSetText "\a3\3den\data\cfg3den\history\makenewlayer_ca.paa";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_bad_language_add_tooltip";

					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						[
							[],
							localize "STR_CAU_xChat_settings_filter_bad_language_add_title",
							{
								if (_confirmed && {_text != ""}) then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlCheckbox,IDC_CB_LANGUAGE_FILTER);

									private _terms = _ctrlCheckbox getVariable ["setting",[]];
									if !(toLower _text in _terms) then {
										_terms pushBackUnique _text;
									};

									["ListModified"] call THIS_FUNC;
								};
							},
							localize "str_single_create",
							"",_display
						] call CAU_UserInputMenus_fnc_text;
					}];
				}
			],
			[
				"ctrlButtonPicture",IDC_BUTTON_LANGUAGE_FILTER_REM,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW((DIALOG_W/3)) - PXW(SIZE_M)*2,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*14)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					USE_CTRL(_ctrlCheckbox,IDC_CB_LANGUAGE_FILTER);
					_ctrl ctrlEnable cbChecked _ctrlCheckbox;

					_ctrl ctrlSetText "\a3\3den\data\cfg3den\history\removefromlayer_ca.paa";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_bad_language_remove_tooltip";

					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlCheckbox,IDC_CB_LANGUAGE_FILTER);
						private _terms = _ctrlCheckbox getVariable ["setting",[]];
						_terms sort true;

						[
							[_terms apply {[[_x]]},0,true],
							localize "STR_CAU_xChat_settings_filter_bad_language_remove_title",
							{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlCheckbox,IDC_CB_LANGUAGE_FILTER);

									_index sort false;

									private _terms = _ctrlCheckbox getVariable ["setting",[]];
									{_terms deleteAt _x} forEach _index;

									["ListModified"] call THIS_FUNC;
								};
							},
							localize "str_xbox_hint_remove",
							"",_display
						] call CAU_UserInputMenus_fnc_listBox;
					}];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_WEBSITE_WHITELIST,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(3) + PXH((SIZE_M*15)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _terms = ["get",VAL_SETTINGS_KEY_WEBSITE_WHITELIST_TERMS] call FUNC(settings);
					_ctrl setVariable ["setting",_terms];
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_WEBSITE_WHITELIST] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{
						params ["_ctrlCheckbox","_checked"];
						_checked = _checked == 1;

						USE_DISPLAY(ctrlParent _ctrlCheckbox);
						USE_CTRL(_ctrlButtonAdd,IDC_BUTTON_WEBSITE_WHITELIST_ADD);
						USE_CTRL(_ctrlButtonRem,IDC_BUTTON_WEBSITE_WHITELIST_REM);

						_ctrlButtonAdd ctrlEnable _checked;
						_ctrlButtonRem ctrlEnable _checked;

						["CBCheckedChanged"] call THIS_FUNC;
					}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(3) + PXH((SIZE_M*15)),
					PXW((DIALOG_W/3)) - PXW(5) - PXW(SIZE_M)*3,
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_website_whitelist_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_website_whitelist_desc";
				}
			],
			[
				"ctrlButtonPicture",IDC_BUTTON_WEBSITE_WHITELIST_ADD,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW((DIALOG_W/3)) - PXW(SIZE_M)*3,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(3) + PXH((SIZE_M*15)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					USE_CTRL(_ctrlCheckbox,IDC_CB_WEBSITE_WHITELIST);
					_ctrl ctrlEnable cbChecked _ctrlCheckbox;

					_ctrl ctrlSetText "\a3\3den\data\cfg3den\history\makenewlayer_ca.paa";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_website_whitelist_add_tooltip";

					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						[
							[],
							localize "STR_CAU_xChat_settings_filter_website_whitelist_add_title",
							{
								if (_confirmed && {_text != ""}) then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlCheckbox,IDC_CB_WEBSITE_WHITELIST);

									private _terms = _ctrlCheckbox getVariable ["setting",[]];
									if !(toLower _text in _terms) then {
										_terms pushBackUnique _text;
									};

									["ListModified"] call THIS_FUNC;
								};
							},
							localize "str_single_create",
							"",_display
						] call CAU_UserInputMenus_fnc_text;
					}];
				}
			],
			[
				"ctrlButtonPicture",IDC_BUTTON_WEBSITE_WHITELIST_REM,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW((DIALOG_W/3)) - PXW(SIZE_M)*2,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(3) + PXH((SIZE_M*15)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					USE_CTRL(_ctrlCheckbox,IDC_CB_WEBSITE_WHITELIST);
					_ctrl ctrlEnable cbChecked _ctrlCheckbox;

					_ctrl ctrlSetText "\a3\3den\data\cfg3den\history\removefromlayer_ca.paa";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_website_whitelist_remove_tooltip";

					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlCheckbox,IDC_CB_WEBSITE_WHITELIST);
						private _terms = _ctrlCheckbox getVariable ["setting",[]];
						_terms sort true;

						[
							[_terms apply {[[_x]]},0,true],
							localize "STR_CAU_xChat_settings_filter_website_whitelist_remove_title",
							{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlCheckbox,IDC_CB_WEBSITE_WHITELIST);

									_index sort false;

									private _terms = _ctrlCheckbox getVariable ["setting",[]];
									{_terms deleteAt _x} forEach _index;

									["ListModified"] call THIS_FUNC;
								};
							},
							localize "str_xbox_hint_remove",
							"",_display
						] call CAU_UserInputMenus_fnc_listBox;
					}];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_MUTED_PLAYERS,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(4) + PXH((SIZE_M*16)),
					PXW((DIALOG_W/3)) - PXW(5) - PXW(SIZE_M)*2,
					PXH(SIZE_M)
				],
				{
					private _terms = ["get",VAL_SETTINGS_KEY_MUTED_PLAYERS] call FUNC(settings);
					_ctrl setVariable ["setting",_terms];

					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_muted_players_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_muted_players_desc";
				}
			],
			[
				"ctrlButtonPicture",IDC_BUTTON_MUTED_PLAYERS_ADD,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW((DIALOG_W/3)) - PXW(SIZE_M)*3,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(4) + PXH((SIZE_M*16)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText "\a3\3den\data\cfg3den\history\makenewlayer_ca.paa";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_muted_players_add";

					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_MUTED_PLAYERS);
						private _terms = _ctrlLabel getVariable ["setting",[]];
						_terms = _terms apply {_x#1};

						private _players = (allPlayers-[player]) select {!(getPlayerUID _x in _terms)} apply {[UNIT_NAME(_x),getPlayerUID _x]};
						_players sort true;

						[
							[_players apply {[[_x#0],nil,nil,nil,nil,str _x]},0,true],
							localize "STR_CAU_xChat_settings_filter_muted_players_add",
							{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlLabel,IDC_LABEL_MUTED_PLAYERS);

									private _terms = _ctrlLabel getVariable ["setting",[]];
									_terms append (_data apply {(parseSimpleArray _x) + [["formatSystemDate",systemTime] call FUNC(commonTask)]});

									["ListModified"] call THIS_FUNC;
								};
							},
							localize "str_single_create",
							"",_display
						] call CAU_UserInputMenus_fnc_listBox;
					}];
				}
			],
			[
				"ctrlButtonPicture",IDC_BUTTON_MUTED_PLAYERS_REM,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/3))*2 + PXW(2) + PXW((DIALOG_W/3)) - PXW(SIZE_M)*2,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(4) + PXH((SIZE_M*16)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText "\a3\3den\data\cfg3den\history\removefromlayer_ca.paa";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_muted_players_remove";

					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrl"];
						USE_DISPLAY(ctrlParent _ctrl);
						USE_CTRL(_ctrlLabel,IDC_LABEL_MUTED_PLAYERS);
						private _terms = _ctrlLabel getVariable ["setting",[]];
						_terms sort true;

						[
							[_terms apply {[[_x#0],[_x#2,[0.75,0.75,0.75,1]],nil,nil,nil,_x#1]},0,true],
							localize "STR_CAU_xChat_settings_filter_muted_players_remove",
							{
								if _confirmed then {
									USE_DISPLAY(THIS_DISPLAY);
									USE_CTRL(_ctrlLabel,IDC_LABEL_MUTED_PLAYERS);

									_index sort false;

									private _terms = _ctrlLabel getVariable ["setting",[]];
									{_terms deleteAt _x} forEach _index;

									["ListModified"] call THIS_FUNC;
								};
							},
							localize "str_xbox_hint_remove",
							"",_display
						] call CAU_UserInputMenus_fnc_listBox;
					}];
				}
			]
		];
	};

	case "KeyDown";
	case "CBCheckedChanged";
	case "SliderPosChanged";
	case "ColorSelected";
	case "ListModified";
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
		USE_CTRL(_ctrlLabelAutocompleteKeybind,IDC_LABEL_AUTOCOMPLETE_KEYBIND);
		USE_CTRL(_ctrlLabelToggleChatFeetKeybind,IDC_LABEL_TOGGLE_CHAT_FEED_KEYBIND);
		USE_CTRL(_ctrlCBHideChatFeedOnloadStreamsafe,IDC_CB_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE);
		USE_CTRL(_ctrlComboTextFont,IDC_COMBO_TEXT_FONT);
		USE_CTRL(_ctrlSliderTextSize,IDC_SLIDER_TEXT_SIZE);
		USE_CTRL(_ctrlLabelTextColor,IDC_LABEL_TEXT_COLOR);
		USE_CTRL(_ctrlLabelBGColor,IDC_LABEL_FEED_BACKGROUND_COLOR);
		USE_CTRL(_ctrlLabelTextMentionColor,IDC_LABEL_TEXT_MENTION_COLOR);
		USE_CTRL(_ctrlLabelMentionBGColor,IDC_LABEL_FEED_MENTION_BACKGROUND_COLOR);
		USE_CTRL(_ctrlCBLogConnect,IDC_CB_LOG_CONNECT);
		USE_CTRL(_ctrlCBLogDisconnect,IDC_CB_LOG_DISCONNECT);
		USE_CTRL(_ctrlCBLogBattleye,IDC_CB_LOG_BATTLEYE_KICK);
		USE_CTRL(_ctrlCBLogKilled,IDC_CB_LOG_KILLED);
		USE_CTRL(_ctrlCBShowGlobal,IDC_CB_CHANNEL_GLOBAL);
		USE_CTRL(_ctrlCBShowSide,IDC_CB_CHANNEL_SIDE);
		USE_CTRL(_ctrlCBShowCommand,IDC_CB_CHANNEL_COMMAND);
		USE_CTRL(_ctrlCBShowGroup,IDC_CB_CHANNEL_GROUP);
		USE_CTRL(_ctrlCBShowVehicle,IDC_CB_CHANNEL_VEHICLE);
		USE_CTRL(_ctrlCBShowDirect,IDC_CB_CHANNEL_DIRECT);
		USE_CTRL(_ctrlCBShowCustom,IDC_CB_CHANNEL_CUSTOM);
		USE_CTRL(_ctrlCBLanguageFilter,IDC_CB_LANGUAGE_FILTER);
		USE_CTRL(_ctrlCBWebsiteWhitelist,IDC_CB_WEBSITE_WHITELIST);
		USE_CTRL(_ctrlLabelMutedPlayers,IDC_LABEL_MUTED_PLAYERS);

		_ctrlButtonSave ctrlEnable false;

		private _commandPrefix = ctrlText _ctrlEditCommandPrefix;
		if (_commandPrefix == "" || {
			"<" in _commandPrefix ||
			"&" in _commandPrefix ||
			"&" in _commandPrefix ||
			" " in _commandPrefix ||
			_commandPrefix find ":" == 0
		}) then {_commandPrefix = nil};
		[
			"set",
			[
				VAL_SETTINGS_KEY_COMMAND_PREFIX,
				if (!isNil "_commandPrefix") then {_commandPrefix}
			]
		] call FUNC(settings);
		_ctrlEditCommandPrefix ctrlSetText (["get",VAL_SETTINGS_KEY_COMMAND_PREFIX] call FUNC(settings));

		["set",[VAL_SETTINGS_KEY_MAX_SAVED,_ctrlComboMaxSavedLogs lbValue (lbCurSel _ctrlComboMaxSavedLogs)]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_MAX_PRINTED,_ctrlComboMaxPrintedLogs lbValue (lbCurSel _ctrlComboMaxPrintedLogs)]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_TTL_PRINTED,_ctrlComboPrintedLogTTL lbValue (lbCurSel _ctrlComboPrintedLogTTL)]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_AUTOCOMPLETE_KEYBIND,_ctrlLabelAutocompleteKeybind getVariable ["setting",[]]]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_TOGGLE_CHAT_FEED_KEYBIND,_ctrlLabelToggleChatFeetKeybind getVariable ["setting",[]]]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE,cbChecked _ctrlCBHideChatFeedOnloadStreamsafe]] call FUNC(settings);

		["set",[VAL_SETTINGS_KEY_TEXT_FONT,_ctrlComboTextFont lbText (lbCurSel _ctrlComboTextFont)]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_TEXT_SIZE,parseNumber(sliderPosition _ctrlSliderTextSize toFixed 1)]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_TEXT_COLOR,_ctrlLabelTextColor getVariable ["setting",[]]]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_FEED_BG_COLOR,_ctrlLabelBGColor getVariable ["setting",[]]]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_TEXT_MENTION_COLOR,_ctrlLabelTextMentionColor getVariable ["setting",[]]]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_FEED_MENTION_BG_COLOR,_ctrlLabelMentionBGColor getVariable ["setting",[]]]] call FUNC(settings);

		["set",[VAL_SETTINGS_KEY_PRINT_CONNECTED,cbChecked _ctrlCBLogConnect]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_DISCONNECTED,cbChecked _ctrlCBLogDisconnect]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_BATTLEYE_KICK,cbChecked _ctrlCBLogBattleye]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_DEATH,cbChecked _ctrlCBLogKilled]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_GLOBAL,cbChecked _ctrlCBShowGlobal]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_SIDE,cbChecked _ctrlCBShowSide]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_COMMAND,cbChecked _ctrlCBShowCommand]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_GROUP,cbChecked _ctrlCBShowGroup]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_VEHICLE,cbChecked _ctrlCBShowVehicle]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_DIRECT,cbChecked _ctrlCBShowDirect]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_PRINT_CUSTOM,cbChecked _ctrlCBShowCustom]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER,cbChecked _ctrlCBLanguageFilter]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_WEBSITE_WHITELIST,cbChecked _ctrlCBWebsiteWhitelist]] call FUNC(settings);
		["set",[VAL_SETTINGS_KEY_MUTED_PLAYERS,_ctrlLabelMutedPlayers getVariable ["setting",[]]]] call FUNC(settings);

		private _languageTerms = _ctrlCBLanguageFilter getVariable ["setting",[]];
		_languageTerms = _languageTerms apply {[count _x,_x]};
		_languageTerms sort false;
		["set",[VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER_TERMS,_languageTerms apply {_x#1}]] call FUNC(settings);

		private _websiteWhitelist = _ctrlCBWebsiteWhitelist getVariable ["setting",[]];
		_websiteWhitelist = _websiteWhitelist apply {[count _x,_x]};
		_websiteWhitelist sort false;
		["set",[VAL_SETTINGS_KEY_WEBSITE_WHITELIST_TERMS,_websiteWhitelist apply {_x#1}]] call FUNC(settings);

		saveProfileNamespace;

		systemChat format["Extended Chat: %1",localize "STR_CAU_xChat_settings_saved_alert"];

		true
	};
	case "closeDisplay":{
		_params params ["_display"];
		USE_CTRL(_ctrlButton,IDC_BUTTON_SAVE_SETTINGS);
		if (ctrlEnabled _ctrlButton) then {
			[
				[localize "STR_CAU_xChat_settings_pending_changes"],
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
	};

};
