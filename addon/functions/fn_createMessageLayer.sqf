/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(createMessageLayer)
#define DISPLAY_NAME VAR_MESSAGE_FEED_DISPLAY

#include "_macros.inc"
#include "_defines.inc"

waitUntil {!isNull(findDisplay 46)};

QUOTE(VAR_MESSAGE_FEED_DISPLAY) cutRsc [QUOTE(VAR_MESSAGE_FEED_DISPLAY),"PLAIN",0,true];

VAR_MESSAGE_FEED_POS = [
	getText(configFile >> "RscChatListMission" >> "x") call BIS_fnc_parseNumber,
	getText(configFile >> "RscChatListMission" >> "y") call BIS_fnc_parseNumber,
	getText(configFile >> "RscChatListMission" >> "w") call BIS_fnc_parseNumber,
	getText(configFile >> "RscChatListMission" >> "h") call BIS_fnc_parseNumber
];

VAR_MESSAGE_FEED_POS set [3,
	(VAR_MESSAGE_FEED_POS#1 - safezoney) + ((VAR_MESSAGE_FEED_POS#3)*6)
];
VAR_MESSAGE_FEED_POS set [1,safezoney];

disableSerialization;
USE_DISPLAY(THIS_DISPLAY);

// VON active speakers ctrl
private _ctrlVoipSpeakers = _display ctrlCreate ["ctrlStructuredText",-1];
_ctrlVoipSpeakers ctrlSetBackgroundColor [0.1,0.1,0.1,0.5];
_ctrlVoipSpeakers ctrlSetPosition [
	VAR_MESSAGE_FEED_POS#0,
	(VAR_MESSAGE_FEED_POS#1)+(VAR_MESSAGE_FEED_POS#3),
	0,0
];
_ctrlVoipSpeakers ctrlCommit 0;
_display setVariable [QUOTE(VAR_VON_SPEAKERS_CTRL),_ctrlVoipSpeakers];

// highlight feed position
/*
private _ctrlGroupBG = _display ctrlCreate ["ctrlStatic",-1];
_ctrlGroupBG ctrlSetBackgroundColor [1,0,0,0.5];
_ctrlGroupBG ctrlSetPosition VAR_MESSAGE_FEED_POS;
_ctrlGroupBG ctrlCommit 0;
*/

addMissionEventHandler ["EachFrame",{call FUNC(repetitiveTasks)}];

// UserInputMenus is used in the settings menu
if (!isClass(configFile >> "CfgPatches" >> "CAU_UserInputMenus")) then {
	{
		diag_log text _x;
		["systemChat",[_x]] call FUNC(sendMessage);
	} forEach [
		"ExtendedChat is missing a dependency: UserInputMenus",
		"Some features may not function as expected",
		"Visit the github for installation instructions: https://github.com/ConnorAU/A3ExtendedChat"
	];
};

if !(_this#0) then {
	private _printWarning = ["get",VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION] call FUNC(settings);
	{
		diag_log text _x;
		if _printWarning then {
			["systemChat",[_x]] call FUNC(sendMessage);
		};
	} forEach [
		format["ExtendedChat is not fully supported by this mission: %1.%2",missionName,worldName],
		"This may result in chat messages not appearing and broken text communication in custom radio channels",
		"Visit the github for setup instructions: https://github.com/ConnorAU/A3ExtendedChat",
		"You can disable this warning log in the ExtendedChat settings menu"
	];
};

[] spawn FUNC(motd);