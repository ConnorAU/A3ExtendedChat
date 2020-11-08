/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_createMessageUI

Description:
	Creates a new control group to display a message in the feed

Parameters:
	None

Return:
	ARRAY - An array of controls in the newly created control group
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(createMessageUI)

#include "_macros.inc"
#include "_defines.inc"

disableSerialization;
USE_DISPLAY(DISPLAY(VAR_MESSAGE_FEED_DISPLAY));
if (isNull _display) exitWith {};

private _ctrlMessageContainer = _display ctrlCreate ["ctrlControlsGroupNoScrollbars",-1];
_ctrlMessageContainer ctrlSetFade 1;
_ctrlMessageContainer ctrlSetPosition [
	VAR_MESSAGE_FEED_POS_X,
	(VAR_MESSAGE_FEED_POS#1) + (VAR_MESSAGE_FEED_POS#3),
	VAR_MESSAGE_FEED_POS#2,
	0
];

private _ctrlMessageBackground = _display ctrlCreate ["ctrlStatic",-1,_ctrlMessageContainer];
_ctrlMessageBackground ctrlSetBackgroundColor (["get",VAL_SETTINGS_KEY_FEED_BG_COLOR] call FUNC(settings));
_ctrlMessageBackground ctrlSetPosition [0,0,VAR_MESSAGE_FEED_POS#2,0];

private _ctrlMessageBackgroundMentioned = _display ctrlCreate ["ctrlStatic",-1,_ctrlMessageContainer];
_ctrlMessageBackgroundMentioned ctrlShow false;
_ctrlMessageBackgroundMentioned ctrlSetBackgroundColor (["get",VAL_SETTINGS_KEY_FEED_MENTION_BG_COLOR] call FUNC(settings));
_ctrlMessageBackgroundMentioned ctrlSetPosition ctrlPosition _ctrlMessageBackground;

private _ctrlMessageStripe = _display ctrlCreate ["ctrlStatic",-1,_ctrlMessageContainer];
_ctrlMessageStripe ctrlSetPosition [0,0,PXW(0.5),0];

private _ctrlMessageText = _display ctrlCreate ["ctrlStructuredText",-1,_ctrlMessageContainer];
_ctrlMessageText ctrlSetPosition [PXW(0.5),0,VAR_MESSAGE_FEED_POS#2 - PXW(1),safezoneH];

private _allControls = [
	_ctrlMessageContainer,
	_ctrlMessageBackground,
	_ctrlMessageBackgroundMentioned,
	_ctrlMessageStripe,
	_ctrlMessageText
];

{_x ctrlCommit 0;} count _allControls;
_allControls
