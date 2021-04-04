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
reverse _eventReturns;
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

// Trim whitespace
_message = trim _message;

// Do nothing if the message is empty
if (_message in [""," "]) exitWith {};

// Detect system message type and block from printing if related setting is disabled
private _settingsBlockPrint = false;
if (_channelID in [0,16]) then {
	if (_channelID == 0) then {
		if (_chatMessageType == 2) then {
			_channelID = 16;
			_settingsBlockPrint = getMissionConfigValue[QUOTE(VAR(deathMessages)),1] isNotEqualTo 1 || !(["get",VAL_SETTINGS_KEY_PRINT_DEATH] call FUNC(settings));
		};
	} else {
		private _matchString = {
			params ["_string","_setting"];
			private _xSplit = ["stringSplitString",[_string,"%s"]] call FUNC(commonTask);
			private _match = true;
			private _inIndex = -1;

			{
				_match = switch _forEachIndex do {
					case 0:{["stringPrefix",[_message,_x,true]] call FUNC(commonTask)};
					case (count _xSplit - 1):{["stringSuffix",[_message,_x,true]] call FUNC(commonTask)};
					default {
						private _lastIndex = _inIndex;
						_inIndex = _message find _x;
						_inIndex > _lastIndex
					};
				};

				if !_match exitWith {};
			} forEach _xSplit;

			if _match exitWith {
				private _return = !(["get",_setting] call FUNC(settings));
				if !_return then {
					_return = switch _setting do {
						case VAL_SETTINGS_KEY_PRINT_CONNECTED:{getMissionConfigValue[QUOTE(VAR(connectMessages)),1] isNotEqualTo 1};
						case VAL_SETTINGS_KEY_PRINT_DISCONNECTED:{getMissionConfigValue[QUOTE(VAR(disconnectMessages)),1] isNotEqualTo 1};
						case VAL_SETTINGS_KEY_PRINT_DEATH:{getMissionConfigValue[QUOTE(VAR(deathMessages)),1] isNotEqualTo 1};
						default {_return};
					};
				};
				_return
			};
			false
		};

		_settingsBlockPrint = [
			[localize "str_mp_connecting",VAL_SETTINGS_KEY_PRINT_CONNECTED],
			[localize "str_mp_connect",VAL_SETTINGS_KEY_PRINT_CONNECTED],
			[localize "str_mp_validerror_2",VAL_SETTINGS_KEY_PRINT_CONNECTED],
			[localize "str_mp_disconnect",VAL_SETTINGS_KEY_PRINT_DISCONNECTED],
			//[localize "str_mp_banned" + ": %s",],
			//[localize "str_mp_banned",],
			//[localize "str_mp_kicked" + ": %s",],
			//[localize "str_mp_kicked",],
			//[localize "str_signature_wrong",],
			//[localize "str_signature_missing",],
			//[localize "str_signature_check_timed_out",],
			//[localize "str_mp_connection_loosing",],
			["Player %s kicked off by BattlEye: %s",VAL_SETTINGS_KEY_PRINT_BATTLEYE_KICK]
		] findIf { _x call _matchString } != -1;

		if _settingsBlockPrint exitWith {};
		if (missionNamespace getVariable ["bis_revive_killfeedShow",false]) then {
			private _replaceFormatIndecies = {
				_this = ["stringReplace",[_this,"%1","%s"]] call FUNC(commonTask);
				_this = ["stringReplace",[_this,"%2","%s"]] call FUNC(commonTask);
				_this
			};
			_settingsBlockPrint = [
				{localize "STR_A3_Revive_MSG_INCAPACITATED" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_INCAPACITATED_BY" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_INCAPACITATED_BY_FF" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_KILLED" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_KILLED_BY" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_KILLED_BY_FF" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_EXECUTED" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_EXECUTED_BY" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_EXECUTED_BY_FF" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_BLEDOUT" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_DROWNED" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_DIED" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_SUICIDED" call _replaceFormatIndecies}/*,
				{localize "STR_A3_Revive_MSG_REVIVED" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_REVIVED_BY" call _replaceFormatIndecies},
				{localize "STR_A3_Revive_MSG_FORCED_RESPAWN" call _replaceFormatIndecies},
				{"%s was secured"},
				{"%s was secured by %s"}*/
			] findIf { [call _x,VAL_SETTINGS_KEY_PRINT_DEATH] call _matchString } != -1;
		};
	};
};

// Send log to server if this player sent the message
if (_senderID isEqualTo clientOwner && {_senderUnit isEqualTo player && {missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]}}) then {
	["text",[_channelID,_message,_senderNameF,getPlayerUID _senderUnit]] remoteExecCall [QUOTE(FUNC(log)),2];
};

private _messageContainsMentions = _message find "@" != -1;

// Split message into segments to allow for parsed and safe structured texts in the same text value
_message = ["stringSplitStringKeep",[_message," "]] call FUNC(commonTask);

// Format emoji keywords and shortcuts
private _containsImg = false;
_message = ["formatImages",[_message]] call FUNC(emoji);

// Format mentions
private _messageMentionsSelf = false;
if _messageContainsMentions then {
	_message = ["parse",_message] call FUNC(mention);
};

// Apply bad language filter
if (["get",VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER] call FUNC(settings)) then {
	private _languageFilters = ["get",VAL_SETTINGS_KEY_BAD_LANGUAGE_FILTER_TERMS] call FUNC(settings);
	private _trim = "`~!@#$%^&*()[]{}-_=+\|/?,.;:'""" + toString[9];
	{
		private _censored = "";
		if (" " in _x) then {
			private _filterSegments = ["stringSplitStringKeep",[_x," "]] call FUNC(commonTask);
			_filterSegments = _filterSegments apply {toLower _x};
			private _termStart = toLower(_filterSegments#0);
			for "_i" from 0 to count _message - 1 do {
				private _segment = _message#_i;
				if (_segment isEqualType "") then {
					private _segmentLow = toLower _segment;
					private _segmentMatch = _segmentLow isEqualTo _termStart;
					private _segmentStartTrim = _segmentLow;
					private _segmentStartTrimed = "";
					if !_segmentMatch then {
						_segmentStartTrim = _segmentLow trim [_trim,1];
						_segmentMatch = _segmentStartTrim isEqualTo _termStart;
						if _segmentMatch then {
							_segmentStartTrimed = _segment select [0,_segmentLow find _segmentStartTrim];
						};
					};
					if _segmentMatch then {
						private _segments = ([_segmentStartTrim] + (_message select [_i + 1,count _filterSegments - 1])) apply {
							if (_x isEqualType "") then {toLower _x} else {_x}
						};
						private _segmentsMatch = _segments isEqualTo _filterSegments;
						private _segmentLastTrimed = "";
						if !_segmentsMatch then {
							private _segmentLast = _segments#(count _segments - 1);
							if (_segmentLast isEqualType "") then {
								private _segmentLastTrim = _segmentLast trim [_trim,2];
								_segments set [count _segments - 1,_segmentLastTrim];
								_segmentsMatch = _segments isEqualTo _filterSegments;
								if _segmentsMatch then {
									_segmentLastTrimed = _segmentLast select [count _segmentLastTrim];
								};
							};
						};
						if _segmentsMatch then {
							if (_censored == "") then {_censored = _x splitString "" apply {["*"," "] select (_x == " ")} joinString ""};
							_message set [_i,_segmentStartTrimed + _censored + _segmentLastTrimed];
							for "_ii" from _i + 1 to _i + count _filterSegments - 1 do {_message set [_ii,""]};
						};
					};
				};
			};
		} else {
			private _term = toLower _x;
			for "_i" from 0 to count _message - 1 do {
				private _segment = _message#_i;
				if (_segment isEqualType "") then {
					private _segmentLow = toLower _segment;
					if (_term in _segmentLow) then {
						if (_censored == "") then {_censored = _x splitString "" apply {"*"} joinString ""};
						if (_segmentLow isEqualTo _term) then {
							_message set [_i,_censored];
						} else {
							private _segmentTrim = _segmentLow trim [_trim,0];
							if (_segmentTrim isEqualTo _term) then {
								_message set [_i,["stringReplace",[_segment,_x,_censored]] call FUNC(commonTask)];
							};
						};
					};
				};
			};
		};
	} forEach _languageFilters;
};

// Wrap message in quotes if the sentence type is 0
if (_sentenceType == 0) then {
	_message = [""""] + _message + [""""];
};

// Compose message
private _messageComposed = composeText _message;

// Check if sender is muted
private _senderUID = getPlayerUID _senderUnit;
private _mutedPlayers = ["get",VAL_SETTINGS_KEY_MUTED_PLAYERS] call FUNC(settings);
private _senderIsMuted = !isNull _senderUnit && {_mutedPlayers findIf {_x#1 isEqualTo _senderUID} != -1};

// Add message to history array
if !_sehBlockHistory then {
	private _messageHistory = _message;

	// Parse whitelisted websites
	if (["get",VAL_SETTINGS_KEY_WEBSITE_WHITELIST] call FUNC(settings)) then {
		private _websiteWhitelist = ["get",VAL_SETTINGS_KEY_WEBSITE_WHITELIST_TERMS] call FUNC(settings);
		for "_i" from 0 to count _messageHistory - 1 do {
			private _segment = _messageHistory#_i;
			if (_segment isEqualType "") then {
				private _segmentLow = toLower _segment;
				{
					if (toLower _x in _segmentLow) exitWith {
						private _hrefPrefix = "";
						if (
							!(["stringPrefix",[_segment,"https://"]] call FUNC(commonTask)) &&
							!(["stringPrefix",[_segment,"http://"]] call FUNC(commonTask))
						) then {_hrefPrefix = "https://"};

						_segment = ["stringReplace",[_segment,"&","&amp;"]] call FUNC(commonTask);
						_segment = ["stringReplace",[_segment,"'","''"]] call FUNC(commonTask);
						_segment = ["<a href='",_hrefPrefix,_segment,"'>",_segment,"</a>"] joinString "";

						_messageHistory set [_i,parseText _segment];
					};
				} forEach _websiteWhitelist;
			};
		};
		_messageHistory = composeText _messageHistory;
	} else {
		_messageHistory = _messageComposed;
	};

	private _historyData = [
		_messageHistory,_channelID,_senderNameF,_senderUID,diag_tickTime,systemTime,_sentenceType,_containsImg,_senderIsMuted,
		if _messageMentionsSelf then {["get",VAL_SETTINGS_KEY_FEED_MENTION_BG_COLOR] call FUNC(settings)} else {[0,0,0,0]}
	];
	VAR_HISTORY pushBack _historyData;

	// Delete old messages if the array had exceeded the limit
	private _maxHistorySize = ["get",VAL_SETTINGS_KEY_MAX_SAVED] call FUNC(settings);
	if (count VAR_HISTORY > _maxHistorySize) then {
		// remove oldest entry to keep well within array limit
		for "_i" from 0 to (count VAR_HISTORY) - _maxHistorySize do {VAR_HISTORY deleteAt 0};
	};
};

// Scripted event return blocked printing message
if _sehBlockPrint exitWith {};

// Setting for system message type blocked printing message
if _settingsBlockPrint exitWith {};

// Don't print message if sender is blocked
if _senderIsMuted exitWith {};

// Get channel filter setting
private _isChannelPrintEnabled = switch _channelID do {
	case 0:{["get",VAL_SETTINGS_KEY_PRINT_GLOBAL] call FUNC(settings)};
	case 1:{["get",VAL_SETTINGS_KEY_PRINT_SIDE] call FUNC(settings)};
	case 2:{["get",VAL_SETTINGS_KEY_PRINT_COMMAND] call FUNC(settings)};
	case 3:{["get",VAL_SETTINGS_KEY_PRINT_GROUP] call FUNC(settings)};
	case 4:{["get",VAL_SETTINGS_KEY_PRINT_VEHICLE] call FUNC(settings)};
	case 5:{["get",VAL_SETTINGS_KEY_PRINT_DIRECT] call FUNC(settings)};
	case 6;case 7;case 8;case 9;case 11;case 12;case 13;case 14;
	case 15:{["get",VAL_SETTINGS_KEY_PRINT_CUSTOM] call FUNC(settings)};
	default {true};
};

// Check print condition
if (_isChannelPrintEnabled && {call _printCondition}) then {
	private _channelColor = ["ChannelColour",_channelID] call FUNC(commonTask);
	private _senderNameSafe = ["StreamSafeName",[_senderUID,_senderNameF]] call FUNC(commonTask);

	// Create message control group
	(call FUNC(createMessageUI)) params ["_ctrlContainer","_ctrlBackground","_ctrlBackgroundMentioned","_ctrlStripe","_ctrlText"];
	_ctrlStripe ctrlSetBackgroundColor _channelColor;

	// Format message to final state
	private _messageColor =	if (_sentenceType == 0) then {"#FFFFFF"} else {
		(["get",VAL_SETTINGS_KEY_TEXT_COLOR] call FUNC(settings)) call BIS_fnc_colorRGBAtoHTML
	};

	if (_senderNameSafe != "") then {
		_senderNameSafe = _senderNameSafe + ": ";
	};

	if (_channelID in [16,17]) then {
		_channelColor = ["ChannelColour",[_channelID,false]] call FUNC(commonTask);
	};

	private _messageFinal = composeText [
		text _senderNameSafe setAttributes ["color",_channelColor call BIS_fnc_colorRGBAtoHTML],
		_messageComposed setAttributes ["color",_messageColor]
	] setAttributes [
		"size",str((["ScaledFeedTextSize"] call FUNC(commonTask))*(["get",VAL_SETTINGS_KEY_TEXT_SIZE] call FUNC(settings))),
		"font",["get",VAL_SETTINGS_KEY_TEXT_FONT] call FUNC(settings)
	];
	_ctrlText ctrlSetStructuredText composeText [_messageFinal];

	// Show mentioned background if self is mentioned
	if _messageMentionsSelf then {
		_ctrlBackgroundMentioned ctrlShow true;
		_ctrlBackground ctrlSetBackgroundColor [0.1,0.1,0.1,0.5];
	};

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
