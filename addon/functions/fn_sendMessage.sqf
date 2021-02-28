/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Warning:
	As of A3 1.99+ you can use native chat sqf commands instead of this function if desired.

Function:
	CAU_xChat_fnc_sendMessage

Description:
	Sends message in the specified channel

Parameters:
	_message     : STRING - The message text
    _sender      : OBJECT - The sender unit
    _channelID   : NUMBER - The channel index the message was sent in
	_setting     : NUMBER - Setting index, only print if filter is disabled

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(sendMessage)

#include "_defines.inc"

SWITCH_SYS_PARAMS;

_params params [
	["_message","",[""]],
	["_sender",objNull,[objNull]],
	["_channelID",-1,[0]],
	["_setting","",[""]]
];

if (_message == "") exitWith {};
if (_setting != "" && {!(["get",_setting] call FUNC(settings))}) exitWith {};

switch (tolower _mode) do {
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
