/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_handleChatMessage

Description:
	Processes and adds all messages received from the HandleChatMessage event

Parameters:
	_channelID       : NUMBER - Channel ID
	_senderID        : NUMBER - Sender's network owner ID
	_senderNameF     : STRING - Sender's name with formatting specific to the channel (eg: "<SIDE> (<NAME>)" in global)
	_message         : STRING - Message content
	_senderUnit      : OBJECT - Unit object of the sender
	_senderName      : STRING - Sender's name without formatting
	_senderStrID     : STRING - Sender's ID used for marker creation
	_forceDisplay    : BOOL - Unknown
	_playerMessage   : BOOL - Unknown
	_sentenceType    : NUMBER - 0 = White wrapped with "", 1 = Normal
	_chatMessageType : NUMBER - 0 = Normal, 1 = SimpleMove messages, 2 = Death messages
	https://community.bistudio.com/wiki/Arma_3:_Event_Handlers/addMissionEventHandler#HandleChatMessage

Return:
	BOOL - Always true to block a message from being printed to vanilla chat
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(handleChatMessage)

#include "_macros.inc"
#include "_defines.inc"

#define VAR_BLOCK_EVENT FUNC_SUBVAR(blockEvent)

// Store print condition to local event handler so any messages sent during this event do not use it on themselves.
private _printCondition = missionNamespace getVariable [QUOTE(VAR_HANDLE_MESSAGE_PRINT_CONDITION),{true}];
VAR_HANDLE_MESSAGE_PRINT_CONDITION = nil;

// Exit event if blocked
if (missionNamespace getVariable [QUOTE(VAR_BLOCK_EVENT),false]) exitWith {
	VAR_BLOCK_EVENT = false;
	true
};

// Fire scripted event handler (before params to avoid privating all the variables)
private _eventReturns = call {
	private "_printCondition";
	[missionNamespace,QUOTE(VAR(handleChatMessage)),_this,true] call BIS_fnc_callScriptedEventHandler;
};

params [
	"_channelID","_senderID","_senderNameF","_message","_senderUnit","_senderName",
	"_senderStrID","_forceDisplay","_playerMessage","_sentenceType","_chatMessageType"
];

// Apply event return value if one is provided
private _sehBlockPrint = false;
private _sehBlockHistory = false;
{
	if (!isNil "_x") exitWith {
		switch true do {
			case (_x isEqualType true):{_sehBlockPrint = _x};
			case (_x isEqualType ""):{_message = _x};
			case (_x isEqualType []):{
				switch true do {
					case (_x isEqualTypeArray ["",""]):{
						_senderNameF = _x#0;
						_message = _x#1;
					};
					case (_x isEqualTypeArray [true,true]):{
						_sehBlockPrint = _x#0;
						_sehBlockHistory = _x#1;
					};
				};
			};
		};
	};
} forEach _eventReturns;

// Do nothing if the message is empty
if (_message == "") exitWith {};

// TODO: remove
// Debug log to find out what exactly causes !_forceDisplay and _playerMessage
if (!_forceDisplay || _playerMessage) then {
	diag_log text(QUOTE(THIS_FUNC) + " - '!_forceDisplay || _playerMessage' : " + str _this);
	if (getPlayerUID player == "76561198090361580") then {
		VAR_BLOCK_EVENT = true;
		systemChat format["%1 : '!_forceDisplay || _playerMessage' anomoly",QUOTE(THIS_FUNC)];
	};
};

// TODO: Delete once HCM EH is fixed and fires kill messages for everyone, not just the victim owner
// Broadcasts kill messages to everyone as the event handler currently only fires for the victim owner
if (_channelID == 0 && _chatMessageType == 2) exitWith {
	if (getMissionConfigValue[QUOTE(VAR(deathMessages)),1] isEqualTo 1) then {
		["systemChat",[_message,nil,nil,VAL_SETTINGS_INDEX_PRINT_KILL]] remoteExecCall [QUOTE(FUNC(sendMessage)),0];
	};
};

// Send log to server if this player sent the message
if (_senderID isEqualTo clientOwner && {_senderUnit isEqualTo player && {missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]}}) then {
	["text",[_channelID,_message,_senderNameF,getPlayerUID _senderUnit]] remoteExecCall [QUOTE(FUNC(log)),2];
};

// Replace bad characters
private _messageSafe = ["SafeStructuredText",_message] call FUNC(commonTask);

// Format emoji keywords and shortcuts
_messageSafe = ["formatImages",_messageSafe] call FUNC(emoji);

// Format mentions
private _messageMentionsSelf = false;
if ("@" in _messageSafe) then {
	private _messageSafeInput = _messageSafe;
	private _messageSafeOutput = [];
	for "_i" from 0 to 1 step 0 do {
		private _mentionIndex = _messageSafeInput find "@";
		if (_mentionIndex < 0) exitwith {_messageSafeOutput pushback _messageSafeInput;};
		_messageSafeOutput pushback (_messageSafeInput select [0,_mentionIndex]);
		_messageSafeInput = _messageSafeInput select [_mentionIndex];

		private _messageMentionLength = _messageSafeInput find " ";
		private _messageMention = if (_messageMentionLength == -1) then {
			_messageSafeInput select [0];
		} else {
			_messageSafeInput select [0,_messageMentionLength];
		};

		private _messageMentionID = _messageMention select [1];
		private _messageMentionIDChars = _messageMentionID splitString "1234567890";
		if (count _messageMentionIDChars == 0) then {
			{
				private _unitID = str(_x getVariable [QUOTE(VAR_UNIT_OWNER_ID),-1]);
				if (_unitID isEqualTo _messageMentionID) exitWith {
					if (_x isEqualTo player) then {_messageMentionsSelf = true};
					_messageMention = [
						"<t color='"+((["get",VAL_SETTINGS_INDEX_TEXT_MENTION_COLOR] call FUNC(settings)) call BIS_fnc_colorRGBAtoHTML)+"'>@",
						["StreamSafeName",[
							getPlayerUID _x,
							_x getVariable [QUOTE(VAR_UNIT_NAME),name _x]
						]] call FUNC(commonTask),
						"</t>"
					] joinString "";
				};
			} forEach allPlayers;
		};

		_messageSafeOutput pushback _messageMention;
		_messageSafeInput = _messageSafeInput select [_messageMentionLength];
	};
	_messageSafe = _messageSafeOutput joinString "";
};


// Add message to history array
private _senderUID = getPlayerUID _senderUnit;
if !_sehBlockHistory then {
	private _historyData = [
		_messageSafe,_channelID,_senderNameF,_senderUID,diag_tickTime,systemTime,_sentenceType,
		if _messageMentionsSelf then {["get",VAL_SETTINGS_INDEX_FEED_MENTION_BG_COLOR] call FUNC(settings)} else {[0,0,0,0]}
	];
	VAR_HISTORY pushBack _historyData;
};

// Delete old messages if the array had exceeded the limit
private _maxHistorySize = ["get",VAL_SETTINGS_INDEX_MAX_SAVED] call FUNC(settings);
if (count VAR_HISTORY > _maxHistorySize) then {
	// remove oldest entry to keep well within array limit
	for "_i" from 0 to 1 step 0 do {
		if (count VAR_HISTORY <= _maxHistorySize) exitWith {};
		VAR_HISTORY deleteAt 0;
	};
};

// Scripted event return blocked printing message
if _sehBlockPrint exitWith {};

// Get channel filter setting
private _isChannelPrintEnabled = switch _channelID do {
	case 0:{["get",VAL_SETTINGS_INDEX_PRINT_GLOBAL] call FUNC(settings)};
	case 1:{["get",VAL_SETTINGS_INDEX_PRINT_SIDE] call FUNC(settings)};
	case 2:{["get",VAL_SETTINGS_INDEX_PRINT_COMMAND] call FUNC(settings)};
	case 3:{["get",VAL_SETTINGS_INDEX_PRINT_GROUP] call FUNC(settings)};
	case 4:{["get",VAL_SETTINGS_INDEX_PRINT_VEHICLE] call FUNC(settings)};
	case 5:{["get",VAL_SETTINGS_INDEX_PRINT_DIRECT] call FUNC(settings)};
	case 6;case 7;case 8;case 9;case 11;case 12;case 13;case 14;
	case 15:{["get",VAL_SETTINGS_INDEX_PRINT_CUSTOM] call FUNC(settings)};
	default {true};
};

// Check print condition
if (_isChannelPrintEnabled && {call _printCondition}) then {
	private _containsImg = "<img " in _messageSafe;
	private _channelColor = ["ChannelColour",_channelID] call FUNC(commonTask);
	private _senderNameSafe = ["StreamSafeName",[_senderUID,_senderNameF]] call FUNC(commonTask);

	// Create message control group
	(call FUNC(createMessageUI)) params ["_ctrlContainer","_ctrlBackground","_ctrlBackgroundMentioned","_ctrlStripe","_ctrlText"];
	_ctrlStripe ctrlSetBackgroundColor _channelColor;

	// Format message to final state
	private _messageColor = (["get",VAL_SETTINGS_INDEX_TEXT_COLOR] call FUNC(settings)) call BIS_fnc_colorRGBAtoHTML;
	if (_sentenceType == 0) then {
		_messageColor = "#FFFFFF";
		_messageSafe = str _messageSafe;
	};
	private _messageFinal = [
		format[
			"<t size='%1' font='%2'>",
			(["ScaledFeedTextSize"] call FUNC(commonTask))*(["get",VAL_SETTINGS_INDEX_TEXT_SIZE] call FUNC(settings)),
			["get",VAL_SETTINGS_INDEX_TEXT_FONT] call FUNC(settings)
		],
		if (_senderNameSafe == "") then {""} else {"<t color='"+(_channelColor call BIS_fnc_colorRGBAtoHTML)+"'>"+_senderNameSafe+":</t> "},
		"<t color='"+_messageColor+"'>"+_messageSafe+"</t>",
		"</t>"
	] joinString "";
	_ctrlText ctrlSetStructuredText parseText _messageFinal;

	// Show mentioned background if self is mentioned
	_ctrlBackgroundMentioned ctrlShow _messageMentionsSelf;

	// Set control positions to fit message
	{
		if (_foreachindex in [1,2]) then {
			_x ctrlSetPositionW ctrlTextWidth _ctrlText;
		};
		_x ctrlSetPositionH (ctrlTextHeight _ctrlText + (if _containsImg then {PXH(0.4)} else {0}));
		_x ctrlCommit 0;
	} forEach [_ctrlContainer,_ctrlBackground,_ctrlBackgroundMentioned,_ctrlStripe,_ctrlText];

	VAR_MESSAGE_FEED_CTRLS pushback _ctrlContainer;
	VAR_NEW_MESSAGE_PENDING = true;
};


// Update history UI if it is open
["NewMessageReceived"] call FUNC(historyUI);


true
