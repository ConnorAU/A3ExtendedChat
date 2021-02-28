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
	VAR_MESSAGE_FEED_INSTANT_COMMIT = false;
	VAR_COMMANDS_ARRAY = [];
	VAR_MESSAGE_FEED_SHOWN = !isStreamFriendlyUIEnabled || {!(["get",VAL_SETTINGS_KEY_HIDE_CHAT_FEED_ONLOAD_STREAMSAFE] call FUNC(settings))};
	VAR_NEW_MESSAGE_PENDING = false;
	VAR_ENABLE_LOGGING = missionNamespace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]; // Done like this to use publicVariable before default value
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
			{},{["init",ctrlParent(_this#0)] call FUNC(settingsUI)}
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
			_ctrlSettings ctrlAddEventHandler ["ButtonClick",{["init",ctrlParent(_this#0)] call FUNC(settingsUI)}];
			_ctrlSettings ctrlCommit 0;
		}] call BIS_fnc_addScriptedEventHandler;
	};

	// Add inbuild commands
	["mute",{["mute",_this] call FUNC(command)}] call FUNC(addCommand);
	["unmute",{["unmute",_this] call FUNC(command)}] call FUNC(addCommand);
	["chat-history",{["history",_this] call FUNC(command)}] call FUNC(addCommand);
	["chat-settings",{["settings",_this] call FUNC(command)}] call FUNC(addCommand);
	if (getMissionConfigValue[QUOTE(VAR(whisperCommand)),1] isEqualTo 1) then {
		["whisper",{["whisper",_this] call FUNC(command)}] call FUNC(addCommand);
	};

	addMissionEventHandler ["HandleChatMessage",{call FUNC(handleChatMessage)}];

	[] spawn {
		scriptName "Extended Chat: Player init";
		waitUntil {player isKindOf "CAManBase"};
		player setVariable [QUOTE(VAR_UNIT_NAME),name player,true];
		player setVariable [QUOTE(VAR_UNIT_OWNER_ID),clientOwner,true];
	};
	[] spawn {
		scriptName "Extended Chat: UI init";
		waitUntil {!isNull findDisplay 46};
		findDisplay 46 displayAddEventHandler ["KeyDown",{
			params ["","_key"];
			private _toggleChatFeedKey = ["get",VAL_SETTINGS_KEY_TOGGLE_CHAT_FEED_KEYBIND] call FUNC(settings);
			if (_toggleChatFeedKey != -1 && {_key == _toggleChatFeedKey}) exitWith {
				VAR_MESSAGE_FEED_SHOWN = !VAR_MESSAGE_FEED_SHOWN;
				VAR_NEW_MESSAGE_PENDING = true;
				true
			};
			false
		}];
	};
};

if isServer then {
	private _extensionEnabled = ("ExtendedChat" callExtension "init") == "init";
	["toggle",_extensionEnabled] call FUNC(log);

	// Set variables to unit on respawn -- this is done automatically by arma, but doesn't seem to be 100% reliable
	addMissionEventHandler ["EntityRespawned",{
		params ["_entity", "_corpse"];
		if (_entity isKindOf "CAManBase" && {isPlayer _entity}) then {
			_entity setVariable [QUOTE(VAR_UNIT_NAME),name _entity,true];
			_entity setVariable [QUOTE(VAR_UNIT_OWNER_ID),owner _entity,true];
		};
	}];
};
