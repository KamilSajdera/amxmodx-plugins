#include <amxmodx>
#include <hamsandwich>
#include <colorchat>
#include <unixtime>
#include <fakemeta>
#include <sqlx>

#define ForArray(%1,%2) for(new %1 = 0; %1 < sizeof %2; %1++)
#define ForPlayers(%1) for(new %1 = 1; %1 <= 32; %1++)

#define maxNameLength 33
#define maxSafeNameLength 50
#define maxIpLength 25
#define maxSidLength 36

new const listReasonsMenu[][] =
{
	"Brak mutacji",
	"Brak mikrofonu",
	"Nie ogarnianie",
	"Przeszkadzanie",
	"Nieumiejetne prowadzenie",
	"Nieznajomosc regulaminu"
};

new const banPlayerCommands[][] =
{
	"/ban",
	"/banct",
	"/zbanuj",
	"/banowaniect"
};

new const mysqlData[][] =
{
	"localhost",
	"user",
	"password",
	"database"
};

enum _:mysqlEnumerator (+= 1)
{
	mysqlHost,
	mysqlUser,
	mysqlPass,
	mysqlDBase
};

enum _:playerData (+= 1)
{
	bool:userBan,
	userName[maxNameLength],
	userSafeName[maxSafeNameLength],
	userIp[maxIpLength],
	userSid[maxSidLength],
	userManyBan
};

new const menuAccessFlag = ADMIN_KICK;

new const chatPrefix[] = "^x04[BAN CT]";


new Handle:sqlHandle,
	userData[33][playerData];

new choosenId;


public plugin_init()
{
	register_plugin("BanCT", "v2.0", "K@MILOVVSKY");

	registerCommands(banPlayerCommands, sizeof(banPlayerCommands), "banCT");

	RegisterHam(Ham_Spawn, "player", "playerSpawned", true);

	register_forward(FM_ClientUserInfoChanged, "clientInfoChanged");
}

public plugin_natives()
{
	register_native("isBannedNative", "nativeLetPlay", true);
}

public plugin_precache()
{
	new errorMessage[512],
		errorCode,
		queryRequest[256],
		Handle:temporaryHandle,
		Handle:query;

	sqlHandle = SQL_MakeDbTuple(mysqlData[mysqlHost], mysqlData[mysqlUser], mysqlData[mysqlPass], mysqlData[mysqlDBase]);
 
	temporaryHandle = SQL_Connect(sqlHandle, errorCode, errorMessage, charsmax(errorMessage));

	formatex(queryRequest, charsmax(queryRequest),
											"CREATE TABLE IF NOT EXISTS `banyct`\
	 										(`id` int(5) NOT NULL auto_increment, \
											`name` VARCHAR(35) NOT NULL, \
											`steam_id` VARCHAR(35) NOT NULL, \
											`ip` VARCHAR(35) NOT NULL, \
											`banned` INT NOT NULL, \
											`admin_name` VARCHAR(35), \
											`timestamp` INT NOT NULL, \
											`date` VARCHAR(33), \
											`reason` VARCHAR(35) NOT NULL, \
											`admin_ub_name` VARCHAR(35) NOT NULL, \
											`manyBan` INT NOT NULL, \
											PRIMARY KEY(`id`))");
 	
 	query = SQL_PrepareQuery(temporaryHandle, queryRequest);
 	
 	SQL_FreeHandle(query);
}

public plugin_end()
{
	SQL_FreeHandle(sqlHandle);
}

public client_putinserver(index)
{
	getVariablesData(index);

	loadUserBanData(index);
}

public banCT(index)
{
	if(!(get_user_flags(index) & menuAccessFlag))
	{
		return PLUGIN_HANDLED;
	}

	new menuIndex = menu_create("Wybierz gracza do zbanowania na CT:", "banCtHandlec");

	new nickGracza[33];
	new maxplayers = get_maxplayers(); 
	new data[6] 

	for(new i=1; i<=maxplayers; i++)  
	{
   		if(!is_user_connected(i))
        	  	continue;     
 		
 		if(is_user_hltv(i) || is_user_bot(i))
    	 		continue;    


  		num_to_str(i, data, 5);
  		get_user_name(i, nickGracza, 31);  
  		menu_additem(menuIndex, nickGracza, data);  
	}

	menu_display(index, menuIndex);

	return PLUGIN_HANDLED;
}

public banCtHandlec(index, menuIndex, item)
{


	if(item == MENU_EXIT)
	{
		menu_destroy(menuIndex);
	
		return PLUGIN_HANDLED;
	}
	
	new choosen[32]; 
	new callback;
	new data[6]; 
	new dostep; 
	
	menu_item_getinfo(menuIndex, item, dostep, data, 5, choosen, 31, callback);
	
	choosenId = str_to_num(data);

	banCTstepTwo(index);
	
	return PLUGIN_HANDLED;
}

public banCTstepTwo(admin)
{

	new menuTitle[128],
		menuIndex = menu_create("", "banCTstepTwoHandle"),
		menuCallback = menu_makecallback("banCTstepTwoCallback");
		

	new nickGracza[33];

	get_user_name(choosenId, nickGracza, charsmax(nickGracza))

	formatex(menuTitle, charsmax(menuTitle), "Czy jestes pewien, ze chcesz zbanowac gracza\r %s\w?^nJesli tak, przejdziesz do listy powodow.", nickGracza);
	
	menu_additem(menuIndex, isBanned(choosenId) ? "\rTak \d(\yma bana!\d)" : "\rTak");
	menu_additem(menuIndex, "\wNie");

	if(isBanned(choosenId))
	{
		menu_additem(menuIndex, "Daj UB", "0", _, menuCallback);
	}

	menu_setprop(menuIndex, MPROP_TITLE, menuTitle);

	menu_display(admin, menuIndex);

	log_amx("#banStep2")

}

public banCTstepTwoCallback(index, menuIndex, item)
{
	switch(item)
	{
		case 0:
		{
			if(isBanned(choosenId))
			{
				return ITEM_DISABLED;
			}
		}

		case 2:
		{
			if(!isBanned(choosenId))
			{
				return ITEM_DISABLED;
			}
		}
	}

	return ITEM_ENABLED;
}

public banCTstepTwoHandle(index, menuIndex, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menuIndex);
	
		return PLUGIN_HANDLED;
	}

	switch(item)
	{
		case 0:
		{
			listReasons(index);
		}

		case 1:
		{
			banCT(index);
		}
		
		case 2:
		{
			unbanMenu(index);
		}
	}

	return PLUGIN_HANDLED;
}

public listReasons(index)
{
	new menuIndex = menu_create("Wybierz powod bana:", "listReasonsHandle")

	ForArray(i, listReasonsMenu)
	{
		menu_additem(menuIndex, listReasonsMenu[i]);
	}

	menu_display(index, menuIndex);
}

public listReasonsHandle(index, menuIndex, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menuIndex);
	
		return PLUGIN_HANDLED;
	}

	menu_destroy(menuIndex);
	banPlayer(index, listReasonsMenu[item]);

	return PLUGIN_HANDLED;
}

public unbanMenu(index)
{
	new menuTitle[128],
		menuIndex,
		menuData[2];


	new nickGracza[33];

	get_user_name(choosenId, nickGracza, charsmax(nickGracza))

	formatex(menuTitle, charsmax(menuTitle), "Jestes pewien, ze chcesz dac UB graczowi\r %s\w?", nickGracza);
	formatex(menuData, charsmax(menuData), "%i", choosenId);

	menuIndex = menu_create(menuTitle, "unbanMenuHandle");

	menu_additem(menuIndex, "Tak", menuData);
	menu_additem(menuIndex, "Nie", menuData);

	menu_display(index, menuIndex)
}

public unbanMenuHandle(index, menuIndex, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menuIndex);
	
		return PLUGIN_HANDLED;
	}

	new menuData[2],
		blank;

	menu_item_getinfo(menuIndex, item, blank, menuData, charsmax(menuData), _, _, blank);

	menu_destroy(menuIndex);

	if(!item)
	{
		unbanPlayer(index);
	}
	else
	{
		banCT(index);
	}

	return PLUGIN_HANDLED;
}

public loadUserBanData(index)
{

	new nickGracza[33];
	new sid[36];
	new ip[25];
	get_user_name(index, nickGracza, charsmax(nickGracza));
	get_user_authid(index, sid, charsmax(sid));
	get_user_ip(index, ip, charsmax(ip));

	new queryRequest[512],
		queryData[1];

	queryData[0] = index;

	formatex(queryRequest, charsmax(queryRequest),
										"SELECT * FROM `banyct` WHERE \
										`name` = '%s' OR \
										`steam_id` = '%s' OR \
										`ip` = '%s'",
										nickGracza, sid, ip);
		
	SQL_ThreadQuery(sqlHandle, "loadUserBanDataHandler", queryRequest, queryData, sizeof(queryData));
}

public loadUserBanDataHandler(failState, Handle:query, errorMessage[], errorCode, queryData[], dataSize)
{
	new index = queryData[0];

	if(errorCode)
	{
		log_amx("Blad w zapytaniu: %s [LoadHandler]", errorMessage);
	}

	if(failState == TQUERY_CONNECT_FAILED)
	{
		log_amx("Nie mozna podlaczyc sie do bazy danych.");

		return PLUGIN_CONTINUE;
	}

	else if(failState == TQUERY_QUERY_FAILED)
	{
		log_amx("Zapytanie anulowane [LoadHandler]");

		return PLUGIN_CONTINUE;
	}

	if(SQL_MoreResults(query))
	{
		userData[index][userBan] = bool:SQL_ReadResult(query, SQL_FieldNameToNum(query, "banned"));
		userData[index][userManyBan] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "manyBan"));
	}
	else
	{
		new queryRequest[192];
		new nickGracza[33];
		new sid[36];
		new ip[25];
		get_user_name(index, nickGracza, charsmax(nickGracza));
		get_user_authid(index, sid, charsmax(sid));
		get_user_ip(index, ip, charsmax(ip));
		
		formatex(queryRequest, charsmax(queryRequest),
												"INSERT INTO `banyct` \
												(`name`, \
												`steam_id`, \
												`ip`, \
												`banned`, \
												`manyBan`) \
												VALUES ('%s', '%s', '%s', 0, 0);", nickGracza, sid, ip);

		SQL_ThreadQuery(sqlHandle, "ignore_handle", queryRequest);
	}

	return PLUGIN_CONTINUE;
}

public ignore_handle(failState, Handle:query, error[], errorNum, data[], dataSize)
{
	if(failState)
	{
		if(failState == TQUERY_CONNECT_FAILED)
		{
			log_amx("[BANY] Could not connect to SQL database. [%d] %s", errorNum, error);
		}

		else if(failState == TQUERY_QUERY_FAILED)
		{
			log_amx("[BANY] Query failed. [%d] %s query: %d", errorNum, error, query);
		}
	}

	return PLUGIN_CONTINUE;
}

public playerSpawned(index)
{
	if(!isBanned(index))
	{
		return;
	}
	
	if(get_user_team(index) == 2)
		kickPlayer(index);
}

public clientInfoChanged(index)
{
	getVariablesData(index);
}



public nativeLetPlay(index)
{
	return isBanned(index);
}


formatDate(unix, output[], outputSize)
{
	new timeData[6];

	UnixToTime(unix, timeData[0], timeData[1], timeData[2], timeData[3], timeData[4], timeData[5]);

	formatex(output, outputSize, "%d/%02d/%02d %02d:%02d:%02d", timeData[0], timeData[1], timeData[2], timeData[3]+2, timeData[4], timeData[5]);
}

bool:isBanned(index)
{
	if(userData[index][userBan] && userData[index][userManyBan] > 0)
	{
		return bool:1;
	}
	else 
		return bool:0;
}

escapeString(string[], length)
{
	new const unsafeCharacters[][][] =
	{
		{ "\\", "\\\\" },
		{ "\0", "\\0" },
		{ "\n", "\\n" },
		{ "\r", "\\r" },
		{ "\x1a", "\Z" },
		{ "'", "\'" },
		{ "`", "\`" },
		{ "^"", "\^"" }
	};

	ForArray(i, unsafeCharacters)
	{
		replace_all(string, length, unsafeCharacters[i][0], unsafeCharacters[i][1]);
	}
}

getVariablesData(index)
{
	get_user_name(index, userData[index][userName], maxNameLength);
	get_user_authid(index, userData[index][userSid], maxSidLength);
	get_user_ip(index, userData[index][userIp], maxIpLength);

	copy(userData[index][userSafeName], maxSafeNameLength, userData[index][userName]);

	escapeString(userData[index][userSafeName], maxSafeNameLength);
}

banPlayer(admin, reason[])
{
	
	new nickGracza[33];
	get_user_name(choosenId, nickGracza, charsmax(nickGracza));

	
	if(!is_user_connected(admin) || !is_user_connected(choosenId))
	{
		return;
	}

	if(isBanned(choosenId))
	{
		printMessage(admin, _, "Gracz^x04 %s^x01 ma juz bana.", nickGracza);
		return;
	}
	printMessage(admin, _, "Zbanowales^x04 %s^x01 na CT z powodu:^x03 %s^x01.", nickGracza, reason);

	userData[choosenId][userBan] = true;
	userData[choosenId][userManyBan]++;
	
	user_kill(choosenId);
	saveBanToDatabase(admin, reason);
}

unbanPlayer(admin)
{
	new nickGracza[33];
	new nickAdmina[33];
	get_user_name(choosenId, nickGracza, charsmax(nickGracza));
	get_user_name(admin, nickAdmina, charsmax(nickAdmina));

	if(!is_user_connected(admin) || !is_user_connected(choosenId))
	{
		return;
	}

	printMessage(admin, _, "Dales UB graczowi^x04 %s^x01.", nickGracza);
	printMessage(choosenId, _, "Dostales UB od admina^x04 %s^x01.", nickAdmina);

	userData[choosenId][userBan] = false;

	unbanFromDatabase(admin);
}

unbanFromDatabase(admin)
{
	new nickGracza[33];
	new sid[36];
	new ip[25];
	new nickAdmina[33];
	get_user_name(choosenId, nickGracza, charsmax(nickGracza));
	get_user_authid(choosenId, sid, charsmax(sid));
	get_user_name(admin, nickAdmina, charsmax(nickAdmina))
	get_user_ip(choosenId, ip, charsmax(ip));


	new queryCommand[512];

	formatex(queryCommand, charsmax(queryCommand), "UPDATE `banyct` SET `banned` = '%i', `admin_ub_name` = ^"%s^" WHERE `name` = '%s' OR `steam_id` = '%s' OR `ip` = '%s';", userData[choosenId][userBan], nickAdmina, nickAdmina, sid, ip);

	SQL_ThreadQuery(sqlHandle, "ignore_handle", queryCommand);
}

saveBanToDatabase(admin, const reason[])
{
	new nickGracza[33];
	new sid[36];
	new ip[25];
	new nickAdmina[33]
	get_user_name(choosenId, nickGracza, charsmax(nickGracza));
	get_user_name(admin, nickAdmina, charsmax(nickAdmina))
	get_user_authid(choosenId, sid, charsmax(sid));
	get_user_ip(choosenId, ip, charsmax(ip));

	set_hudmessage(0, 255, 0, -1.0, 0.02, 2, 6.0, 7.0, 0.1, 0.7, 5)
	show_hudmessage(0, "%s dostal bana na CT | Powod: %s", nickGracza, reason);

	new queryRequest[512],
		banDate[33],
		currentUnix = get_systime();

	formatDate(currentUnix, banDate, charsmax(banDate));

	formatex(queryRequest, charsmax(queryRequest),
										"UPDATE `banyct` SET \
										`steam_id` = '%s', \
										`ip` = '%s', \
										`banned` = '%i', \
										`date` = '%s', \
										`admin_name` = '%s', \
										`timestamp` = '%i', \
										`reason` = '%s', \
										`manyBan` = '%i' \
										 WHERE `name` = '%s';", sid, ip, userData[choosenId][userBan], banDate, nickAdmina, currentUnix, reason, userData[choosenId][userManyBan], nickGracza);
		

	SQL_ThreadQuery(sqlHandle, "ignore_handle", queryRequest);
}

kickPlayer(index)
{
	if(!is_user_connected(index))
	{
		return;
	}

	server_cmd("kick #%d ^"Nie mozesz grac w CT, poniewaz dostales bana!^"", get_user_userid(index));
}

/*
	Prints message to a player or all players with prefix and proper formating.
*/
printMessage(index, Color:messageColor = NORMAL, const initialMessage[], any:...)
{
	new newMessage[191];

	// Add additional arguments to the message.
	vformat(newMessage, charsmax(newMessage), initialMessage, 4);

	// Check if we go above the character limit if we add the prefix.
	// ReHLDS and its sub-modules (like safenameandchat for example), do not work 100% properly.
	if(strlen(newMessage) + strlen(chatPrefix) > 191)
	{
		ColorChat(index, messageColor, newMessage);

		return;
	}

	new colorIdentificator[5];
	
	// Format color-identificator-prefix thingy.
	formatex(colorIdentificator, charsmax(colorIdentificator),
																messageColor == NORMAL ? 		"^x01" :
																(messageColor == TEAM_COLOR ? 	"^x03" :
																(messageColor == GREEN ? 		"^x04" : "^x01")));

	// Format new message with proper colors and prefix.
	format(newMessage, charsmax(newMessage), "^x03%s %s%s", chatPrefix, colorIdentificator, newMessage);

	// Display new message.
	ColorChat(index, messageColor, newMessage);
}

stock registerCommands(const array[][], arraySize, function[])
{
	#if !defined ForRange

		#define ForRange(%1,%2,%3) for(new %1 = %2; %1 <= %3; %1++)

	#endif

	#if AMXX_VERSION_NUM >= 183
	
	ForRange(i, 0, arraySize - 1)
	{
		ForRange(j, 0, 1)
		{
			register_clcmd(fmt("%s %s", !j ? "say" : "say_team", array[i]), function);
		}
	}

	#else

	new newCommand[33];

	ForRange(i, 0, arraySize - 1)
	{
		ForRange(j, 0, 1)
		{
			formatex(newCommand, charsmax(newCommand), "%s %s", !j ? "say" : "say_team", array[i]);
			register_clcmd(newCommand, function);
		}
	}

	#endif
}