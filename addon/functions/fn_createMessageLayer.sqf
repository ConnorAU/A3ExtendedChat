/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_createMessageLayer

Description:
    Creates the message feed display

Parameters:
	0 : BOOL - Indicates if the system has been enabled in the mission config

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(createMessageLayer)
#define DISPLAY_NAME VAR_MESSAGE_FEED_DISPLAY

#include "_macros.inc"
#include "_defines.inc"

waitUntil {!isNull(findDisplay 46)};

// Execute this section of script in unscheduled environment
isNil {
	QUOTE(VAR_MESSAGE_FEED_DISPLAY) cutRsc [QUOTE(VAR_MESSAGE_FEED_DISPLAY),"PLAIN",0,true];

	VAR_MESSAGE_FEED_POS = [
		getText(configFile >> "RscChatListMission" >> "x") call BIS_fnc_parseNumber,
		getText(configFile >> "RscChatListMission" >> "y") call BIS_fnc_parseNumber,
		getText(configFile >> "RscChatListMission" >> "w") call BIS_fnc_parseNumber,
		getText(configFile >> "RscChatListMission" >> "h") call BIS_fnc_parseNumber
	];
	VAR_MESSAGE_FEED_POS_X = VAR_MESSAGE_FEED_POS#0;

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
	if (!isClass(configFile >> "CfgFunctions" >> "CAU_UserInputMenus") && !isClass(missionConfigFile >> "CfgFunctions" >> "CAU_UserInputMenus")) then {
		{
			diag_log text _x;
			systemChat _x;
		} forEach [
			"ExtendedChat is missing a dependency: UserInputMenus",
			"Some features may not function as expected",
			"Visit the github for setup instructions: https://github.com/ConnorAU/A3ExtendedChat"
		];
	};
};

{
	_x params [["_delay",0,[0]],["_message","",[""]]];
	uiSleep _delay;
	systemChat _message;
} forEach getArray(missionConfigFile >> QUOTE(VAR(MOTD)));

nil
