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
		[ QUOTE(THIS_FUNC) ] call BIS_fnc_recompile; // TODO: remove

		_params params ["_display","_ctrlEdit"];

		findDisplay 24 displayAddEventHandler ["Unload",{
			DISPLAY(VAR_CHAT_OVERLAY_DISPLAY) closeDisplay 2;
		}];

		private _ctrlList = _display ctrlCreate ["ctrlListbox",-1];
		_display setVariable ["ctrlListSuggestions",_ctrlList];

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
		parseSimpleArray _data params ["_event","_data"];

		_data call compile _event;
	};


	case "updateMonitor":{
		private _ctrlEdit = findDisplay 24 displayCtrl 101;
		private _ctrlEditSelection = ctrlTextSelection _ctrlEdit;
		private _ctrlEditSelectionLast = _ctrlEdit getVariable [QUOTE(VAR_CTRL_EDIT_SEL_LAST),[]];

		if !(_ctrlEditSelection isEqualTo _ctrlEditSelectionLast) then {
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
			":","@",
			["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call FUNC(settings)
		];
		private _ctrlEditTextSegmentTypeForced = _ctrlList getVariable ["ctrlEditTextSegmentTypeForced",-1];
		private _ctrlEditTextSegmentTypeCond =_ctrlEditTextSegmentTypePrefixed findIf {_ctrlEditTextSegment find _x == 0};

		// Force select command type if first char is # (a3 commands)
		if (_ctrlEditTextSegmentTypeCond == -1 && {_ctrlEditTextSegment find "#" == 0}) then {_ctrlEditTextSegmentTypeCond = 2};

		// Force reset type from command to nothing if text cursor is not at start of edit
		if (_ctrlEditTextSegmentTypeCond == 2 && {_ctrlEditTextSelection#0 != 0 && {" " in ctrlText _ctrlEdit}}) then {_ctrlEditTextSegmentTypeCond = -1};

		// Determine final segment type
		private _ctrlEditTextSegmentType = [_ctrlEditTextSegmentTypeForced,_ctrlEditTextSegmentTypeCond] select (_ctrlEditTextSegmentTypeForced == -1);

		// Force reset segment type if type has no items to populate the list with
		if (
			(_ctrlEditTextSegmentType == 0 && {!(["isAvailable"] call FUNC(emoji))}) ||
			{
				// TODO: uncomment
				(_ctrlEditTextSegmentType == 1 && {false/*allPlayers findIf {_x != player} == -1*/})/* ||
				{_ctrlEditTextSegmentType == 2 && {false}}*/
			}
		) then {_ctrlEditTextSegmentType = -1};

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
			toLower(_ctrlEditTextSegment select [count(_ctrlEditTextSegmentTypePrefixed param [_ctrlEditTextSegmentType,""])])
		};

		// Trim : off the end of an emoji keyword so it can be easily used again
		if (_ctrlEditTextSegmentType == 0 && {
			(_ctrlEditTextSegmentSearch select [count _ctrlEditTextSegmentSearch - 1]) == ":"
		}) then {
			_ctrlEditTextSegmentSearch = _ctrlEditTextSegmentSearch select [0,count _ctrlEditTextSegmentSearch - 2];
		};

		// Define list items
		private _items = [[
			"Exit",
			"\a3\3den\data\controlsgroups\tutorial\close_ca.paa",
			"","",
			"_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',-1];['updateItems'] call " + QUOTE(THIS_FUNC),
			[0.8,0.8,0.8,1],
			{_ctrlEditTextSegmentType != -1}
		]];

		private _ctrlListSearchDisplayAll = _ctrlEditTextSegmentTypeForced == -1 && {_ctrlEditTextSegmentSearch == ""};
		switch _ctrlEditTextSegmentType do {
			case 0:{
				private _emojis = ["getList"] call FUNC(emoji);
				{
					if (
						_ctrlListSearchDisplayAll ||
						{_ctrlEditTextSegmentSearch in toLower(_x#2) || {_ctrlEditTextSegmentSearch in toLower(_x#0)}}
					) then {
						_items pushBack [
							_x#0,_x#1,
							format["Keyword: %1%2",_x#2,["",endl+"Shortcut: "+_x#3] select (_x#3 != "")],
							_x#2,
							"['insertItem',[0,_data]] call " + QUOTE(THIS_FUNC)
						];
					};
				} forEach _emojis;
			};
			case 1:{
				// TODO: add mentions parsing on receiving end
				private _players = [];
				{
					// TODO: uncomment
					if (true/*_x != player*/) then {
						_items pushBack [
							_x getVariable [QUOTE(VAR_UNIT_NAME),name _x],
							"","",str clientOwner,
							"['insertItem',[1,_data]] call " + QUOTE(THIS_FUNC)
						];
					};
				} forEach allPlayers;
				_players sort true;
				_items append _players
			};
			case 2:{
				// Wipe force variable incase it is set to command
				_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',-1];

				private _xChatCommands = [];
				{
					if (_ctrlListSearchDisplayAll || {_ctrlEditTextSegmentSearch in toLower(_x#0)}) then {
						_xChatCommands pushBack [
							_ctrlEditTextSegmentTypePrefixed#2 + _x#0,
							"\a3\data_f\images\mod_base_logo_small_ca.paa",
							"",_x#0,"['insertItem',[2,_data,0]] call " + QUOTE(THIS_FUNC)
						];
					};
				} forEach VAR_COMMANDS_ARRAY;
				_xChatCommands sort true;
				_items append _xChatCommands;

				// TODO: add cba commands?

				private _votedInAdmin = serverCommandAvailable "#kick";
				private _loggedInAdmin = serverCommandAvailable "#lock";
				private _a3Commands = [];
				{
					if (serverCommandAvailable _x) then {
						if (_ctrlListSearchDisplayAll || {_ctrlEditTextSegmentSearch in toLower _x}) then {
							_a3Commands pushBack [_x,"","",_x,"['insertItem',[2,_data,1]] call " + QUOTE(THIS_FUNC)];
						};
					};
				} forEach [
					"#login","#userlist","#beclient","#vote", // any user
					"#kick","#debug", // voted in admin
					"#logout","#restart","#mission","#missions","#reassign","#monitor","#init", // voted/logged in admin
					"#lock","#unlock","#maxping","#maxdesync","#maxpacketloss", // logged in admin/host
					"#shutdown","#restartserver","#exec","#beserver","#monitords","#logentities","#exportjipqueue", // logged in admin
					"#captureframe","#enabletest","#disabletest" // certain game builds
				];
				_a3Commands sort true;
				_items append _a3Commands;
			};
			default {
				_items = [
					[
						"Insert an emoji",
						"cau\extendedchat\images\ico_emoji.paa",
						"","",
						"_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',0];['updateItems'] call " + QUOTE(THIS_FUNC),
						[0.8,0.8,0.8,1],
						{_ctrlEditTextSegmentType == -1 && {["isAvailable"] call FUNC(emoji)}}
					],
					[
						"Mention a player",
						"cau\extendedchat\images\ico_mention.paa",
						"","",
						"_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',1];['updateItems'] call " + QUOTE(THIS_FUNC),
						[0.8,0.8,0.8,1],
						// TODO: uncomment
						{_ctrlEditTextSegmentType == -1 && {true/*allPlayers findIf {_x != player} > -1*/}} // && has mentions to show
					],
					[
						"Insert a command",
						"cau\extendedchat\images\ico_command.paa",
						"","",
						"_ctrlList setVariable ['ctrlEditTextSegmentTypeForced',2];['updateItems'] call " + QUOTE(THIS_FUNC),
						[0.8,0.8,0.8,1],
						{_ctrlEditTextSegmentType == -1 && _ctrlEditTextSelection#0 == 0} // && has commands to show
					]
				];
			};
		};

		// Delete exit item if the type is not forced or if it is the only item
		if (_ctrlEditTextSegmentType != -1 && {count _items == 1 || _ctrlEditTextSegmentTypeForced == -1}) then {_items deleteAt 0};

		// Clear list of existing items
		lbClear _ctrlList;
		_ctrlList lbSetCurSel -1;

		// Add new items to list
		{
			_x params ["_text","_image","_tooltip","_data","_event",["_color",[1,1,1,1]],["_condition",{true}]];
			if (call _condition) then {
				private _index = _ctrlList lbAdd _text;
				_ctrlList lbSetTooltip [_index,_tooltip];
				_ctrlList lbSetData [_index,str[_event,_data]];
				_ctrlList lbSetColor [_index,_color];
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
			_ctrlListMaxWidth = _ctrlListMaxWidth max ((_ctrlList lbText _i) getTextWidth [_ctrlListFont,_ctrlListRowH]);
		};

		private _ctrlListH = ((lbSize _ctrlList * _ctrlListRowH) min (10 * _ctrlListRowH)) + PXH(.1);
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
		_params params ["_type","_data","_data2"];

		private _ctrlEdit = findDisplay 24 displayCtrl 101;

		_data = switch _type do {
			case 0:{":"+_data+":"};
			case 1:{"@"+_data};
			case 2:{
				if (_data2 == 0) then {
					(["get",VAL_SETTINGS_INDEX_COMMAND_PREFIX] call FUNC(settings)) + _data
				} else {_data}
			};
			default {_data};
		};

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

		// TODO: modify to work with ctrlTextSelection selected ranges
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
