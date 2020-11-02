/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_settings

Description:
	Master handler for the settings system

Parameters:
	_mode   : STRING - The name of the sub-function
    _params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(settings)

#include "_defines.inc"
#include "_dikcodes.inc"

SWITCH_SYS_PARAMS;

private _settings = profileNameSpace getVariable [VAR_SETTINGS,[[],[]]];

switch _mode do {
	case "init":{
		[ QUOTE(THIS_FUNC) ] call BIS_fnc_recompile;
		["init2",_params] call THIS_FUNC;
	};
	case "init2":{
		// verify the settings array elements
		private _version = if (_settings isEqualTypeArray [[],[]]) then {
			_settings#1 param [_settings#0 find VAL_SETTINGS_KEY_VERSION,"v0",[""]];
		} else {
			_settings param [0,"v0",[""]];
		};
		private _repeatInit = false;
		private _resetArray = false;

		switch _version do {
			case "v1":{
				private _correctSize = count _settings == 15;
				private _correctFormat = _settings params ["",
					["_VAL_SETTINGS_INDEX_COMMAND_PREFIX","",[""]],
					["_VAL_SETTINGS_INDEX_MAX_SAVED",0,[0]],
					["_VAL_SETTINGS_INDEX_MAX_PRINTED",0,[0]],
					["_VAL_SETTINGS_INDEX_TTL_PRINTED",0,[0]],
					["_VAL_SETTINGS_INDEX_PRINT_CONNECTED",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DISCONNECTED",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_KILL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GLOBAL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_SIDE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_COMMAND",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GROUP",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_VEHICLE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DIRECT",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_CUSTOM",true,[true]]
				];

				if (!_correctSize || !_correctFormat) then {
					_resetArray = true;
				} else {
					_settings set [0,"v1.1"];
					_settings = [_settings,[true],8/*VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION*/] call BIS_fnc_arrayInsert;

					profileNameSpace setVariable [VAR_SETTINGS,_settings];
					_repeatInit = true;
				};
			};
			case "v1.1":{
				private _correctSize = count _settings == 16;
				private _correctFormat = _settings params ["",
					["_VAL_SETTINGS_INDEX_COMMAND_PREFIX","",[""]],
					["_VAL_SETTINGS_INDEX_MAX_SAVED",0,[0]],
					["_VAL_SETTINGS_INDEX_MAX_PRINTED",0,[0]],
					["_VAL_SETTINGS_INDEX_TTL_PRINTED",0,[0]],
					["_VAL_SETTINGS_INDEX_PRINT_CONNECTED",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DISCONNECTED",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_KILL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GLOBAL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_SIDE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_COMMAND",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GROUP",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_VEHICLE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DIRECT",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_CUSTOM",true,[true]]
				];

				if (!_correctSize || !_correctFormat) then {
					_resetArray = true;
				} else {
					_settings set [0,"v1.2"];
					_settings = [_settings,[
						"RobotoCondensedLight",1,
						[0.651,0.651,0.651,1],[0.1,0.1,0.1,0.5]
					],5/*VAL_SETTINGS_INDEX_TEXT_FONT*/] call BIS_fnc_arrayInsert;

					profileNameSpace setVariable [VAR_SETTINGS,_settings];
					_repeatInit = true;
				};
			};
			case "v1.2":{
				private _correctSize = count _settings == 20;
				private _correctFormat = _settings params ["",
					["_VAL_SETTINGS_INDEX_COMMAND_PREFIX","",[""]],
					["_VAL_SETTINGS_INDEX_MAX_SAVED",0,[0]],
					["_VAL_SETTINGS_INDEX_MAX_PRINTED",0,[0]],
					["_VAL_SETTINGS_INDEX_TTL_PRINTED",0,[0]],
					["_VAL_SETTINGS_INDEX_TEXT_FONT","",[""]],
					["_VAL_SETTINGS_INDEX_TEXT_SIZE",0,[0]],
					["_VAL_SETTINGS_INDEX_TEXT_COLOR",[],[[]],4],
					["_VAL_SETTINGS_INDEX_FEED_BG_COLOR",[],[[]],4],
					["_VAL_SETTINGS_INDEX_PRINT_CONNECTED",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DISCONNECTED",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_KILL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GLOBAL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_SIDE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_COMMAND",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GROUP",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_VEHICLE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DIRECT",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_CUSTOM",true,[true]]
				];

				if (!_correctSize || !_correctFormat) then {
					_resetArray = true;
				} else {
					_settings set [0,"v2"];
					_settings = [_settings,[
						[0.545098,0.65098,0.894118,1],
						[0.984,0.655,0.071,0.2],
						DIK_TAB
					],9/*VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR*/] call BIS_fnc_arrayInsert;
					_settings = [_settings,[true],14/*VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR*/] call BIS_fnc_arrayInsert;
					_settings deleteAt 16; // unsupported mission log

					profileNameSpace setVariable [VAR_SETTINGS,_settings];
					_repeatInit = true;
				};
			};
			case "v2":{
				private _correctSize = count _settings == 23;
				private _correctFormat = _settings params ["",
					["_VAL_SETTINGS_INDEX_COMMAND_PREFIX","",[""]],
					["_VAL_SETTINGS_INDEX_MAX_SAVED",0,[0]],
					["_VAL_SETTINGS_INDEX_MAX_PRINTED",0,[0]],
					["_VAL_SETTINGS_INDEX_TTL_PRINTED",0,[0]],
					["_VAL_SETTINGS_INDEX_TEXT_FONT","",[""]],
					["_VAL_SETTINGS_INDEX_TEXT_SIZE",0,[0]],
					["_VAL_SETTINGS_INDEX_TEXT_COLOR",[],[[]],4],
					["_VAL_SETTINGS_INDEX_FEED_BG_COLOR",[],[[]],4],
					["_VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR",[],[[]],4],
					["_VAL_SETTINGS_INDEX_FEED_MENTION_BG_COLOR",[],[[]],4],
					["_VAL_SETTINGS_INDEX_AUTOCOMPLETE_KEYBIND",0,[0]],
					["_VAL_SETTINGS_INDEX_PRINT_CONNECTED",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DISCONNECTED",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_BATTLEYE_KICK",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_KILL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GLOBAL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_SIDE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_COMMAND",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GROUP",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_VEHICLE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DIRECT",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_CUSTOM",true,[true]]
				];

				if (!_correctSize || !_correctFormat) then {
					_resetArray = true;
				} else {
					private _keys = [];
					private _values = [];
					{
						_keys pushBack _x;
						_values pushBack (_settings#_forEachIndex);
					} forEach [
						VAL_SETTINGS_KEY_VERSION,
						VAL_SETTINGS_KEY_COMMAND_PREFIX,
						VAL_SETTINGS_KEY_MAX_SAVED,
						VAL_SETTINGS_KEY_MAX_PRINTED,
						VAL_SETTINGS_KEY_TTL_PRINTED,
						VAL_SETTINGS_KEY_TEXT_FONT,
						VAL_SETTINGS_KEY_TEXT_SIZE,
						VAL_SETTINGS_KEY_TEXT_COLOR,
						VAL_SETTINGS_KEY_FEED_BG_COLOR,
						VAL_SETTINGS_KEY_TEXT_MENTION_COLOR,
						VAL_SETTINGS_KEY_FEED_MENTION_BG_COLOR,
						VAL_SETTINGS_KEY_AUTOCOMPLETE_KEYBIND,
						VAL_SETTINGS_KEY_PRINT_CONNECTED,
						VAL_SETTINGS_KEY_PRINT_DISCONNECTED,
						VAL_SETTINGS_KEY_PRINT_BATTLEYE_KICK,
						VAL_SETTINGS_KEY_PRINT_DEATH,
						VAL_SETTINGS_KEY_PRINT_GLOBAL,
						VAL_SETTINGS_KEY_PRINT_SIDE,
						VAL_SETTINGS_KEY_PRINT_COMMAND,
						VAL_SETTINGS_KEY_PRINT_GROUP,
						VAL_SETTINGS_KEY_PRINT_VEHICLE,
						VAL_SETTINGS_KEY_PRINT_DIRECT,
						VAL_SETTINGS_KEY_PRINT_CUSTOM
					];

					profileNameSpace setVariable [VAR_SETTINGS,[_keys,_values]];

					["set",[VAL_SETTINGS_KEY_VERSION,"v2.1"]] call THIS_FUNC;
					["set",[VAL_SETTINGS_KEY_TOGGLE_CHAT_FEED_KEYBIND,-1]] call THIS_FUNC;
					["set",[VAL_SETTINGS_KEY_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE,false]] call THIS_FUNC;

					_repeatInit = true;
				};
			};
			case "v2.1":{
				private _correctSize = count(_settings#0) == 25 && count(_settings#1) == 25;
				private _correctFormat = true;

				private _default = ["default"] call THIS_FUNC;
				{
					private _value = _settings#1#(_settings#0 find _x);
					private _dValue = _default#1#_forEachIndex;
					if (isNil "_value" || {!(_value isEqualType _dValue)}) then {
						_correctFormat = false;
						diag_log [_x,typeName _dValue,typeName _value,_value];
						[_value] param [0,_dValue,[_dValue]]; // Used to show script error
					};
				} forEach _default#0;

				if (!_correctSize || !_correctFormat) then {
					_resetArray = true;
				};
			};
			default {_resetArray = true};
		};

		if _resetArray then {
			diag_log text "Extended Chat: Reverting settings to default values";
			profileNameSpace setVariable [VAR_SETTINGS,["default"] call THIS_FUNC];
		};

		if _repeatInit then {
			// repeat when updating to a new version format.
			// will save the settings in the next version format then repeat the init to verify/update again if multiple versions behind.
			diag_log text "Extended Chat: Repeating settings initialization";
			_this call THIS_FUNC;
		} else {
			saveProfileNamespace;
		};
	};


	case "default":{
		[[
			VAL_SETTINGS_KEY_VERSION,
			VAL_SETTINGS_KEY_COMMAND_PREFIX,
			VAL_SETTINGS_KEY_MAX_SAVED,
			VAL_SETTINGS_KEY_MAX_PRINTED,
			VAL_SETTINGS_KEY_TTL_PRINTED,
			VAL_SETTINGS_KEY_AUTOCOMPLETE_KEYBIND,
			VAL_SETTINGS_KEY_TOGGLE_CHAT_FEED_KEYBIND,
			VAL_SETTINGS_KEY_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE,
			VAL_SETTINGS_KEY_TEXT_FONT,
			VAL_SETTINGS_KEY_TEXT_SIZE,
			VAL_SETTINGS_KEY_TEXT_COLOR,
			VAL_SETTINGS_KEY_FEED_BG_COLOR,
			VAL_SETTINGS_KEY_TEXT_MENTION_COLOR,
			VAL_SETTINGS_KEY_FEED_MENTION_BG_COLOR,
			VAL_SETTINGS_KEY_PRINT_CONNECTED,
			VAL_SETTINGS_KEY_PRINT_DISCONNECTED,
			VAL_SETTINGS_KEY_PRINT_BATTLEYE_KICK,
			VAL_SETTINGS_KEY_PRINT_DEATH,
			VAL_SETTINGS_KEY_PRINT_GLOBAL,
			VAL_SETTINGS_KEY_PRINT_SIDE,
			VAL_SETTINGS_KEY_PRINT_COMMAND,
			VAL_SETTINGS_KEY_PRINT_GROUP,
			VAL_SETTINGS_KEY_PRINT_VEHICLE,
			VAL_SETTINGS_KEY_PRINT_DIRECT,
			VAL_SETTINGS_KEY_PRINT_CUSTOM
		],[
			"v2.1",
			"#",
			500,
			10,
			45,
			DIK_TAB,
			-1,
			false,
			"RobotoCondensedLight",
			1,
			[0.651,0.651,0.651,1],
			[0.1,0.1,0.1,0.5],
			[0.545098,0.65098,0.894118,1],
			[0.984,0.655,0.071,0.2],
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true
		]]
	};


	case "get":{
		private _default = ["default"] call THIS_FUNC;
		private _value = _default#1 param [_default#0 find _params,nil];
		_settings#1 param [_settings#0 find _params,_value,[_value]];
	};
	case "set":{
		_params params ["_key","_value"];
		private _index = _settings#0 find _key;
		if (_index == -1) then {_index = _settings#0 pushBack _key};
		_settings#1 set [_index,_value];
		profileNamespace setVariable [VAR_SETTINGS,_settings];
	};
	case "reset":{
		profileNameSpace setVariable [VAR_SETTINGS,nil];
		["init"] call THIS_FUNC;
	};
};
