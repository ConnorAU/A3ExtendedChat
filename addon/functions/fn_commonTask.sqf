/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_commonTask

Description:
	A single function containing frequently used micro-functions

Parameters:
	_mode   : STRING - The name of the micro-function
    _params : ANY    - The arguments provided to the micro-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(commonTask)

#include "_macros.inc"
#include "_defines.inc"

SWITCH_SYS_PARAMS;

switch _mode do {
	case "ChannelColour":{
		_params params ["_id",["_systemPrimary",true]];
		["colorConfigToRGBA",switch _id do {
			case 0:{getArray(configFile >> "RscChatListDefault" >> "colorGlobalChannel")};
			case 1:{getArray(configFile >> "RscChatListDefault" >> "colorSideChannel")};
			case 2:{getArray(configFile >> "RscChatListDefault" >> "colorCommandChannel")};
			case 3:{getArray(configFile >> "RscChatListDefault" >> "colorGroupChannel")};
			case 4:{getArray(configFile >> "RscChatListDefault" >> "colorVehicleChannel")};
			case 5:{getArray(configFile >> "RscChatListDefault" >> "colorDirectChannel")};
			case 6;case 7;case 8;case 9;case 10;case 11;case 12;case 13;case 14;
			case 15:{["get",[_params - 5,0]] call FUNC(radioChannelCustom)};

			default {
				// red for history view, grey for message feed
				[
					[0.8,0.1,0.1,1],
					[0,0,0,0.4]
				] select _systemPrimary;
			};
		}] call THIS_FUNC;
	};
	case "ChannelName":{
		switch _params do {
			case 0:{localize "str_channel_global"};
			case 1:{localize "str_channel_side"};
			case 2:{localize "str_channel_command"};
			case 3:{localize "str_channel_group"};
			case 4:{localize "str_channel_vehicle"};
			case 5:{localize "str_channel_direct"};
			case 6;case 7;case 8;case 9;case 10;case 11;case 12;case 13;case 14;
			case 15:{["get",[_params-5,1]] call FUNC(radioChannelCustom)};
			case -2:{localize "STR_CAU_xChat_channel_command"}; // chat commands
			default {localize "STR_CAU_xChat_channel_system"};
		};
	};
	case "SideName":{
		switch _params do {
			case civilian:{localize "str_civilian"};
			case west:{localize "str_west"};
			case east:{localize "str_east"};
			case independent:{localize "str_guerrila"};
			default {""};
		};
	};
	case "StreamSafeName":{
		_params params ["_uid","_name"];
		[_name,localize "str_a3_rscdisplaydynamicgroups_you"] select (_uid == getPlayerUID player && {isStreamFriendlyUIEnabled})
	};
	case "ClientNamePrefix":{
		_params params ["_unit","_channelID"];
		if (_channelID < 6) then {
			private _prefix = switch _channelID do {
				case 0:{["SideName",side group _unit] call THIS_FUNC};
				case 1;
				case 2:{groupID group _unit};
				default {""};
			};
			if (_prefix != "") then {
				format["(%1) %2",_prefix,UNIT_NAME(_unit)];
			} else {UNIT_NAME(_unit)};
		} else {
			private _channelName = ["get",[_channelID - 5,1]] call FUNC(radioChannelCustom);
			private _channelCallsign = ["get",[_channelID - 5,2]] call FUNC(radioChannelCustom);
			if (["stringPrefix",[_channelCallsign,"$STR_"]] call THIS_FUNC) then {
				_channelCallsign = localize _channelCallsign;
			};
			{
				_channelCallsign = ["stringReplace",[_channelCallsign,_x#0,_x#1]] call THIS_FUNC;
				false
			} count [
				["%CHANNEL_LABEL",_channelName],
				["%UNIT_SIDE",["SideName",playerSide] call FUNC(commonTask)],
				["%UNIT_NAME",UNIT_NAME(player)],
				["%UNIT_RANK",[player,"displayNameShort"] call BIS_fnc_rankParams],
				["%UNIT_ID",""], // not sure what this refers to
				["%UNIT_REF",""], // not sure what this refers to
				["%UNIT_GRP_NAME",groupID group player],
				["%UNIT_GRP_LEADER",["",", "+ tolower localize "str_3den_attributes_triggeractivationowner_leader_text"] select (player == leader group player)],
				["%UNIT_VEH_NAME",["",getText(configFile >> "CfgVehicles" >> typeof player >> "displayName")] select (player != vehicle player)],
				["%UNIT_VEH_POSITION ",mapGridPosition vehicle player]
			];
			_channelCallsign
		};
	};
	case "ScaledFeedTextSize":{
		(((((safezoneW/safezoneH)min 1.2)/1.2)/25)*0.8)/(PXH(4.32))
	};
	case "colorConfigToRGBA":{
		/*
			BIS_fnc_colorConfigToRGBA uses safe number parsing which doesn't permit
			** Reverted to unsafe number parsing
		*/
		_params apply {_x call BIS_fnc_parseNumber};
	};
	case "formatSystemDate":{
		_params params ["_year","_month","_day","_hour","_minute"];

		private _meridiem = ["AM","PM"] select (_hour >= 12);
		_hour = if (_hour == 0) then {12} else {if (_hour > 12) then {_hour - 12} else {_hour}};
		if (_minute < 10) then {_minute = "0" + str _minute};

		format [
			"%1 %2, %3, %4:%5 %6",
			localize format["str_3den_attributes_date_month%1_text",_month],
			_day,_year,_hour,_minute,_meridiem
		];
	};


	case "stringPrefix":{
		_params params ["_input","_find",["_caseSensitive",false]];

		if !_caseSensitive then {
			_input = toLower _input;
			_find = toLower _find;
		};

		_input find _find == 0
	};
	case "stringSuffix":{
		_params params ["_input","_find",["_caseSensitive",false]];

		if !_caseSensitive then {
			_input = toLower _input;
			_find = toLower _find;
		};

		(_input select [count _input - count _find,count _find]) isEqualTo _find
	};
	case "stringReplace":{
		_params params ["_input","_find","_replace",["_caseSensitive",false]];
		_find params ["_find",["_findPrefix",""],["_findSuffix",""]];
		private _findFull = _findPrefix + _find + _findSuffix;
		private _findLen = count _find;
		private _findPLen = count _findPrefix;
		if !_caseSensitive then {_findFull = toLower _findFull};
		private _output = [];
		private _index = -1;
		for "_i" from 0 to 1 step 0 do {
			_index = if _caseSensitive then {_input find _findFull} else {
				tolower _input find _findFull
			};
			if (_index < 0) exitwith {_output pushback _input;};
			if (_findPrefix != "") then {_index = _index + _findPLen};
			_output pushback (_input select [0,_index]);
			_output pushback _replace;
			_input = _input select [_index + _findLen];
		};
		_output joinString ""
	};
	case "stringSplitString":{
		_params params ["_input","_find"];
		private _findLen = count _find;
		_find = toLower _find;
		private _output = [];
		private _index = -1;
		for "_i" from 0 to 1 step 0 do {
			_index = tolower _input find _find;
			if (_index < 0) exitwith {_output pushback _input;};
			_output pushback (_input select [0,_index]);
			_input = _input select [_index + _findLen];
		};
		_output
	};
	case "stringSplitStringKeep":{
		_params params ["_input","_find"];
		private _findLen = count _find;
		private _findLow = toLower _find;
		private _output = [];
		private _index = -1;
		for "_i" from 0 to 1 step 0 do {
			_index = tolower _input find _findLow;
			if (_index < 0) exitwith {_output pushback _input;};
			_output pushback (_input select [0,_index]);
			_output pushBack _find;
			_input = _input select [_index + _findLen];
		};
		_output
	};
};
