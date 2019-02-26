/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#include "functions\_defines.inc"

class VAR_MESSAGE_FEED_DISPLAY {
	idd=-1;
	onLoad=uiNamespace setVariable [QUOTE(VAR_MESSAGE_FEED_DISPLAY),_this select 0];
	fadein=0;
	fadeout=0;
	duration=1e14;
};