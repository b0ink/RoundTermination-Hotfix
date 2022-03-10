#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#pragma newdecls required
#pragma semicolon 1


public Plugin myinfo =
{
	name = "No round termination hotfix",
	author = "BOINK",
	description = "",
	version = "1.0.0",
	url = ""
};

int CT_WINS = 0;
int T_WINS = 0;

public void OnPluginStart(){
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_start",  Event_RoundStart);
}

public void OnMapStart(){
	ServerCommand("mp_ignore_round_win_conditions 1");
	CT_WINS = 0;
	T_WINS = 0;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	int alivet = 0;
	int alivect = 0;

	for(int i = 0; i <= MaxClients; i++){
		if(IsValidClient(i) && IsPlayerAlive(i)){
			if(GetClientTeam(i) == CS_TEAM_CT) alivect++;
			if(GetClientTeam(i) == CS_TEAM_T) alivet++;
		}
	}
	//todo ignore termination if there arent any players on one team
	if(alivect == 0 || alivet == 0){
		ServerCommand("mp_ignore_round_win_conditions 0");
		if(alivet > 0){
			CS_TerminateRound(5.0, CSRoundEnd_TerroristWin);
			T_WINS++;
		}else if (alivect > 0){
			CS_TerminateRound(5.0, CSRoundEnd_CTWin);
			CT_WINS++;
		}else{
			CS_TerminateRound(5.0, CSRoundEnd_Draw);
		}
	}

}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast){
	SetTeamScore(CS_TEAM_CT, CT_WINS);
	SetTeamScore(CS_TEAM_T, T_WINS);
	ServerCommand("mp_ignore_round_win_conditions 1");
}

stock bool IsValidClient(int client, bool nobots = true){
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client))) {
        return false;
    }
    return IsClientInGame(client);
}