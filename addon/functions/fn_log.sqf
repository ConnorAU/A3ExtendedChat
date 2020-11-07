/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_log

Description:
	Master handler for server-side logging

Parameters:
	_mode   : STRING - The name of the sub-function
    _params : ANY    - The arguments provided to the sub-function

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(log)

#include "_defines.inc"

#define VAL_ENABLE_LOG_VAR(n) format["%1_%2",QUOTE(VAR_ENABLE_LOGGING),n]

if !isServer exitWith {};

SWITCH_SYS_PARAMS;

switch _mode do {
	case "toggle":{
		// toggle entire logging system
		if (_params isEqualType true) exitWith {
			// broadcast variable to prevent remoteexec while logging is disabled
			missionNameSpace setVariable [QUOTE(VAR_ENABLE_LOGGING),_params,true];
			_params
		};

		// toggle individual channel
		if !(_params isEqualType 0) exitWith {false};
		private _variable = VAL_ENABLE_LOG_VAR(_params);
		private _value = missionNameSpace getVariable [_variable,true];
		if !(_value isEqualType true) then {_value = true;};
		_value = !_value;
		missionNameSpace setVariable [_variable,_value];
		_value
	};
	case "text":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]) exitWith {};
		_params params [
			["_channelID",-10,[0]],
			["_text","",[""]],
			["_name","",[""]],
			["_pid","",[""]]
		];
		if !(missionNameSpace getVariable [VAL_ENABLE_LOG_VAR(_channelID),true]) exitWith {};
		if (_text == "") exitWith {};

		private _channel = ["ChannelName",_channelID] call FUNC(commonTask);

		// Parse mentions
		if (_text find "@" != -1) then {
			_text = ["stringSplitStringKeep",[_text," "]] call FUNC(commonTask);
			_text = ["parse",_text] call FUNC(mention);
			_text = _text apply {if (_x isEqualType "") then {_x} else {str _x}} joinString "";
		};

		private _log = if (_channelID < 0 || _channelID > 15) then {_text} else {
			format[
				(["(%3) ",""] select (_pid == "")) + "%1: %2",
				_name,_text,_pid
			];
		};

		// text _log so it dequotes the log string
		"ExtendedChat" callExtension [format["%1 %2",_channelID,_channel],[text _log]];
	};
	case "voice":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]) exitWith {};
		_params params [
			["_active",true,[true]],
			["_channelID",-10,[0]],
			["_name","",[""]],
			["_pid","",[""]]
		];

		// dont log channels like system as it cant be spoken into
		if !(missionNameSpace getVariable [VAL_ENABLE_LOG_VAR(_channelID),true]) exitWith {};

		private _channel = ["ChannelName",_channelID] call FUNC(commonTask);
		if (_channel == "") exitWith {};

		private _log = format[
			"(%1) %2 %4 speaking in %3",
			_pid,_name,_channel,
			["stopped","started"] select _active
		];

		// text _log so it dequotes the log string
		"ExtendedChat" callExtension [format["%1 %2 VON",_channelID,_channel],[text _log]];
	};
};

nil
