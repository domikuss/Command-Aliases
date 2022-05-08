#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

#define PATH_TO_CONFIG "configs/CommandAliases.ini"
#define MAX_ALIASES 32

StringMap g_hCommands;

public Plugin myinfo =
{
	name = "Command Aliases",
	author = "Domikuss",
	description = "Allows you to assign an alternative command name/s",
	version = "1.0.0",
	url = "https://github.com/Domikuss/Command-Aliases"
};

public void OnPluginStart()
{
	g_hCommands = new StringMap();
	RegAdminCmd("sm_cmda_reload", CmdReload, ADMFLAG_ROOT, "Reload Config - Command Aliases");
}

public void OnMapStart()
{
	LoadConfig();
}

void LoadConfig()
{
	KeyValues hKvConfig;
	char sPath[PLATFORM_MAX_PATH], sBuf[MAX_ALIASES*32], sKey[32], sArray[MAX_ALIASES][32];

	g_hCommands.Clear();

	BuildPath(Path_SM, sPath, PLATFORM_MAX_PATH, PATH_TO_CONFIG);

	hKvConfig = new KeyValues("CommandAliases");

	if(!hKvConfig.ImportFromFile(sPath))
	{
		SetFailState("Command Aliases - config is not found (%s).", sPath);
	}

	hKvConfig.Rewind();
	hKvConfig.JumpToKey("commands");

	if (hKvConfig.GotoFirstSubKey(false))
	{
		do
		{
			hKvConfig.GetSectionName(sKey, sizeof sKey);
			hKvConfig.GetString(NULL_STRING, sBuf, sizeof(sBuf));
			int iSize = ExplodeString(sBuf, ";", sArray, sizeof sArray, sizeof sArray[]);
		
			for(int i = 0; i < iSize; i++)
			{
				TrimString(sArray[i]);
				if(sArray[i][0])
				{
					g_hCommands.SetString(sArray[i], sKey);
					RegConsoleCmd(sArray[i], CommandCB);
				}
			}
		}
		while(hKvConfig.GotoNextKey(false));
	}

	delete hKvConfig;
}

Action CommandCB(int iClient, int iArgs)
{
	char sCommand[32], sBuf[32];

	GetCmdArg(0, sCommand, sizeof(sCommand));
	g_hCommands.GetString(sCommand, sBuf, sizeof(sBuf));
	ClientCommand(iClient, sBuf);

	return Plugin_Handled;
}

Action CmdReload(int iClient, int iArgs)
{
	LoadConfig();

	ReplyToCommand(iClient, "The plugin config was successfully reloaded");

	return Plugin_Handled;
}