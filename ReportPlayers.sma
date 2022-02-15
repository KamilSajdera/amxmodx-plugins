#include <amxmodx>
#include <sqlx>
#include <ColorChat>
#include <core>

new Handle:MySQL;
new MaxPlayers;
new ReportReason[32][50];
new PlayerTimeBlock[32], PlayerNameBlock[32];


new oddaj_id[33];
new Reported[33]; // nick zgloszonego
new IdReported; // id zgloszonego

public plugin_init() 
{
	register_plugin("Report Player", "1.0", "K@MILOVVSKY");
	
	register_clcmd("say /zglos", "PlayerMenu");
	register_clcmd("say_team /zglos", "PlayerMenu");
}


public plugin_cfg()
{
	new szError[512], szErr
	MaxPlayers = get_maxplayers();

	MySQL = SQL_MakeDbTuple("host", "user", "password", "database");
	new Handle:SqlConnection = SQL_Connect(MySQL, szErr, szError, charsmax( szError ))

	if(SqlConnection == Empty_Handle)
		set_fail_state( szError )

}

public PlayerMenu(id)
{
	if(PlayerTimeBlock[id] > get_systime())
	{
		if(is_user_steam(id)){
			ColorChat(id, GREEN, "Musisz odczekac 3 minuty od ostatniego zgloszenia")
		}
		else {
			ColorChat(id, GREEN, "Musisz odczekac 7 minut od ostatniego zgloszenia")
		}
		return PLUGIN_HANDLED;
	}

	new menu = menu_create("Wybierz gracza do zgloszenia:", "PlayerMenuHandle");
	
	for(new i=0, n=0; i<=32; i++)
	{
		if(!is_user_connected(i))
			continue;
		if(is_user_hltv(i))
			continue;
		if(is_user_bot(i))
			continue;

		oddaj_id[n++] = i;
		new nazwa_gracza2[64];
		get_user_name(i, nazwa_gracza2, 63);
		menu_additem(menu, nazwa_gracza2, "0", 0);
	}
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;

}

public PlayerMenuHandle(id, menu, item)
{
	
	if(item == MENU_EXIT) 
	{
		
		menu_destroy(menu);
	
		return PLUGIN_HANDLED;
	
	}
	
	IdReported = oddaj_id[item];
	get_user_name(IdReported, Reported, 32);
	
	if(equali(Reported, PlayerNameBlock[item]))
	{
		ColorChat(id, GREEN, "[BLAD]^x01 Ten gracz byl^x03 przed chwila^x01 zglaszany!");
		return PLUGIN_HANDLED;
	}
	
	PlayerNameBlock[item] = Reported[id];
	
	set_task(300.0, "UnblockPlayerName", id);
	
	PlayerReasonMenu(id);

	return PLUGIN_HANDLED;

}

public PlayerReasonMenu(id)
{

	new Menu = menu_create("Wybierz powod", "PlayerReasonHandle");
	
	menu_additem(Menu, "Gracz ma WH");
	menu_additem(Menu, "Gracz ma SH");
	menu_additem(Menu, "Gracz ma AIM-a");
	menu_additem(Menu, "Gracz utrudnia gre");
	menu_additem(Menu, "Gracz reklamuje");
	menu_additem(Menu, "Gracz nie wykonuje celow mapy");
	
	menu_setprop(Menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(Menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(Menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, Menu);
	
	return PLUGIN_HANDLED;

}

public PlayerReasonHandle(id, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}
	
	switch(Item)
	{
	
		case 0: ReportReason[id] = "ma WH";
		case 1: ReportReason[id] = "ma SH";
		case 2: ReportReason[id] = "ma AIM-a";
		case 3: ReportReason[id] = "utrudnia gre";
		case 4: ReportReason[id] = "reklamuje";
		case 5: ReportReason[id] = "nie wykonuje celow mapy";
	
	}
	
	menu_destroy(Menu);
	QueryCheckAdmin(id);

	return PLUGIN_HANDLED;
	
}

public QueryCheckAdmin(id)
{

	new AdminNumber;

	for(new Number = 1; Number <= MaxPlayers; Number++)
	{
		
		if(is_user_connected(Number) && !is_user_bot(Number) && !is_user_hltv(Number) && get_user_flags(Number) & ADMIN_BAN)
		{
			AdminNumber++;
		}
		
	}
	
	if(AdminNumber > 0)
	{
	
		new Message[256];
		new Time = get_systime();

		get_user_name(IdReported, Reported, 32);
		
		formatex(Message, 255, "[Report Player] Gracz %s %s", Reported, ReportReason[id]);
		
		client_cmd(id, "; say_team @ %s", Message);
		
		ColorChat(id, GREEN, "[INFO]^x01 Gracz zostal zgloszony na^x03 u@^x01 poniewaz na serwerze jest admin");


	
		if(is_user_steam(id)){
			PlayerTimeBlock[id] = Time + 180;
		}
		else {
			PlayerTimeBlock[id] = Time + 420;
		}
	
	}
	
	else
	{
	
		AddReportPlayerIframe(id);
	
	}

}

public UnblockPlayerName(id)
{
	PlayerNameBlock = "";
}



public AddReportPlayerIframe(id)
{

	static Query[512];
	
	new SIDReporting[35], SIDReported[35], Reporting[33], szServerIP[22], Timee[32];

	new Time = get_systime();

	get_user_name(id, Reporting, 32);
	get_user_name(IdReported, Reported, 32);

	get_user_authid(id, SIDReporting, sizeof(SIDReporting)-1)
	get_user_authid(IdReported, SIDReported, sizeof(SIDReported)-1)

	get_user_ip( 0, szServerIP, sizeof szServerIP - 1 );
	get_time("%Y-%m-%d %H:%M:%S",Timee,31)

	
	
	formatex(Query, 511, "INSERT INTO `reports` (`r_reporting_nick`, `r_reporting_sid`, `r_reported_nick`, `r_reported_sid`, `r_server_ip`, `r_reason`, `r_time`) VALUES ('%s','%s','%s','%s','%s','%s','%s')", Reporting, SIDReporting, Reported, SIDReported, szServerIP, ReportReason[id], Timee) // Dodajemy do bazy dane nick i ilosc zabojstw
	
	ColorChat(id, GREEN, "[POWODZENIE]^x01 Gracz^x03 zostal zgloszony^x01! Twoje zgloszenie za chwile pojawi sie na forum.");

	if(is_user_steam(id)){
		PlayerTimeBlock[id] = Time + 180;
	}
	else {
		PlayerTimeBlock[id] = Time + 420;
	}
	
	SQL_ThreadQuery(MySQL, "Query", Query);
	
}

public Query(iFailState, Handle:hQuery, szError[], iError, iData[], iDataSize, Float:fQueueTime) 
{ 

	if(iFailState == TQUERY_CONNECT_FAILED || iFailState == TQUERY_QUERY_FAILED) 
	{
	
		log_amx("%s", szError); 
		
		return;
		
	}
	
}

stock bool:is_user_steam(id) {

	 	static pcv_dp_r_id_provider;
        pcv_dp_r_id_provider = get_cvar_pointer("dp_r_id_provider");
        server_cmd("dp_clientinfo %d", id);
        server_exec();
        
        static uClient;
        uClient = get_pcvar_num(pcv_dp_r_id_provider);
        
        if ( uClient == 2)
                return true;
        
        return false;

}
