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
			} forEach ("true" configClasses (_x >> "CfgEmoji"));
		} forEach [missionConfigFile,configFile];
		false
	};
	case "getList":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {[]};
		_params params [["_force",false,[true]]];
		private _addedClasses = [];
		private _emojis = [];
		private _condition = ["call compile getText(_x >> 'condition')","true"] select _force;
		{
			_x = _x select {_addedClasses pushBackUnique configName _x != -1} apply {
				[
					getText(_x >> "displayName"),
					getText(_x >> "icon"),
					getArray(_x >> "keywords"),
					getArray(_x >> "shortcuts"),
					_forEachIndex == 0,
					getText(_x >> "condition")
				]
			};
			_emojis append _x;
		} forEach [
			_condition configClasses (missionConfigFile >> "CfgEmoji"),
			_condition configClasses (configFile >> "CfgEmoji")
		];
		_emojis
	};
	case "getItem":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {[]};
		_params params [["_find","",[""]],["_force",false,[true]]];
		private _condition = format[
			"'%1' in getArray(_x >> 'keywords')%2",
			_find,
			if _force then {""} else {" && {call compile getText(_x >> 'condition')}"}
		];
		private _emoji = [];
		{
			if (count _x > 0) exitWith {
				_emoji = [
					getText(_x#0 >> "displayName"),
					getText(_x#0 >> "icon"),
					getArray(_x#0 >> "keywords"),
					getArray(_x#0 >> "shortcuts"),
					_forEachIndex == 0,
					getText(_x#0 >> "condition")
				];
			};
		} forEach [
			_condition configClasses (missionConfigFile >> "CfgEmoji"),
			_condition configClasses (configFile >> "CfgEmoji")
		];
		_emoji
	};
	case "getImage":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {""};
		private _emoji = ["getItem",[_params,true]] call THIS_FUNC;
		if (_emoji isEqualTo []) exitWith {""};
		format["<img color='#FFFFFF' image='%1'/>",_emoji#1];
	};
	case "formatCondition":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {_params};
		{
			_x params ["","_icon","_keywords","_shortcuts","","_condition"];
			if !([] call compile _condition) then {
				{
					_params = ["formatLogic",[_params,_x,""]] call THIS_FUNC;
				} forEach _shortcuts;
				{
					_params = ["formatLogic",[_params,":"+_x+":",""]] call THIS_FUNC;
				} forEach _shortcuts;
			};
		} forEach (["getList",true] call THIS_FUNC);
		_params
	};
	case "formatImages":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_EMOJIS),false]) exitWith {_params};
		{
			_x params ["","_icon","_keywords","_shortcuts"];
			_icon = format["<img color='#FFFFFF' image='%1'/>",_icon];
			{
				_params = ["formatLogic",[_params,["SafeStructuredText",_x] call FUNC(commonTask),_icon]] call THIS_FUNC;
			} forEach _shortcuts;
			{
				_params = ["formatLogic",[_params,":"+_x+":",_icon]] call THIS_FUNC;
			} forEach _keywords;
		} forEach (["getList",true] call THIS_FUNC);
		_params
	};
	case "formatLogic":{
		_params params ["_text","_find","_replace"];

		if (_text isEqualTo _find) then {_text = _replace} else {
			if (_find in _text) then {
				if (["stringPrefix",[_text,format["%1 ",_find],true]] call FUNC(commonTask)) then {
					_text = _replace + (_text select [count _find]);
				};
				if (["stringSuffix",[_text,format[" %1",_find],true]] call FUNC(commonTask)) then {
					_text = (_text select [0,count _text - count _find]) + _replace;
				};
				_text = ["stringReplace",[_text,[_find," "," "],_replace,true]] call FUNC(commonTask);
			};
		};

		_text
	};
};
