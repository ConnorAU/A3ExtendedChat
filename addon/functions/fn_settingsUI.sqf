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

#define DIALOG_W 150
#define DIALOG_H 125

#define IDC_BUTTON_SAVE_SETTINGS                  1
#define IDC_EDIT_COMMAND_PREFIX                   2
#define IDC_COMBO_MAX_SAVED_LOGS                  3
#define IDC_COMBO_MAX_PRINTED_LOGS                4
#define IDC_COMBO_PRINTED_LOG_TTL                 5
#define IDC_LABEL_TEXT_FONT                       6
#define IDC_COMBO_TEXT_FONT                       7
#define IDC_LABEL_TEXT_SIZE                       8
#define IDC_SLIDER_TEXT_SIZE                      9
#define IDC_LABEL_TEXT_COLOR                      10
#define IDC_LABEL_FEED_BACKGROUND_COLOR           11
#define IDC_LABEL_TEXT_MENTION_COLOR              12
#define IDC_LABEL_FEED_MENTION_BACKGROUND_COLOR   13
#define IDC_LABEL_AUTOCOMPLETE_KEYBIND            14
#define IDC_CB_LOG_CONNECT                        15
#define IDC_CB_LOG_DISCONNECT                     16
#define IDC_CB_LOG_BATTLEYE_KICK                  17
#define IDC_CB_LOG_KILLED                         18
#define IDC_CB_CHANNEL_GLOBAL                     19
#define IDC_CB_CHANNEL_SIDE                       20
#define IDC_CB_CHANNEL_COMMAND                    21
#define IDC_CB_CHANNEL_GROUP                      22
#define IDC_CB_CHANNEL_VEHICLE                    23
#define IDC_CB_CHANNEL_DIRECT                     24
#define IDC_CB_CHANNEL_CUSTOM                     25

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
									_display closeDisplay 2;
									["reset"] call FUNC(settings);
									systemChat format["Extended Chat: %1",localize "STR_CAU_xChat_settings_reset_alert"];
									// Can't close one display and open another in the same frame
									[] spawn {
										// execute unscheduled
										isNil {["init"] call THIS_FUNC};
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
					PXW((DIALOG_W/2)) - PXW(3),
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
					PXW((DIALOG_W/2)) - PXW(3),
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
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				]
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH(SIZE_M),
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_command_prefix_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_command_prefix_desc";
				}
			],
			[
				"RscEdit",IDC_EDIT_COMMAND_PREFIX,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(2) + PXH((SIZE_M*2)),
					PXW((DIALOG_W/2)) - PXW(7),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetFont FONT_NORMAL;
					_ctrl ctrlSetFontHeight PXH(4.32);
					_ctrl ctrlSetBackgroundColor [COLOR_TAB_RGBA];

					_ctrl ctrlSetText (["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["KeyDown",{["KeyDown"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(3) + PXH((SIZE_M*3)),
					PXW((DIALOG_W/2)) - PXW(3),
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
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(3) + PXH((SIZE_M*4)),
					PXW((DIALOG_W/2)) - PXW(7),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(4) + PXH((SIZE_M*5)),
					PXW((DIALOG_W/2)) - PXW(3),
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
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(4) + PXH((SIZE_M*6)),
					PXW((DIALOG_W/2)) - PXW(7),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(5) + PXH((SIZE_M*7)),
					PXW((DIALOG_W/2)) - PXW(3),
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
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(5) + PXH((SIZE_M*8)),
					PXW((DIALOG_W/2)) - PXW(7),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(6) + PXH((SIZE_M*9)),
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_text_font_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_text_font_desc";
					_ctrl ctrlSetFont (["get",VAL_SETTINGS_INDEX_TEXT_FONT] call FUNC(settings));
				}
			],
			[
				"ctrlCombo",IDC_COMBO_TEXT_FONT,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(6) + PXH((SIZE_M*10)),
					PXW((DIALOG_W/2)) - PXW(7),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_INDEX_TEXT_FONT] call FUNC(settings);
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
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(7) + PXH((SIZE_M*11)),
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText format[localize "STR_CAU_xChat_settings_configuration_text_size_label",["get",VAL_SETTINGS_INDEX_TEXT_SIZE] call FUNC(settings)];
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_text_size_desc";
				}
			],
			[
				"ctrlXSliderH",IDC_SLIDER_TEXT_SIZE,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(7) + PXH((SIZE_M*12)),
					PXW((DIALOG_W/2)) - PXW(7),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(9) + PXH((SIZE_M*13)),
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW(2) + (PXW((DIALOG_W/2)) - PXW(3)) - PXW(22),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(9) + PXH((SIZE_M*13)),
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
					PXCX(DIALOG_W) + PXW(2.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(11) + PXH((SIZE_M*14)),
					PXW((DIALOG_W/2)) - PXW(25.5),
					PXH(SIZE_M)
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
					PXCX(DIALOG_W) + PXW(2) + (PXW((DIALOG_W/2)) - PXW(3)) - PXW(22),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(11) + PXH((SIZE_M*14)),
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
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(13) + PXH((SIZE_M*15)),
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_text_mention_color_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_text_mention_color_desc";

					private _setting = ["get",VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR] call FUNC(settings);
					_ctrl ctrlSetTextColor _setting;
					_ctrl setVariable ["setting",_setting];
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW(2) + (PXW((DIALOG_W/2)) - PXW(3)) - PXW(22),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(13) + PXH((SIZE_M*15)),
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
					PXCX(DIALOG_W) + PXW(2.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(15) + PXH((SIZE_M*16)),
					PXW((DIALOG_W/2)) - PXW(25.5),
					PXH(SIZE_M)
				],
				{
					// BG layer for mention bg color
					_ctrl ctrlSetBackgroundColor [0.1,0.1,0.1,0.5];
				}
			],
			[
				"ctrlStatic",IDC_LABEL_FEED_MENTION_BACKGROUND_COLOR,[
					PXCX(DIALOG_W) + PXW(2.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(15) + PXH((SIZE_M*16)),
					PXW((DIALOG_W/2)) - PXW(25.5),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_configuration_feed_mention_bg_color_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_feed_mention_bg_color_desc";

					private _setting = ["get",VAL_SETTINGS_INDEX_FEED_MENTION_BG_COLOR] call FUNC(settings);
					_ctrl ctrlSetBackgroundColor _setting;
					_ctrl setVariable ["setting",_setting];
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW(2) + (PXW((DIALOG_W/2)) - PXW(3)) - PXW(22),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(15) + PXH((SIZE_M*16)),
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
			[
				"ctrlStatic",IDC_LABEL_AUTOCOMPLETE_KEYBIND,[
					PXCX(DIALOG_W) + PXW(2.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(17) + PXH((SIZE_M*17)),
					PXW((DIALOG_W/2)) - PXW(25.5),
					PXH(SIZE_M)
				],
				{
					private _setting = ["get",VAL_SETTINGS_INDEX_AUTOCOMPLETE_KEYBIND] call FUNC(settings);
					_ctrl setVariable ["setting",_setting];

					_ctrl ctrlSetText format[localize "STR_CAU_xChat_settings_configuration_autocomplete_keybind_label",keyName _setting];
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_configuration_autocomplete_keybind_desc";
				}
			],
			[
				"ctrlButton",-1,[
					PXCX(DIALOG_W) + PXW(2) + (PXW((DIALOG_W/2)) - PXW(3)) - PXW(22),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(17) + PXH((SIZE_M*17)),
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
					_display displayAddEventHandler ["KeyDown",{
						params  ["_display","_key"];
						USE_CTRL(_ctrlLabel,IDC_LABEL_AUTOCOMPLETE_KEYBIND);

						private _active = _ctrlLabel getVariable ["active",false];
						if _active exitWith {
							_ctrlLabel setVariable ["setting",_key];
							_ctrlLabel ctrlSetText format[localize "STR_CAU_xChat_settings_configuration_autocomplete_keybind_label",keyName _key];
							["KeyDown"] call THIS_FUNC;
							true
						};

						false
					}];
				}
			],

		// ~~ Filters
			[
				"ctrlStaticBackground",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(1),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				],
				{
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.2];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(1),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_title";
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.4];
				}
			],
			[
				"ctrlStaticFrame",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(1),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW((DIALOG_W/2)) - PXW(3),
					PXH(DIALOG_H) - PXH(4) - PXH(SIZE_M) - PXH((SIZE_M + 2))
				]
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_CONNECT,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH(SIZE_M),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_CONNECTED] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH(SIZE_M),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_connect_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_connect_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_DISCONNECT,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*2)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_DISCONNECTED] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*2)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_disconnect_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_disconnect_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_BATTLEYE_KICK,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*3)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_BATTLEYE_KICK] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*3)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_battleye_kick_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_battleye_kick_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_LOG_KILLED,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*4)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_KILL] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH(1) + PXH((SIZE_M*4)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_settings_filter_kill_log_label";
					_ctrl ctrlSetTooltip localize "STR_CAU_xChat_settings_filter_kill_log_desc";
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CHANNEL_GLOBAL,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*6)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_GLOBAL] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*6)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*7)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_SIDE] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*7)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*8)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_COMMAND] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*8)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*9)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_GROUP] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*9)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*10)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_VEHICLE] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*10)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*11)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_DIRECT] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*11)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
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
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*12)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_CUSTOM] call FUNC(settings));
					_ctrl ctrlAddEventHandler ["CheckedChanged",{["CBCheckedChanged"] call THIS_FUNC}];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW((DIALOG_W/2)) + PXW(2) + PXW(SIZE_M) ,
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + PXH((SIZE_M*12)),
					PXW((DIALOG_W/2)) - PXW(4) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channelName = localize "STR_CAU_xChat_channels_custom";
					_ctrl ctrlSetText _channelName;
					_ctrl ctrlSetTooltip format[localize "STR_CAU_xChat_settings_filter_channel_desc",_channelName];
				}
			]
		];
	};

	case "KeyDown";
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
		USE_CTRL(_ctrlLabelTextMentionColor,IDC_LABEL_TEXT_MENTION_COLOR);
		USE_CTRL(_ctrlLabelMentionBGColor,IDC_LABEL_FEED_MENTION_BACKGROUND_COLOR);
		USE_CTRL(_ctrlLabelAutocompleteKeybind,IDC_LABEL_AUTOCOMPLETE_KEYBIND);
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
				VAL_SETTINGS_INDEX_COMMAND_PREFIX,
				if (!isNil "_commandPrefix") then {_commandPrefix}
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
		["set",[VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR,_ctrlLabelTextMentionColor getVariable ["setting",[]]]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_FEED_MENTION_BG_COLOR,_ctrlLabelMentionBGColor getVariable ["setting",[]]]] call FUNC(settings);

		["set",[VAL_SETTINGS_INDEX_AUTOCOMPLETE_KEYBIND,_ctrlLabelAutocompleteKeybind getVariable ["setting",[]]]] call FUNC(settings);

		["set",[VAL_SETTINGS_INDEX_PRINT_CONNECTED,cbChecked _ctrlCBLogConnect]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_DISCONNECTED,cbChecked _ctrlCBLogDisconnect]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_BATTLEYE_KICK,cbChecked _ctrlCBLogBattleye]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_KILL,cbChecked _ctrlCBLogKilled]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_GLOBAL,cbChecked _ctrlCBShowGlobal]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_SIDE,cbChecked _ctrlCBShowSide]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_COMMAND,cbChecked _ctrlCBShowCommand]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_GROUP,cbChecked _ctrlCBShowGroup]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_VEHICLE,cbChecked _ctrlCBShowVehicle]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_DIRECT,cbChecked _ctrlCBShowDirect]] call FUNC(settings);
		["set",[VAL_SETTINGS_INDEX_PRINT_CUSTOM,cbChecked _ctrlCBShowCustom]] call FUNC(settings);

		saveProfileNamespace;

		systemChat format["Extended Chat: %1",localize "STR_CAU_xChat_settings_saved_alert"];

		true
	};

};
