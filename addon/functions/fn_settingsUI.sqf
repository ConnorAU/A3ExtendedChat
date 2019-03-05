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

#define DIALOG_W 120
#define DIALOG_H 82

#define IDC_BUTTON_SAVE_SETTINGS 			1
#define IDC_EDIT_COMMAND_PREFIX				2
#define IDC_COMBO_MAX_SAVED_LOGS 			3
#define IDC_COMBO_MAX_PRINTED_LOGS			4
#define IDC_COMBO_PRINTED_LOG_TTL			5
#define IDC_CB_LOG_CONNECT					6
#define IDC_CB_LOG_DISCONNECT				7
#define IDC_CB_LOG_KILLED					8
#define IDC_CB_CHANNEL_UNSUPPORTED_MISSION	9
#define IDC_CB_CHANNEL_GLOBAL				10
#define IDC_CB_CHANNEL_SIDE					11
#define IDC_CB_CHANNEL_COMMAND				12
#define IDC_CB_CHANNEL_GROUP				13
#define IDC_CB_CHANNEL_VEHICLE				14
#define IDC_CB_CHANNEL_DIRECT				15
#define IDC_CB_CHANNEL_CUSTOM				16

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
					_ctrl ctrlAddEventHandler ["ButtonClick",{(ctrlParent(_this#0)) closeDisplay 2}];
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
					_ctrl ctrlSetBackgroundColor ([COLOR_OVERLAY_RGB,0.2] apply {[_x] call BIS_fnc_parseNumber});
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
					_ctrl ctrlSetBackgroundColor ([COLOR_OVERLAY_RGB,0.4] apply {[_x] call BIS_fnc_parseNumber});
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

		// ~~ Filters 
			[
				"ctrlStaticBackground",-1,[
					CENTER_XA(DIALOG_W) + PX_WA((DIALOG_W/2)) + PX_WS(1),
					CENTER_YA(DIALOG_H) + PX_HA(SIZE_M) + PX_HS(2),
					PX_WA((DIALOG_W/2)) - PX_WS(3),
					PX_HA(DIALOG_H) - PX_HS(4) - PX_HA(SIZE_M) - PX_HA((SIZE_M + 2))
				],
				{
					_ctrl ctrlSetBackgroundColor ([COLOR_OVERLAY_RGB,0.2] apply {[_x] call BIS_fnc_parseNumber});
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
					_ctrl ctrlSetBackgroundColor ([COLOR_OVERLAY_RGB,0.4] apply {[_x] call BIS_fnc_parseNumber});
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
