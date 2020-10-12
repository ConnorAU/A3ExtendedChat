/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_addMessage

Description:
	Adds a new message to the feed

Parameters:
    _text                : STRING - The message text
    _channelID           : NUMBER - The channnel index the message was sent in
    _senderName          : STRING - The name of the sender
    _senderUID           : STRING - The steam uid of the sender
    _senderSide          : SIDE   - The side of the sender
    _senderGroup         : GROUP  - The group of the sender
    _senderVehicle       : OBJECT - The vehicle of the sender
    _customChannelName   : STRING - The name of the custom channel the message was sent in
    _customChannelColour : ARRAY  - The color of the custom channel the message was sent in
    _canPrintCondition   : CODE   - The condition to evaluate before adding the message

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(addMessage)

#include "_macros.inc"
#include "_defines.inc"

params [
	["_text","",[""]],
	["_channelID",-1,[0]],
	["_senderName","",[""]],
	["_senderUID","",[""]],
	["_senderSide",sideUnknown,[sideUnknown]],
	["_senderGroup",grpNull,[grpNull]],
	["_senderVehicle",objNull,[objNull]],
	["_customChannelName","",[""]],
	["_customChannelColour",[],[[]]],
	["_canPrintCondition",{true},[{}]]
];

if (isServer && {_channelID == -1}) then {
	if (missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]) then {
		["text",[_channelID,_text,_senderName,_senderUID]] call FUNC(log);
	};
};

// dedicated server doesnt need to print to message feed
if isDedicated exitWith {};

private _canReceiveMessage = if (_senderUID == getPlayerUID player) then {true} else {
	switch _channelID do {
		case -1;
		case 0:{true};
		case 1:{_senderSide isEqualTo playerSide};
		case 2:{leader group player isEqualTo player && {side group player isEqualTo side _senderGroup}}; // is this the right condition? idk the proper criteria for command chat
		case 3:{_senderGroup isEqualTo group player};
		case 4:{_senderVehicle isEqualTo vehicle player};
		case 5:{_senderVehicle distance player <= 30};
		case 6;case 7;case 8;case 9;case 11;case 12;case 13;case 14;
		case 15:{player in (["get",[_channelID-5,3]] call FUNC(radioChannelCustom))};
		default {false};
	};
};

if !_canReceiveMessage exitWith {};

private _historyData = [_text,_channelID,_senderName,_senderUID,_customChannelColour,_customChannelName,diag_tickTime];
VAR_HISTORY pushBack _historyData;
[missionNamespace,QUOTE(VAR(messageAdded)),_historyData] call BIS_fnc_callScriptedEventHandler;

private _maxHistorySize = ["get",VAL_SETTINGS_INDEX_MAX_SAVED] call FUNC(settings);
if (count VAR_HISTORY > _maxHistorySize) then {
	// remove oldest entry to keep well within array limit
	for "_i" from 0 to 1 step 0 do {
		if (count VAR_HISTORY <= _maxHistorySize) exitWith {};
		VAR_HISTORY deleteAt 0;
	};
};

private _isChannelPrintEnabled = switch _channelID do {
	case -1:{true};
	case 0:{["get",VAL_SETTINGS_INDEX_PRINT_GLOBAL] call FUNC(settings)};
	case 1:{["get",VAL_SETTINGS_INDEX_PRINT_SIDE] call FUNC(settings)};
	case 2:{["get",VAL_SETTINGS_INDEX_PRINT_COMMAND] call FUNC(settings)};
	case 3:{["get",VAL_SETTINGS_INDEX_PRINT_GROUP] call FUNC(settings)};
	case 4:{["get",VAL_SETTINGS_INDEX_PRINT_VEHICLE] call FUNC(settings)};
	case 5:{["get",VAL_SETTINGS_INDEX_PRINT_DIRECT] call FUNC(settings)};
	case 6;case 7;case 8;case 9;case 11;case 12;case 13;case 14;
	case 15:{["get",VAL_SETTINGS_INDEX_PRINT_CUSTOM] call FUNC(settings)};
	default {false};
};

// condition to print the message on screen
if (_isChannelPrintEnabled && {[] call _canPrintCondition}) then {
	private _containsImg = ["<img ",_text] call BIS_fnc_inString;
	private _stripeColour = if (count _customChannelColour == 4) then {_customChannelColour} else {
		["ChannelColour",_channelID] call FUNC(commonTask);
	};
	_senderName = ["StreamSafeName",[_senderUID,_senderName]] call FUNC(commonTask);

	(call FUNC(createMessageUI)) params ["_ctrlContainer","_ctrlBackground","_ctrlStripe","_ctrlText"];

	_ctrlStripe ctrlSetBackgroundColor _stripeColour;
	private _finalText = [
		format[
			"<t size='%1' font='%2'>",
			(["ScaledFeedTextSize"] call FUNC(commonTask))*(["get",VAL_SETTINGS_INDEX_TEXT_SIZE] call FUNC(settings)),
			["get",VAL_SETTINGS_INDEX_TEXT_FONT] call FUNC(settings)
		],
		if (_senderName == "") then {""} else {"<t color='#FFFFFF'>"+_senderName+" </t>"},
		"<t color='"+((["get",VAL_SETTINGS_INDEX_TEXT_COLOR] call FUNC(settings)) call BIS_fnc_colorRGBAtoHTML)+"'>"+_text+"</t>",
		"</t>"
	] joinString "";
	_ctrlText ctrlSetStructuredText parseText _finalText;

	{
		private _ctrlPos = ctrlPosition _x;
		if (_foreachindex == 1) then {
			_ctrlPos set [2,ctrlTextWidth _ctrlText];
		};
		_ctrlPos set [3,ctrlTextHeight _ctrlText + ([0,PXH(0.4)] select _containsImg)];
		_x ctrlSetPosition _ctrlPos;
		_x ctrlCommit 0;
	} forEach [_ctrlContainer,_ctrlBackground,_ctrlStripe,_ctrlText];

	VAR_MESSAGE_FEED_CTRLS pushback _ctrlContainer;
	VAR_NEW_MESSAGE_PENDING = true;
};

// update history UI if it is open
["NewMessageReceived"] call FUNC(historyUI);

nil
