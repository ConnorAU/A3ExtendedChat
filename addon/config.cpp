class CfgPatches {
	class CAU_ExtendedChat {
        name="ExtendedChat";
        author="Connor";
        url="https://steamcommunity.com/id/_connor";

		requiredVersion=0.01;
		requiredAddons[]={"CAU_UserInputMenus", "A3_Functions_F"};
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

class CfgRemoteExec {
	class Functions {
		class CAU_xChat_fnc_sendMessage {allowedTargets=0;};
		class CAU_xChat_fnc_log {allowedTargets=2;};
		class CAU_xChat_fnc_radioChannelCustom {allowedTargets=2;};
	};
};
