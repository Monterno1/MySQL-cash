#include <a_samp>
#include <fix>
#include <a_mysql>
#include <streamer>
#include <Pawn.CMD>
#include <sscanf2>
#include <foreach>
#include <Pawn.Regex>
#include <crashdetect>
#include <string>

#pragma tabsize 0

#define     MySQL_HOST "localhost"
#define     MySQL_USER "root"
#define     MySQL_PASS ""
#define     MySQL_BASE "project"

#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll
#define SPD ShowPlayerDialog

#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_PINK 0xFF66FFAA
#define COLOR_BLUE 0x0000BBAA
#define COLOR_DARKRED 0x660000AA
#define COLOR_ORANGE 0xFF9900AA
#define COLOR_BRIGHTRED 0xFF0000AA
#define COLOR_INDIGO 0x4B00B0AA
#define COLOR_VIOLET 0x9955DEEE
#define COLOR_LIGHTRED 0xFF99AADD
#define COLOR_SEAGREEN 0x00EEADDF
#define COLOR_GRAYWHITE 0xEEEEFFC4
#define COLOR_LIGHTNEUTRALBLUE 0xabcdef66
#define COLOR_GREENISHGOLD 0xCCFFDD56
#define COLOR_LIGHTBLUEGREEN 0x0FFDD349
#define COLOR_NEUTRALBLUE 0xABCDEF01
#define COLOR_LIGHTCYAN 0xAAFFCC33
#define COLOR_LEMON 0xDDDD2357
#define COLOR_MEDIUMBLUE 0x63AFF00A
#define COLOR_NEUTRAL 0xABCDEF97
#define COLOR_BLACK 0x00000000
#define COLOR_NEUTRALGREEN 0x81CFAB00
#define COLOR_DARKGREEN 0x12900BBF
#define COLOR_LIGHTGREEN 0x24FF0AB9
#define COLOR_DARKBLUE 0x300FFAAB
#define COLOR_BLUEGREEN 0x46BBAA00
#define COLOR_PINK 0xFF66FFAA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_DARKRED 0x660000AA
#define COLOR_ORANGE 0xFF9900AA
#define COLOR_PURPLE 0x800080AA
#define COLOR_GRAD1 0xB4B5B7FF
#define COLOR_GRAD2 0xBFC0C2FF
#define COLOR_RED1 0xFF0000AA
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_BROWN 0x993300AA
#define COLOR_CYAN 0x99FFFFAA
#define COLOR_TAN 0xFFFFCCAA
#define COLOR_PINK 0xFF66FFAA
#define COLOR_KHAKI 0x999900AA
#define COLOR_LIME 0x99FF00AA
#define COLOR_SYSTEM 0xEFEFF7AA
#define COLOR_GRAD2 0xBFC0C2FF
#define COLOR_GRAD4 0xD8D8D8FF
#define COLOR_GRAD6 0xF0F0F0FF
#define COLOR_GRAD2 0xBFC0C2FF
#define COLOR_GRAD3 0xCBCCCEFF
#define COLOR_GRAD5 0xE3E3E3FF
#define COLOR_GRAD1 0xB4B5B7FF

main()
{
	print("\n----------------------------------");
	print("--------PROJECT ZERO STARTED--------");
	print("----------------------------------\n");
}

//====================================TRASH HOLDER==============================
new MySQL:dbHandle;
new PlayerAFK[MAX_PLAYERS];
//------------------------------------ MYSQL-----------------------------------


enum player
{
	ID,
	NAME[MAX_PLAYER_NAME],
	PASSWORD[65],
	SALT[11],
	EMAIL[65],
	REGDATA[13],
	REGIP[16],
	SKIN,
	ADMIN,
	CASH,
 }
 new player_info [MAX_PLAYERS] [player];
 
 enum dialogs
 {
	DLG_NONE,
	DLG_REG,
	DLG_REGEMAIL,
	DLG_LOG,
	DLG_REGREF,
 }

public OnGameModeInit()
{
	ConnectMySQL();
	
	SetTimer("SecondUpdate", 1000, true);
	return 1;
}

stock ConnectMySQL()
{
	dbHandle = mysql_connect(MySQL_HOST, MySQL_USER, MySQL_PASS, MySQL_BASE);
	switch(mysql_errno())
	{
		case 0: print("IT IS WORKING");
		default: print("IT IS NOOOOOT WORKING");
		
	}
	mysql_log(ALL);
	mysql_set_charset("cp1251");
 }

public OnGameModeExit()
{
	return 1;
}

forward SecondUpdate();
public SecondUpdate()
{
	foreach(new i:Player)
	{
	    PlayerAFK[i]++;
	    if(PlayerAFK[i] >= 3)
		{
			new string[] = "{FF0000} AFK: ";
			if(PlayerAFK[i] < 60)
			{
				format(string, sizeof(string), "%s%d sec", string, PlayerAFK[i]);
			}
			else
			{
			    new minute = floatround(PlayerAFK[i]/60, floatround_floor);
			    new second = PlayerAFK[i] % 60;
			    format(string, sizeof(string), "%s%d min. %d sec.", string, minute, second );
			}
			SetPlayerChatBubble(i, string, -1, 20, 1000);
		}
	}
	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{

	GetPlayerName(playerid, player_info[playerid][NAME], MAX_PLAYER_NAME);
	TogglePlayerSpectating(playerid, 1);
	InterpolateCameraPos(playerid, -371.9478,1239.1519,30.7224,-618.3073,1185.9912,27.1245, 15000);


	static const fmt_query[] = "SELECT `password`, `salt` FROM `players` WHERE `name` = '%s'";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
	format(query, sizeof(query), fmt_query, player_info[playerid][NAME]);
	mysql_tquery(dbHandle, query, "CheckRegistration", "i", playerid);
	
	SetPVarInt(playerid, "WrongPassword", 3);
	return 1;
}

forward CheckRegistration(playerid);
	public CheckRegistration(playerid)
	{
			new rows;
			cache_get_row_count(rows);
			if(rows)
	{
			cache_get_value_name(0, "password", player_info[playerid][PASSWORD], 65);
		 	cache_get_value_name(0, "salt", player_info[playerid][SALT], 11);
			ShowLogin(playerid);
 	}
			else ShowRegistration(playerid);
	}

stock ShowLogin(playerid)
{
	new dialog[200+(-2+MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	"{FFFFFF} Welcome back {dba212} %s, {FFFFFF} happy to see you again!\n\
	{dba212} Project ZERO {FFFFFF}is on a run, and we need your help!\n\n\
	To continue enter your password in line below:",
	player_info[playerid][NAME]);

 SPD(playerid, DLG_LOG, DIALOG_STYLE_INPUT, "{dba212}Authorization{FFFFFF}", dialog, "Enter", "Exit");
	
}
stock ShowRegistration(playerid)
{
	new dialog[251+(-2+MAX_PLAYER_NAME)];
	format (dialog, sizeof(dialog),
	"{ff8800}%s {FFFFFF}Welcome to the {dba212}Project Zero!\n\
	{FFFFFF}Create account first, its easy ;) \n\n\
	{FFFFFF}The password {FFFFFF}must contain 6 - 32 characters\n\
	{FFFFFF}Make sure that your {dba212}password is strong",
	player_info[playerid] [NAME]
	);
	SPD(playerid, DLG_REG, DIALOG_STYLE_INPUT, "{dba212}Registration  {FFFFFF}Create a new password", dialog, "Continue", "Exit");
}


public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	static const fmt_query2[] = "SELECT * FROM `players` WHERE `cash` = '%d' AND `id` = '%d', 0, 99999999";
new query[sizeof(fmt_query2)+(-2+9)+(-2+8)];
format(query, sizeof(query), fmt_query2, player_info[playerid][CASH], player_info[playerid][ID]);
mysql_query(dbHandle, query);
if(GetPVarInt(playerid, "logged") == 0)
{
SCM(playerid, COLOR_RED, "[ERROR]You have to register before playing.");
return Kick(playerid);
}

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
if(GetPVarInt(playerid, "logged") == 0)
{
SCM(playerid, COLOR_RED, "[ERROR]You have to register use chat.");
return Kick(playerid);
}
	new string[144];
	if(strlen(text) < 113)
	{
	format(string, sizeof(string), "%s[%d]: %s", player_info[playerid][NAME], playerid, text);
	SCMTA (COLOR_WHITE, string);
	SetPlayerChatBubble(playerid, text, COLOR_WHITE, 20, 5000);
	}
	else
	{
		SCM(playerid, COLOR_GREY, "Too much text for one message -_-");
	    return 0;
	}

	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
		return 1;
		}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
        PlayerAFK[playerid] = 0;
    	if(GetPlayerMoney(playerid) != player_info[playerid][CASH])
	{
 ResetPlayerMoney(playerid);
 GivePlayerMoney(playerid, player_info[playerid][CASH]);
}
return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}
//===========================REGISTER AND LOGIN SYSTEMS=========================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
	{
	switch (dialogid)
		{
	case DLG_REG:
			{
		if(response)
				{
		    	if(!strlen (inputtext))
 			  	{
				    ShowRegistration(playerid);
				    return SCM(playerid, COLOR_RED, "[WARNING] {FFFFFF}Create new password and press \"Continue\"");
				}
			if (strlen(inputtext) < 6 || strlen(inputtext) > 32)
				{
			ShowRegistration (playerid);
			return SCM(playerid, COLOR_RED, "[WARNING] {FFFFFF}Password may contains 6 - 32 characters");
 				}
				new regex:rg_passwordcheck = regex_new("^[a-zA-z0-9]{1,}$");
				if (regex_check(inputtext, rg_passwordcheck))
				{
				    new salt[11];
				    for(new i; i < 11; i++)
					{
					    salt[i] = random (79) + 47;
					}
					salt[10] = 0;
					SHA256_PassHash(inputtext, salt, player_info[playerid][PASSWORD], 65);
					strmid(player_info[playerid][SALT], salt, 0, 11, 11);
					printf("%s", player_info[playerid][SALT]);
				SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT, "{dba212}Registration {473dff} E-mail",
				"			         {FFFFFF}Enter your {473dff}e-mail {FFFFFF}adress\n\
				{FFFFFF}If you lose {dba212}password {FFFFFF}or {dba212}name {FFFFFF}of your account there will be opportunity to bring it back",
				"Continue", "");
						
				}
				else
				{
		  			ShowRegistration(playerid);
		  			regex_delete(rg_passwordcheck);
		    		return SCM(playerid, COLOR_RED, "[WARNING]{FFFFFF} Password may contains only 6 - 32 characters");
					}
	                regex_delete(rg_passwordcheck);
				}
			else
			{
				SCM(playerid, COLOR_RED, "Use \"/q\", to leave the server");
				SPD(playerid, -1, 0, " ", " ", " ", "");
				return Kick(playerid);
				}
		 }
		case DLG_REGEMAIL:
		{
		if(!strlen(inputtext))
			{
				SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT, "{dba212}Registration {473dff} E-mail",
				"			         {FFFFFF}Enter your {473dff}e-mail {FFFFFF}adress\n\
				{FFFFFF}If you lose {dba212}password {FFFFFF}or {dba212}name {FFFFFF}of your account there will be opportunity to bring it back",
				"Continue", "");
				return SCM(playerid, COLOR_RED, "[WARNING]{FFFFFF}Check your {473dff}e-mail {FFFFFF}adress before using it");
					}
					new regex:rg_emailcheck = regex_new("^[a-zA-Z0-9.-_]{1,43}@[a-zA-Z]{1,12}.[a-zA-Z]{1,8}$");
					if(regex_check(inputtext, rg_emailcheck))
					{
    strmid(player_info[playerid][EMAIL], inputtext, 0, strlen(inputtext), 64);
     }
					else
					{
						SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT, "{dba212}Registration {473dff} E-mail",
				"			         {FFFFFF}Enter your {473dff}e-mail {FFFFFF}adress\n\
				{FFFFFF}If you lose {dba212}password {FFFFFF}or {dba212}name {FFFFFF}of your account there will be opportunity to bring it back",
				"Continue", "");
				regex_delete(rg_emailcheck);
				return SCM(playerid, COLOR_RED, "[WARNING]{FFFFFF}Check your {473dff}e-mail {FFFFFF}adress before using it");
				}
					regex_delete(rg_emailcheck);
	new Year, Month, Day;
  	getdate (Year, Month, Day);
  	new date[13];
  	format(date, sizeof(date), "%02d.%02d.%d", Day, Month, Year);
  	new ip[16];
  	GetPlayerIp(playerid, ip, sizeof (ip));
  	static const fmt_query[] = "INSERT INTO `players` (`name`, `password`, `salt`,`email`,`regdata`, `regip`) VALUES ('%s', '%s', '%s', '%s', '%s', '%s')";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)+(-2+64)+(-2+10)+(-2+64)+(-2+12)+(-2+15)];
	format(query, sizeof(query), fmt_query, player_info[playerid][NAME], player_info[playerid][PASSWORD], player_info[playerid][SALT], player_info[playerid][EMAIL], date, ip);
	mysql_tquery(dbHandle, query);
	static const fmt_query2[] = "SELECT * FROM `players` WHERE `name` = '%s' AND  `password` = '%s'";
	format(query, sizeof(query), fmt_query2, player_info[playerid][NAME], player_info[playerid][PASSWORD]);
	mysql_tquery(dbHandle, query, "PlayerLogin", "i", playerid);
					}
  case DLG_LOG:
  {
  if(response)
  {
    new checkpass[65];
	SHA256_PassHash(inputtext, player_info[playerid][SALT], checkpass, 65);
	if(strcmp(player_info[playerid][PASSWORD], checkpass, false, 64) == 0)
	{
	static const fmt_query[] = "SELECT * FROM `players` WHERE `name` = '%s' AND `password` = '%s'";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)+(-2+64)];
	format(query, sizeof(query), fmt_query, player_info[playerid][NAME], player_info[playerid][PASSWORD]);
	mysql_tquery(dbHandle, query, "PlayerLogin", "i", playerid);
	}
	else
	{
new string[100];
SetPVarInt(playerid, "WrongPassword", GetPVarInt(playerid, "WrongPassword")-1);
if(GetPVarInt(playerid, "WrongPassword") > 0)
{
format (string, sizeof(string), "[WARNING] {FFFFFF}You used a wrong password. You have %d more tries to get into your account", GetPVarInt(playerid, "WrongPassword"));
SCM(playerid, COLOR_RED, string);
}
if(GetPVarInt(playerid, "WrongPassword") == 0)
{
SCM(playerid, COLOR_RED, "[ERROR]{FFFFFF}You entered wrong password too many times");
SPD(playerid, -1,0, " ", " ", " ", "");
Kick(playerid);
}
ShowLogin(playerid);
}
}
  else
  {
			SCM(playerid, COLOR_RED, "Use \"/q\", to leave the server");
			SPD(playerid, -1, 0, " ", " ", " ", "");
			return Kick(playerid);
		}
	}
}
return 1;
  }
  forward PlayerLogin(playerid);
  public PlayerLogin(playerid)
  {
  new rows;
  cache_get_row_count(rows);
  if (rows)
  {
	cache_get_value_name_int(0, "id", player_info[playerid][ID]);
	cache_get_value_name(0, "email", player_info[playerid][EMAIL], 65);
	cache_get_value_name(0, "regdata", player_info[playerid][REGDATA], 13);
	cache_get_value_name(0, "regip", player_info[playerid][REGIP],16);
	cache_get_value_name(0, "admin", player_info[playerid][ADMIN], 1);
	cache_get_value_name(0, "cash", player_info[playerid][CASH]);

	TogglePlayerSpectating(playerid, 0);
  	
	SetPVarInt(playerid, "logged", 1);
	SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
   SpawnPlayer(playerid);
   }
  }
//==============================================================================
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

stock GiveMoney(playerid, cash)
{
	player_info[playerid][CASH] += cash;
		static const fmt_query[] = "UPDATE `players` SET `cash` = '%d' WHERE `id` = '%d'";
	new query[sizeof(fmt_query)+(-2+9)+(-2+8)];
	format(query, sizeof(query), fmt_query, player_info[playerid][CASH], player_info[playerid][ID]);
	mysql_query(dbHandle, query);
	GivePlayerMoney(playerid, cash);
return 1;
}

