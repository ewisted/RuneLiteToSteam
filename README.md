[![CircleCI](https://circleci.com/gh/ewisted/RuneLiteToSteam/tree/main.svg?style=svg&circle-token=8c654f518bad9bbf7a3940c4fd75e4fe1c71d53a)](https://circleci.com/gh/ewisted/RuneLiteToSteam)

# RuneLiteToSteam
A Powershell module that helps you launch RuneLite through Steam.

## Getting Started
All you need to get up and running is this module, a [RuneLite installation](https://runelite.net/), an [OSRS Steam client installation](https://store.steampowered.com/app/1343370/Old_School_RuneScape/), and Powershell. Once you have those, just follow these steps:
1. Open up a new Powershell window (press Win+R, type `powershell`, and hit enter)
2. Enter the following commands in the Powershell window.
  ```
  Install-Module RuneLiteToSteam
  Copy-RuneLiteToSteam
  ```
As long as there were no errors, launching OSRS through Steam should now launch RuneLite.

### Reverting back to the Steam client
Reverting back is simple. Just run the copy command again with the `-Revert` switch:
  ```
  Copy-RuneLiteToSteam -Revert
  ```
  
## Run at Startup/Logon
Eventually Steam is going to update OSRS and overwrite RuneLite or RuneLite could be updated from its orginal install location. The script takes these cases into account and keeps track of RuneLite's MD5 hash in order to be idempotent. Therefore, it is recommended to schedule to run the script at startup or logon. To do so just follow these steps:
1. Open up a Powershell window as administrator (type `Powershell` in Windows Search, right click it, and select `Run as administrator`)
2. Run the Copy-RuneLiteToSteam command with the `-Schedule` parameter. It accepts either `Startup` or `Logon`.
  ```
  Copy-RuneLiteToSteam -Schedule "schedule-type"
  ```
The `-Schedule` parameter also works with the `-Revert` switch, so using both will remove the scheduled task.
  ```
  Copy-RuneLiteToSteam -Schedule "schedule-type" -Revert
  ```