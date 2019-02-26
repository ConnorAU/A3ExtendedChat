/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(addCommand)

#include "_defines.inc"

params [["_command","",[""]],["_code",{},[{}]],["_preventOverwrite",true,[true]]];

if (_command != "" && str _code != "{}") then {
	if _preventOverwrite then {
		private _codeStr = str _code;
		_codeStr = _codeStr select [1,count _codeStr - 2];
		_code = compileFinal _codeStr;
	};
	missionNameSpace setVariable [QUOTE(VAR_COMMAND_CODE_PREFIX)+_command,_code];
};
