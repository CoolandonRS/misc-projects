# Backup.ps1
A powershell script to backup minecraft servers automatically. Made to be run using a plugin and supports using RCON to send messages to the server when the backup starts and ends.

**If using RCON you must download [MCRCON](https://github.com/Tiiffi/mcrcon/releases/latest) and put it in the same directory as the powershell file**

This does require going into the ps1 and changing the config at the top, however you will of course not need to change the RCON config if you aren't using RCON.

The way I have formatted the comments there is `Accepted datatype || Description || Default` or `Accepted Option 1 | Accepted Option 2 || Description || Default`

The RCON implementation does support creating more then the default two message events, but you will need to add a few `if`s in `Send-Minecraft` and a new variable in the config following the same structure.