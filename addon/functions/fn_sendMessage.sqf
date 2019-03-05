/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(sendMessage)

#include "_defines.inc"

SWITCH_SYS_PARAMS;

private _arguments = [];
_params params [
	["_message","",[""]],
	["_sender",objNull,[objNull]],
	["_channelID",-1,[0]]
];

private _arguments = switch (tolower _mode) do {
	case "systemchat":{[_message]};
	case "globalchat";
	case "sidechat";
	case "commandchat";
	case "groupchat";
	case "vehiclechat";
	case "directchat"; // not an sqf command, no reason not to have it here though
	case "customchat":{
		_channelID = if (_channelID >= 6) then {_channelID} else {
			["globalchat","sidechat","commandchat","groupchat","vehiclechat","directchat"] find tolower _mode
		};
		[
			_message,
			_channelID,
			[
				"SafeStructuredText",
				["ClientNamePrefix",[_sender,_channelID]] call FUNC(commonTask)
			] call FUNC(commonTask),
			getPlayerUID _sender,
			side group _sender,
			group _sender,
			vehicle _sender,
			if (_channelID < 6) then {""} else {
				["get",[_channelID - 5,1]] call FUNC(radioChannelCustom)
			},
			if (_channelID < 6) then {[]} else {
				["get",[_channelID - 5,0]] call FUNC(radioChannelCustom)
			}
		]
	};
	default {[]};
};

if !(_arguments isEqualTo []) then {
	_arguments call FUNC(addMessage);
};