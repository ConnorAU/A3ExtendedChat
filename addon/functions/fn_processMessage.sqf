/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_processMessage

Description:
	Intercepts sent messages and directs them to the necessary functions

Parameters:
	_ctrl : CONTROL - The edit control on the chat display

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(processChatInput)

#include "_defines.inc"

disableSerialization;
params ["_ctrl"];

private _text = ctrlText _ctrl;
if (_text == "") exitWith {};

// muted text check that works even with custom channels
USE_DISPLAY(findDisplay 63);
USE_CTRL(_ctrlMuteChat,104);
if (ctrlText _ctrlMuteChat == getText(configfile >> "RscDisplayChannel" >> "controls" >> "MuteChat" >> "textMuted")) exitWith {};

private _currentChannel = currentChannel;
private _command = ["globalChat","sideChat","commandChat","groupChat","vehicleChat","directChat","customChat"] param [_currentChannel min 6,""];
if (_command == "") exitWith {};

private _pid = getPlayerUID player;

private _commandPrefix = ["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call FUNC(settings);
if ([_text,_commandPrefix] call FUNC(stringPrefix)) exitWith {
	if (missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]) then {
		["text",[-2,_text,UNIT_NAME(player),_pid]] remoteExecCall [QUOTE(FUNC(log)),2];
	};

	[_text] call FUNC(processCommand);
	_ctrl ctrlSetText "";
};

// send log from here so it contains original unstructured text
if (missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]) then {
	private _name = ["ClientNamePrefix",[player,_currentChannel]] call FUNC(commonTask);
	["text",[_currentChannel,_text,_name,_pid]] remoteExecCall [QUOTE(FUNC(log)),2];
};

// strip emojis from text if condition is not met
_text = ["formatCondition",_text] call FUNC(emoji);

// Set modified text to control
_ctrl ctrlSetText _text;
