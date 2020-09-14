#include <amxmodx>
#include <amxmisc>
#include <engine> 
#include <vault>
#include <nvault>
#include <ColorChat>

#define FLAGA_VIP ADMIN_LEVEL_H

new model_noza[33]
new model_m4[33]
new model_ak[33]
new model_awp[33]

new cacheKnife[64]; 
new cacheM4[64];
new cacheAK[64];
new cacheAWP[64];

new userFrags[33] // fragi
new g_name[33][48]
new plik_vault

new const knifePrice[][] = {
	"100",
	"300",
	"750",
	"1150",
	"1500",
	"2000",
	"3000",
	"4500",
	"8000",
	"14000"
};


////START SKIN NAMES

new const nameKnife[][] = 
{
	"Doppler | Ruby",
	"Butterfly | Fade",
	"Butterfly | North",
	"Shadow Daggers | Neon Rider",
	"Bayonet | Slaughter", 
	"Bayonet | Fade",
	"Bayonet M9 | Dopler",
	"Butterfly | Fade",
	"Shadow Daggers | Neon Rider",
	"Bayonet M9 | Fade",
	"Flip | Fade",
	"Karambit | Dragon Lore"
};

new const nameM4[][] = 
{
	"M4A1 | Icarus Fell",
	"M4A1 | Howl \y[VIP]",
	"M4A1 | Space \y[VIP]"
};

new const nameAK[][] = 
{
	"AK47 | Anubis",
	"AK47 | Wasteland Rebel \y[VIP]",
	"AK47 | The Empress \y[VIP]"
};

new const nameAWP[][] = 
{
	"AWP | Oni Taiji",
	"AWP | Phobos \y[VIP]",
	"AWP | Dragon Lore \y[VIP]"
};

/// END SKIN NAMES


/// START FILE NAMES

new const fileNameKnife[][] = 
{
	"/noz/v_knifeNewDoppler.mdl",
	"/noz/v_knifeNewButterfly.mdl",
	"/noz/v_knifeNewButterfly2.mdl",
	"/noz/v_knifeNewShadows.mdl",
	"/noz/v_knifeNewBayonet.mdl",
	"/noz/v_knifeNewBayonet2.mdl",
	"/noz/v_knifeNewM9Dopler.mdl",
	"/noz/v_knifeNewButterfly3.mdl",
	"/noz/v_knifeNewShadows2.mdl",
	"/noz/v_knifeNewBayonet3.mdl",
	"/noz/v_knifeNewFlip.mdl",
	"/noz/v_knifeNewKarambit.mdl"
};

new const fileNameM4[][] = 
{
	"/m4a1/v_m4a1NewIcarus.mdl",
	"/m4a1/v_m4a1NewHowl.mdl",
	"/m4a1/v_m4a1NewDesolate.mdl"
};

new const fileNameAK[][] = 
{
	"/ak47/v_ak47NewAnubis.mdl",
	"/ak47/v_ak47NewWesteland.mdl",
	"/ak47/v_ak47NewEmpress.mdl"
};

new const fileNameAWP[][] = 
{
	"/awp/v_awpNewOni.mdl",
	"/awp/v_awpNewPhobos.mdl",
	"/awp/v_awpNewDlore.mdl"
};


////END FILE NAMES

public plugin_init() { 
	
	register_plugin("Wybor skinow", "v2", "K@MILOVVSKY")
	register_event("CurWeapon","CurWeapon","be","1=1") 
	register_clcmd("say /skiny", "menuWyboru")
	register_clcmd("say /skin", "menuWyboru")
	register_clcmd("say /skins", "menuWyboru")
	register_clcmd("say /modele", "menuWyboru")
	register_clcmd("say /model", "menuWyboru")
	register_clcmd("say /models", "menuWyboru")

	plik_vault = nvault_open("fragi") //tutaj podajemy "nazwe" pliku z danymi
	if(plik_vault == INVALID_HANDLE)
		set_fail_state("Nie moge otworzyc pliku :/");


	register_event("DeathMsg", "DeathMsg", "a")
	
}

public client_disconnected(id) {
	save_frags(id)
	userFrags[id]=0 // zeby ktos kto wejdzie po nas nie mial naszych fragow zapisanych w tablicy
	copy(g_name[id], 47, "");
}

public plugin_end()
	nvault_close(plik_vault)

public plugin_precache() { 

	//zwykle modele
	precache_model("models/v_knife.mdl") 
	precache_model("models/v_m4a1.mdl") 
	precache_model("models/v_ak47.mdl") 
	precache_model("models/v_awp.mdl") 

	for(new i = 0; i < sizeof fileNameKnife; i++)
	{
		formatex(cacheKnife, charsmax(cacheKnife), "models/skiny%s", fileNameKnife[i]);
		precache_model(cacheKnife);	
	}
	
	for(new i = 0; i < sizeof fileNameM4; i++)
	{
		formatex(cacheM4, charsmax(cacheM4), "models/skiny%s", fileNameM4[i]);
		precache_model(cacheM4);
	}

	for(new i = 0; i < sizeof fileNameAK; i++)
	{
		formatex(cacheAK, charsmax(cacheAK), "models/skiny%s", fileNameAK[i]);
		precache_model(cacheAK);
	}

	for(new i = 0; i < sizeof fileNameAWP; i++)
	{
		formatex(cacheAWP, charsmax(cacheAWP), "models/skiny%s", fileNameAWP[i]);
		precache_model(cacheAWP);
	}
	
} 

public DeathMsg()
{
	new killer = read_data(1)	
	
 	userFrags[killer]++;
}

public menuWyboru(id)
{
	new menuBody[512]
	formatex(menuBody, charsmax(menuBody), "\d[\r*\yDeagleShot.eu\r*\d]^n\wMenu Skinow:\y")
	new menu = menu_create(menuBody, "skinsmenu")

	menu_additem(menu, "\wNoz")
	menu_additem(menu, "\wM4A1")
	menu_additem(menu, "\wAK47")
	menu_additem(menu, "\wAWP")

	if(!(get_user_flags(id) & FLAGA_VIP))
		menu_addtext(menu, "^n\wNie posiadasz jeszcze \rVIP'a\w. \yPora to zmienic!^n\wJesli chcesz skorzystac ze skinow, wpisz \r/sklepsms", 0);
	
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);
}
public skinsmenu(id, menu, item) {

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	switch(item) 
	{
		case 0: menu_noze(id)
		case 1: menu_m4(id)
		case 2: menu_ak(id)
		case 3: menu_awp(id)
		default: return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
} 
public menu_noze(id) {

	new formatKnifes[128];

	new menuBody[512]
	formatex(menuBody, charsmax(menuBody), "\ySkiny do \rNoza^n\wPo osiagnieciu odpowiedniej ilosci fragow, dostaniesz dostep do ponizszych skinow!^nTwoje fragi: \r%d\w", userFrags[id])
	new menu = menu_create(menuBody, "knifemenu")

	new checkAccess = menu_makecallback("hasAccessKnife");

	menu_additem(menu, "Domyslny")
	
	for(new i = 0; i < sizeof nameKnife; i++)
	{
		if(i == 0)
		{
			menu_additem(menu, nameKnife[0])
			continue;
		}
		else if(i == 1 )
		{
			menu_additem(menu, nameKnife[1])
			continue;
		}
		else 
		{
			
			formatex(formatKnifes, charsmax(formatKnifes), "%s \y[\r%d\w fragow\y]", nameKnife[i], str_to_num(knifePrice[i-2]))
			menu_additem(menu, formatKnifes,"",0, checkAccess)
		}
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);
}

public knifemenu(id, menu, item) {
	SetKnife(id, item)
	ColorChat(id, GREEN, "[DD2]^x01 Zmieniles noz na^x03 %s^x01.", nameKnife[item])
	ZapiszNoz(id)
	return PLUGIN_HANDLED
} 

public SetKnife(id , Knife) {

	model_noza[id] = Knife
	
	new Clip, Ammo, Weapon = get_user_weapon(id, Clip, Ammo) 
	if ( Weapon != CSW_KNIFE )
	return PLUGIN_HANDLED
	
	new vModel[56]
	
	if(Knife == 0)
		format(vModel,55,"models/v_knife.mdl");
	else 
		format(vModel,55,"models/skiny%s", fileNameKnife[Knife])
	
	entity_set_string(id, EV_SZ_viewmodel, vModel)
	
	return PLUGIN_HANDLED;  
}

public menu_m4(id) {

	new menuBody[512]
	formatex(menuBody, charsmax(menuBody), "\ySkiny do \rM4A1:")
	new menu = menu_create(menuBody, "m4menu")
	
	new checkAccess = menu_makecallback("hasAccess");

	menu_additem(menu, "Domyslny")

		
	
	for(new i = 0; i < sizeof nameM4; i++)
	{
		if(i <= 0)
		{
			menu_additem(menu, nameM4[0])
			continue;
		}
		else 
		menu_additem(menu, nameM4[i],"",0, checkAccess)
	}

	
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);
}

public m4menu(id, menu, item) {
	SetM4A1(id, item)
	ColorChat(id, GREEN, "[DD2]^x01 Zmieniles skin M4A1 na^x03 %s^x01.", nameM4[item])
	ZapiszM4(id)
	return PLUGIN_HANDLED
} 

public SetM4A1(id , M4A1) {
	model_m4[id] = M4A1
	
	new Clip, Ammo, Weapon = get_user_weapon(id, Clip, Ammo) 
	if ( Weapon != CSW_M4A1 )
	return PLUGIN_HANDLED
	
	new vModel[56]
	
	if(M4A1 == 0)
		format(vModel,55,"models/v_m4a1.mdl");
	else 
		format(vModel,55,"models/skiny%s", fileNameM4[M4A1])
	
	entity_set_string(id, EV_SZ_viewmodel, vModel)
	
	return PLUGIN_HANDLED;  
}
public menu_ak(id) {

	new menuBody[512]
	formatex(menuBody, charsmax(menuBody), "\ySkiny do \rAK47:")
	new menu = menu_create(menuBody, "akmenu")

	new checkAccess = menu_makecallback("hasAccess");

	menu_additem(menu, "Domyslny")
	
	
	
	for(new i = 0; i < sizeof nameAK; i++)
	{
		if(i <= 0)
		{
			menu_additem(menu, nameAK[0])
			continue;
		}
		else 
		menu_additem(menu, nameAK[i],"",0, checkAccess)
	}
	
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);
}

public akmenu(id, menu, item) {
	SetAK47(id, item)
	ColorChat(id, GREEN, "[DD2]^x01 Zmieniles skin AK47 na^x03 %s^x01.", nameAK[item])
	ZapiszAK(id)
	return PLUGIN_HANDLED
} 

public SetAK47(id , AK47) {
	model_ak[id] = AK47
	
	new Clip, Ammo, Weapon = get_user_weapon(id, Clip, Ammo) 
	if ( Weapon != CSW_AK47 )
	return PLUGIN_HANDLED
	
	new vModel[56]
	
	if(AK47 == 0)
		format(vModel,55,"models/v_ak47.mdl");
	else 
		format(vModel,55,"models/skiny%s", fileNameAK[AK47])
	
	entity_set_string(id, EV_SZ_viewmodel, vModel)
	
	return PLUGIN_HANDLED;  
}
public menu_awp(id) {

	new menuBody[512]
	formatex(menuBody, charsmax(menuBody), "\ySkiny do \rAWP:")
	new menu = menu_create(menuBody, "awpmenu")
	
	new checkAccess = menu_makecallback("hasAccess");

	menu_additem(menu, "Domyslny")
	
	for(new i = 0; i < sizeof nameAWP; i++)
	{
		if(i <= 0)
		{
			menu_additem(menu, nameAWP[0])
			continue;
		}
		else 
		menu_additem(menu, nameAWP[i],"",0, checkAccess)
	}
	

	
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);
}

public awpmenu(id, menu, item) {
	SetAWP(id, item)
	ColorChat(id, GREEN, "[DD2]^x01 Zmieniles skin AWP na^x03 %s^x01.", nameAWP[item])
	ZapiszAWP(id)
	return PLUGIN_HANDLED
} 

public SetAWP(id , AWP) {
	model_awp[id] = AWP
	
	new Clip, Ammo, Weapon = get_user_weapon(id, Clip, Ammo) 
	if ( Weapon != CSW_AWP )
	return PLUGIN_HANDLED
	
	new vModel[56]
	
	if(AWP == 0)
		format(vModel,55,"models/v_awp.mdl");
	else 
		format(vModel,55,"models/skiny%s", fileNameAWP[AWP])
	
	entity_set_string(id, EV_SZ_viewmodel, vModel)
	
	return PLUGIN_HANDLED;  
}


public CurWeapon(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	

	SetKnife(id, model_noza[id])
	SetM4A1(id, model_m4[id])
	SetAK47(id, model_ak[id])
	SetAWP(id, model_awp[id])
	
	return PLUGIN_HANDLED   

}
public client_authorized(id)
{
	ZaladujNoze(id)
	ZaladujM4(id)
	ZaladujAK(id)
	ZaladujAWP(id)
	load_frags(id);
}

ZapiszNoz(id)
{ 
	
	new authid[32]
	get_user_authid(id, authid, 31)
	
	new vaultkey[64]
	new vaultdata[64]
	
	format(vaultkey, 63, "Knife_%s", authid)
	format(vaultdata, 63, "%d", model_noza[id])
	set_vaultdata(vaultkey, vaultdata)
}

ZaladujNoze(id) 
{ 
	new authid[32] 
	get_user_authid(id,authid,31)
	
	new vaultkey[64], vaultdata[64]
	
	format(vaultkey, 63, "Knife_%s", authid)
	get_vaultdata(vaultkey, vaultdata, 63)
	model_noza[id] = str_to_num(vaultdata)
	
}
ZapiszM4(id)
{ 
	
	new authid[32]
	get_user_authid(id, authid, 31)
	
	new vaultkey[64]
	new vaultdata[64]
	
	format(vaultkey, 63, "M4A1_%s", authid)
	format(vaultdata, 63, "%d", model_m4[id])
	set_vaultdata(vaultkey, vaultdata)
}

ZaladujM4(id) 
{ 
	new authid[32] 
	get_user_authid(id,authid,31)
	
	new vaultkey[64], vaultdata[64]
	
	format(vaultkey, 63, "M4A1_%s", authid)
	get_vaultdata(vaultkey, vaultdata, 63)
	model_m4[id] = str_to_num(vaultdata)
	
}
ZapiszAK(id)
{ 
	
	new authid[32]
	get_user_authid(id, authid, 31)
	
	new vaultkey[64]
	new vaultdata[64]
	
	format(vaultkey, 63, "AK47_%s", authid)
	format(vaultdata, 63, "%d", model_ak[id])
	set_vaultdata(vaultkey, vaultdata)
}

ZaladujAK(id) 
{ 
	new authid[32] 
	get_user_authid(id,authid,31)
	
	new vaultkey[64], vaultdata[64]
	
	format(vaultkey, 63, "AK47_%s", authid)
	get_vaultdata(vaultkey, vaultdata, 63)
	model_ak[id] = str_to_num(vaultdata)
	
}
ZapiszAWP(id)
{ 
	
	new authid[32]
	get_user_authid(id, authid, 31)
	
	new vaultkey[64]
	new vaultdata[64]
	
	format(vaultkey, 63, "AWP_%s", authid)
	format(vaultdata, 63, "%d", model_awp[id])
	set_vaultdata(vaultkey, vaultdata)
}

ZaladujAWP(id) 
{ 
	new authid[32] 
	get_user_authid(id,authid,31)
	
	new vaultkey[64], vaultdata[64]
	
	format(vaultkey, 63, "AWP_%s", authid)
	get_vaultdata(vaultkey, vaultdata, 63)
	model_awp[id] = str_to_num(vaultdata)
	
} 

public hasAccess(id, menu, item)
{
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		return ITEM_ENABLED;
	}
	else {
		return ITEM_DISABLED;
	}

}

public hasAccessKnife(id, menu, item)
{
	if(userFrags[id] >= str_to_num(knifePrice[item-3]))
	{
		return ITEM_ENABLED;
	}
	else {
		return ITEM_DISABLED;
	}

}

public load_frags(id)
{
	new name[48]
	get_user_name(id,name,47)
	new vaultkey[64],vaultdata[128]
	formatex(vaultkey,63,"%s-fragi",name)
	
	if(nvault_get(plik_vault,vaultkey,vaultdata,127)) { // pobieramy dane
		new fragitemp[16], nametemp[48];
		parse(vaultdata, fragitemp, 15,  nametemp, 47) // wydobywamy z ciagu vaultdata nasze dane
		
		userFrags[id]=str_to_num(fragitemp) // przypisujemy danym ich wartosci wczytane
		
		copy(g_name[id], 47, nametemp);
	}
	
	return PLUGIN_CONTINUE
}  

public save_frags(id)
{
	new name[48]
	get_user_name(id,name,47)
	new vaultkey[64],vaultdata[128] // 2 zmienne na klucz i dane ktore bedziemy zapisywac
	formatex(vaultkey,63,"%s-fragi",name) //formatujemy klucz czyli nasz identyfikator dostepu najlepiej zeby roznil sie on 1 czlonem od pozostalych
	formatex(vaultdata,127,"%d ^"%s^"", userFrags[id], name) // formatujemy dane
	nvault_set(plik_vault,vaultkey,vaultdata) // zapisujemy dane "pod" danym kluczem w pliku
	
	return PLUGIN_CONTINUE
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
