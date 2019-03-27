/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(repetitiveTasks)

#include "_macros.inc"
#include "_defines.inc"
#include "_dikcodes.inc"

// hide default chat
if shownChat then {showChat false;};

// add event to chat box so we can capture the message when sent 
// is done in this loop to avoid issues with keyhandlers & config based events
#define VAR_CHAT_INPUT_EVENT_HANDLER QUOTE(FUNC_SUBVAR(evhID))
#define VAR_CHAT_INPUT_CHAR_COUNTER QUOTE(FUNC_SUBVAR(char_counter))
USE_DISPLAY(findDisplay 24);
if (!isNull _display) then {

	// Close chat input if a message was recently sent. Spam prevention.
	if ((missionNamespace getVariable [QUOTE(VAR_MESSAGE_SENT_COOLDOWN),0]) > diag_tickTime) exitWith {
		_display closeDisplay 0;
	};

	// prevent evh adding multiple times
	USE_CTRL(_ctrlEdit,101);
	if !(_ctrlEdit getVariable [VAR_CHAT_INPUT_EVENT_HANDLER,false]) then {

		// add event to capture sent message text
		_ctrlEdit setVariable [VAR_CHAT_INPUT_EVENT_HANDLER,true];
		_ctrlEdit ctrlAddEventHandler ["Destroy",{
			if (_this#1 == 1) then {
				[_this#0] call FUNC(processMessage);
			};
			nil
		}];

		private _backgroundColour = ["(profilenamespace getvariable ['IGUI_BCG_RGB_R',0])","(profilenamespace getvariable ['IGUI_BCG_RGB_G',1])","(profilenamespace getvariable ['IGUI_BCG_RGB_B',1])","(profilenamespace getvariable ['IGUI_BCG_RGB_A',0.8])"] apply {[_x] call BIS_fnc_parseNumber};

		// hide background control that spans the screen width
		private _ctrlChatBG = (allControls _display) select (allControls _display findIf {ctrlIDC _x == -1});
		_ctrlChatBG ctrlShow false;

		// resize the chat ctrl to span the screen width
		private _ctrlEditPos = ctrlPosition _ctrlEdit;
		_ctrlEditPos set [2,safezoneW - (_ctrlEditPos#0 - safeZoneX)];
		_ctrlEdit ctrlSetFont FONT_NORMAL;
		_ctrlEdit ctrlSetBackgroundColor [COLOR_BACKGROUND_RGBA];
		_ctrlEdit ctrlSetPosition _ctrlEditPos;
		_ctrlEdit ctrlCommit 0;
		
		// create character counter
		private _ctrlCharCount = _display ctrlCreate ["ctrlStatic",-1];
		_ctrlCharCount ctrlSetText format[localize "STR_CAU_xChat_chat_character_count",0];
		_ctrlCharCount ctrlSetFontHeight _ctrlEditPos#3;
		_ctrlCharCount ctrlSetBackgroundColor _backgroundColour;
		_ctrlCharCount ctrlSetPosition [_ctrlEditPos#0,_ctrlEditPos#1 - ctrlTextHeight _ctrlCharCount,ctrlTextWidth _ctrlCharCount,ctrlTextHeight _ctrlCharCount];
		_ctrlCharCount ctrlCommit 0;
		_ctrlEdit setVariable [VAR_CHAT_INPUT_CHAR_COUNTER,_ctrlCharCount];

		if (count (["getList"] call FUNC(emoji)) > 0) then {
			["initDisplay",[_ctrlEdit,VAR_CHAT_INPUT_CHAR_COUNTER]] call FUNC(emoji);
		};
		private _ctrlCharCountUpdate = {
			params ["_ctrlEdit","_ctrlCharCount"];
			private _thread = _ctrlCharCount getVariable ["thread",scriptNull];
			terminate _thread;
		
			_thread = [_ctrlEdit,_ctrlCharCount] spawn {
				// this event is done in a spawn so it can correctly count the 
				// _ctrlEdit text after deleting characters
				params ["_ctrlEdit","_ctrlCharCount"];
				private _charCount = count ctrlText _ctrlEdit;
				_ctrlCharCount ctrlSetText format[localize "STR_CAU_xChat_chat_character_count",_charCount];
				_ctrlCharCount ctrlSetTextColor [
					linearConversion[100,150,_charCount,1,[COLOR_NOTE_ERROR_RGB]#0,true],
					linearConversion[100,150,_charCount,1,[COLOR_NOTE_ERROR_RGB]#1,true],
					linearConversion[100,150,_charCount,1,[COLOR_NOTE_ERROR_RGB]#2,true],
					1
				];
				private _ctrlCharCountPos = ctrlPosition _ctrlCharCount;
				_ctrlCharCountPos set [2,ctrlTextWidth _ctrlCharCount];
				_ctrlCharCount ctrlSetPosition _ctrlCharCountPos;
				_ctrlCharCount ctrlCommit 0;
			};

			_ctrlCharCount setVariable ["thread",_thread];
		};
		_ctrlCharCount setVariable ["update",_ctrlCharCountUpdate];

		// add keydown event to update the character counter
		_ctrlEdit ctrlAddEventHandler ["KeyDown",{
			params ["_ctrlEdit"];
			private _ctrlCharCount = _ctrlEdit getVariable [VAR_CHAT_INPUT_CHAR_COUNTER,controlNull];
			if (!isNull _ctrlCharCount) then {
				[_ctrlEdit,_ctrlCharCount] call (_ctrlCharCount getVariable ["update",{}]);
			};
		}];
	};
};

// add buttons to interrupt menu, in a loop for same reason as above ^
#define VAR_INTERRUPT_DISPLAY_BUTTONS QUOTE(FUNC_SUBVAR(escReady))
USE_DISPLAY(findDisplay 49);
if (!isNull _display) then {
	if !(_display getVariable [VAR_INTERRUPT_DISPLAY_BUTTONS,false]) then {
		_display setVariable [VAR_INTERRUPT_DISPLAY_BUTTONS,true];

		private _buttonPos = ctrlPosition (_display displayCtrl 2);
		private _buttonColour = ([
			COLOR_ACTIVE_RGB,
			"(profilenamespace getVariable ['GUI_BCG_RGB_A',0.5])"
		] apply {[_x] call BIS_fnc_parseNumber});

		_buttonPos set [1,safezoneY + PX_HA(5)];
		private _ctrlHistory = _display ctrlCreate ["RscButtonMenu",-1];
		_ctrlHistory ctrlSetText localize "STR_CAU_xChat_interrupt_history";		
		_ctrlHistory ctrlSetFont FONT_SEMIBOLD;
		_ctrlHistory ctrlSetBackgroundColor _buttonColour;
		_ctrlHistory ctrlSetPosition _buttonPos;
		_ctrlHistory ctrlAddEventHandler ["ButtonClick",{["init"] call FUNC(historyUI)}];
		_ctrlHistory ctrlCommit 0;

		_buttonPos set [1,_buttonPos#1 + _buttonPos#3 + PX_HA(1)];
		private _ctrlSettings = _display ctrlCreate ["RscButtonMenu",-1];
		_ctrlSettings ctrlSetText localize "STR_CAU_xChat_interrupt_settings";		
		_ctrlSettings ctrlSetFont FONT_SEMIBOLD;
		_ctrlSettings ctrlSetBackgroundColor _buttonColour;
		_ctrlSettings ctrlSetPosition _buttonPos;
		_ctrlSettings ctrlAddEventHandler ["ButtonClick",{["init"] call FUNC(settingsUI)}];
		_ctrlSettings ctrlCommit 0;
	};
};

// Handle message controls
#define VAR_UPDATE_MESSAGES_TICK FUNC_SUBVAR(messages_update_tick)
#define VAR_UPDATE_MESSAGES_CTRL_STATE QUOTE(FUNC_SUBVAR(ctrl_state))
#define VAR_UPDATE_MESSAGES_CTRL_TICK QUOTE(FUNC_SUBVAR(ctrl_tick))
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
		_y = _y - _ctrlPos#3 - PX_HS(0.5);
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
#define VAR_UPDATE_VON_TICK FUNC_SUBVAR(von_update_tick)
#define VAR_UPDATE_VON_ISSPEAKING FUNC_SUBVAR(von_is_speaking)
if (VAR_ENABLE_VON_CTRL && {diag_tickTime >= (missionNameSpace getVariable [QUOTE(VAR_UPDATE_VON_TICK),0])}) then {
	VAR_UPDATE_VON_TICK = diag_tickTime + 0.1;
	private _speakers = [];
	private _playerIsSpeaking = false;

	{
		private _channel = getPlayerChannel _x;
		if (_channel != -1) then {
			private _colour = if (_channel < 6) then {
				["ChannelColour",_channel] call FUNC(commonTask);
			} else {
				["get",[_channel - 5,0]] call FUNC(radioChannelCustom);
			};

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

	_ctrlVoipSpeakerPos set [2,(ctrlTextWidth _ctrlVoipSpeaker + PX_WA(0.1)) min (VAR_MESSAGE_FEED_POS#2)];
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