/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_fn_suggestionUI

Description:
	Master handler for the suggestion UI

Parameters:
	_mode   : STRING - The name of the sub-function
    _params : ANY    - The arguments provided to the sub-function

Return:
	ANY - Return type depends on the _mode specified
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(suggestionUI)

#include "_macros.inc"
#include "_defines.inc"
#include "_dikcodes.inc"

#define VAR_CTRL_EDIT_SEL_LAST FUNC_SUBVAR(txtSelLast)

SWITCH_SYS_PARAMS;

switch _mode do {
	case "init":{
		_params params ["_display","_ctrlEdit"];

		findDisplay 24 displayAddEventHandler ["Unload",{
			DISPLAY(VAR_CHAT_OVERLAY_DISPLAY) closeDisplay 2;
		}];

		private _ctrlList = _display ctrlCreate ["ctrlListbox",-1];
		_display setVariable ["ctrlListSuggestions",_ctrlList];

		findDisplay 24 displayAddEventHandler ["KeyDown",{
			if ((_this#1 isEqualTo (["get",VAL_SETTINGS_KEY_AUTOCOMPLETE_KEYBIND] call FUNC(settings)))) then {
				["KeyDownAutoComplete"] call THIS_FUNC;
				true
			};
		}];

		_ctrlList ctrlAddEventHandler ["LBSelChanged",{["LBSelChanged",_this] call THIS_FUNC}];

		(_display getVariable ["tasks",[]]) pushBack [
			[],
			{["updateMonitor"] call THIS_FUNC},
			{true},{false}
		];

		["updateItems"] call THIS_FUNC;

		setMousePosition [0.175,0.9];
	};


	case "LBSelChanged":{
		_params params ["_ctrlList","_index"];
		if (_index == -1) exitWith {};

		private _data = _ctrlList lbData _index;
		if (_data == "") exitWith {};

		// Reset force variable if it is set to command as we can only have one command per message
		private _ctrlEditTextSegmentTypeForced = _ctrlList getVariable ["ctrlEditTextSegmentTypeForced",-1];
		if (_ctrlEditTextSegmentTypeForced == 2) then {
			_ctrlList setVariable ["ctrlEditTextSegmentTypeForced",-1]
		};

		parseSimpleArray _data params ["_event","_data"];
		_data call compile _event;
	};
	case "KeyDownAutoComplete":{
		USE_DISPLAY(DISPLAY(VAR_CHAT_OVERLAY_DISPLAY));
		private _ctrlList = _display getVariable ["ctrlListSuggestions",controlNull];

		private _ctrlEditTextSegmentType = _ctrlList getVariable ["ctrlEditTextSegmentType",-1];
		private _ctrlEditTextSegmentTypeForced = _ctrlList getVariable ["ctrlEditTextSegmentTypeForced",-1];

		if (_ctrlEditTextSegmentType != -1 || _ctrlEditTextSegmentTypeForced != -1) then {
			private _index = [1,0] select (_ctrlEditTextSegmentTypeForced == -1);
			["LBSelChanged",[_ctrlList,_index]] call THIS_FUNC;
		};
	};


	case "updateMonitor":{
		private _ctrlEdit = findDisplay 24 displayCtrl 101;
		private _ctrlEditSelection = ctrlTextSelection _ctrlEdit;
		private _ctrlEditSelectionLast = _ctrlEdit getVariable [QUOTE(VAR_CTRL_EDIT_SEL_LAST),[]];

		if (_ctrlEditSelection isNotEqualTo _ctrlEditSelectionLast) then {
			_ctrlEdit setVariable [QUOTE(VAR_CTRL_EDIT_SEL_LAST),_ctrlEditSelection];

			(DISPLAY(VAR_CHAT_OVERLAY_DISPLAY) getVariable ["tasks",[]]) pushBack [
				[],
				{["updateItems"] call THIS_FUNC},
				{true},{true}
			];
		};
	};
	case "updateItems":{
		USE_DISPLAY(DISPLAY(VAR_CHAT_OVERLAY_DISPLAY));
		private _ctrlList = _display getVariable ["ctrlListSuggestions",controlNull];

		// Get text segment
		private _ctrlEdit = findDisplay 24 displayCtrl 101;
		private _ctrlEditTextSelection = ctrlTextSelection _ctrlEdit;
		private _ctrlEditTextSegment = ["getTextSelectionSegment",[_ctrlEdit]] call THIS_FUNC;

		// Determine segment types
		private _ctrlEditTextSegmentTypePrefixed = [
			[":",[0]],["@",[0,1]],
			[["get",VAL_SETTINGS_KEY_COMMAND_PREFIX] call FUNC(settings),[0]]
		];
		private _ctrlEditTextSegmentTypeForced = _ctrlList getVariable ["ctrlEditTextSegmentTypeForced",-1];
		private _ctrlEditTextSegmentTypeCond =_ctrlEditTextSegmentTypePrefixed findIf {_ctrlEditTextSegment find (_x#0) in (_x#1)};

		// Force select command type if first char is # (a3 commands)
		if (_ctrlEditTextSegmentTypeCond == -1 && {_ctrlEditTextSegment find "#" == 0}) then {_ctrlEditTextSegmentTypeCond = 2};

		// Force reset type from command to nothing if text cursor is not at start of edit
		if (_ctrlEditTextSegmentTypeCond == 2 && {_ctrlEditTextSelection#0 != 0 && {" " in ctrlText _ctrlEdit}}) then {_ctrlEditTextSegmentTypeCond = -1};

		// Determine final segment type
		private _ctrlEditTextSegmentType = [_ctrlEditTextSegmentTypeForced,_ctrlEditTextSegmentTypeCond] select (_ctrlEditTextSegmentTypeForced == -1);

		// Force reset segment type if type has no items to populate the list with
		if (_ctrlEditTextSegmentType == 0 && {!(["isAvailable"] call FUNC(emoji))}) then {_ctrlEditTextSegmentType = -1};

		// Save segment type to ctrl
		if ((ctrlText _ctrlEdit == "" || _ctrlEditTextSegment != "") && {_ctrlEditTextSegmentTypeForced == -1}) then {
			_ctrlList setVariable ["ctrlEditTextSegmentType",_ctrlEditTextSegmentType];
		} else {
			// Use last saved segment type if the segment is empty (either cursor at start of text or after a space char(s))
			if (_ctrlEditTextSegmentType == -1) then {
				_ctrlEditTextSegmentType = _ctrlList getVariable ["ctrlEditTextSegmentType",-1];
			};
		};

		// Define sub-segment search string
		private _ctrlEditTextSegmentSearch = if (_ctrlEditTextSegmentTypeForced != -1 && {
			_ctrlEditTextSegmentTypeCond == -1 ||
			_ctrlEditTextSegmentTypeForced != _ctrlEditTextSegmentTypeCond
		}) then {""} else {
			toLower(_ctrlEditTextSegment select [count((_ctrlEditTextSegmentTypePrefixed param [_ctrlEditTextSegmentType,[]])#0)])
		};

		// Trim : off the end of an emoji keyword so it can be easily used again
		if (_ctrlEditTextSegmentType == 0 && {
			(_ctrlEditTextSegmentSearch select [count _ctrlEditTextSegmentSearch - 1]) == ":"
		}) then {
			_ctrlEditTextSegmentSearch = _ctrlEditTextSegmentSearch select [0,count _ctrlEditTextSegmentSearch - 2];
		};

		// Define list items
		private _items = [];

		private _ctrlListSearchDisplayAll = _ctrlEditTextSegmentTypeForced == -1 && {_ctrlEditTextSegmentSearch == ""};
		private _sortBySearch = {
			_this sort true;
			_this apply {_x select [1,count _x]};
		};
		switch _ctrlEditTextSegmentType do {
			case 0:{
				private _emojis = ["getList"] call FUNC(emoji);
				{
					if (count(_x#2) > 0) then {
						private _matchKeyword = _x#2 findIf {tolower _x find _ctrlEditTextSegmentSearch == 0} > -1;
						private _matchTitle = _ctrlEditTextSegmentSearch in toLower(_x#0);
						if (_ctrlListSearchDisplayAll || {_matchKeyword || _matchTitle}) then {
							_items pushBack [
								[1,0] select (_matchKeyword || _matchTitle),
								[_x#0,_x#3 joinString "  "],_x#1,
								format[
									"Keyword%2:  %1%3",
									_x#2 apply {":"+_x+":"} joinString "  ",
									if (count(_x#2) > 1) then {"s"} else {""},
									if (count(_x#3) > 0) then {format[
										"%3Shortcut%2:  %1",
										_x#3 joinString "  ",
										if (count(_x#3) > 1) then {"s"} else {""},
										endl
									]} else {""}
								],
								_x#2#0,
								"['insertItem',[0,_data]] call " + QUOTE(THIS_FUNC)
							];
						};
					};
				} forEach _emojis;
				_items = _items call _sortBySearch;
			};
			case 1:{
				private _ctrlEditTextSegmentMentionContainsType = _ctrlEditTextSegment find "@" == 1;
				private _ctrlEditTextSegmentMentionType = _ctrlEditTextSegment select [0,[0,1] select _ctrlEditTextSegmentMentionContainsType];
				private _ctrlEditTextSegmentSearchTrimPrefix = _ctrlEditTextSegmentSearch select [[0,1] select _ctrlEditTextSegmentMentionContainsType];

				_ctrlListSearchDisplayAll = _ctrlEditTextSegmentTypeForced == -1 && {_ctrlEditTextSegmentSearchTrimPrefix == ""};

				if (_ctrlEditTextSegmentMentionType in ["","p"]) then {
					private _players = [];
					{
						private _unitName = ["StreamSafeName",[getPlayerUID _x,UNIT_NAME(_x)]] call FUNC(commonTask);
						private _unitID = str(UNIT_OID(_x));
						if (
							_ctrlListSearchDisplayAll ||
							{_ctrlEditTextSegmentSearchTrimPrefix in toLower _unitName || {_unitID find _ctrlEditTextSegmentSearchTrimPrefix == 0}}
						) then {
							private _unitIDMention = "p@"+_unitID;
							_players pushBack [
								[1,0] select (toLower _unitName find _ctrlEditTextSegmentSearchTrimPrefix == 0 || {_unitID find _ctrlEditTextSegmentSearchTrimPrefix == 0}),
								[_unitName,_unitIDMention],"\a3\3den\data\displays\display3den\panelright\modeobjects_ca.paa",
								"",_unitIDMention,"['insertItem',[1,_data]] call " + QUOTE(THIS_FUNC)
							];
						};
					} forEach allPlayers;
					_players = _players call _sortBySearch;
					_items append _players;
				};

				private _mentionGroupsMode = getMissionConfigValue[QUOTE(VAR(mentionGroups)),1];
				if (_mentionGroupsMode in [1,2] && {_ctrlEditTextSegmentMentionType in ["","g"]}) then {
					private _allGroups = allGroups;
					if (_mentionGroupsMode == 1) then {
						private _sideGroupPlayer = side group player;
						_allGroups = _allGroups select {side _x isEqualTo _sideGroupPlayer};
					};

					private _groups = [];
					{
						private _groupName = groupId _x;
						private _groupID = netId _x;
						if (
							_ctrlListSearchDisplayAll ||
							{_ctrlEditTextSegmentSearchTrimPrefix in toLower _groupName || {_groupID find _ctrlEditTextSegmentSearchTrimPrefix == 0}}
						) then {
							private _groupIDMention = "g@"+_groupID;
							_groups pushBack [
								[1,0] select (toLower _groupName find _ctrlEditTextSegmentSearchTrimPrefix == 0 || {_groupID find _ctrlEditTextSegmentSearchTrimPrefix == 0}),
								[_groupName,_groupIDMention],"\a3\3den\data\displays\display3den\panelright\modegroups_ca.paa",
								"",_groupIDMention,"['insertItem',[1,_data]] call " + QUOTE(THIS_FUNC)
							];
						};
					} forEach _allGroups;
					_groups = _groups call _sortBySearch;
					_items append _groups;
				};

				if (_ctrlEditTextSegmentMentionType in ["","r"]) then {
					private _roles = [];
					{
						_x params ["_roleID","_roleName"];
						_roleID = str _roleID;
						if (
							_ctrlListSearchDisplayAll ||
							{_ctrlEditTextSegmentSearchTrimPrefix in toLower _roleName || {_roleID find _ctrlEditTextSegmentSearchTrimPrefix == 0}}
						) then {
							private _roleIDMention = "r@"+_roleID;
							_roles pushBack [
								[1,0] select (toLower _roleName find _ctrlEditTextSegmentSearchTrimPrefix == 0 || {_roleID find _ctrlEditTextSegmentSearchTrimPrefix == 0}),
								[_roleName,_roleIDMention],"\a3\3den\data\displays\display3den\statusbar\server_ca.paa",
								"",_roleIDMention,"['insertItem',[1,_data]] call " + QUOTE(THIS_FUNC)
							];
						};
					} forEach (["getAllRoles"] call FUNC(role));
					_roles = _roles call _sortBySearch;
					_items append _roles;
				};
			};
			case 2:{
				private _votedInAdmin = serverCommandAvailable "#kick";
				private _loggedInAdmin = serverCommandAvailable "#lock";

				{
					if (_ctrlListSearchDisplayAll || {_ctrlEditTextSegmentSearch in toLower(_x#0)}) then {
						_items pushBack [
							[1,0] select (toLower(_x#0) find _ctrlEditTextSegmentSearch == 0),
							_ctrlEditTextSegmentTypePrefixed#2#0 + _x#0,"","",
							_ctrlEditTextSegmentTypePrefixed#2#0 + _x#0,"['insertItem',[2,_data]] call " + QUOTE(THIS_FUNC)];
					};
				} forEach VAR_COMMANDS_ARRAY;

				if isClass(configFile >> "CfgPatches" >> "cba_events") then {
					private _cbaCommandsNamespace = missionNamespace getVariable ["cba_events_customChatCommands",locationNull];

					if (!isNull _cbaCommandsNamespace) then {
						private _cbaCommandsAccess = ["all"];
						if (isServer || _votedInAdmin) then {_cbaCommandsAccess pushBack "admin"};
						if (isServer || _loggedInAdmin) then {_cbaCommandsAccess pushBack "adminlogged"};

						{
							(_cbaCommandsNamespace getVariable _x) params ["","_access"];

							if (_access in _cbaCommandsAccess) then {
								if (_ctrlListSearchDisplayAll || {_ctrlEditTextSegmentSearch in toLower _x}) then {
									_items pushBack [
										[1,0] select (toLower _x find _ctrlEditTextSegmentSearch == 0),
										["#" + _x,"CBA"],"","","#" + _x,"['insertItem',[2,_data]] call " + QUOTE(THIS_FUNC)
									];
								};
							};
						} forEach allVariables _cbaCommandsNamespace;
					};
				};

				{
					if (serverCommandAvailable _x) then {
						if (_ctrlListSearchDisplayAll || {_ctrlEditTextSegmentSearch in toLower _x}) then {
							_items pushBack [
								[1,0] select (toLower _x find _ctrlEditTextSegmentSearch == 1),
								[_x,"Arma 3"],"","",_x,"['insertItem',[2,_data]] call " + QUOTE(THIS_FUNC)
							];
						};
					};
				} forEach [
					"#login","#userlist","#beclient","#vote", // any user
					"#kick","#debug", // voted in admin
					"#logout","#restart","#mission","#missions","#reassign","#monitor","#init", // voted/logged in admin
					"#lock","#unlock","#maxping","#maxdesync","#maxpacketloss", // logged in admin/host
					"#shutdown","#restartserver","#exec","#beserver","#monitords","#logentities","#exportjipqueue", // logged in admin
					"#captureframe","#captureslowframe","#enabletest","#disabletest" // certain game builds
				];

				_items = _items call _sortBySearch;
			};
			default {
				_items = [
					[
						"Emojis",
						"cau\extendedchat\data\images\ico_emoji.paa",
						"","",
						"_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',0];['updateItems'] call " + QUOTE(THIS_FUNC),
						[0.8,0.8,0.8,1],
						{_ctrlEditTextSegmentType == -1 && {["isAvailable"] call FUNC(emoji)}}
					],
					[
						"Mentions",
						"cau\extendedchat\data\images\ico_mention.paa",
						"","",
						"_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',1];['updateItems'] call " + QUOTE(THIS_FUNC),
						[0.8,0.8,0.8,1],
						{_ctrlEditTextSegmentType == -1}
					],
					[
						"Commands",
						"cau\extendedchat\data\images\ico_command.paa",
						"","",
						"_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',2];['updateItems'] call " + QUOTE(THIS_FUNC),
						[0.8,0.8,0.8,1],
						{_ctrlEditTextSegmentType == -1 && _ctrlEditTextSelection#0 == 0}
					]
				];
			};
		};

		// Add exit item if the type is forced
		if (_ctrlEditTextSegmentType != -1 && {count _items > 0 && _ctrlEditTextSegmentTypeForced != -1}) then {
			_items = [[
				"Exit",
				"\a3\3den\data\controlsgroups\tutorial\close_ca.paa",
				"","",
				"_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',-1];['updateItems'] call " + QUOTE(THIS_FUNC),
				[0.8,0.8,0.8,1],
				{_ctrlEditTextSegmentType != -1}
			]] + _items;
		};

		// Clear list of existing items
		lbClear _ctrlList;
		_ctrlList lbSetCurSel -1;

		// Add new items to list
		{
			_x params ["_text","_image","_tooltip","_data","_event",["_color",[1,1,1,1]],["_condition",{true}]];
			_text params ["_text",["_textRight",""]];
			if (call _condition) then {
				private _index = _ctrlList lbAdd _text;
				_ctrlList lbSetTextRight [_index,_textRight];
				_ctrlList lbSetTooltip [_index,_tooltip];
				_ctrlList lbSetData [_index,str[_event,_data]];
				_ctrlList lbSetColor [_index,_color];
				_ctrlList lbSetColorRight [_index,[0.5,0.5,0.5,1]];
				_ctrlList lbSetPicture [_index,_image];
				_ctrlList lbSetPictureColor [_index,_color];
			};
		} forEach _items;

		// Update list position
		private _ctrlCharCounter = _display getVariable ["ctrlCharCount",controlNull];

		private _ctrlListRowH = (configFile >> "ctrlListbox" >> "rowHeight") call BIS_fnc_parseNumber;// BIS_fnc_parseNumberSafe doesn't work here
		private _ctrlListFont = getText(configFile >> "ctrlListbox" >> "font");
		private _ctrlListMaxWidth = 0;
		for "_i" from 0 to lbSize _ctrlList - 1 do {
			private _rowText = _ctrlList lbText _i;
			private _rowTextRight = _ctrlList lbTextRight _i;
			if (_rowTextRight != "") then {_rowText = _rowText + "     " + _rowTextRight};
			_ctrlListMaxWidth = _ctrlListMaxWidth max (_rowText getTextWidth [_ctrlListFont,_ctrlListRowH]);
		};

		private _ctrlListH = ((lbSize _ctrlList * _ctrlListRowH) min (10 * _ctrlListRowH)) + PXH(.2);
		private _ctrlListY = ctrlPosition _ctrlEdit#1 - _ctrlListH;
		private _ctrlListW = _ctrlListRowH + _ctrlListMaxWidth + 0.016;
		if (lbSize _ctrlList > 10) then {_ctrlListW = _ctrlListW + PXW(5)};
		private _ctrlListX = (ctrlPosition _ctrlCharCounter#0 + ctrlPosition _ctrlCharCounter#2) max
			(ctrlPosition _ctrlEdit#0 + ((ctrlText _ctrlEdit select [0,ctrlTextSelection _ctrlEdit#0]) getTextWidth [
				FONT_NORMAL,//getText(configFile >> "RscDisplayChat" >> "controls" >> "CA_Line" >> "font"),
				ctrlTextHeight _ctrlEdit
			]) + 0.008) min
			(ctrlPosition _ctrlEdit#0 + ctrlPosition _ctrlEdit#2 - _ctrlListW);

		_ctrlList ctrlSetPosition [_ctrlListX,_ctrlListY,_ctrlListW,_ctrlListH];
		_ctrlList ctrlCommit 0;
	};


	case "getTextSelectionSegment":{
		_params params ["_ctrlEdit"];

		private _ctrlEditText = ctrlText _ctrlEdit;
		private _ctrlEditSelection = ctrlTextSelection _ctrlEdit;

		private _ctrlEditTextSegment = "";
		if (_ctrlEditSelection#1 == 0) then {
			for "_i" from (_ctrlEditSelection#0 - 1) to 0 step -1 do {
				if ((_ctrlEditText select [_i,1]) == " ") exitWith {
					if (_ctrlEditTextSegment == "") then {_ctrlEditTextSegment = " "};
				};
				_ctrlEditTextSegment = _ctrlEditText select [_i,_ctrlEditSelection#0 - _i];
			};
		};

		_ctrlEditTextSegment
	};


	case "insertItem":{
		_params params ["_type","_data"];

		private _ctrlEdit = findDisplay 24 displayCtrl 101;

		if (_type == 0) then {_data = ":"+_data+":"};

		private _ctrlEditText = ctrlText _ctrlEdit;
		ctrlTextSelection _ctrlEdit params ["_ctrlEditSelIndexStart"/*,"_ctrlEditSelIndexLength"*/];

		private _ctrlEditTextNewLength = count _ctrlEditText + count _data + 1;
		if (_ctrlEditTextNewLength == 151) then {_ctrlEditTextNewLength = 150};
		if (_ctrlEditTextNewLength > 151) exitWith {
			_ctrlEdit spawn {
				private _start = diag_tickTime;
				private _end = _start + 0.25;

				[COLOR_NOTE_ERROR_RGBA] params ["_errR","_errG","_errB","_errA"];
				[COLOR_BACKGROUND_RGBA] params ["_normR","_normG","_normB","_normA"];

				waitUntil {
					_this ctrlSetBackgroundColor [
						linearConversion[_start,_end,diag_tickTime,_errR,_normR,true],
						linearConversion[_start,_end,diag_tickTime,_errG,_normG,true],
						linearConversion[_start,_end,diag_tickTime,_errB,_normB,true],
						linearConversion[_start,_end,diag_tickTime,_errA,_normA,true]
					];
					diag_tickTime > _end
				};
			};
		};

		private _ctrlEditSelIndexLength = 0;
		private _ctrlEditTextSegment = ["getTextSelectionSegment",[_ctrlEdit]] call THIS_FUNC;
		private _ctrlEditTextSelPrevChar = _ctrlEditText select [_ctrlEditSelIndexStart - 1,1];
		if (_ctrlEditTextSelPrevChar != " ") then {
			_ctrlEditSelIndexLength = count _ctrlEditTextSegment;
		};

		private _dataAddSpace = _ctrlEditTextNewLength < 150 && {
			(_ctrlEditText select [_ctrlEditSelIndexStart,1]) != " "
		};

		_ctrlEditText = [
			_ctrlEditText select [0,_ctrlEditSelIndexStart - _ctrlEditSelIndexLength],
			_data,
			[""," "] select _dataAddSpace,
			_ctrlEditText select [_ctrlEditSelIndexStart]
		] joinString "";

		_ctrlEdit ctrlSetText _ctrlEditText;
		_ctrlEdit ctrlSetTextSelection [_ctrlEditSelIndexStart - _ctrlEditSelIndexLength + count _data + ([0,1] select _dataAddSpace),0];

		USE_DISPLAY(DISPLAY(VAR_CHAT_OVERLAY_DISPLAY));
		private _ctrlCharCounter = _display getVariable ["ctrlCharCount",controlNull];
		[_ctrlEdit] call (_ctrlCharCounter getVariable ["update",{}]);
	};
};
