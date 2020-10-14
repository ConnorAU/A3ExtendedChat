/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_init

Description:
	Initializes the mod

Parameters:
	None

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(init)

#include "_macros.inc"
#include "_defines.inc"

private _mission = toLower format["%1.%2",missionName,worldName];
private _isMainMenu = ("true" configClasses (configFile >> "CfgMissions" >> "CutScenes")) findIf {
	_mission in toLower getText(_x >> "directory")
} > -1;
if _isMainMenu exitWith {};

if (missionNamespace getVariable [QUOTE(VAR(initialized)),false]) exitWith {};
VAR(initialized) = true;

if !(getMissionConfigValue[QUOTE(VAR(enabled)),1] isEqualTo 1) exitWith {
	diag_log format["ExtendedChat is disabled in mission %1",str _mission];
};

if hasInterface then {
	VAR_HISTORY = [];
	VAR_MESSAGE_FEED_CTRLS = [];
	VAR_COMMANDS_ARRAY = [];
	VAR_MESSAGE_FEED_SHOWN = true;
	VAR_NEW_MESSAGE_PENDING = false;
	VAR_ENABLE_LOGGING = false;
	VAR_ENABLE_VON_CTRL = difficultyOption "vonID" > 0;

	VAR_ENABLE_EMOJIS =  getMissionConfigValue[QUOTE(VAR(emojis)),1] isEqualTo 1;

	["init"] call FUNC(settings);

	[] spawn FUNC(createMessageLayer);

	// Add buttons to interrupt menu
	if isClass(configFile >> "CfgPatches" >> "WW2_Core_f_WW2_UI_InterruptMenu_f") then {
		// Add via IFA3 interrupt menu framework
		["cau_extendedchat","Extended Chat"] call WW2_InterruptMenu_fnc_addHeading;
		[
			"cau_extendedchat",localize "STR_CAU_xChat_interrupt_history_ww2","",
			{},{["init",ctrlParent(_this#0)] call FUNC(historyUI)}
		] call WW2_InterruptMenu_fnc_addButton;
		[
			"cau_extendedchat",localize "STR_CAU_xChat_interrupt_settings_ww2","",
			{},{["init"] call FUNC(settingsUI)}
		] call WW2_InterruptMenu_fnc_addButton;
	} else {
		// Add via scripted eh, fires during onLoad
		[missionNamespace,"OnGameInterrupt",{
			params ["_display"];
			private _buttonPos = ctrlPosition (_display displayCtrl 2);
			private _buttonColour = ["colorConfigToRGBA",[
				COLOR_ACTIVE_RGB,
				"(profilenamespace getVariable ['GUI_BCG_RGB_A',0.5])"
			]] call FUNC(commonTask);

			_buttonPos set [1,safezoneY + PXH(5)];
			private _ctrlHistory = _display ctrlCreate ["RscButtonMenu",-1];
			_ctrlHistory ctrlSetText localize "STR_CAU_xChat_interrupt_history";
			_ctrlHistory ctrlSetFont FONT_SEMIBOLD;
			_ctrlHistory ctrlSetBackgroundColor _buttonColour;
			_ctrlHistory ctrlSetPosition _buttonPos;
			_ctrlHistory ctrlAddEventHandler ["ButtonClick",{["init",ctrlParent(_this#0)] call FUNC(historyUI)}];
			_ctrlHistory ctrlCommit 0;

			_buttonPos set [1,_buttonPos#1 + _buttonPos#3 + PXH(1)];
			private _ctrlSettings = _display ctrlCreate ["RscButtonMenu",-1];
			_ctrlSettings ctrlSetText localize "STR_CAU_xChat_interrupt_settings";
			_ctrlSettings ctrlSetFont FONT_SEMIBOLD;
			_ctrlSettings ctrlSetBackgroundColor _buttonColour;
			_ctrlSettings ctrlSetPosition _buttonPos;
			_ctrlSettings ctrlAddEventHandler ["ButtonClick",{["init"] call FUNC(settingsUI)}];
			_ctrlSettings ctrlCommit 0;
		}] call BIS_fnc_addScriptedEventHandler;
	};

	addMissionEventHandler ["HandleChatMessage",{call FUNC(handleChatMessage)}];

	[] spawn {
		waitUntil {player isKindOf "CAManBase"};
		player setVariable [QUOTE(VAR_UNIT_NAME),name player,true];
		player setVariable [QUOTE(VAR_UNIT_OWNER_ID),clientOwner,true];
	};
};

if isServer then {
	private _extensionEnabled = ("ExtendedChat" callExtension "init") == "init";
	["toggle",_extensionEnabled] call FUNC(log);

	if (getMissionConfigValue[QUOTE(VAR(connectMessages)),1] isEqualTo 1) then {
		addMissionEventHandler ["PlayerConnected",{
			params ["","_uid","_name"];

			if (_uid != "") then {
				[[_uid,_name],{
					private _message = [
						localize "str_mp_connect","%s",
						["StreamSafeName",_this] call FUNC(commonTask)
					] call FUNC(stringReplace);

					VAR_HANDLE_MESSAGE_PRINT_CONDITION = { ["get",VAL_SETTINGS_INDEX_PRINT_CONNECTED] call FUNC(settings) };
					systemChat _message;
				}] remoteExec ["call"];
			};
		}];
	};
	if (getMissionConfigValue[QUOTE(VAR(disconnectMessages)),1] isEqualTo 1) then {
		addMissionEventHandler ["PlayerDisconnected",{
			params ["","_uid","_name","","_owner"];
			[[_uid,_name],{
				private _message = [
					localize "str_mp_disconnect","%s",
					["StreamSafeName",_this] call FUNC(commonTask)
				] call FUNC(stringReplace);

				VAR_HANDLE_MESSAGE_PRINT_CONDITION = { ["get",VAL_SETTINGS_INDEX_PRINT_DISCONNECTED] call FUNC(settings) };
				systemChat _message;
			}] remoteExec ["call"];
		}];
	};
};

// add kill log event to everyone
if isServer then {
	addMissionEventHandler ["EntityRespawned",{
		params ["_entity", "_corpse"];
		if (_entity isKindOf "CAManBase" && {isPlayer _entity}) then {
			_entity setVariable [QUOTE(VAR_UNIT_NAME),name _entity,true];
			_entity setVariable [QUOTE(VAR_UNIT_OWNER_ID),owner _entity,true];
		};
	}];
};
