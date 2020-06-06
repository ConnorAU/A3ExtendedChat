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
if (_command != "" && str _code != "{}") then {
	if _preventOverwrite then {
		private _codeStr = str _code;
		_codeStr = _codeStr select [1,count _codeStr - 2];
		_code = compileFinal _codeStr;
	};
    private _var = QUOTE(VAR_COMMAND_CODE_PREFIX) + _command;
    _success = isNil _var;
    if _success then {
	    missionNameSpace setVariable [_var,_code];
    } else {
        // Attempt to wipe the variable to see if it can be overridden
        missionNameSpace setVariable [_var,nil];
        _success = isNil _var;
        if _success then {
	        missionNameSpace setVariable [_var,_code];
        };
    };
};

_success
