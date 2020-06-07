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

#define IDC_CB_SYSTEM 		1
#define IDC_CB_GLOBAL 		2
#define IDC_CB_SIDE 		3
#define IDC_CB_COMMAND 		4
#define IDC_CB_GROUP 		5
#define IDC_CB_VEHICLE 		6
#define IDC_CB_DIRECT 		7
#define IDC_CB_CUSTOM 		8
#define IDC_EDIT_SEARCH 	9
#define IDC_GROUP_MESSAGES 	10
#define IDC_STATIC_RELOAD 	11
#define IDC_BUTTON_RELOAD 	12
#define IDC_IMAGE_SPINNER 	13

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
				"ctrlStaticBackground",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW(50),
					PXH(SIZE_M) + PXH((SIZE_M*10.5))
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
				"ctrlStaticFrame",-1,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH(SIZE_M) + PXH(2),
					PXW(50),
					PXH(SIZE_M) + PXH((SIZE_M*10.5))
				]
			],
			[
				"ctrlCheckbox",IDC_CB_SYSTEM,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4),
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
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = -1;
					_ctrl ctrlSetStructuredText parseText format["<t size='1.04167'>%1</t>",(["ChannelName",_channel] call FUNC(commonTask))];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_GLOBAL,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH(SIZE_M),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_GLOBAL] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];

					// for some reason this ctrl is closing the display when clicked
					_ctrl ctrlAddEventHandler ["ButtonClick",{true}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH(SIZE_M),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 0;
					_ctrl ctrlSetStructuredText parseText format["<t size='1.04167'>%1</t>",(["ChannelName",_channel] call FUNC(commonTask))];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_SIDE,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*2)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_SIDE] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*2)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 1;
					_ctrl ctrlSetStructuredText parseText format["<t size='1.04167'>%1</t>",(["ChannelName",_channel] call FUNC(commonTask))];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_COMMAND,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*3)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_COMMAND] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*3)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 2;
					_ctrl ctrlSetStructuredText parseText format["<t size='1.04167'>%1</t>",(["ChannelName",_channel] call FUNC(commonTask))];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_GROUP,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*4)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_GROUP] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*4)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 3;
					_ctrl ctrlSetStructuredText parseText format["<t size='1.04167'>%1</t>",(["ChannelName",_channel] call FUNC(commonTask))];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_VEHICLE,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*5)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_VEHICLE] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*5)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 4;
					_ctrl ctrlSetStructuredText parseText format["<t size='1.04167'>%1</t>",(["ChannelName",_channel] call FUNC(commonTask))];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_DIRECT,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*6)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_DIRECT] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*6)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 5;
					_ctrl ctrlSetStructuredText parseText format["<t size='1.04167'>%1</t>",(["ChannelName",_channel] call FUNC(commonTask))];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[
				"ctrlCheckbox",IDC_CB_CUSTOM,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*7)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl cbSetChecked (["get",VAL_SETTINGS_INDEX_PRINT_CUSTOM] call FUNC(settings));
					_ctrl ctrlAddEventhandler ["CheckedChanged",{["CBFilterChanged",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlStructuredText",-1,[
					PXCX(DIALOG_W) + PXW(4) + PXW(SIZE_M),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*7)),
					PXW(50) - PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					private _channel = 6;
					_ctrl ctrlSetStructuredText parseText format["<t size='1.04167'>%1</t>",(["ChannelName",_channel] call FUNC(commonTask))];
					_ctrl ctrlSetTextColor (["ChannelColour",_channel] call FUNC(commonTask));
					_ctrl ctrlAddEventHandler ["ButtonClick",format["['CBLabelClicked',%1] call %2",_channel,QUOTE(THIS_FUNC)]];
				}
			],
			[// ctrlEdit crashes game when used with ctrlCreate
				"RscEdit",IDC_EDIT_SEARCH,[
					PXCX(DIALOG_W) + PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*8.5)),
					PXW(50) - PXW(SIZE_M) - PXW(4),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetFont FONT_NORMAL;
					_ctrl ctrlSetFontHeight PXH(4.32);
					_ctrl ctrlSetBackgroundColor [COLOR_OVERLAY_RGB,0.4];
					_ctrl ctrlAddEventHandler ["KeyDown",{["EditSearchModified",_this] call THIS_FUNC}];
				}
			],
			[
				"ctrlButtonSearch",-1,[
					PXCX(DIALOG_W) + PXW(4)	 + PXW(50) - PXW(SIZE_M) - PXW(4),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(4) + PXH((SIZE_M*8.5)),
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlAddEventHandler ["ButtonClick",{["ButtonSearchClicked"] call THIS_FUNC}];
				}
			],
			[// Can't colour ctrlButton so doing this as alternative
				"ctrlStatic",IDC_STATIC_RELOAD,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(3) + PXH((SIZE_M*10.5)),
					PXW(50),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlShow false;
					_ctrl ctrlSetBackgroundColor [COLOR_NOTE_ERROR_RGBA];
				}
			],
			[// Clear button with hover highlight
				"ctrlButtonFilter",IDC_BUTTON_RELOAD,[
					PXCX(DIALOG_W) + PXW(2),
					PXCY(DIALOG_H) + PXH((SIZE_M*2)) + PXH(3) + PXH((SIZE_M*10.5)),
					PXW(50),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlShow false;
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

		USE_CTRL(_ctrlNewMessageStatic,IDC_STATIC_RELOAD);
		USE_CTRL(_ctrlNewMessageButton,IDC_BUTTON_RELOAD);

		private _newMessages = _ctrlNewMessageButton getVariable ["newMessages",0];
		_newMessages = _newMessages + 1;
		_ctrlNewMessageButton setVariable ["newMessages",_newMessages];

		_ctrlNewMessageButton ctrlSetText format[
			"New Message%1 (%2)",
			["s",""] select (_newMessages == 1),
			_newMessages
		];
		_ctrlNewMessageStatic ctrlShow true;
		_ctrlNewMessageButton ctrlShow true;
	};
	case "CBLabelClicked":{
		private _idc = switch _params do {
			case 0:{IDC_CB_GLOBAL};
			case 1:{IDC_CB_SIDE};
			case 2:{IDC_CB_COMMAND};
			case 3:{IDC_CB_GROUP};
			case 4:{IDC_CB_VEHICLE};
			case 5:{IDC_CB_DIRECT};
			case 6:{IDC_CB_CUSTOM};
			default {IDC_CB_SYSTEM};
		};

		disableSerialization;
		USE_DISPLAY(THIS_DISPLAY);

		private _toggleMode = [
			{ctrlIDC _this == _idc},
			{ctrlIDC _this != _idc}
		] select (cbChecked(_display displayCtrl _idc));
		{_x cbSetChecked (_x call _toggleMode)} count [
			_display displayCtrl IDC_CB_SYSTEM,
			_display displayCtrl IDC_CB_GLOBAL,
			_display displayCtrl IDC_CB_SIDE,
			_display displayCtrl IDC_CB_COMMAND,
			_display displayCtrl IDC_CB_GROUP,
			_display displayCtrl IDC_CB_VEHICLE,
			_display displayCtrl IDC_CB_DIRECT,
			_display displayCtrl IDC_CB_CUSTOM
		];

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

		USE_CTRL(_ctrlCBSystem,IDC_CB_SYSTEM);
		USE_CTRL(_ctrlCBGlobal,IDC_CB_GLOBAL);
		USE_CTRL(_ctrlCBSide,IDC_CB_SIDE);
		USE_CTRL(_ctrlCBCommand,IDC_CB_COMMAND);
		USE_CTRL(_ctrlCBGroup,IDC_CB_GROUP);
		USE_CTRL(_ctrlCBVehicle,IDC_CB_VEHICLE);
		USE_CTRL(_ctrlCBDirect,IDC_CB_DIRECT);
		USE_CTRL(_ctrlCBCustom,IDC_CB_CUSTOM);
		USE_CTRL(_ctrlEditSearch,IDC_EDIT_SEARCH);
		USE_CTRL(_ctrlGroupMessages,IDC_GROUP_MESSAGES);
		USE_CTRL(_ctrlNewMessageStatic,IDC_STATIC_RELOAD);
		USE_CTRL(_ctrlNewMessageButton,IDC_BUTTON_RELOAD);
		USE_CTRL(_ctrlImageSpinner,IDC_IMAGE_SPINNER);

		_ctrlGroupMessages ctrlShow false;
		_ctrlImageSpinner ctrlShow true;

		_ctrlNewMessageStatic ctrlShow false;
		_ctrlNewMessageButton ctrlShow false;
		_ctrlNewMessageButton setVariable ["newMessages",0];

		private _showSystem = cbChecked _ctrlCBSystem;
		private _showGlobal = cbChecked _ctrlCBGlobal;
		private _showSide = cbChecked _ctrlCBSide;
		private _showCommand = cbChecked _ctrlCBCommand;
		private _showGroup = cbChecked _ctrlCBGroup;
		private _showVehicle = cbChecked _ctrlCBVehicle;
		private _showDirect = cbChecked _ctrlCBDirect;
		private _showCustom = cbChecked _ctrlCBCustom;

		private _searchTerm = ctrlText _ctrlEditSearch;
		private _doSearchStrings = _searchTerm != "";

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

			(VAR_HISTORY#_i) params ["_text","_channel","_senderName","_senderUID","_channelColour","_channelName","_received"];

			private _canSeeChannel = switch _channel do {
				case 0:{_showGlobal};
				case 1:{_showSide};
				case 2:{_showCommand};
				case 3:{_showGroup};
				case 4:{_showVehicle};
				case 5:{_showDirect};
				case 6;case 7;case 8;case 9;case 10;case 11;case 12;case 13;case 14;
				case 15:{_showCustom};
				default {_showSystem};
			};
			private _containsSearchTerm = if _doSearchStrings then {
				[_searchTerm,_text] call BIS_fnc_inString || {
					[_searchTerm,_senderName] call BIS_fnc_inString || {
						_searchTerm == _senderUID
					}
				}
			} else {true};

			if (_canSeeChannel && _containsSearchTerm) then {
				_channelName = if (_channelName != "") then {_channelName} else {
					["ChannelName",_channel] call FUNC(commonTask);
				};
				private _channelColour = if (count _channelColour == 4) then {_channelColour} else {
					["ChannelColour",_channel] call FUNC(commonTask);
				};
				_senderName = ["StreamSafeName",[_senderUID,_senderName]] call FUNC(commonTask);

				private _ctrlMessageContainer = ["CreateMessageCard",[_ctrlGroupMessages,_channelName,_channelColour,_received call _getTimePast,_senderName,_text]] call THIS_FUNC;

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
		_params params ["_ctrlGroupMessages","_channelName","_channelColour","_received","_senderName","_text"];

		disableSerialization;
		USE_DISPLAY(THIS_DISPLAY);
		private _ctrlGroupMessagesPos = ctrlPosition _ctrlGroupMessages;

		private _ctrlMessageContainer = _display ctrlCreate ["ctrlControlsGroupNoScrollbars",-1,_ctrlGroupMessages];
		private _ctrlMessageContainerPos = [PXW(2),_ctrlGroupMessagesPos#3,_ctrlGroupMessagesPos#2 - PXW(4),0];

		private _ctrlMessageBackground = _display ctrlCreate ["ctrlStatic",2,_ctrlMessageContainer];
		_ctrlMessageBackground ctrlSetBackgroundColor [0,0,0,0.2];
		private _ctrlMessageBackgroundPos = [0,0,_ctrlGroupMessagesPos#2 - PXW(4),0];

		private _ctrlMessageStripe = _display ctrlCreate ["ctrlStatic",3,_ctrlMessageContainer];
		_ctrlMessageStripe ctrlSetBackgroundColor _channelColour;
		private _ctrlMessageStripePos = [0,0,PXW(0.5),0];

		private _ctrlMessageText = _display ctrlCreate ["ctrlStructuredText",4,_ctrlMessageContainer];
		private _ctrlMessageTextPos = [PXW(0.5),PXH(1),_ctrlMessageContainerPos#2 - PXW(0.5),0];
		_ctrlMessageText ctrlSetPosition _ctrlMessageTextPos;
		_ctrlMessageText ctrlCommit 0;

		_finalText = [];
		if (_senderName != "") then {
			_finalText pushback format[
				"<t font='%2'>%1</t> %3",
				localize "STR_CAU_xChat_history_sent_by",
				FONT_BOLD,
				_senderName
			];
		};
		_finalText pushback format[
			"<t font='%2'>%1</t> <t color='%3'>%4</t>",
			localize "STR_CAU_xChat_history_channel",
			FONT_BOLD,
			_channelColour call BIS_fnc_colorRGBAToHTML,
			_channelName
		];
		_finalText pushback format[
			"<t font='%2'>%1</t> %3",
			localize "STR_CAU_xChat_history_received",
			FONT_BOLD,
			_received
		];
		_finalText pushback format[
			"<t font='%2'>%1</t><br/><t color='#A6A6A6'>%3</t>",
			localize "STR_CAU_xChat_history_message",
			FONT_BOLD,
			_text
		];

		_finalText = "<t size='1.15741'>"+(_finalText joinString "<br/>")+"</t>";
		_ctrlMessageText ctrlSetStructuredText parseText _finalText;
		private _containsImg = ["<img ",_text] call BIS_fnc_inString;

		private _height = ctrlTextHeight _ctrlMessageText + ([0,PXH(0.4)] select _containsImg);
		_ctrlMessageContainerPos set [3,_height + PXH(2)];
		_ctrlMessageBackgroundPos set [3,_ctrlMessageContainerPos#3];
		_ctrlMessageStripePos set [3,_ctrlMessageContainerPos#3];
		_ctrlMessageTextPos set [3,_height];

		_ctrlMessageContainer ctrlSetPosition _ctrlMessageContainerPos;
		_ctrlMessageBackground ctrlSetPosition _ctrlMessageBackgroundPos;
		_ctrlMessageStripe ctrlSetPosition _ctrlMessageStripePos;
		_ctrlMessageText ctrlSetPosition _ctrlMessageTextPos;

		{_x ctrlCommit 0;} count [
			_ctrlMessageContainer,
			_ctrlMessageBackground,
			_ctrlMessageStripe,
			_ctrlMessageText
		];

		_ctrlMessageContainer
	};
};
