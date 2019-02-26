/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(motd)

#include "_defines.inc"

{
	_x params [["_delay",0,[0]],["_message","",[""]]];
	uiSleep _delay;
	["systemChat",[_message]] call FUNC(sendMessage);
} forEach getArray(missionConfigFile >> QUOTE(VAR(MOTD)));