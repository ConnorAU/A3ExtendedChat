/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_command

Description:
	Master handler for all chat commands included with the mod

Parameters:
	_mode   : STRING - The name of the sub-function
	_params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(command)

#include "_macros.inc"
#include "_defines.inc"


if (_this#0 isequaltype "") exitWith {
	[ QUOTE(THIS_FUNC) ] call BIS_fnc_recompile;
	[true,_this] call THIS_FUNC;
};
_this = _this#1;


SWITCH_SYS_PARAMS;

switch _mode do {
	case "mute";
	case "unmute":{
		if (_params isEqualTo []) exitWith {
			//systemChat "No target provided";
		};

		private _parsed = ["extractTargets",_params joinString " "] call FUNC(mention);

		if (_parsed findIf {_x isEqualType grpNull} != -1) then {
			//systemChat "Groups cannot be muted";
		};
		if (_parsed findIf {_x isEqualType []} != -1) then {
			//systemChat "Roles cannot be muted";
		};

		_parsed = (_parsed-[clientOwner]) select {_x isEqualType 0};
		if (_parsed isEqualTo []) exitWith {
			//systemChat "No target mention found";
		};

		private _found = [];
		private _setting = ["get",VAL_SETTINGS_KEY_MUTED_PLAYERS] call FUNC(settings);

		if (_mode isEqualTo "mute") then {
			private _time = ["formatSystemDate",systemTime] call FUNC(commonTask);
			{
				private _pIndex = _parsed find (UNIT_OID(_x));
				if (_pIndex != -1) then {
					private _unitUID = getPlayerUID _x;
					if (_setting findIf {_x#1 isEqualTo _unitUID} == -1) then {
						_found pushBack format["p@%1",_parsed#_pIndex];
						_setting pushBack [UNIT_NAME(_x),_unitUID,_time];
					};
				};
			} forEach allPlayers;
		} else {
			{
				private _pIndex = _parsed find (UNIT_OID(_x));
				if (_pIndex != -1) then {
					private _unitUID = getPlayerUID _x;
					private _mIndex = _setting findIf {_x#1 isEqualTo _unitUID};
					if (_mIndex != -1) then {
						_found pushBack format["p@%1",_parsed#_pIndex];
						_setting deleteAt _mIndex;
					};
				};
			} forEach allPlayers;
		};

		["set",[VAL_SETTINGS_KEY_MUTED_PLAYERS,_setting]] call FUNC(settings);

		if (_found isNotEqualTo []) then {
			private _action = ["Unmuted ","Muted "] select (_mode isEqualTo "mute");
			systemChat (_action+(_found joinString " "));
		};
	};

	case "whisper":{
		if (count _params == 1) exitWith {
			//systemChat "No whisper message provided";
		};

		_params params ["_target"];
		if (_target find "@" != 1) exitWith {
			//systemChat "No whisper target mention provided";
		};

		private _parsed = ["extractTargets",_target] call FUNC(mention);
		if (_parsed isEqualTo []) exitWith {
			//systemChat "No whisper target found";
		};
		if (_parsed isEqualTo [clientOwner]) exitWith {
			//systemChat "You cannot whisper yourself";
		};

		private _message = _argumentsRaw select [count _target + 1];

		[
			"systemChat",
			["p@",clientOwner," whispers to you ",_target," : ",_message] joinString ""
		] remoteExecCall [QUOTE(FUNC(sendMessage)),_parsed#0];

		systemChat (["You whispered to ",_target," : ",_message] joinString "");
	};

	case "history":{["init",findDisplay 46] call FUNC(historyUI)};
	case "settings":{["init",findDisplay 46] call FUNC(settingsUI)};
};
