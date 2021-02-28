/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_historyUI

Description:
	Master handler for the message history UI

Parameters:
	_mode   : STRING - The name of the sub-function
    _params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(historyUI)
#define DISPLAY_NAME VAR(displayHistory)

#include "_macros.inc"
#include "_defines.inc"
#include "_dikcodes.inc"

#define DIALOG_W ((safezoneW/GRID_W) - 10)
#define DIALOG_H ((safezoneH/GRID_H) - 10)

#define IDC_STATIC_FILTER    1
#define IDC_FRAME_FILTER     2
#define IDC_CB_MUTED_PLAYERS 3
#define IDC_CB_SYSTEM        4
#define IDC_CB_GLOBAL        5
#define IDC_CB_SIDE          6
#define IDC_CB_COMMAND       7
#define IDC_CB_GROUP         8
#define IDC_CB_VEHICLE       9
#define IDC_CB_DIRECT        10
#define IDC_CB_CUSTOM_1      11
#define IDC_CB_CUSTOM_2      12
#define IDC_CB_CUSTOM_3      13
#define IDC_CB_CUSTOM_4      14
#define IDC_CB_CUSTOM_5      15
#define IDC_CB_CUSTOM_6      16
#define IDC_CB_CUSTOM_7      17
#define IDC_CB_CUSTOM_8      18
#define IDC_CB_CUSTOM_9      19
#define IDC_CB_CUSTOM_10     20
#define IDC_EDIT_SEARCH      21
#define IDC_GROUP_MESSAGES   22
#define IDC_BUTTON_RELOAD    23
#define IDC_IMAGE_SPINNER    24

disableSerialization;
SWITCH_SYS_PARAMS;

switch _mode do {
	case "init":{
		USE_DISPLAY(_params createDisplay "RscDisplayEmpty");
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
					_ctrl ctrlSetText localize "STR_CAU_xChat_history_title";
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
					_ctrl ctrlAddEventHandler ["ButtonClick",{(ctrlParent(_this#0)) closeDisplay 2}];
				}
			],

		// ~~ Filter Panel
			[
				"ctrlStaticBackground",IDC_STATIC_FILTER,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW(50),
					PXH(SIZE_M) + PXH(SIZE_M) + PXH(5) + PXH((SIZE_M*9))
				],
				{
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.2];
				}
			],
			[
				"ctrlStatic",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW(50),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_history_filter_title";
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.4];
				}
			],
			[
				"ctrlStaticFrame",IDC_FRAME_FILTER,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW(50),
					PXH(SIZE_M) + PXH(SIZE_M) + PXH(5) + PXH((SIZE_M*9))
				]
			],
			[
				"ctrlEdit",IDC_EDIT_SEARCH,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4),
					PXW(50) - PXW(SIZE_M) - PXW(4),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlAddEventHandler ["KeyDown",{["EditSearchModified",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlButtonSearch",-1,[
					PXCX(DIALOG_W) + PXW(4)	 + PXW(50) - PXW(SIZE_M) - PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlAddEventHandler ["ButtonClick",{["ButtonSearchClicked"] call THIS_FUNC}];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_MUTED_PLAYERS,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(7),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					// system can have hundreds of logs, is best to hide them unless the player wants to see system logs
					_ctrl cbSetChecked false;
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];

					// for some reason this ctrl is closing the display when clicked
					_ctrl ctrlAddEventHandler ["ButtonClick",{true}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(7),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = -1;
					_ctrl ctrlSetStructuredText composeText [text(localize "STR_CAU_xChat_settings_filter_muted_players_label") setAttributes ["size","1.04167"]];
					_ctrl ctrlAddEventHandler ["ButtonClick",{
						params ["_ctrlButton"];
						USE_DISPLAY(ctrlParent _ctrlButton);
						USE_CTRL(_ctrlCB,IDC_CB_MUTED_PLAYERS);
						_ctrlCB cbSetChecked !cbChecked _ctrlCB;

						["PopulateList"] spawn THIS_FUNC;
					}];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_SYSTEM,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH(SIZE_M),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					// system can have hundreds of logs, is best to hide them unless the player wants to see system logs
					_ctrl cbSetChecked false;
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];

					// for some reason this ctrl is closing the display when clicked
					_ctrl ctrlAddEventHandler ["ButtonClick",{true}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH(SIZE_M),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = -1;
					_ctrl ctrlSetStructuredText composeText [text(["ChannelName",_channel] call FUNC(commonTask)) setAttributes ["size","1.04167"]];
					_ctrl ctrlSetTextColor (["ChannelColour",[_channel,false]] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_GLOBAL,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*2)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_GLOBAL] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];

					// for some reason this ctrl is closing the display when clicked
					_ctrl ctrlAddEventHandler ["ButtonClick",{true}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*2)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 0;
					_ctrl ctrlSetStructuredText composeText [text(["ChannelName",_channel] call FUNC(commonTask)) setAttributes ["size","1.04167"]];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_SIDE,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*3)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_SIDE] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*3)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 1;
					_ctrl ctrlSetStructuredText composeText [text(["ChannelName",_channel] call FUNC(commonTask)) setAttributes ["size","1.04167"]];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_COMMAND,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*4)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_COMMAND] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*4)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 2;
					_ctrl ctrlSetStructuredText composeText [text(["ChannelName",_channel] call FUNC(commonTask)) setAttributes ["size","1.04167"]];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_GROUP,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*5)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_GROUP] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*5)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 3;
					_ctrl ctrlSetStructuredText composeText [text(["ChannelName",_channel] call FUNC(commonTask)) setAttributes ["size","1.04167"]];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_VEHICLE,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*6)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_VEHICLE] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*6)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 4;
					_ctrl ctrlSetStructuredText composeText [text(["ChannelName",_channel] call FUNC(commonTask)) setAttributes ["size","1.04167"]];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_DIRECT,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*7)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_DIRECT] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*3)) + PXH(9) + PXH((SIZE_M*7)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 5;
					_ctrl ctrlSetStructuredText composeText [text(["ChannelName",_channel] call FUNC(commonTask)) setAttributes ["size","1.04167"]];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[// Clear button with hover highlight
				"ctrlButtonFilter",IDC_BUTTON_RELOAD,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(SIZE_M) + PXH(9) + PXH((SIZE_M*8.5)),
					PXW(50),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlShow false;
					_ctrl ctrlSetBackgroundColor [COLOR_NOTE_ERROR_RGBA];
					_ctrl ctrlAddEventHandler ["ButtonClick",{["ButtonNewMessageClicked"] call THIS_FUNC}];
				}
			],

		// ~~ Message View
			[
				"ctrlStaticBackground",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(50),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW(DIALOG_W) - PXW(50) - PXW(6),
					PXH(DIALOG_H) - PXH(SIZE_M) - PXH((SIZE_M + 2)) - PXH(4)
				],
				{
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.2];
				}
			],
			[
				"ctrlStaticFrame",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(50),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW(DIALOG_W) - PXW(50) - PXW(6),
					PXH(DIALOG_H) - PXH(SIZE_M) - PXH((SIZE_M + 2)) - PXH(4)
				]
			],
			[
				"ctrlStaticPicture",IDC_IMAGE_SPINNER,[
					PXCX(DIALOG_W) + PXW(4) + PXW(50) + ((PXW(DIALOG_W) - PXW(50) - PXW(6))/2) - PXW(7.5),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2) + ((PXH(DIALOG_H) - PXH(SIZE_M) - PXH((SIZE_M + 2)) - PXH(4))/2) - PXH(7.5),
					PXW(15),
					PXH(15)
				],
				{
					_ctrl ctrlShow false;
					_ctrl ctrlSetText "a3\ui_f\data\map\markers\system\empty_ca.paa";

					private _evh = {
						((_this#0) displayCtrl IDC_IMAGE_SPINNER) ctrlSetAngle [diag_tickTime*30%360,0.5,0.5,true];
					};
					(ctrlParent _ctrl) displayAddEventHandler ["MouseMoving",_evh];
					(ctrlParent _ctrl) displayAddEventHandler ["MouseHolding",_evh];
				}
			],
			[
				"ctrlControlsGroup",IDC_GROUP_MESSAGES,[
					PXCX(DIALOG_W) + PXW(4) + PXW(50),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW(DIALOG_W) - PXW(50) - PXW(6),
					PXH(DIALOG_H) - PXH(SIZE_M) - PXH((SIZE_M + 2)) - PXH(4)
				]
			]
		];

		// Create custom channel checkboxes
		private _customChannelIDCs = [
			IDC_CB_CUSTOM_1,
			IDC_CB_CUSTOM_2,
			IDC_CB_CUSTOM_3,
			IDC_CB_CUSTOM_4,
			IDC_CB_CUSTOM_5,
			IDC_CB_CUSTOM_6,
			IDC_CB_CUSTOM_7,
			IDC_CB_CUSTOM_8,
			IDC_CB_CUSTOM_9,
			IDC_CB_CUSTOM_10
		];

		USE_CTRL(_ctrlCBDirect,IDC_CB_DIRECT);
		private _ctrlLabelDirect = allControls _display param [(allControls _display find _ctrlCBDirect) + 1,controlNull];
		private _ctrlPosCB = ctrlPosition _ctrlCBDirect;
		private _ctrlPosLabel = ctrlPosition _ctrlLabelDirect;

		private _customChannels = 0;
		for "_i" from 0 to 9 do {
			private _inChannnel = player in (["get",[_i + 1,3]] call FUNC(radioChannelCustom));

			if _inChannnel then {
				_customChannels = _customChannels + 1;

				_ctrlPosCB set [1,_ctrlPosCB#1 + PXH(SIZE_M)];
				_ctrlPosLabel set [1,_ctrlPosCB#1];

				private _ctrlCB = _display ctrlCreate ["ctrlCheckbox",_customChannelIDCs#_i];
				_ctrlCB ctrlSetPosition _ctrlPosCB;
				_ctrlCB cbSetChecked (["get",VAL_SETTINGS_KEY_PRINT_CUSTOM] call FUNC(settings));
				_ctrlCB ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				_ctrlCB ctrlCommit 0;

				private _channelID = _i + 6;
				private _ctrlLabel = _display ctrlCreate ["ctrlStructuredText",_customChannelIDCs#_i];
				_ctrlLabel ctrlSetPosition _ctrlPosLabel;
				_ctrlLabel ctrlSetStructuredText composeText [text(["ChannelName",_channelID] call FUNC(commonTask)) setAttributes ["size","1.04167"]];
				_ctrlLabel ctrlSetTextColor (["ChannelColour",_channelID] call FUNC(commonTask));
				_ctrlLabel ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channelID,QUOTE(THIS_FUNC)]];
				_ctrlLabel ctrlCommit 0;
			};
		};

		USE_CTRL(_ctrlFilterBG,IDC_STATIC_FILTER);
		USE_CTRL(_ctrlFilterFrame,IDC_FRAME_FILTER);
		USE_CTRL(_ctrlNewMessageButton,IDC_BUTTON_RELOAD);

		private _ctrlPosAdd = PXH((SIZE_M*_customChannels));

		{
			_x ctrlSetPositionH (ctrlPosition _x#3 + _ctrlPosAdd);
			_x ctrlCommit 0;
		} foreach [_ctrlFilterBG,_ctrlFilterFrame];

		_ctrlNewMessageButton ctrlSetPositionY (ctrlPosition _ctrlFilterBG#1 + ctrlPosition _ctrlFilterBG#3 + PXH(2));
		_ctrlNewMessageButton ctrlCommit 0;


		["PopulateList"] spawn THIS_FUNC;
	};

	case "CBFilterChanged";
	case "ButtonNewMessageClicked";
	case "ButtonSearchClicked":{
		["PopulateList"] spawn THIS_FUNC;
	};
	case "NewMessageReceived":{
		disableSerialization;
		USE_DISPLAY(THIS_DISPLAY);
		if (isNull _display) exitWith {};

		USE_CTRL(_ctrlNewMessageButton,IDC_BUTTON_RELOAD);

		private _newMessages = _ctrlNewMessageButton getVariable ["newMessages",0];
		_newMessages = _newMessages + 1;
		_ctrlNewMessageButton setVariable ["newMessages",_newMessages];

		_ctrlNewMessageButton ctrlSetText format[
			"%1 New Message%2",
			_newMessages,
			["s",""] select (_newMessages == 1)
		];
		_ctrlNewMessageButton ctrlShow true;
	};
	case "CBLabelClicked":{
		private _idcs = [
			IDC_CB_GLOBAL,
			IDC_CB_SIDE,
			IDC_CB_COMMAND,
			IDC_CB_GROUP,
			IDC_CB_VEHICLE,
			IDC_CB_DIRECT,
			IDC_CB_CUSTOM_1,
			IDC_CB_CUSTOM_2,
			IDC_CB_CUSTOM_3,
			IDC_CB_CUSTOM_4,
			IDC_CB_CUSTOM_5,
			IDC_CB_CUSTOM_6,
			IDC_CB_CUSTOM_7,
			IDC_CB_CUSTOM_8,
			IDC_CB_CUSTOM_9,
			IDC_CB_CUSTOM_10,
			IDC_CB_SYSTEM
		];
		private _idc = _idcs param [_params,IDC_CB_SYSTEM];

		disableSerialization;
		USE_DISPLAY(THIS_DISPLAY);

		private _toggleMode = [{_x == _idc},{_x != _idc}] select cbChecked(_display displayCtrl _idc);
		{(_display displayCtrl _x) cbSetChecked (call _toggleMode)} count _idcs;

		["PopulateList"] spawn THIS_FUNC;
	};
	case "EditSearchModified":{
		_params params ["_ctrl","_key"];

		private _thread = _ctrl getVariable ["thread",scriptNull];
		terminate _thread;

		if (_key in [DIK_RETURN,DIK_NUMPADENTER]) then {
			["PopulateList"] spawn THIS_FUNC;
		} else {
			_thread = _mode spawn {
				scriptName format["%1: %2",QUOTE(THIS_FUNC),_this];
				uiSleep 1;
				["PopulateList"] spawn THIS_FUNC;
			};
			_ctrl setVariable ["thread",_thread];
		};
	};

	case "PopulateList":{
		USE_DISPLAY(THIS_DISPLAY);
		if (isNull _display) exitWith {};
		if (_display getVariable ["populating",false]) exitWith {};
		_display setVariable ["populating",true];

		USE_CTRL(_ctrlCBMutedPlayers,IDC_CB_MUTED_PLAYERS);
		USE_CTRL(_ctrlCBSystem,IDC_CB_SYSTEM);
		USE_CTRL(_ctrlCBGlobal,IDC_CB_GLOBAL);
		USE_CTRL(_ctrlCBSide,IDC_CB_SIDE);
		USE_CTRL(_ctrlCBCommand,IDC_CB_COMMAND);
		USE_CTRL(_ctrlCBGroup,IDC_CB_GROUP);
		USE_CTRL(_ctrlCBVehicle,IDC_CB_VEHICLE);
		USE_CTRL(_ctrlCBDirect,IDC_CB_DIRECT);
		USE_CTRL(_ctrlCBCustom1,IDC_CB_CUSTOM_1);
		USE_CTRL(_ctrlCBCustom2,IDC_CB_CUSTOM_2);
		USE_CTRL(_ctrlCBCustom3,IDC_CB_CUSTOM_3);
		USE_CTRL(_ctrlCBCustom4,IDC_CB_CUSTOM_4);
		USE_CTRL(_ctrlCBCustom5,IDC_CB_CUSTOM_5);
		USE_CTRL(_ctrlCBCustom6,IDC_CB_CUSTOM_6);
		USE_CTRL(_ctrlCBCustom7,IDC_CB_CUSTOM_7);
		USE_CTRL(_ctrlCBCustom8,IDC_CB_CUSTOM_8);
		USE_CTRL(_ctrlCBCustom9,IDC_CB_CUSTOM_9);
		USE_CTRL(_ctrlCBCustom10,IDC_CB_CUSTOM_10);
		USE_CTRL(_ctrlEditSearch,IDC_EDIT_SEARCH);
		USE_CTRL(_ctrlGroupMessages,IDC_GROUP_MESSAGES);
		USE_CTRL(_ctrlNewMessageButton,IDC_BUTTON_RELOAD);
		USE_CTRL(_ctrlImageSpinner,IDC_IMAGE_SPINNER);

		_ctrlGroupMessages ctrlShow false;
		_ctrlImageSpinner ctrlShow true;

		_ctrlNewMessageButton ctrlShow false;
		_ctrlNewMessageButton setVariable ["newMessages",0];

		private _shownSystemChannel = cbChecked _ctrlCBSystem;
		private _shownChatChannels = [
			cbChecked _ctrlCBGlobal,
			cbChecked _ctrlCBSide,
			cbChecked _ctrlCBCommand,
			cbChecked _ctrlCBGroup,
			cbChecked _ctrlCBVehicle,
			cbChecked _ctrlCBDirect,
			!isNull _ctrlCBCustom1 && {cbChecked _ctrlCBCustom1},
			!isNull _ctrlCBCustom2 && {cbChecked _ctrlCBCustom2},
			!isNull _ctrlCBCustom3 && {cbChecked _ctrlCBCustom3},
			!isNull _ctrlCBCustom4 && {cbChecked _ctrlCBCustom4},
			!isNull _ctrlCBCustom5 && {cbChecked _ctrlCBCustom5},
			!isNull _ctrlCBCustom6 && {cbChecked _ctrlCBCustom6},
			!isNull _ctrlCBCustom7 && {cbChecked _ctrlCBCustom7},
			!isNull _ctrlCBCustom8 && {cbChecked _ctrlCBCustom8},
			!isNull _ctrlCBCustom9 && {cbChecked _ctrlCBCustom9},
			!isNull _ctrlCBCustom10 && {cbChecked _ctrlCBCustom10}
		];

		private _searchTerm = ctrlText _ctrlEditSearch;
		private _doSearchStrings = _searchTerm != "";
		private _mutedPlayers = ["get",VAL_SETTINGS_KEY_MUTED_PLAYERS] call FUNC(settings);
		private _showMutedPlayers = cbChecked _ctrlCBMutedPlayers;

		private _getTimePast = {
			private _elapsed = diag_tickTime - _this;
			private _hours = floor(_elapsed / 3600);
			private _minutes = floor((_elapsed / 60) % 60);
			format[localize "STR_CAU_xChat_history_time_past",_hours,_minutes];
		};

		private _oldMessageCtrls = _ctrlGroupMessages getVariable ["controls",[]];
		{ctrlDelete _x} count _oldMessageCtrls;

		private _newMessageCtrls = [];
		private _y = PXH(2);

		private _historyLen = count VAR_HISTORY - 1;
		for "_i" from _historyLen to 0 step -1 do {
			if (isNull _display) then {
				// End thread if display is closed while loading the messages
				terminate _thisScript;
			};

			(VAR_HISTORY#_i) params ["_text","_channel","_senderName","_senderUID","_receivedTickGame","_receivedDateSys","_sentenceType","_containsImg","_senderIsMuted","_mentionBGColor"];

			private _canSeeChannel = _shownChatChannels param [_channel,_shownSystemChannel];
			private _containsSearchTerm = !_doSearchStrings || {
				tolower _searchTerm in toLower str _text || {
					tolower _searchTerm in toLower _senderName || {
						_searchTerm == _senderUID
					}
				}
			};
			private _notMuted = _mutedPlayers findIf {_x#1 isEqualTo _senderUID} == -1;

			if (_canSeeChannel && _containsSearchTerm && (_notMuted || {!_notMuted && _showMutedPlayers})) then {
				private _channelName = ["ChannelName",_channel] call FUNC(commonTask);
				private _channelColour = ["ChannelColour",_channel] call FUNC(commonTask);
				_senderName = ["StreamSafeName",[_senderUID,_senderName]] call FUNC(commonTask);

				private _ctrlMessageContainer = ["CreateMessageCard",[
					_ctrlGroupMessages,_channel,_channelName,_channelColour,
					_receivedTickGame call _getTimePast,["formatSystemDate",_receivedDateSys] call FUNC(commonTask),
					_senderName,_text,_sentenceType,_containsImg,_senderIsMuted,_mentionBGColor
				]] call THIS_FUNC;

				private _ctrlMessageContainerPos = ctrlPosition _ctrlMessageContainer;
				_ctrlMessageContainerPos set [1,_y];
				_ctrlMessageContainer ctrlSetPosition _ctrlMessageContainerPos;
				_ctrlMessageContainer ctrlCommit 0;

				_y = _y + (_ctrlMessageContainerPos#3) + PXH(1);

				_newMessageCtrls pushBack _ctrlMessageContainer;
			};
		};

		private _ctrlBottomPadding = _display ctrlCreate ["ctrlStatic",-1,_ctrlGroupMessages];
		_ctrlBottomPadding ctrlSetPosition [0,_y + PXH(1),0,0];
		_ctrlBottomPadding ctrlCommit 0;
		_newMessageCtrls pushBack _ctrlBottomPadding;

		_ctrlGroupMessages setVariable ["controls",_newMessageCtrls];

		_ctrlImageSpinner ctrlShow false;
		_ctrlGroupMessages ctrlShow true;

		_display setVariable ["populating",false];
	};

	case "CreateMessageCard":{
		_params params ["_ctrlGroupMessages","_channel","_channelName","_channelColour","_receivedTickGame","_receivedDateSys","_senderName","_text","_sentenceType","_containsImg","_senderIsMuted","_mentionBGColor"];

		disableSerialization;
		USE_DISPLAY(THIS_DISPLAY);
		private _ctrlGroupMessagesPos = ctrlPosition _ctrlGroupMessages;

		private _ctrlMessageContainer = _display ctrlCreate ["ctrlControlsGroupNoScrollbars",-1,_ctrlGroupMessages];
		private _ctrlMessageContainerPos = [PXW(2),_ctrlGroupMessagesPos#3,_ctrlGroupMessagesPos#2 - PXW(4),0];

		private _ctrlMessageBackground = _display ctrlCreate ["ctrlStatic",-1,_ctrlMessageContainer];
		_ctrlMessageBackground ctrlSetBackgroundColor [0,0,0,0.2];
		private _ctrlMessageBackgroundPos = [0,0,_ctrlGroupMessagesPos#2 - PXW(4),0];

		private _ctrlMessageMentionBackground = _display ctrlCreate ["ctrlStatic",-1,_ctrlMessageContainer];
		_ctrlMessageMentionBackground ctrlSetBackgroundColor _mentionBGColor;

		private _ctrlMessageStripe = _display ctrlCreate ["ctrlStatic",-1,_ctrlMessageContainer];
		_ctrlMessageStripe ctrlSetBackgroundColor _channelColour;
		private _ctrlMessageStripePos = [0,0,PXW(0.5),0];

		private _ctrlMessageText = _display ctrlCreate ["ctrlStructuredText",-1,_ctrlMessageContainer];
		private _ctrlMessageTextPos = [PXW(0.5),PXH(1),_ctrlMessageContainerPos#2 - PXW(0.5),0];
		_ctrlMessageText ctrlSetPosition _ctrlMessageTextPos;
		_ctrlMessageText ctrlCommit 0;

		if (_channel < 0 || _channel > 15) then {
			_channelColour = ["ChannelColour",[_channelColour,false]] call FUNC(commonTask);
		};

		_finalText = [];
		if (_senderName != "") then {
			_finalText append [
				text(localize "STR_CAU_xChat_history_sent_by") setAttributes ["font",FONT_BOLD],
				" ",
				_senderName,
				if _senderIsMuted then {
					composeText["  ",image "\a3\ui_f\data\igui\rscingameui\rscdisplaychannel\mutechat_crossed_ca.paa" setAttributes ["color","#707070"]]
				} else {""},
				lineBreak
			];
		};

		_finalText append [
			text(localize "STR_CAU_xChat_history_channel") setAttributes ["font",FONT_BOLD],
			" ",
			text _channelName setAttributes ["color",_channelColour call BIS_fnc_colorRGBAToHTML],
			lineBreak,
			text(localize "STR_CAU_xChat_history_received") setAttributes ["font",FONT_BOLD],
			" ",
			format[
				["%1 (%2)","%2"] select isStreamFriendlyUIEnabled,
				_receivedDateSys,_receivedTickGame
			],
			lineBreak,
			text(localize "STR_CAU_xChat_history_message") setAttributes ["font",FONT_BOLD],
			" ",
			_text setAttributes [
				"color",["#A6A6A6","#FFFFFF"] select (_sentenceType == 0),
				"colorLink",["colorConfigToRGBA",[COLOR_ACTIVE_RGB,1]] call FUNC(commonTask) call BIS_fnc_colorRGBAtoHTML
			]
		];

		_finalText = composeText _finalText setAttributes ["size","1.15741"];
		_ctrlMessageText ctrlSetStructuredText composeText [_finalText];

		private _height = ctrlTextHeight _ctrlMessageText + (if _containsImg then {PXH(0.4)} else {0});
		_ctrlMessageContainerPos set [3,_height + PXH(2)];
		_ctrlMessageBackgroundPos set [3,_ctrlMessageContainerPos#3];
		_ctrlMessageStripePos set [3,_ctrlMessageContainerPos#3];
		_ctrlMessageTextPos set [3,_height];

		_ctrlMessageContainer ctrlSetPosition _ctrlMessageContainerPos;
		_ctrlMessageBackground ctrlSetPosition _ctrlMessageBackgroundPos;
		_ctrlMessageMentionBackground ctrlSetPosition _ctrlMessageBackgroundPos;
		_ctrlMessageStripe ctrlSetPosition _ctrlMessageStripePos;
		_ctrlMessageText ctrlSetPosition _ctrlMessageTextPos;

		{_x ctrlCommit 0;} count [
			_ctrlMessageContainer,
			_ctrlMessageBackground,
			_ctrlMessageMentionBackground,
			_ctrlMessageStripe,
			_ctrlMessageText
		];

		_ctrlMessageContainer
	};
};
