/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_motd

Description:
	Prints defined message-of-the-day strings to the feed

Parameters:
	None

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(motd)

#include "_defines.inc"

{
	_x params [["_delay",0,[0]],["_message","",[""]]];
	uiSleep _delay;
	systemChat _message;
} forEach getArray(missionConfigFile >> QUOTE(VAR(MOTD)));

nil
