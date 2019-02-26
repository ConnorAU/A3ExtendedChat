/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(processChatCommand)

#include "_defines.inc"

params ["_text"];

private _split = _text splitString " ";
private _prefix = ["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call FUNC(settings);
private _command = _split#0 select [count _prefix,count(_split#0)];
private _arguments = _split select [1,count _split];

["systemChat",[_split#0]] call FUNC(sendMessage);
_arguments call (missionNameSpace getVariable [QUOTE(VAR_COMMAND_CODE_PREFIX)+_command,{}]);