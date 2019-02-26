/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/
 
#define THIS_FUNC FUNC(createMessageUI)

#include "_macros.inc"
#include "_defines.inc"

disableSerialization;
USE_DISPLAY(DISPLAY(VAR_MESSAGE_FEED_DISPLAY));
if (isNull _display) exitWith {};

private _ctrlMessageContainer = _display ctrlCreate ["ctrlControlsGroupNoScrollbars",-1];
_ctrlMessageContainer ctrlSetFade 1;
_ctrlMessageContainer ctrlSetPosition [
	VAR_MESSAGE_FEED_POS#0,
	(VAR_MESSAGE_FEED_POS#1) + (VAR_MESSAGE_FEED_POS#3),
	VAR_MESSAGE_FEED_POS#2,
	0
];

private _ctrlMessageBackground = _display ctrlCreate ["ctrlStatic",2,_ctrlMessageContainer];
_ctrlMessageBackground ctrlSetBackgroundColor [0.1,0.1,0.1,0.5];
_ctrlMessageBackground ctrlSetPosition [0,0,VAR_MESSAGE_FEED_POS#2,0];

private _ctrlMessageStripe = _display ctrlCreate ["ctrlStatic",3,_ctrlMessageContainer];
_ctrlMessageStripe ctrlSetPosition [0,0,PX_WS(0.5),0];

private _ctrlMessageText = _display ctrlCreate ["ctrlStructuredText",4,_ctrlMessageContainer];
_ctrlMessageText ctrlSetPosition [PX_WS(0.5),0,VAR_MESSAGE_FEED_POS#2 - PX_WS(1),safezoneH];

private _allControls = [
	_ctrlMessageContainer,
	_ctrlMessageBackground,
	_ctrlMessageStripe,
	_ctrlMessageText
];

{_x ctrlCommit 0;} count _allControls;
_allControls