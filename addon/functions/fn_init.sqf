/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(init)

#include "_defines.inc"

private _isMainMenu = false;
private _mission = format["%1.%2",missionName,worldName];
{
	if ([_mission,getText(_x >> "directory")] call BIS_fnc_inString) exitWith {
		_isMainMenu = true;
	};
} count ("true" configClasses (configFile >> "CfgMissions" >> "CutScenes"));
if _isMainMenu exitWith {};

private _isNumber = isNumber(missionConfigFile >> QUOTE(VAR(enabled)));
if (_isNumber && {getNumber(missionConfigFile >> QUOTE(VAR(enabled))) != 1}) exitWith {
	[] spawn {
		waitUntil {!isNull findDisplay 46};
		private _log = format["ExtendedChat is disabled in this mission: %1.%2",missionName,worldName];
		diag_log _log;
		if (["get",VAL_SETTINGS_INDEX_PRINT_UNSUPPORTED_MISSION] call FUNC(settings)) then {
			systemChat _log;
		};
	};
};

if hasInterface then {
	VAR_HISTORY = [];
	VAR_MESSAGE_FEED_CTRLS = [];
	VAR_NEW_MESSAGE_PENDING = false;
	VAR_ENABLE_LOGGING = false;
	VAR_ENABLE_VON_CTRL = difficultyOption "vonID" > 0;

	VAR_ENABLE_EMOJIS = getNumber(missionConfigFile >> QUOTE(VAR(emojis))) > 0;

	["init"] call FUNC(settings);

	[_isNumber] spawn FUNC(createMessageLayer);

	[] spawn {
		waitUntil {player isKindOf "CAManBase"};
		player setVariable [QUOTE(VAR_UNIT_NAME),name player,true];
	};
};

if isServer then {
	private _extensionEnabled = ("ExtendedChat" callExtension "init") == "init";
	["toggle",_extensionEnabled] call FUNC(log);

	["init"] call FUNC(radioChannelCustom);

	if (getNumber(missionConfigFile >> QUOTE(VAR(connectMessages))) > 0) then {
		addMissionEventHandler ["PlayerConnected",{
			params ["","_uid","_name"];

			if (_uid != "") then {
				[[_uid,_name],{
					[				
						[
							localize "str_mp_connect","%s",
							["StreamSafeName",_this] call FUNC(commonTask)
						] call FUNC(stringReplace),
						nil,nil,_this#0,nil,nil,nil,nil,nil,
						{
							["get",VAL_SETTINGS_INDEX_PRINT_CONNECTED] call FUNC(settings)
						}
					] call FUNC(addMessage);
				}] remoteExec ["call"];
			};
		}];
	};
	if (getNumber(missionConfigFile >> QUOTE(VAR(disconnectMessages))) > 0) then {
		addMissionEventHandler ["PlayerDisconnected",{
			params ["","_uid","_name","","_owner"];
			["disconnect",_owner] call FUNC(radioChannelCustom);
			[[_uid,_name],{
				[
					[
						localize "str_mp_disconnect","%s",
						["StreamSafeName",_this] call FUNC(commonTask)
					] call FUNC(stringReplace),
					nil,nil,_this#0,nil,nil,nil,nil,nil,
					{
						["get",VAL_SETTINGS_INDEX_PRINT_DISCONNECTED] call FUNC(settings)
					}
				] call FUNC(addMessage);
			}] remoteExec ["call"];
		}];
	};
};

// add kill log event to everyone
if (difficultyOption "deathMessages" > 0 && getNumber(missionConfigFile >> QUOTE(VAR(deathMessages))) > 0) then {
	addMissionEventHandler ["EntityKilled",{
		params ["_killed", "_killer", "_instigator"];
		if (isNull _instigator) then {_instigator = UAVControl vehicle _killer # 0};
		if (isNull _instigator) then {_instigator = _killer};

		if (_killed isKindOf "CAManBase" && {isPlayer _killed}) then {	
			private _killedUID = getPlayerUID _killed;
			private _instigatorUID = getPlayerUID _instigator;
			private _text = ["STR_A3_Revive_MSG_KILLED","STR_A3_Revive_MSG_KILLED_BY"] select (_instigator isKindOf "CAManBase" && {_killedUID != _instigatorUID});

			[
				format[
					localize _text,
					["StreamSafeName",[_killedUID,UNIT_NAME(_killed)]] call FUNC(commonTask),
					["StreamSafeName",[_instigatorUID,UNIT_NAME(_instigator)]] call FUNC(commonTask)
				],
				nil,nil,_killedUID,nil,nil,nil,nil,nil,
				{
					["get",VAL_SETTINGS_INDEX_PRINT_KILL] call FUNC(settings)
				}
			] call FUNC(addMessage);
		};
	}];

	if isServer then {
		addMissionEventHandler ["EntityRespawned",{
			params ["_entity", "_corpse"];
			if (_entity isKindOf "CAManBase" && {isPlayer _entity}) then {
				_entity setVariable [QUOTE(VAR_UNIT_NAME),name _entity,true];
			};
		}];
	};
};