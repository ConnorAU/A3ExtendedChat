/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_emoji

Description:
	Master handler for all emoji related tasks

Parameters:
	_mode   : STRING - The name of the sub-function
    _params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(emoji)

#include "_macros.inc"
#include "_defines.inc"

#define DIALOG_W ((BUTTON_W*(EMOJI_W-1)) + 2 + (SIZE_M*2) + 4)
#define DIALOG_H ((BUTTON_H*6) + (SIZE_M*2) + 6)

#define BUTTON_W (SIZE_M*2)
#define BUTTON_H (SIZE_M*2)

#define EMOJI_W 8

SWITCH_SYS_PARAMS;

switch _mode do {
	/*case "initDisplay":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {};

		USE_DISPLAY(findDisplay 24);
		USE_CTRL(_ctrlEdit,101);
		private _ctrlEditHeight = ctrlPosition _ctrlEdit#3;

		USE_DISPLAY(DISPLAY(VAR_CHAT_OVERLAY_DISPLAY));
		private _ctrlCharCounter = _display getVariable ["ctrlCharCount",controlNull];

		private _ctrlGroupMain = _display ctrlCreate ["ctrlControlsGroupNoScrollbars",-1];
		_ctrlGroupMain ctrlSetPosition [
			PXCX(DIALOG_W),
			(safezoney+safezoneh) - _ctrlEditHeight*2.5 - PXH(DIALOG_H),
			PXW(DIALOG_W),
			PXH(DIALOG_H)
		];
		_ctrlGroupMain ctrlCommit 0;

		_ctrlGroupMain ctrlAddEventHandler ["Unload",{
			diag_log (_this#0);
			USE_DISPLAY(ctrlParent(_this#0));
			diag_log _display;
			private _ctrlList = _display getVariable ["ctrlListSuggestions",controlNull];
			diag_log _ctrlList;
			_ctrlList ctrlShow true;
			_ctrlList ctrlEnable true;
		}];

		{
			_x params ["_type","_idc","_position",["_init",{}]];
			private _ctrl = _display ctrlCreate [_type,_idc,_ctrlGroupMain];
			_ctrl ctrlSetPosition _position;
			call _init;
			_ctrl ctrlCommit 0;
		} count [

		// ~~ Main Controls
			[// dummy ctrl because creating certain controls hides the first ctrl, thanks arma
				"ctrlStatic",-1,[0,0,0,0]
			],
			[
				"ctrlStaticBackground",-1,[
					0,0,
					PXW(DIALOG_W),
					PXH(DIALOG_H)
				]
			],
			[
				"ctrlStaticTitle",-1,[
					0,0,
					PXW(DIALOG_W),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText localize "STR_CAU_xChat_emoji_title";
				}
			],
			[
				"ctrlButtonPicture",-1,[
					PXW((DIALOG_W - SIZE_M)),
					0,
					PXW(SIZE_M),
					PXH(SIZE_M)
				],
				{
					_ctrl ctrlSetText "\a3\3DEN\Data\Displays\Display3DEN\search_end_ca.paa";
					_ctrl ctrlAddEventHandler ["ButtonClick",{["closeDisplay",[ctrlParentControlsGroup(_this#0)]] call THIS_FUNC}];
				}
			],
			[
				"ctrlStaticFooter",-1,[
					0,
					PXH((DIALOG_H - SIZE_M - 2)),
					PXW(DIALOG_W),
					PXH((SIZE_M + 2))
				]
			],

		// ~~ Body,
			[
				"ctrlStaticOverlay",-1,[
					PXW(2),
					PXH((SIZE_M + 2)),
					PXW((DIALOG_W - 4)),
					PXH((DIALOG_H - 4 - SIZE_M - SIZE_M - 2))
				],
				{
					_ctrl ctrlSetBackgroundColor [0,0,0,1];
				}
			],
			[
				"ctrlControlsGroup",-1,[
					PXW(2),
					PXH((SIZE_M + 2)),
					PXW((DIALOG_W - 4)),
					PXH((DIALOG_H - 4 - SIZE_M - SIZE_M - 2))
				],
				{
					USE_DISPLAY(ctrlParent _ctrl);
					private _ctrlPos = ctrlPosition _ctrl;
					private _subCtrlPos = [
						-PXW(BUTTON_W),
						-PXH(BUTTON_H),
						PXW(BUTTON_W),
						PXH(BUTTON_H)
					];

					private _emojis = ["getList"] call THIS_FUNC;
					private _missionRoot = str missionConfigFile select [0,count str missionConfigFile - 15];

					if (count _emojis == 0) exitWith {
						["closeDisplay",[_ctrl]] call THIS_FUNC;
					};

					//_emojis sort true;
					{
						_x params ["_name","_icon","_keyword","_shortcut","_inMission"];
						_keyword = ":"+_keyword+":";

						if ((_forEachIndex%EMOJI_W) == 0) then {
							_subCtrlPos set [0,0];
							_subCtrlPos set [1,(_subCtrlPos#1)+PXH(BUTTON_H)];
						} else {
							_subCtrlPos set [0,(_subCtrlPos#0)+PXW(BUTTON_W)];
						};

						private _subCtrl = _display ctrlCreate ["ctrlButtonPictureKeepAspect",-1,_ctrl];
						if _inMission then {_icon = _missionRoot + _icon};
						_subCtrl ctrlSetText _icon;
						_subCtrl ctrlSetTooltip format["Name:%4%1%4%4Keyword:%4%2%4%3",_name,_keyword,["",endl+"Shortcut:"+endl+_shortcut] select (_shortcut != ""),endl];
						_subCtrl ctrlSetPosition _subCtrlPos;
						_subCtrl ctrlCommit 0;

						_subCtrl ctrlAddEventHandler ["ButtonClick",format["['ButtonClick',%1] call %2",_x,QUOTE(THIS_FUNC)]];
					} forEach _emojis;
				}
			]
		];
	};
	case "closeDisplay":{
		_params params ["_ctrlGroupMain"];

		USE_DISPLAY(ctrlParent _ctrlGroupMain);
		private _ctrlList = _display getVariable ["ctrlListSuggestions",controlNull];
		_ctrlList ctrlShow true;
		_ctrlList ctrlEnable true;

		ctrlDelete _ctrlGroupMain;
	};
	case "ButtonClick":{
		_params params ["","","_keyword","_shortcut"];

		// needs to be a seperate display so the mouse cursor will show up
		USE_DISPLAY(findDisplay 24);
		USE_CTRL(_ctrlEdit,101);

		private _insert = [":"+_keyword+":",_shortcut] select (_shortcut != "");
		private _text = ctrlText _ctrlEdit;
		ctrlTextSelection _ctrlEdit params ["_curPos","_selection"];

		if (_selection < 0) then {
			_curPos = _curPos + _selection;
			_selection = abs _selection;
		};

		_text = [
			_text select [0,_curPos],
			_insert,
			_text select [_curPos + _selection]
		] joinString "";

		// char limit
		if (count _text <= 150) then {
			_ctrlEdit ctrlSetText _text;
			_ctrlEdit ctrlSetTextSelection [_curPos + count _insert,0];

			USE_DISPLAY(DISPLAY(VAR_CHAT_OVERLAY_DISPLAY));
			private _ctrlCharCount = _display getVariable ["ctrlCharCount",controlNull];
			if (!isNull _ctrlCharCount) then {
				[_ctrlEdit] call (_ctrlCharCount getVariable ["update",{}]);
			};
		} else {
			_ctrlEdit spawn {
				private _start = diag_tickTime;
				private _end = _start + 0.25;

				[COLOR_NOTE_ERROR_RGBA] params ["_errR","_errG","_errB","_errA"];
				[COLOR_BACKGROUND_RGBA] params ["_normR","_normG","_normB","_normA"];

				waitUntil {
					_this ctrlSetBackgroundColor [
						linearConversion[_start,_end,diag_tickTime,_errR,_normR,true],
						linearConversion[_start,_end,diag_tickTime,_errG,_normG,true],
						linearConversion[_start,_end,diag_tickTime,_errB,_normB,true],
						linearConversion[_start,_end,diag_tickTime,_errA,_normA,true]
					];
					diag_tickTime > _end
				};
			};
		};
	};*/


	case "isAvailable":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {false};
		_params params [["_force",false,[true]]];
		scopeName _mode;
		{
			{
				if (_force || {[] call compile getText(_x >> "condition")}) then {
					true breakOut _mode;
				};
			} forEach _x; //  list of classes
		} forEach [
			"true" configClasses (missionConfigFile >> "CfgEmoji"),
			"true" configClasses (configFile >> "CfgEmoji")
		];
		false
	};
	case "getList":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {[]};
		_params params [["_force",false,[true]]];
		private _addedKeywords = [];
		private _emojis = [];
		{
			private _forEachI = _forEachIndex;
			{
				if (_force || {[] call compile getText(_x >> "condition")}) then {
					private _keyword = getText(_x >> "keyword");
					if !(_keyWord in _addedKeywords) then {
						_addedKeywords pushback getText(_x >> "keyword");
						_emojis pushBack [
							getText(_x >> "displayName"),
							gettext(_x >> "icon"),
							_keyword,
							gettext(_x >> "shortcut"),
							_forEachI == 0,
							getText(_x >> "condition")
						];
					};
				};
				false
			} count _x; //  list of classes
		} forEach [
			"true" configClasses (missionConfigFile >> "CfgEmoji"),
			"true" configClasses (configFile >> "CfgEmoji")
		];
		_emojis
	};
	case "getImage":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {""};
		private _emojis = ["getList"] call THIS_FUNC;
		private _index = _emojis findIf {(_x#2) == _params};
		if (_index == -1) exitWith {""};
		format["<img color='#FFFFFF' image='%1'/>",_emojis#_index#1];
	};
	case "formatCondition":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {_params};
		{
			_x params ["","_icon","_keyword","_shortcut","","_condition"];
			if !([] call compile _condition) then {
				_keyword = ":"+_keyword+":";
				if (_shortcut != "") then {
					_params = [_params,_shortcut,"",true] call FUNC(stringReplace);
				};
				_params = [_params,_keyword,"",true] call FUNC(stringReplace);
			};
		} count (["getList",true] call THIS_FUNC);
		_params
	};
	case "formatImages":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {_params};
		{
			_x params ["","_icon","_keyword","_shortcut"];
			_keyword = ":"+_keyword+":";
			if (_shortcut != "") then {
				_params = [_params,["SafeStructuredText",_shortcut] call FUNC(commonTask),_keyword,true] call FUNC(stringReplace);
			};
			_params = [_params,_keyword,["getImage",_x#2] call THIS_FUNC,true] call FUNC(stringReplace);
		} count (["getList",true] call THIS_FUNC);
		_params
	};
};
