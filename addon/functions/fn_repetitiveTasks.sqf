/* ----------------------------------------------------------------------------
Project:
	https://github.com/ConnorAU/A3ExtendedChat

Author:
	ConnorAU - https://github.com/ConnorAU

Function:
	CAU_xChat_fnc_repetitiveTasks

Description:
	Master function for tasks that must be executed on every frame

Parameters:
	None

Return:
	Nothing
---------------------------------------------------------------------------- */

#define THIS_FUNC FUNC(repetitiveTasks)

#include "_macros.inc"
#include "_defines.inc"
#include "_dikcodes.inc"

// hide default chat
if shownChat then {showChat false;};

// add event to chat box so we can capture the message when sent
// is done in this loop to avoid issues with keyhandlers & config based events
#define VAR_CHAT_INITIALIZED QUOTE(FUNC_SUBVAR(chatInitialized))
USE_DISPLAY(findDisplay 24);
if (!isNull _display) then {

	// prevent evh adding multiple times
	USE_CTRL(_ctrlEdit,101);
	if !(_ctrlEdit getVariable [VAR_CHAT_INITIALIZED,false]) then {

		// add event to capture sent message text
		_ctrlEdit setVariable [VAR_CHAT_INITIALIZED,true];
		_ctrlEdit ctrlAddEventHandler ["Destroy",{
			if (_this#1 == 1) then {
				[_this#0] call FUNC(processMessage);
			};
			nil
		}];

		// hide background control that spans the screen width
		private _ctrlChatBG = (allControls _display) select (allControls _display findIf {ctrlClassName _x == "CA_Background"});
		_ctrlChatBG ctrlShow false;

		private _displayOverlay = findDisplay 46 createDisplay "RscDisplayEmpty";
		uiNamespace setVariable [QUOTE(VAR_CHAT_OVERLAY_DISPLAY),_displayOverlay];

		// set up per frame unscheduled task handler
		private _eventUnscheduledLoop = {
			params ["_display"];
			private _tasks = _display getVariable ["tasks",[]];

			{
				_x params ["_args","_code",["_execute",{true}],["_remove",{true}]];
				if (_args call _execute) then {_args call _code};
				if (_args call _remove) then {_tasks set [_forEachIndex,0]};
			} forEach _tasks;

			_display setVariable ["tasks",_tasks - [0]];
		};
		_displayOverlay setVariable ["tasks",[]];
		_displayOverlay displayAddEventHandler ["MouseMoving",_eventUnscheduledLoop];
		_displayOverlay displayAddEventHandler ["MouseHolding",_eventUnscheduledLoop];

		// resize the chat ctrl to span the screen width
		private _ctrlEditPos = ctrlPosition _ctrlEdit;
		//_ctrlEditPos set [2,safezoneW - (_ctrlEditPos#0 - safeZoneX)];
		//_ctrlEdit ctrlSetPosition _ctrlEditPos;
		_ctrlEdit ctrlSetFont FONT_NORMAL;
		_ctrlEdit ctrlSetBackgroundColor [COLOR_BACKGROUND_RGBA];
		_ctrlEdit ctrlCommit 0;

		// create character counter
		private _ctrlCharCount = _displayOverlay ctrlCreate ["ctrlStatic",-1];
		_ctrlCharCount ctrlSetText format[localize "STR_CAU_xChat_chat_character_count",0];
		_ctrlCharCount ctrlSetFontHeight _ctrlEditPos#3;
		_ctrlCharCount ctrlSetBackgroundColor [
			profilenamespace getvariable ["IGUI_BCG_RGB_R",0],
			profilenamespace getvariable ["IGUI_BCG_RGB_G",1],
			profilenamespace getvariable ["IGUI_BCG_RGB_B",1],
			profilenamespace getvariable ["IGUI_BCG_RGB_A",0.8]
		];
		_ctrlCharCount ctrlSetPosition [
			_ctrlEditPos#0,
			_ctrlEditPos#1 - ctrlTextHeight _ctrlCharCount - PXH(.5),
			ctrlTextWidth _ctrlCharCount,
			ctrlTextHeight _ctrlCharCount + PXH(.5)
		];
		_ctrlCharCount ctrlCommit 0;
		_displayOverlay setVariable ["ctrlCharCount",_ctrlCharCount];

		// intialise suggest ui
		["init",[_displayOverlay,_ctrlEdit]] call FUNC(suggestionUI);

		// add keydown event to update the character counter text and colour
		private _eventCharCountUpdate = {
			params ["_ctrlEdit"];
			private _display = ctrlParent _ctrlEdit;
			private _displayOverlay = uiNamespace getVariable [QUOTE(VAR_CHAT_OVERLAY_DISPLAY),displayNull];
			private _ctrlCharCount = _displayOverlay getVariable ["ctrlCharCount",controlNull];
			if (!isNull _ctrlCharCount) then {
				(_displayOverlay getVariable ["tasks",[]]) pushBack [
					[_ctrlEdit,_ctrlCharCount],{
						// Added to as a task to delay execution by at least a frame as the modification to text input doesn't occur until after keyDown
						params ["_ctrlEdit","_ctrlCharCount"];
						private _charCount = count ctrlText _ctrlEdit;
						_ctrlCharCount ctrlSetText format[localize "STR_CAU_xChat_chat_character_count",_charCount];
						_ctrlCharCount ctrlSetTextColor [
							linearConversion[100,150,_charCount,1,[COLOR_NOTE_ERROR_RGB]#0,true],
							linearConversion[100,150,_charCount,1,[COLOR_NOTE_ERROR_RGB]#1,true],
							linearConversion[100,150,_charCount,1,[COLOR_NOTE_ERROR_RGB]#2,true],
							1
						];
						_ctrlCharCount ctrlSetPositionW ctrlTextWidth _ctrlCharCount;
						_ctrlCharCount ctrlCommit 0;
					}
				];
			};
		};
		_ctrlEdit ctrlAddEventHandler ["KeyDown",_eventCharCountUpdate];
		_ctrlCharCount setVariable ["update",_eventCharCountUpdate];

		// add keydown event to open the history viewer
		_display displayAddEventHandler ["KeyDown",{
			params ["_display","_key"];
			if (_key in [DIK_PGUP,DIK_PGDN]) then {
				["init",_display] call FUNC(historyUI);
				true
			};
		}];
	};
};

// Handle message controls
#define VAR_UPDATE_MESSAGES_TICK FUNC_SUBVAR(messagesUpdateTick)
#define VAR_UPDATE_MESSAGES_CTRL_STATE QUOTE(FUNC_SUBVAR(ctrlState))
#define VAR_UPDATE_MESSAGES_CTRL_TICK QUOTE(FUNC_SUBVAR(ctrlTick))
if (VAR_NEW_MESSAGE_PENDING || {diag_tickTime >= (missionNameSpace getVariable [QUOTE(VAR_UPDATE_MESSAGES_TICK),0])}) then {
	VAR_UPDATE_MESSAGES_TICK = diag_tickTime + 0.25;
	VAR_NEW_MESSAGE_PENDING = false;

	USE_DISPLAY(DISPLAY(VAR_MESSAGE_FEED_DISPLAY));
	private _y = (VAR_MESSAGE_FEED_POS#1)+(VAR_MESSAGE_FEED_POS#3);
	private _activeMessageCtrls = count VAR_MESSAGE_FEED_CTRLS - 1;

	private _maxMsgsShown = ["get",VAL_SETTINGS_INDEX_MAX_PRINTED] call FUNC(settings);
	private _maxMsgTTL = ["get",VAL_SETTINGS_INDEX_TTL_PRINTED] call FUNC(settings);

	for "_i" from _activeMessageCtrls to 0 step -1 do {
		private _ctrl = VAR_MESSAGE_FEED_CTRLS#_i;

		private _state = _ctrl getVariable [VAR_UPDATE_MESSAGES_CTRL_STATE,0];
		private _tick = _ctrl getVariable [VAR_UPDATE_MESSAGES_CTRL_TICK,0];

		private _ctrlPos = ctrlPosition _ctrl;
		_y = _y - _ctrlPos#3 - PXH(0.5);
		_ctrlPos set [1,_y];
		_ctrl ctrlSetPosition _ctrlPos;

		if ((_activeMessageCtrls - _i) >= _maxMsgsShown) then {
			_tick = diag_tickTime;
		};

		switch _state do {
			case 0:{ // new
				_ctrl ctrlSetFade 0;
				_ctrl setVariable [VAR_UPDATE_MESSAGES_CTRL_STATE,1];
				_ctrl setVariable [VAR_UPDATE_MESSAGES_CTRL_TICK,diag_tickTime + _maxMsgTTL];
			};
			case 1:{ // active
				if (diag_tickTime >= _tick) then {
					_ctrl ctrlSetFade 1;
					_ctrl setVariable [VAR_UPDATE_MESSAGES_CTRL_STATE,2];
					_ctrl setVariable [VAR_UPDATE_MESSAGES_CTRL_TICK,diag_tickTime + 0.5];
				} else {
					_ctrl ctrlSetFade 0;
				};
			};
			case 2:{ // expired
				if (diag_tickTime >= _tick) then {
					ctrlDelete _ctrl;
					VAR_MESSAGE_FEED_CTRLS deleteAt _i;
				};
			};
		};

		if !VAR_MESSAGE_FEED_SHOWN then {
			_ctrl ctrlSetFade 1;
		};
		_ctrl ctrlCommit 0.2;
	};
};

// Update VON speakers ctrl
#define VAR_UPDATE_VON_TICK FUNC_SUBVAR(vonUpdateTick)
#define VAR_UPDATE_VON_ISSPEAKING FUNC_SUBVAR(vonIsSpeaking)
if (VAR_ENABLE_VON_CTRL && {diag_tickTime >= (missionNameSpace getVariable [QUOTE(VAR_UPDATE_VON_TICK),0])}) then {
	VAR_UPDATE_VON_TICK = diag_tickTime + 0.1;
	private _speakers = [];
	private _playerIsSpeaking = false;

	{
		private _channel = getPlayerChannel _x;
		if (_channel != -1) then {
			private _colour = ["ChannelColour",_channel] call FUNC(commonTask);

			_speakers pushBack format[
				"<t color='%1'>%2</t>",
				_colour call BIS_fnc_colorRGBAtoHTML,
				["SafeStructuredText",UNIT_NAME(_x)] call FUNC(commonTask)
			];

			if (_x == player) then {
				_playerIsSpeaking = true;
			};
		};
		false
	} count allPlayers;

	private _text = [
		format["<t size='%1'>",["ScaledFeedTextSize"] call FUNC(commonTask)],
		_speakers joinString ", ",
		"</t>"
	] joinString "";

	USE_DISPLAY(DISPLAY(VAR_MESSAGE_FEED_DISPLAY));
	private _ctrlVoipSpeaker = _display getVariable [QUOTE(VAR_VON_SPEAKERS_CTRL),controlNull];
	private _ctrlVoipSpeakerPos = ctrlPosition _ctrlVoipSpeaker;
	_ctrlVoipSpeaker ctrlShow false;
	_ctrlVoipSpeaker ctrlSetStructuredText parseText _text;

	_ctrlVoipSpeakerPos set [2,safeZoneW];
	_ctrlVoipSpeaker ctrlSetPosition _ctrlVoipSpeakerPos;
	_ctrlVoipSpeaker ctrlCommit 0;

	_ctrlVoipSpeakerPos set [2,(ctrlTextWidth _ctrlVoipSpeaker + PXW(0.1)) min (VAR_MESSAGE_FEED_POS#2)];
	_ctrlVoipSpeaker ctrlSetPosition _ctrlVoipSpeakerPos;
	_ctrlVoipSpeaker ctrlCommit 0;

	_ctrlVoipSpeakerPos set [3,ctrlTextHeight _ctrlVoipSpeaker];
	_ctrlVoipSpeaker ctrlSetPosition _ctrlVoipSpeakerPos;
	_ctrlVoipSpeaker ctrlCommit 0;

	_ctrlVoipSpeaker ctrlShow true;

	if !_playerIsSpeaking then {
		// incase direct chat is being used
		_playerIsSpeaking = !isNull findDisplay 55 && !isNull findDisplay 63;
	};

	private _isSpeaking = missionNamespace getVariable [QUOTE(VAR_UPDATE_VON_ISSPEAKING),false];
	if !(_isSpeaking isEqualTo _playerIsSpeaking) then {
		VAR_UPDATE_VON_ISSPEAKING = !_isSpeaking;
		[
			"voice",
			[
				VAR_UPDATE_VON_ISSPEAKING,
				currentChannel,
				["ClientNamePrefix",[player,currentChannel]] call FUNC(commonTask),
				getplayerUID player
			]
		] remoteExecCall [QUOTE(FUNC(log)),2];
	};
};

nil
