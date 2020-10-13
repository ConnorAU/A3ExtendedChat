/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_processCommand

Description:
	Invokes the requested command with the arguments provided

Parameters:
	_text : STRING - The complete message text

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(processChatCommand)

#include "_defines.inc"

params ["_text"];

private _split = _text splitString " ";
private _prefix = ["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call FUNC(settings);
private _command = _split#0 select [count _prefix,count(_split#0)];
private _arguments = _split select [1,count _split];

systemChat(_split#0);

private _commands = VAR_COMMANDS_ARRAY;
private _index = _commands findIf {_x#0 == _command};
if (_index > -1) then {
	_arguments call (_commands#_index#1);
};

nil
