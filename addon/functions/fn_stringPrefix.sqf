/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(stringPrefix)

#include "_defines.inc"

params ["_input","_find",["_caseSensitive",false]];

private _index = if _caseSensitive then {_input find _find} else {
    tolower _input find toLower _find
};

_index == 0