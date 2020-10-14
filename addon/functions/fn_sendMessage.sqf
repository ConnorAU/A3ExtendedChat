/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Warning:
	This function is deprecated as of A3 1.99+ and only exists
	to maintain backwards compatibility. Please use the native
	chat sqf commands.

Function:
	CAU_xChat_fnc_sendMessage

Description:
	Sends message in the specified channel

Parameters:
	_message   : STRING - The message text
    _sender    : OBJECT - The sender unit
    _channelID : NUMBER - The channel index the message was sent in
	_setting   : CODE   - Only print if setting filtering is disabled

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
	["_channelID",-1,[0]],
	["_setting",-1,[0]]
];

if (_message == "") exitWith {};
if (_setting > -1 && {!(["get",_setting] call FUNC(settings))}) exitWith {};

private _arguments = switch (tolower _mode) do {
	case "systemchat":{systemChat _message};
	case "globalchat":{_sender globalChat _message};
	case "sidechat":{_sender sideChat _message};
	case "commandchat":{_sender commandChat _message};
	case "groupchat":{_sender groupChat _message};
	case "vehiclechat":{_sender vehicleChat  _message};
	//case "directchat"; // not an sqf command, no reason not to have it here though
	case "customchat":{_sender customChat [_channelID,_message]};
};

nil
