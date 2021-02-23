/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_addCommand

Description:
	Adds a command that can be invoked from the chat input

Parameters:
	_command          : STRING - The keyword used in chat to invoke the command
	_code             : CODE   - The code to execute when the command is invoked
    _preventOverwrite : BOOL   - Recompiles _code with compileFinal to prevent modification (default: true)

Return:
	BOOL - true if the command was added, false if it failed
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(addCommand)

#include "_defines.inc"

params [["_command","",[""]],["_code",{},[{}]],["_preventOverwrite",true,[true]]];

private _success = false;
if (_command != "" && _code isNotEqualTo {}) then {
	private _commands = VAR_COMMANDS_ARRAY;
	private _index = _commands findIf {_x#0 == _command};

	// Exit if overwrite prevented
	if (_index > -1 && {_commands#_index#2}) exitWith {};
	if (_index == -1) then {_index = count _commands};

	_commands set [_index,[_command,_code,_preventOverwrite]];
	_success = true;
};

_success
