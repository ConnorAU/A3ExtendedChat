/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_stringReplace

Description:
	None

Parameters:
	_input         : STRING - String to search
    _find          : STRING - String to find
    _replace       : STRING - String to put in _find's place
    _caseSensitive : BOOL   - Specifies a case sensitive or case inssensitive search (default: false)

Return:
	STRING - Modified _input string
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(stringReplace)

#include "_defines.inc"

params ["_input","_find","_replace",["_caseSensitive",false]];
private _findLen = count _find;
if !_caseSensitive then {_find = toLower _find};
private _output = [];
private _index = -1;
for "_i" from 0 to 1 step 0 do {
    _index = if _caseSensitive then {_input find _find} else {
        tolower _input find _find
    };
    if (_index < 0) exitwith {_output pushback _input;};
    _output pushback (_input select [0,_index]);
    _output pushback _replace;
    _input = _input select [_index + _findLen,count _input];
};
_output joinString ""
