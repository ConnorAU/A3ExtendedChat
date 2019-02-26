/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

class CfgPatches {
	class ExtendedChat {
        name="ExtendedChat";
        author="Connor";
        url="https://steamcommunity.com/id/_connor";

		requiredVersion=0.01;
		requiredAddons[]={};
		units[]={};
		weapons[]={};
	};
};

class CfgFunctions {
	#include "CfgFunctions.cpp"
};

class RscTitles {
	#include "RscTitles.cpp"
};