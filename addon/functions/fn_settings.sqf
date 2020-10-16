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

switch _mode do {
	case "init":{
		// verify the settings array elements
		private _settings = profileNameSpace getVariable [VAR_SETTINGS,["v0"]];
		private _version = _settings param [0,"v0",[""]];
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
					_settings deleteAt 15; // unsupported mission log

					profileNameSpace setVariable [VAR_SETTINGS,_settings];
					_repeatInit = true;
				};
			};
			case "v2":{
				private _correctSize = count _settings == 22;
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
					["_VAL_SETTINGS_INDEX_PRINT_KILL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GLOBAL",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_SIDE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_COMMAND",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_GROUP",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_VEHICLE",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_DIRECT",true,[true]],
					["_VAL_SETTINGS_INDEX_PRINT_CUSTOM",true,[true]]
				];

				if (!_correctSize || !_correctFormat) then {_resetArray = true};
			};
			default {_resetArray = true;};
		};

		if _resetArray then {
			profileNameSpace setVariable [VAR_SETTINGS,[]];

			_settings = [
				["get",0] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_MAX_SAVED] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_MAX_PRINTED] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_TTL_PRINTED] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_TEXT_FONT] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_TEXT_SIZE] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_TEXT_COLOR] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_FEED_BG_COLOR] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_FEED_MENTION_BG_COLOR] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_AUTOCOMPLETE_KEYBIND] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_CONNECTED] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_DISCONNECTED] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_KILL] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_GLOBAL] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_SIDE] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_COMMAND] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_GROUP] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_VEHICLE] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_DIRECT] call THIS_FUNC,
				["get",VAL_SETTINGS_INDEX_PRINT_CUSTOM] call THIS_FUNC
			];
		};

		profileNameSpace setVariable [VAR_SETTINGS,_settings];

		if _repeatInit then {
			// repeat when updating to a new version format.
			// will save the settings in the next version format then repeat the init to verify/update again if multiple versions behind.
			_this call THIS_FUNC;
		} else {
			saveProfileNamespace;
		};
	};
	case "get":{
		private _settings = profileNameSpace getVariable [VAR_SETTINGS,[]];
		private _default = [
			"v2",                             // Array format version
			"#",                              // VAL_SETTINGS_INDEX_COMMAND_PREFIX
			500,                              // VAL_SETTINGS_INDEX_MAX_SAVED
			10,                               // VAL_SETTINGS_INDEX_MAX_PRINTED
			45,                               // VAL_SETTINGS_INDEX_TTL_PRINTED
			"RobotoCondensedLight",           // VAL_SETTINGS_INDEX_TEXT_FONT
			1,                                // VAL_SETTINGS_INDEX_TEXT_SIZE
			[0.651,0.651,0.651,1],            // VAL_SETTINGS_INDEX_TEXT_COLOR
			[0.1,0.1,0.1,0.5],                // VAL_SETTINGS_INDEX_FEED_BG_COLOR
			[0.545098,0.65098,0.894118,1],    // VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR
			[0.984,0.655,0.071,0.2],          // VAL_SETTINGS_INDEX_FEED_MENTION_BG_COLOR
			DIK_TAB,                          // VAL_SETTINGS_INDEX_AUTOCOMPLETE_KEYBIND
			true,                             // VAL_SETTINGS_INDEX_PRINT_CONNECTED
			true,                             // VAL_SETTINGS_INDEX_PRINT_DISCONNECTED
			true,                             // VAL_SETTINGS_INDEX_PRINT_KILL
			true,                             // VAL_SETTINGS_INDEX_PRINT_GLOBAL
			true,                             // VAL_SETTINGS_INDEX_PRINT_SIDE
			true,                             // VAL_SETTINGS_INDEX_PRINT_COMMAND
			true,                             // VAL_SETTINGS_INDEX_PRINT_GROUP
			true,                             // VAL_SETTINGS_INDEX_PRINT_VEHICLE
			true,                             // VAL_SETTINGS_INDEX_PRINT_DIRECT
			true                              // VAL_SETTINGS_INDEX_PRINT_CUSTOM
		]#_params;
		_settings param [_params,_default,[_default]];
	};
	case "set":{
		private _settings = profileNameSpace getVariable [VAR_SETTINGS,[]];
		_settings set _params;
	};
	case "reset":{
		profileNameSpace setVariable [VAR_SETTINGS,nil];
		["init"] call THIS_FUNC;
	};
};
