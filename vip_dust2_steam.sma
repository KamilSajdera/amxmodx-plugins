#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <stripweapons>

#define NIGHT_FROM 22
#define NIGHT_TO 9// tak naprawde to 10, zmiana czasu :P

forward amxbans_admin_connect(id);

new CsArmorType:armortype, bool:g_Vip[33], gRound=0, g_Hudmsg, menu,
menu_callback_handler, weapon_id;


public plugin_init(){
	register_plugin("VIP Ultimate", "12.3.0.2", "benio101 & speedkill");
	RegisterHam(Ham_Spawn, "player", "SpawnedEventPre", 1);
	register_event("DeathMsg", "DeathMsg", "a");
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
	register_logevent("GameCommencing", 2, "1=Game_Commencing");
	register_message(get_user_msgid("ScoreAttrib"), "VipStatus");
	register_message(get_user_msgid("SayText"),"handleSayText");

	
	g_Hudmsg=CreateHudSyncObj();
}
public client_authorized(id , const authid[]){

	if(get_user_flags(id) & 524288 == 524288)
		return PLUGIN_HANDLED;
	else if(!is_user_steam(id))
		return PLUGIN_HANDLED;
	else if(isNight())
		return PLUGIN_HANDLED;
	else 
		client_authorized_vip(id);

	return PLUGIN_HANDLED;

}
public client_authorized_vip(id){
	g_Vip[id]=true;
	new g_Name[64];
	get_user_name(id,g_Name,charsmax(g_Name));
	set_hudmessage(24, 190, 220, 0.25, 0.2, 0, 6.0, 6.0);
	ShowSyncHudMsg(0, g_Hudmsg, "VIP %s wbija na serwer!",g_Name);
	set_user_flags(id, ADMIN_LEVEL_H);
}
public client_disconnected(id){
	if(g_Vip[id]){
		client_disconnect_vip(id);
	}
}
public client_disconnect_vip(id){
	g_Vip[id]=false;
	remove_user_flags(id, ADMIN_LEVEL_H);
}
public SpawnedEventPre(id){
	if(g_Vip[id]){
		if(is_user_alive(id)){
			SpawnedEventPreVip(id);
		}
	}
}
public SpawnedEventPreVip(id){
	cs_set_user_armor(id, min(cs_get_user_armor(id,armortype)+100, 100), CS_ARMOR_VESTHELM);
	new henum=(user_has_weapon(id,CSW_HEGRENADE)?cs_get_user_bpammo(id,CSW_HEGRENADE):0);
	give_item(id, "weapon_hegrenade");
	++henum;
	new fbnum=(user_has_weapon(id,CSW_FLASHBANG)?cs_get_user_bpammo(id,CSW_FLASHBANG):0);
	give_item(id, "weapon_flashbang");
	++fbnum;
	new sgnum=(user_has_weapon(id,CSW_SMOKEGRENADE)?cs_get_user_bpammo(id,CSW_SMOKEGRENADE):0);
	give_item(id, "weapon_smokegrenade");
	++sgnum;
	show_vip_menu(id);
	if(get_user_team(id)==2){
		give_item(id, "item_thighpack");
	}
}
public menu_1_handler(id){
	StripWeapons(id, Secondary);
	give_item(id, "weapon_deagle");
	give_item(id, "ammo_50ae");
	weapon_id=find_ent_by_owner(-1, "weapon_deagle", id);
	if(weapon_id)cs_set_weapon_ammo(weapon_id, 7);
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	StripWeapons(id, Primary);
	give_item(id, "weapon_ak47");
	give_item(id, "ammo_762nato");
	weapon_id=find_ent_by_owner(-1, "weapon_ak47", id);
	if(weapon_id)cs_set_weapon_ammo(weapon_id, 30);
	cs_set_user_bpammo(id, CSW_AK47, 90);
}
public menu_2_handler(id){
	StripWeapons(id, Secondary);
	give_item(id, "weapon_deagle");
	give_item(id, "ammo_50ae");
	weapon_id=find_ent_by_owner(-1, "weapon_deagle", id);
	if(weapon_id)cs_set_weapon_ammo(weapon_id, 7);
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	StripWeapons(id, Primary);
	give_item(id, "weapon_m4a1");
	give_item(id, "ammo_556nato");
	weapon_id=find_ent_by_owner(-1, "weapon_m4a1", id);
	if(weapon_id)cs_set_weapon_ammo(weapon_id, 30);
	cs_set_user_bpammo(id, CSW_M4A1, 90);
}
public menu_3_handler(id){
	StripWeapons(id, Secondary);
	give_item(id, "weapon_deagle");
	give_item(id, "ammo_50ae");
	weapon_id=find_ent_by_owner(-1, "weapon_deagle", id);
	if(weapon_id)cs_set_weapon_ammo(weapon_id, 7);
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	StripWeapons(id, Primary);
	give_item(id, "weapon_awp");
	give_item(id, "ammo_338magnum");
	weapon_id=find_ent_by_owner(-1, "weapon_awp", id);
	if(weapon_id)cs_set_weapon_ammo(weapon_id, 10);
	cs_set_user_bpammo(id, CSW_AWP, 30);
}
public DeathMsg(){
	new killer=read_data(1);
	new victim=read_data(2);
	
	if(is_user_alive(killer) && g_Vip[killer] && get_user_team(killer) != get_user_team(victim)){
		DeathMsgVip(killer,victim,read_data(3));
	}
}
public DeathMsgVip(kid,vid,hs){
	set_user_health(kid, min(get_user_health(kid)+(hs?10:5),100));
	cs_set_user_money(kid, cs_get_user_money(kid)+(hs?300:150));
}
public show_vip_menu(id){
	menu=menu_create("\rMenu VIPa","menu_handler");
	menu_callback_handler=menu_makecallback("menu_callback");
	new bool:active=false, num=-1;
	menu_additem(menu,"\d(\w700\y$\d) \wAK47 + Deagle","",0,menu_callback_handler);
	if(menu_callback(id, menu, ++num)==ITEM_ENABLED){
		active=true;
	}
	menu_additem(menu,"\d(\w700\y$\d) \wM4A1 + Deagle","",0,menu_callback_handler);
	if(menu_callback(id, menu, ++num)==ITEM_ENABLED){
		active=true;
	}
	menu_additem(menu,"\d(\w1500\y$\d) \wAWP + Deagle","",0,menu_callback_handler);
	if(menu_callback(id, menu, ++num)==ITEM_ENABLED){
		active=true;
	}
	if(active){
		menu_setprop(menu,MPROP_EXITNAME,"Wyjscie");
		menu_setprop(menu,MPROP_TITLE,"\yMenu Vipa Steam");
		menu_setprop(menu,MPROP_NUMBER_COLOR,"\r");
		menu_display(id, menu);
	} else {
		menu_destroy(menu);
	}
}
public event_new_round(){
	++gRound;
}
public GameCommencing(){
	gRound=0;
}
public menu_callback(id, menu, item){
	if(is_user_alive(id)){
		if(gRound>=2){
			if(cs_get_user_money(id)>=700){
				if(item==0){
					return ITEM_ENABLED;
				}
				if(item==1){
					return ITEM_ENABLED;
				}
			}
		}
		if(gRound>=3){
			if(cs_get_user_money(id)>=1500){
				if(item==2){
					return ITEM_ENABLED;
				}
			}
		}
	}
	return ITEM_DISABLED;
}
public menu_handler(id, menu, item){
	if(is_user_alive(id)){
		if(gRound>=2){
			if(cs_get_user_money(id)>=700){
				if(item==0){
					menu_1_handler(id);
					cs_set_user_money(id, cs_get_user_money(id)-700, 1);
				}
				if(item==1){
					menu_2_handler(id);
					cs_set_user_money(id, cs_get_user_money(id)-700, 1);
				}
			}
		}
		if(gRound>=3){
			if(cs_get_user_money(id)>=1500){
				if(item==2){
					menu_3_handler(id);
					cs_set_user_money(id, cs_get_user_money(id)-1500, 1);
				}
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public VipStatus(){
	new id=get_msg_arg_int(1);
	if(is_user_alive(id) && g_Vip[id]){
		set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2)|4);
	}
}
public handleSayText(msgId,msgDest,msgEnt){
	new id = get_msg_arg_int(1);
	
	if(is_user_connected(id) && g_Vip[id]){
		new szTmp[256],szTmp2[256];
		get_msg_arg_string(2,szTmp, charsmax(szTmp))
		
		new szPrefix[64] = "^x04[V.I.P]";
		
		if(!equal(szTmp,"#Cstrike_Chat_All")){
			add(szTmp2,charsmax(szTmp2),szPrefix);
			add(szTmp2,charsmax(szTmp2)," ");
			add(szTmp2,charsmax(szTmp2),szTmp);
		}
		else{
			add(szTmp2,charsmax(szTmp2),szPrefix);
			add(szTmp2,charsmax(szTmp2),"^x03 %s1^x01 :  %s2");
		}
		set_msg_arg_string(2,szTmp2);
	}
	return PLUGIN_CONTINUE;
}
public amxbans_admin_connect(id){
	client_authorized(id,"");
}


stock bool:is_user_steam(id) 
{
        new auth[65]
        get_user_authid(id,auth,64)
        if(contain(auth, "STEAM_0:0:") != -1 || contain(auth, "STEAM_0:1:") != -1)
                return true;
        return false;
}

stock isNight()
{
	new szHour[4], iHour;

	get_time("%H", szHour, 3);
   	iHour = str_to_num(szHour);
    
    if(NIGHT_FROM <= iHour || iHour <= NIGHT_TO)
       	return 1;
     else 
     	return 0;

    //return 0;
}