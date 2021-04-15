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

private _settings = profileNameSpace getVariable [VAR_SETTINGS,createHashMap];

switch _mode do {
	case "init":{
		// verify the settings array elements
		private _version = if (_settings isEqualType createHashMap) then {
			_settings getOrDefault [VAL_SETTINGS_KEY_VERSION,"v0"]
		} else {
			if (_settings isEqualTypeArray [[],[]]) then {
				_settings#1 param [_settings#0 find VAL_SETTINGS_KEY_VERSION,"v0",[""]];
			} else {
				_settings param [0,"v0",[""]];
			};
		};

		private _repeatInit = false;
		private _resetSettings = false;

		switch _version do {
			case "v2.2":{
				private _default = ["default"] call THIS_FUNC;
				private _correctSize = count keys _settings == count keys _default;
				private _correctFormat = true;

				{
					private _value = _settings get _x;
					private _dValue = _default get _x;
					if (isNil "_value" || {!(_value isEqualType _dValue)}) then {
						_correctFormat = false;
						diag_log [_x,typeName _dValue,typeName _value,_value];
						[_value] param [0,_dValue,[_dValue]]; // Used to show script error
					};
				} forEach keys _settings;

				if (!_correctSize || !_correctFormat) then {
					_resetSettings = true;
				};
			};
			case "v2.1":{
				private _default = ["default"] call THIS_FUNC;
				private _defaultCount = count keys _default;

				private _correctSize = count(_settings#0) == _defaultCount && count(_settings#1) == _defaultCount;
				private _correctFormat = true;

				{
					private _value = _settings#1#(_settings#0 find _x);
					private _dValue = _default get _x;
					if (isNil "_value" || {!(_value isEqualType _dValue)}) then {
						_correctFormat = false;
						diag_log [_x,typeName _dValue,typeName _value,_value];
						[_value] param [0,_dValue,[_dValue]]; // Used to show script error
					};
				} forEach keys _default;

				if (!_correctSize || !_correctFormat) then {
					_resetSettings = true;
				} else {
					private _default = ["default"] call THIS_FUNC;
					private _hashmap = [];

					{
						private _value = _settings#1#_forEachIndex;
						private _dValue = _default get _x;

						if (isNil "_value" || {!(_value isEqualType _dValue)}) then {
							_correctFormat = false;
							diag_log [_x,typeName _dValue,typeName _value,_value];
							_value = [_value] param [0,_dValue,[_dValue]]; // Used to show script error
						};

						_hashmap pushBack [_x,_value];
					} forEach _settings#0;

					_settings = createHashMapFromArray _hashmap;
					profileNameSpace setVariable [VAR_SETTINGS,_settings];

					["set",[VAL_SETTINGS_KEY_VERSION,"v2.2"]] call THIS_FUNC;

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
					_resetSettings = true;
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

					private _default = ["default"] call THIS_FUNC;
					["set",[VAL_SETTINGS_KEY_VERSION,"v2.1"]] call THIS_FUNC;
					["add",VAL_SETTINGS_KEY_TOGGLE_CHAT_FEED_KEYBIND] call THIS_FUNC;
					["add",VAL_SETTINGS_KEY_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE] call THIS_FUNC;
					["add",VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER] call THIS_FUNC;
					["add",VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER_TERMS] call THIS_FUNC;
					["add",VAL_SETTINGS_KEY_WEBSITE_WHITELIST] call THIS_FUNC;
					["add",VAL_SETTINGS_KEY_WEBSITE_WHITELIST_TERMS] call THIS_FUNC;
					["add",VAL_SETTINGS_KEY_MUTED_PLAYERS] call THIS_FUNC;

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
					_resetSettings = true;
				} else {
					_settings set [0,"v2"];
					_settings insert [9/*VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR*/,[
						[0.545098,0.65098,0.894118,1],
						[0.984,0.655,0.071,0.2],
						DIK_TAB
					],false];
					_settings insert [14/*VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR*/,[true],false];
					_settings deleteAt 16; // unsupported mission log

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
					_resetSettings = true;
				} else {
					_settings set [0,"v1.2"];
					_settings insert [5/*VAL_SETTINGS_INDEX_TEXT_FONT*/,[
						"RobotoCondensedLight",1,
						[0.651,0.651,0.651,1],[0.1,0.1,0.1,0.5]
					],false];

					profileNameSpace setVariable [VAR_SETTINGS,_settings];
					_repeatInit = true;
				};
			};
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
					_resetSettings = true;
				} else {
					_settings set [0,"v1.1"];
					_settings insert [8/*VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION*/,[true],false];

					profileNameSpace setVariable [VAR_SETTINGS,_settings];
					_repeatInit = true;
				};
			};
			default {_resetSettings = true};
		};

		if _resetSettings then {
			diag_log text "Extended Chat: Reverting settings to default values";
			profileNameSpace setVariable [VAR_SETTINGS,["default"] call THIS_FUNC];
		};

		if _repeatInit then {
			// repeat when updating to a new version format.
			// will save the settings in the next version format then repeat the init to verify/update again if multiple versions behind.
			diag_log text "Extended Chat: Repeating settings initialization";
			if (productVersion#2 isEqualTo 202) then {
				// Temporary workaround for some bug causing game crash in 2.02 when updating from v1.1
				addMissionEventHandler ["EachFrame",format["removeMissionEventHandler ['EachFrame',_thisEventhandler];%1 call %2",_this,QUOTE(THIS_FUNC)]];
			} else {
				_this call THIS_FUNC;
			};
		} else {
			saveProfileNamespace;
		};
	};


	case "default":{
		private _languageFilter = loadFile "cau\extendedchat\data\profanity\list.txt" splitString endl;

		createHashMapFromArray [
			[VAL_SETTINGS_KEY_VERSION,"v2.2"],
			[VAL_SETTINGS_KEY_COMMAND_PREFIX,"#"],
			[VAL_SETTINGS_KEY_MAX_SAVED,500],
			[VAL_SETTINGS_KEY_MAX_PRINTED,10],
			[VAL_SETTINGS_KEY_TTL_PRINTED,45],
			[VAL_SETTINGS_KEY_AUTOCOMPLETE_KEYBIND,DIK_TAB],
			[VAL_SETTINGS_KEY_TOGGLE_CHAT_FEED_KEYBIND,-1],
			[VAL_SETTINGS_KEY_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE,false],
			[VAL_SETTINGS_KEY_TEXT_FONT,"RobotoCondensedLight"],
			[VAL_SETTINGS_KEY_TEXT_SIZE,1],
			[VAL_SETTINGS_KEY_TEXT_COLOR,[0.651,0.651,0.651,1]],
			[VAL_SETTINGS_KEY_FEED_BG_COLOR,[0.1,0.1,0.1,0.5]],
			[VAL_SETTINGS_KEY_TEXT_MENTION_COLOR,[0.545098,0.65098,0.894118,1]],
			[VAL_SETTINGS_KEY_FEED_MENTION_BG_COLOR,[0.984,0.655,0.071,0.2]],
			[VAL_SETTINGS_KEY_PRINT_CONNECTED,true],
			[VAL_SETTINGS_KEY_PRINT_DISCONNECTED,true],
			[VAL_SETTINGS_KEY_PRINT_BATTLEYE_KICK,true],
			[VAL_SETTINGS_KEY_PRINT_DEATH,true],
			[VAL_SETTINGS_KEY_PRINT_GLOBAL,true],
			[VAL_SETTINGS_KEY_PRINT_SIDE,true],
			[VAL_SETTINGS_KEY_PRINT_COMMAND,true],
			[VAL_SETTINGS_KEY_PRINT_GROUP,true],
			[VAL_SETTINGS_KEY_PRINT_VEHICLE,true],
			[VAL_SETTINGS_KEY_PRINT_DIRECT,true],
			[VAL_SETTINGS_KEY_PRINT_CUSTOM,true],
			[VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER,false],
			[VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER_TERMS,_languageFilter],
			[VAL_SETTINGS_KEY_WEBSITE_WHITELIST,true],
			[VAL_SETTINGS_KEY_WEBSITE_WHITELIST_TERMS,["arma3.com","bohemia.net","bistudio.com","youtu.be"]],
			[VAL_SETTINGS_KEY_MUTED_PLAYERS,[]]
		]
	};


	case "get":{
		private _default = ["default"] call THIS_FUNC;
		private _value = _settings getOrDefault [_params,_default get _params];
		if (_value isEqualType []) then {+_value} else {_value}
	};
	case "set":{
		_params params ["_key","_value"];
		if (_settings isEqualType createHashMap) then {
			_settings set [_key,_value];
		} else {
			_settings#1 set [_settings#0 find _key,_value];
		};
		profileNamespace setVariable [VAR_SETTINGS,_settings];
	};
	case "add":{
		private _default = ["default"] call THIS_FUNC;
		if (_settings isEqualType createHashMap) then {
			_settings set [_params,_default get _params];
		} else {
			private _value = _default get _params;
			_settings#0 pushBack _params;
			_settings#1 pushBack _value;
		};
		profileNamespace setVariable [VAR_SETTINGS,_settings];
	};
	case "remove":{
		if (_settings isEqualType createHashMap) then {
			_settings deleteAt _params;
		} else {
			private _index = _settings#0 find _params;
			_settings#0 deleteAt _index;
			_settings#1 deleteAt _index;
		};
		profileNamespace setVariable [VAR_SETTINGS,_settings];
	};
	case "reset":{
		profileNameSpace setVariable [VAR_SETTINGS,nil];
		["init"] call THIS_FUNC;
	};
};
