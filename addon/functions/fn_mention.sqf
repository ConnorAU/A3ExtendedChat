/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_mention

Description:
	Master handler for all mention related tasks

Parameters:
	_mode   : STRING - The name of the sub-function
	_params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(mention)

#include "_macros.inc"
#include "_defines.inc"

SWITCH_SYS_PARAMS;

switch _mode do {
	case "parse":{
		{
			if (_x isEqualType "" && {_x find "@" == 1}) then {
				private _fei = _forEachIndex;
				private _messageMentionType = _x select [0,1];
				private _messageMentionID = _x select [2];
				switch _messageMentionType do {
					case "p":{
						private _messageMentionIDChars = _messageMentionID splitString "1234567890";
						if (count _messageMentionIDChars == 0) then {
							{
								private _unitID = str(UNIT_OID(_x));
								if (_unitID isEqualTo _messageMentionID) exitWith {
									// Set variable to true in parent scope (HCM event)
									if (_x isEqualTo player) then {_messageMentionsSelf = true};

									private _unitName = "@"+(["StreamSafeName",[getPlayerUID _x,UNIT_NAME(_x)]] call FUNC(commonTask));
									_params set [
										_fei,
										text _unitName setAttributes [
											"color",(["get",VAL_SETTINGS_KEY_TEXT_MENTION_COLOR] call FUNC(settings)) call BIS_fnc_colorRGBAtoHTML
										]
									];
								};
							} forEach allPlayers;
						};
					};
					case "g":{
						private _messageMentionIDChars = _messageMentionID splitString "1234567890:";
						if (count _messageMentionIDChars == 0) then {
							private _group = groupFromNetId _messageMentionID;
							if (!isNull _group) then {
								if (player in units _group) then {_messageMentionsSelf = true};

								_params set [
									_fei,
									text("@" + groupId _group) setAttributes [
										"color",(["get",VAL_SETTINGS_KEY_TEXT_MENTION_COLOR] call FUNC(settings)) call BIS_fnc_colorRGBAtoHTML
									]
								];
							};
						};
					};
					case "r":{
						private _messageMentionIDChars = _messageMentionID splitString "1234567890";
						if (count _messageMentionIDChars == 0) then {
							private _role = ["getRole",parseNumber _messageMentionID] call FUNC(role);
							if (_role isNotEqualTo []) then {
								if (clientOwner in _role#3) then {_messageMentionsSelf = true};

								_params set [
									_fei,
									text("@" + _role#1) setAttributes ["color",_role#2]
								];
							};
						};
					};
				};
			};
		} forEach _params;

		_params
	};
	case "filterGroups":{
		if !("@" in _params) exitWith {_params};

		private _mentionGroupsMode = getMissionConfigValue[QUOTE(VAR(mentionGroups)),1];
		if (_mentionGroupsMode == 2) exitWith {_params};

		_params = ["stringSplitStringKeep",[_params," "]] call FUNC(commonTask);

		private _sideGroupPlayer = side group player;
		private _strip = [{true},{side _group != _sideGroupPlayer}]#_mentionGroupsMode;

		{
			if (_x find "g@" == 0) then {
				private _messageMentionID = _x select [2];
				private _messageMentionIDChars = _messageMentionID splitString "1234567890:";
				if (count _messageMentionIDChars == 0) then {
					private _group = groupFromNetId _messageMentionID;
					if (!isNull _group && _strip) then {
						_params set [_forEachIndex,""];
					};
				};
			};
		} forEach _params;

		_params joinString ""
	};
	case "extractTargets":{
		if !("@" in _params) exitWith {[]};

		private _mentions = [];
		_params = ["stringSplitStringKeep",[_params," "]] call FUNC(commonTask);

		{
			if (_x find "@" == 1) then {
				private _messageMentionType = _x select [0,1];
				private _messageMentionID = _x select [2];
				switch _messageMentionType do {
					case "p":{
						private _messageMentionIDChars = _messageMentionID splitString "1234567890";
						if (count _messageMentionIDChars == 0) then {
							{
								private _unitID = UNIT_OID(_x);
								if (str _unitID isEqualTo _messageMentionID) exitWith {_mentions pushBack _unitID};
							} forEach allPlayers;
						};
					};
					case "g":{
						private _messageMentionIDChars = _messageMentionID splitString "1234567890:";
						if (count _messageMentionIDChars == 0) then {
							private _group = groupFromNetId _messageMentionID;
							if (!isNull _group) then {_mentions pushBack _group};
						};
					};
					case "r":{
						private _messageMentionIDChars = _messageMentionID splitString "1234567890";
						if (count _messageMentionIDChars == 0) then {
							private _role = ["getRole",parseNumber _messageMentionID] call FUNC(role);
							if (_role isNotEqualTo []) then {_mentions pushBack _role#3};
						};
					};
				};
			};
		} forEach _params;

		_mentions
	};
};
