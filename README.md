# A3ExtendedChat
Adds new functionality to the Arma 3 chat system with emojis, history viewer, message filters and commands!

Video demo: https://youtu.be/RBhJ8USHqOk

# Download
- [Steam workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=)
- [Github Releases](https://github.com/ConnorAU/A3ExtendedChat/releases)

# Developer Info
This mod is designed to work as an enabled mod & packed within a mission file.

## Mission Setup
1. Add the following properties to the `description.ext` of your mission and configure them to your liking.
```cpp
// Enables the extended chat mod
CAU_xChat_enabled = 1; // 0 - disabled, 1 - enabled

// Enables the use of emojis in chat. Automatically disabled if no emojis are found on the client
CAU_xChat_emojis = 1; // 0 - disabled, 1 - enabled

// Toggle "<Name> connected" logs when a player loads into mission
CAU_xChat_connectMessages = 1; // 0 - disabled, 1 - enabled

// Toggle "<Name> disconnected" logs when a player leaves the mission
CAU_xChat_disconnectMessages = 1; // 0 - disabled, 1 - enabled

// Toggle "<Name1> was killed by <Name2>" and "<Name> was killed" when a player dies
CAU_xChat_deathMessages = 1; // 0 - disabled, 1 - enabled

// System logs printed to chat when the player loads into the mission
CAU_xChat_MOTD[]={
//  {delay before printing,message}
    {0,"This message printed immediately"},
    {2,"This message printed after a 2 second delay"}
};
```
2. If using function whitelisting in `CfgRemoteExec`, add the following lines
```cpp
class CAU_xChat_fnc_sendMessage {allowedTargets=0;};
class CAU_xChat_fnc_log {allowedTargets=2;};
class CAU_xChat_fnc_radioChannelCustom {allowedTargets=2;};
```

### Additional Setup (Script version only)
1. Download the script version of this mod from the [releases](https://github.com/ConnorAU/A3ExtendedChat/releases) page
2. Drag and drop the `ExtendedChat` folder into your mission root
3. Open your `description.ext`
4. Add the following line inside class `CfgFunctions`
```cpp
#include "ExtendedChat\CfgFunctions.cpp"
```
5. Add the following line inside class `RscTitles`
```cpp
#include "ExtendedChat\RscTitles.cpp"
```
6. Merge the `stringtable.xml` from the script release with your mission `stringtable.xml`, ensuring the `CAU_xChat` package is inside the `<Project></Project>` tags

An example `description.ext` can be found inside the script release files if you are confused by any of the instructions above.

## Server Setup
Full chat logs can be saved to log files if you wish. Simply add the mod to your server and place the .dll library from the [releases](https://github.com/ConnorAU/A3ExtendedChat/releases) page in the `@ExtendedChat` folder.

The `.bikey` file for this mod can be found on the [releases](https://github.com/ConnorAU/A3ExtendedChat/releases) page.

## Emoji Setup
Emojis can be added to the `description.ext` and `config.cpp`. The mod will search the `missionConfigFile` for emojis before the `configFile` which allows for overwriting modded emojis on a per-mission basis.

Emojis must be placed inside of `class CfgEmoji {};`.  
Use the following class template to define your emojis:
```cpp
class unique_emoji_class {
    displayName="Emoji Display Name";
    icon="file\path\to\my\emoji.paa";
    keyword="emoji_keyword"; // will be recognized as :emoji_keyword: in chat
    shortcut=">:D"; // >:D will also be recognized as this emoji (optional)
    condition="true"; // Restrict who can use this emoji to whoever meets the condition
};
```

An example emoji pack is available on the [releases](https://github.com/ConnorAU/A3ExtendedChat/releases) page, containing 52 popular "Twemoji" emojis. Simply add the client files into the ExtendedChat mod folder.

## Functions
Some sqf commands have no effect when this mod is enabled. New functions to replace these commands can be found below.


### [CAU_xChat_fnc_addCommand](https://github.com/ConnorAU/A3ExtendedChat/blob/master/addon/functions/fn_addCommand.sqf)
![Effect: Local](https://community.bistudio.com/wikidata/images/5/52/effects_local.gif)  
Definition: Add new command keyword and associated action. When the command is called in chat, any additional text written after the keyword will be provided as an argument to the action.
Syntax:
- Command: String - keyword used to call the command  
- Action: Code - The code to be executed when the command is called
- Permanent: Bool - Prevent the command code from being overwritten (Optional, default: true)

Example:
```sqf
["myCommand",{
    hint format["Command executed with the following arguments: %1",_this];
}] call CAU_xChat_fnc_addCommand;
```

### [CAU_xChat_fnc_radioChannelCustom](https://github.com/ConnorAU/A3ExtendedChat/blob/master/addon/functions/fn_radioChannelCustom.sqf)
![Server Execution Only](https://community.bistudio.com/wikidata/images/9/9f/Exec_Server.gif) ![Arguments: Global](https://community.bistudio.com/wikidata/images/2/25/arguments_global.gif) ![Effect: Global](https://community.bistudio.com/wikidata/images/f/f7/effects_global.gif)  
Definition: Replaces sqf commands for custom radio channels. Must be executed by the server, regardless of the command.

Syntax:   
- Command: String - sqf command to perform   
    Supported Commands:
    - [radioChannelCreate](https://community.bistudio.com/wiki/radioChannelCreate)
    - [radioChannelAdd](https://community.bistudio.com/wiki/radioChannelAdd)
    - [radioChannelRemove](https://community.bistudio.com/wiki/radioChannelRemove)
    - [radioChannelSetLabel](https://community.bistudio.com/wiki/radioChannelSetLabel)
    - [radioChannelSetCallSign](https://community.bistudio.com/wiki/radioChannelSetCallSign)
- Arguments: Array - Varies by command, read the command BIWiki page for arguments

Example:  
```sqf
private _channelID = ["radioChannelCreate",[[1,0,0,1],"New Channel","%UNIT_NAME",[unit_1]]] call CAU_xChat_fnc_radioChannelCustom;

["radioChannelAdd",[_channelID,[unit_2,unit_3]]] call CAU_xChat_fnc_radioChannelCustom;

["radioChannelRemove",[_channelID,[unit_1]]] call CAU_xChat_fnc_radioChannelCustom;

["radioChannelSetLabel",[_channelID,"New Channel Label"]] call CAU_xChat_fnc_radioChannelCustom;

["radioChannelSetCallSign",[_channelID,"%UNIT_RANK. %UNIT_NAME"]] call CAU_xChat_fnc_radioChannelCustom;
```

### [CAU_xChat_fnc_sendMessage](https://github.com/ConnorAU/A3ExtendedChat/blob/master/addon/functions/fn_sendMessage.sqf)
![Arguments: Global](https://community.bistudio.com/wikidata/images/2/25/arguments_global.gif) ![Effect: Local](https://community.bistudio.com/wikidata/images/5/52/effects_local.gif)  
Definition: Replaces sqf commands used for printing messages to chat.  
Syntax:
- Command: String - sqf command to perform  
    Supported Commands:
    - [systemChat](https://community.bistudio.com/wiki/systemChat)
    - [globalChat](https://community.bistudio.com/wiki/globalChat)
    - [sideChat](https://community.bistudio.com/wiki/sideChat)
    - [commandChat](https://community.bistudio.com/wiki/commandChat)
    - [groupChat](https://community.bistudio.com/wiki/groupChat)
    - [vehicleChat](https://community.bistudio.com/wiki/vehicleChat)
    - directChat (not an sqf command, but supported in this system)
    - [customChat](https://community.bistudio.com/wiki/customChat)
- Arguments: Array
    - Message: String - Text to print to the message feed
    - Sender: Object (Optional, not required for systemChat)
    - ChannelID: Number (6-15) (Optional, only required for custom channels)

Example 1:
```sqf
["systemChat",["This is systemChat"]] call CAU_xChat_fnc_sendMessage;
["globalChat",["This is globalChat",player]] call CAU_xChat_fnc_sendMessage;
["sideChat",["This is sideChat",player]] call CAU_xChat_fnc_sendMessage;
["commandChat",["This is commandChat",player]] call CAU_xChat_fnc_sendMessage;
["groupChat",["This is groupChat",player]] call CAU_xChat_fnc_sendMessage;
["vehicleChat",["This is vehicleChat",player]] call CAU_xChat_fnc_sendMessage;
["directChat",["This is directChat",player]] call CAU_xChat_fnc_sendMessage;
["customChat",["This is customChat",player,6]] call CAU_xChat_fnc_sendMessage;
```

Example 2:
```sqf
// remoteExec a systemChat message to everyone
["systemChat",["This is systemChat"]] remoteExecCall ["CAU_xChat_fnc_sendMessage"];
```

# License
This work is licensed under CUP-License (CUP-L), Version 1.0  
http://cup-arma3.org/license  
https://github.com/ConnorAU/A3ExtendedChat/blob/master/LICENSE

# Contact Me
If you have any questions about this mod, you can contact me on discord: https://discord.gg/DMkxetD
