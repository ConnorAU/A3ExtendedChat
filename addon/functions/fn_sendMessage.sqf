/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_sendMessage

Description:
	Prepares sender arguments for addMessage

Parameters:
	_message   : STRING - The message text
    _sender    : OBJECT - The sender unit
    _channelID : NUMBER - The channel index the message was sent in

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(sendMessage)

#include "_defines.inc"

SWITCH_SYS_PARAMS;

private _arguments = [];
_params params [
	["_message","",[""]],
	["_sender",objNull,[objNull]],
	["_channelID",-1,[0]]
];

_message = ["formatImages",_message] call FUNC(emoji);
if (_message == "") exitWith {};

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

nil
