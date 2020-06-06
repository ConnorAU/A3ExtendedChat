/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_stringPrefix

Description:
	Checks if a string starts with the specified series of characters

Parameters:
	_input         : STRING - String to search
    _find          : STRING - String to find
    _caseSensitive : BOOL   - Specifies a case sensitive or case inssensitive search (default: false)

Return:
	BOOL - true if _input starts with _find
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(stringPrefix)

#include "_defines.inc"

params ["_input","_find",["_caseSensitive",false]];

private _index = if _caseSensitive then {_input find _find} else {
    tolower _input find toLower _find
};

_index == 0
