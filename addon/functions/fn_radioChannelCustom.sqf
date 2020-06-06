/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_radioChannelCustom

Description:
	Master handler for the custom radio channel system

Parameters:
	_mode   : STRING - The name of the sub-function
    _params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(radioChannelCustom)

#include "_defines.inc"

#define VAR_CHANNEL_INFO FUNC_SUBVAR(info)

SWITCH_SYS_PARAMS;

switch (tolower _mode) do {
	case "init":{
		if !isServer exitWith {};
		if (!isNil QUOTE(VAR_CHANNEL_INFO)) exitWith {};
		VAR_CHANNEL_INFO = [[[],"","",[]]];
		publicVariable QUOTE(VAR_CHANNEL_INFO);
	};
	case "radiochannelcreate":{
		if !isServer exitWith {-1};
		_params params [
			["_colour",[1,1,1,1],[[]],4],
			["_label","",[""]],
			["_callSign","",[""]],
			["_units",[],[[]]]
		];
		if (_callSign == "") then {_callSign = "(%UNIT_GRP_NAME) %UNIT_NAME"};
		private _id = radioChannelCreate[_colour,_label,_callSign,[],false];
		VAR_CHANNEL_INFO set [_id,[_colour,_label,_callSign,[]]];
		if (_label == "") then {
			_label = format["Radio Channel %1",_id];
			["radioChannelSetLabel",[_id,_label]] call THIS_FUNC;
		};
		["radioChannelAdd",[_id,_units]] call THIS_FUNC;
		_id
	};
	case "radiochanneladd":{
		if !isServer exitWith {};
		_params params [
			["_id",-1,[0]],
			["_units",[],[[]]]
		];
		if (_id < 1) exitWith {};
		_id radioChannelAdd _units;

		private _idInfo = VAR_CHANNEL_INFO#_id;
		private _idUnits = _idInfo#3;
		{_idUnits pushBackUnique (owner _x);false} count _units;
		publicVariable QUOTE(VAR_CHANNEL_INFO);
	};
	case "radiochannelremove":{
		if !isServer exitWith {};
		_params params [
			["_id",-1,[0]],
			["_units",[],[[]]]
		];
		if (_id < 1) exitWith {};
		_id radioChannelRemove _units;

		private _idInfo = VAR_CHANNEL_INFO#_id;
		_idInfo set [3,(_idInfo#3) - (_units apply {owner _x})];
		publicVariable QUOTE(VAR_CHANNEL_INFO);
	};
	case "radiochannelsetlabel":{
		if !isServer exitWith {};
		_params params [
			["_id",-1,[0]],
			["_label","",[""]]
		];
		if (_id < 1 || _label == "") exitWith {};
		_id radioChannelSetLabel _label;

		(VAR_CHANNEL_INFO#_id) set [1,_label];
		publicVariable QUOTE(VAR_CHANNEL_INFO);
	};
	case "radiochannelsetcallsign":{
		if !isServer exitWith {};
		_params params [
			["_id",-1,[0]],
			["_callSign","",[""]]
		];
		if (_id < 1 || _callSign == "") exitWith {};
		_id radioChannelSetCallSign _callSign;

		(VAR_CHANNEL_INFO#_id) set [2,_callSign];
		publicVariable QUOTE(VAR_CHANNEL_INFO);
	};
	case "disconnect":{
		if !isServer exitWith {};
		private _removed = false;
		{
			if (_params in (_x#3)) then {
				_removed = true;
				_x set [3,(_x#3) - [_params]];
			};
			false
		} count VAR_CHANNEL_INFO;
		if _removed then {
			publicVariable QUOTE(VAR_CHANNEL_INFO);
		};
	};
	case "get":{
		_params params [
			["_id",-1,[0]],
			["_index",-1,[0]]
		];
		if (-1 in [_id,_index]) exitWith {};
		VAR_CHANNEL_INFO#_id#_index
	};
};
