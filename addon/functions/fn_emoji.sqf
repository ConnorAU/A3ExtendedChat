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
					_params = ["stringReplace",[_params,_shortcut,"",true]] call FUNC(commonTask);
				};
				_params = ["stringReplace",[_params,_keyword,"",true]] call FUNC(commonTask);
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
				_params = ["stringReplace",[_params,["SafeStructuredText",_shortcut] call FUNC(commonTask),_keyword,true]] call FUNC(commonTask);
			};
			_params = ["stringReplace",[_params,_keyword,["getImage",_x#2] call THIS_FUNC,true]] call FUNC(commonTask);
		} count (["getList",true] call THIS_FUNC);
		_params
	};
};
