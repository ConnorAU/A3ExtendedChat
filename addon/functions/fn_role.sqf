/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_role

Description:
	Master handler for all role related tasks

Parameters:
	_mode   : STRING - The name of the sub-function
	_params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(role)

#include "_macros.inc"
#include "_defines.inc"

#define VAR_DATA QUOTE(FUNC_SUBVAR(data))
#define GET_DATA (missionNamespace getVariable [VAR_DATA,[]]) params [["_id",-1],["_roles",[]]]

SWITCH_SYS_PARAMS;

switch _mode do {
	case "create":{
		private _defaultColor = ["get",VAL_SETTINGS_KEY_TEXT_MENTION_COLOR] call FUNC(settings);
		_params params [
			["_name","",[""]],
			["_color",_defaultColor,[[],""]],
			["_ownerIDs",[],[[]]]
		];

		if (_name == "") exitWith {false};

		GET_DATA;

		if (_roles findIf {(_x#1) == _name} != -1) exitWith {-1};

		if (_color isEqualTo "" || (_color isEqualType [] && {!(_color isEqualTypeArray [0,0,0,0])})) then {_color = _defaultColor};
		if (_color isEqualType []) then {_color = _color call BIS_fnc_colorRGBAtoHTML};

		_id = _id + 1;
		_roles pushBack [_id,_name,_color,_ownerIDs];

		missionNamespace setVariable [VAR_DATA,[_id,_roles],true];

		_id
	};
	case "delete":{
		_params params [["_roleID",-1,[0]]];

		GET_DATA;

		private _index = _roles findIf {_x#0 isEqualTo _roleID};
		if (_index == -1) exitWith {false};

		_roles deleteAt _index;
		missionNamespace setVariable [VAR_DATA,[_id,_roles],true];

		true
	};


	case "add":{
		_params params [["_roleID",-1,[0]],["_ownerIDs",[],[[],0]]];

		GET_DATA;

		private _index = _roles findIf {_x#0 isEqualTo _roleID};
		if (_index == -1) exitWith {false};

		if (_ownerIDs isEqualType 0) then {_ownerIDs = [_ownerIDs]};
		_ownerIDs = _ownerIDs  - _roles#_index#3;
		_roles#_index#3 append _ownerIDs;

		missionNamespace setVariable [VAR_DATA,[_id,_roles],true];

		true
	};
	case "remove":{
		_params params [["_roleID",-1,[0]],["_ownerIDs",[],[[],0]]];

		GET_DATA;

		private _index = _roles findIf {_x#0 isEqualTo _roleID};
		if (_index == -1) exitWith {false};

		if (_ownerIDs isEqualType 0) then {_ownerIDs = [_ownerIDs]};
		_roles#_index set [3,_roles#_index#3 - _ownerIDs];

		missionNamespace setVariable [VAR_DATA,[_id,_roles],true];

		true
	};


	case "getAllRoles":{
		GET_DATA;
		_roles
	};
	case "getRole":{
		_params params [["_roleID",-1,[0]]];
		GET_DATA;
		_roles param [_roles findIf {_x#0 isEqualTo _roleID},[]]
	};
	case "getUnitRoles":{
		_params params [["_unit",objNull,[objNull]]];
		["getOwnerIDRoles",[UNIT_OID(_unit)]] call THIS_FUNC;
	};
	case "getOwnerIDRoles":{
		_params params [["_ownerID",-1,[0]]];
		GET_DATA;
		_roles select {_ownerID in _x#3}
	};
};
