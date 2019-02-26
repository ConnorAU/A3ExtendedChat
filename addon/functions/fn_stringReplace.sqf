/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

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
