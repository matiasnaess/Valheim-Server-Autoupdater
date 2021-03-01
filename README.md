# Valheim-Server-Autoupdater :crossed_swords:
Simple Powershell script for automatically keeping your Valheim Server up to date.

![Image of Script](https://i.imgur.com/Bv9q8Rg.png)


## Prerequisites
Before you can begin using the Autoupdater you must have SteamCMD and Valheim Dedicated Server installed. 

## How to use 
* Move both the config file and Powershell script to your SteamCMD folder. 
* Change the config to your liking, such as the server name and password. 
**Remember to specify the paths for SteamCMD and your server folder** 
* Save the config and run the script using Powershell 

## How does it work? 
The script will every 5 minutes query the Steam API too check if a new version of Valheim is relased. 
If there is a new update the script will stop the server, apply the update, and then start the server again. 

You can easily change how often too check for an update by editing the script. (See code comments) 


### TO DO
- [ ] Add time of query
- [ ] Add auto backup of world
- [ ] Add script that installs SteamCMD and Valheim Server
- [ ] Add server uptime
