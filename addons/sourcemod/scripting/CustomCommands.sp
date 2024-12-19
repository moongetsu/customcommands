#include <sourcemod>
#include <sdktools>
#include <multicolors>
#pragma newdecls required

public Plugin myinfo =
{
    name = "Custom Commands",
    author = "moongetsu", 
    description = "Plugin for custom commands with config",
    version = "1.0.0",
    url = "https://github.com/moongetsu"
};

ArrayList g_Commands;
ArrayList g_Responses;

public void OnPluginStart()
{
    g_Commands = new ArrayList(64);
    g_Responses = new ArrayList(1024);
    
    LoadCommands();
}

void LoadCommands()
{
    char configPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, configPath, sizeof(configPath), "configs/custom_commands.cfg");
    
    if (!FileExists(configPath))
    {
        SetFailState("The config file was not found: %s", configPath);
        return;
    }
    
    g_Commands.Clear();
    g_Responses.Clear();
    
    KeyValues kv = new KeyValues("CustomCommands");
    kv.ImportFromFile(configPath);
    
    if (!kv.GotoFirstSubKey())
    {
        delete kv;
        return;
    }
    
    char command[64], response[1024];
    
    do
    {
        kv.GetSectionName(command, sizeof(command));
        kv.GetString("response", response, sizeof(response));
        
        char commandBuffer[64];
        Format(commandBuffer, sizeof(commandBuffer), "sm_%s", command);
        
        g_Commands.PushString(commandBuffer);
        g_Responses.PushString(response);
        
        RegConsoleCmd(commandBuffer, Command_CustomResponse);
        
    } while (kv.GotoNextKey());
    
    delete kv;
}

public Action Command_CustomResponse(int client, int args)
{
    char command[64];
    GetCmdArg(0, command, sizeof(command));
    
    int index = g_Commands.FindString(command);
    if (index == -1)
        return Plugin_Continue;
        
    char response[1024];
    g_Responses.GetString(index, response, sizeof(response));
    
    char messages[10][1024];
    int count = ExplodeString(response, "\\n", messages, sizeof(messages), sizeof(messages[]));
    
    for (int i = 0; i < count; i++)
    {
        CPrintToChat(client, "%s", messages[i]);
    }
    
    return Plugin_Handled;
}