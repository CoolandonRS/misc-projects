Set-PSDebug -Trace 0
# If using Essentials you will need to set it to run a batch file that will run this powershell until they start recognizing powershell files.
######################################## BEGIN CONFIG ########################################
# Any config value with a default value of $null needs to be set manually, and should not be kept as null.
$compress = "none" # "none" | "Optimal" | "Fastest" || How the file is zipped. Make sure you get the capitals right! || DEFAULT: "none"
$deleteBin = $false # Bool || Wether or not to empty the recycling bin after deleting files. || DEFAULT: $false
$doDelete = $true # Bool || Whether or not to delete old backups || DEFAULT: $true
$cutoffTime = New-TimeSpan -Days 7 # -Years # | -Months # | -Days # | -Hours # | -Seconds # || Length of Time in Time. Can use multiple operators. WARNING: Do not change "New-TimeSpan" at any point. The changed parameter follows that cmdlet. || DEFAULT: -Days 7
$excludeString = "ex-" # string || Will not delete any old files that begin with this string. WARNING: Last charecter MUST be "-" || DEFAULT: "ex-"
$debug = "info" # "time" | "info" | "none" || Whether or not to display debug information. || DEFAULT: "info"
$serverPath = $null # Any string || The file path to the server || DEFAULT: $null
$backupPath = "$serverPath\backups" # string || The file path to where backups are saved || DEFAULT: "$serverPath\backups"
$tempBackupPath = "$backupPath\TEMP" # string || The file path to where temporary backups are stored || DEFAULT: "$backupPath\TEMP"
$overworldName = "world" # string || The name of the servers overworld file (path and id will all be this variable) || DEFAULT: "world"
$worldNames = "nether","end" # Array of strings || The names of other worlds to backup || DEFAULT: "nether","end"
$worldIDs = "world_nether","world_the_end" # Array of strings || The IDs of other worlds to backup || DEFAULT: "world_nether","world_the_end"
$worldPaths = "DIM-1","DIM1" # Array of strings || The relative path from $serverPath\$worldID[#] to the region (and other) folders, excluding them.
$dateFormat = "yyyy-MM-dd-hh-mm-ss" # string || The date format backups will be saved as. This string MUST be default for worldedit compatibility, but otherwise can be whatever you want following .NET date specifications || DEFAULT: $dateFormat
######################################## BEGIN RCON ###########################################
$doRCON = $false # Bool || Whether or not to brodcast messages to RCON || DEFAULT: $false
$rconIP = "localhost" # string or int || The IP rcon will connect to || DEFAULT: "localhost"
$rconPort = 25575 # int || The port rcon will connect to || DEFAULT: "25575"
$rconPass = $null # string || The password rcon will use || DEFAULT: $null
$beginCast = @{
    enabled = $true # Bool || Wether or not to send a command on begin || DEFAULT: $true
    command = "tellraw" # string || What command to send. If tellraw, match "tellraw" exactly to use auto-parsing || DEFAULT: "tellraw"
    selector = "@a" # string or $false || The player selector to use. Inserted directly after 'command' || DEFAULT: @a
    content = $false # string or $false || The arguments and content to be used in a non tellraw message. || DEFAULT: $false
    # TELLRAW_PARAMETERS || All of these are only used when 'command' is "tellraw"
    tr_content = "Backup Starting! ","Server preformance may decrease slightly." # Array of strings || What to put in the tellraw. Seperate the array by different colors or formats. (What would be in its own object in the command) || DEFAULT: "Backup Starting! ","Server preformance may decrease slightly."
    tr_color = "dark_red","red" # Array of strings || What colors to use for corresponding'tr_content' values. Follows minecrafts color system. || DEFAULT: "dark_red","red"
    tr_format = @($true,$false,$false,$false,$false),@($false,$false,$false,$false,$false) # Array of Arrays of Bools || What formatting to apply to corresponding parts of 'tr_content' (bold,italic,underline,strikethrough,obfuscate) || DEFAULT: @($true,$false,$false,$false,$false),@($false,$false,$false,$false,$false)
}
$endCast = @{
    enabled = $true # Bool || Wether or not to send a command on begin || DEFAULT: $true
    command = "tellraw" # string || What command to send. If tellraw, match "tellraw" exactly to use auto-parsing || DEFAULT: "tellraw"
    selector = "@a" # string or $false || The player selector to use. Inserted directly after 'command' || DEFAULT: @a
    content = $false # string or $false || The arguments and content to be used in a non tellraw message. If using a tellraw, set to $false || DEFAULT: $false
    # TELLRAW_PARAMETERS || All of these are only used when 'command' is "tellraw".
    tr_content = "Backup Complete! ","Server preformance should return to normal." # Array of strings || What to put in the tellraw. INCLUDE SPACES. Seperate the array by different colors or formats. (What would be in its own object in the command) || DEFAULT: "Backup Complete! ","Server preformance should return to normal."
    tr_color = "dark_green","green" # Array of strings || What colors to use for corresponding 'tr_content' values. Follows minecrafts color system. || DEFAULT: "dark_green","green"
    tr_format = @($true,$false,$false,$false,$false),@($false,$false,$false,$false,$false) # Array of Arrays of Bools || What formatting to apply to corresponding parts of 'tr_content' (bold,italic,underline,strikethrough,obfuscate) || DEFAULT: @($true,$false,$false,$false,$false),@($false,$false,$false,$false,$false)
}
######################################## END CONFIG ###########################################
# BEGIN SETUP
if ($debug -eq "time") { $Timer = [System.Diagnostics.Stopwatch]::StartNew() }
function Send-Elapsed {
    param ( [string]$msg )
    if ($debug -eq "time") {
        $elapsed = [math]::Round($Timer.Elapsed.TotalMilliseconds)
        Write-Host "$msg Elapsed: $elapsed"
    }
    else {
        if (($debug -eq "info") -or ($msg = "Backup complete.")) { Write-Host "$msg" }
    }
}
function Send-Minecraft {
    param ( [string]$time )
    if ($doRCON) {
        if ($time -eq "begin") {
            if ($beginCast["enabled"]) {
                $tempBool = $true
            }
            else {
                $tempBool = $false
            }
        }
        if ($time -eq "end") {
            if ($endCast["enabled"]) {
                $tempBool = $true
            }
            else {
                $tempBool = $false
            }
        }
        # An if here is needed for a custom RCON event
        if ($tempBool) {
            if ($time -eq "begin") { $tempCast = $beginCast }
            if ($time -eq "end") { $tempCast = $endCast }
            # An if here is needed for a custom RCON event
            if ($tempCast["command"] -eq "tellraw") {
                $prevStr = "none"
                for ($rep = 0; $rep -ne $tempCast["tr_content"].Count; $rep++ ) {
                    $prevRep = $rep-1
                    $tempStr1 = $tempCast["tr_content"][$rep]
                    $tempStr2 = $tempCast["tr_color"][$rep]
                    if ($tempCast["tr_format"][$rep][0]) {
                        if (-not($rep -eq 0)) {
                            if (-not($tempCast["tr_format"][$prevRep][0])) {
                                $tempStr3 = ",\`"bold\`":true"
                            }
                            else { $tempStr3 = "" }
                        } else { $tempStr3 = ",\`"bold\`":true" }
                    }
                    else {
                        if (-not($rep -eq 0)) {
                            if ($tempCast["tr_format"][$prevRep][0]) {
                                $tempStr3 = ",\`"bold\`":false"
                            }
                            else { $tempStr3 = "" }
                        } else { $tempStr3 = "" }
                    }
                    if ($tempCast["tr_format"][$rep][1]) {
                        if (-not($rep -eq 0)) {
                            if (-not($tempCast["tr_format"][$prevRep][1])) {
                                $tempStr4 = ",\`"italic\`":true"
                            }
                            else { $tempStr4 = "" }
                        } else { $tempStr4 = ",\`"italic\`":true" }
                    }
                    else {
                        if (-not($rep -eq 0)) {
                            if ($tempCast["tr_format"][$prevRep][1]) {
                                $tempStr4 = ",\`"italic\`":false"
                            }
                            else { $tempStr4 = "" }
                        } else { $tempStr4 = "" }
                    }
                    if ($tempCast["tr_format"][$rep][2]) {
                        if (-not($rep -eq 0)) {
                            if (-not($tempCast["tr_format"][$prevRep][2])) {
                                $tempStr5 = ",\`"underlined\`":true"
                            }
                            else { $tempStr5 = "" }
                        } else { $tempStr5 = ",\`"underlined\`":true" }
                    }
                    else {
                        if (-not($rep -eq 0)) {
                            if ($tempCast["tr_format"][$prevRep][2]) {
                                $tempStr5 = ",\`"underlined\`":false"
                            }
                            else { $tempStr5= "" }
                        } else { $tempStr5 = "" }
                    }
                    if ($tempCast["tr_format"][$rep][3]) {
                        if (-not($rep -eq 0)) {
                            if (-not($tempCast["tr_format"][$prevRep][3])) {
                                $tempStr6 = ",\`"strikethrough\`":true"
                            }
                            else { $tempStr6 = "" }
                        } else { $tempStr6 = ",\`"strikethrough\`":true" }
                    }
                    else {
                        if (-not($rep -eq 0)) {
                            if ($tempCast["tr_format"][$prevRep][3]) {
                                $tempStr6 = ",\`"strikethrough\`":false"
                            }
                            else { $tempStr6 = "" }
                        } else { $tempStr6 = "" }
                    }
                    if ($tempCast["tr_format"][$rep][4]) {
                        if (-not($rep -eq 0)) {
                            if (-not($tempCast["tr_format"][$prevRep][4])) {
                                $tempStr3 = ",\`"obfuscated\`":true"
                            }
                            else { $tempStr3 = "" }
                        } else { $tempStr3 = ",\`"obfuscated\`":true" }
                    }
                    else {
                        if (-not($rep -eq 0)) {
                            if ($tempCast["tr_format"][$prevRep][4]) {
                                $tempStr7 = ",\`"obfuscated\`":false"
                            }
                            else { $tempStr7 = "" }
                        } else { $tempStr7 = "" }
                    }
                    $tempStr = "{\`"text\`":\`"$tempStr1\`",\`"color\`":\`"$tempStr2\`"$tempStr3$tempStr4$tempStr5$tempStr6$tempStr7}"
                    if ($prevStr -ne "none") {
                        $tempStr = "$prevStr,$tempStr"
                        $prevStr = $tempStr
                    }
                    else {
                        $prevStr = "[$tempStr"
                    }
                }
                $tempMsgJSON = "$prevStr]"
                $tempSelector = $tempCast["selector"]
                .\mcrcon.exe -H $rconIP -P $rconPort -p $rconPass "tellraw $tempSelector $tempMsgJSON"
            }
            else {
                if(($tempCast["selector"] -is [Bool]) -and (-not($tempCast["selector"]))) {
                    if(($tempCast["content"] -is [Bool]) -and (-not($tempCast["selector"]))) {
                        .\mcrcon.exe -H $rconIP -P $rconPort -p $rconPass $tempCast["command"]
                    }
                    else {
                        $tempCmd = $tempCast["command"]
                        $tempContent = $tempCast["content"]
                        .\mcrcon.exe -H $rconIP -P $rconPort -p $rconPass "$tempCmd $tempContent"
                    }
                }
                else {
                    $tempCmd = $tempCast["command"]
                    $tempContent = $tempCast["content"]
                    $tempSelector = $tempCast["selector"]
                    .\mcrcon.exe -H $rconIP -P $rconPort -p $rconPass "$tempCmd $tempSelector $tempContent"
                }
            }
        }
    }
}
$worldCount = $worldNames.Count
$unformatDate = Get-Date
$date = $unformatDate.ToString($dateFormat)
$cutoffDate = $unformatDate - $cutoffTime
$cutoffFormat = $cutoffDate.ToString($dateFormat)
Send-Minecraft "begin"
if ($debug -ne "none" ) {
Write-Host "Current date: $date"
Write-Host "Deleting old files: $doDelete"
if ($doDelete) {
    Write-Host "Compression Mode: $compress"
    Write-Host "Handle Discrepancies: $checkDiscrepancy"
    if ($checkDiscrepancy) { Write-Host "Discrepancy Handling: $dateHandle" }
    $cutoffTimeFormat = [math]::Round($cutoffTime.TotalHours, 3)
    Write-Host "Cutoff Length: $cutoffTimeFormat Hours"
}
Write-Host "Empty bin: $deleteBin"
}
Write-Host "Starting Backup."
if ($compress -ne "none") {
    function Backup-Temp {
        param ([string]$name, [string]$id, [string]$path)
        Copy-Item -Path "$serverPath\$id\$path" -Destination "$tempBackupPath\$name" -Force -Recurse
        Send-Elapsed "Temp primary backup of $name finished."
        Copy-Item -Path "$serverPath\$id\*.*" -Destination "$tempBackupPath\$name" -Force -Recurse
        Send-Elapsed "Temp backup of $name loose files complete."
        Send-Elapsed "Temp backup of $name complete."
    }
    $ErrorActionPreference = "SilentlyContinue"
    Copy-Item -Path "$serverPath\$overworldName" -Destination "$tempBackupPath\$overworldName"  -Force -Recurse
    Send-Elapsed "Temp backup of $overworldName finished."
    for ($rep = 0; $rep -ne $worldCount; $rep++) {
        Backup-Temp -name $worldNames[$rep] -id $worldIDs[$rep] -path $worldPaths[$rep]
    }
    Send-Elapsed "Beggining to zip."
    $ErrorActionPreference = "Continue"
    # BEGIN ZIP
    function Compress-TempBackup {
        param ( [string]$name, [string]$id )
        Compress-Archive -Path "$tempBackupPath\$name\*" -DestinationPath "$backupPath\$id\$date" -CompressionLevel $compress -Force
        Send-Elapsed "$name zipped."
    }
    Compress-TempBackup -name $overworldName -id $overworldName
    for ($rep = 0; $rep -ne $worldCount; $rep++) {
        Compress-TempBackup -name $worldNames[$rep] -id $worldIDs[$rep]
    }
    # BEGIN DELETE
    function Remove-TempBackup {
        param ( [string]$name )
        Remove-Item -Path "$tempBackupPath\$name" -Force -Recurse
        Send-Elapsed "Temp backup of $name removed."
    }
    Remove-TempBackup -name $overworldName
    for ($rep = 0; $rep -ne $worldCount; $rep++) {
        Remove-TempBackup -name $worldNames[$rep]
    }
    if ($deleteBin) { Clear-RecycleBin -Force }
}
else {
    function Backup-World {
        param ( [string]$name, [string]$id, [string]$path )
        Copy-Item -Path "$serverPath\$id\$path" -Destination "$backupPath\$id\$date" -Force -Recurse
        Send-Elapsed "Primary Backup of $name finished."
        Copy-Item -Path "$serverPath\$id\*.*" -Destination "$backupPath\$id\$date" -Force -Recurse
        Send-Elapsed "Backup of $name loose files complete."
        Send-Elapsed "Backup of $name complete."
    }
    $ErrorActionPreference = "SilentlyContinue"
    Copy-Item -Path "$serverPath\$overworldName" -Destination "$backupPath\$overworldName\$date"  -Force -Recurse
    Send-Elapsed "Backup of $overworldName finished."
    for ($rep = 0; $rep -ne $worldCount; $rep++) {
        Backup-World -name $worldNames[$rep] -id $worldIDs[$rep] -path $worldPaths[$rep]
    }
    $ErrorActionPreference = "Continue"
}
if ($doDelete) {
    function Remove-OldBackups {
        param ( [string]$name, [string]$id, [array]$list, [int]$count )
    for (($nameCount = 0), ($dateCount = 1); $nameCount -ne $count; ($nameCount = $nameCount + 2), ($dateCount = $dateCount + 2)) {
        $tempName = $list[$nameCount]
        $tempDate = $list[$dateCount]
        $tempElapsed = New-TimeSpan -Start $tempDate -End $unformatDate
        $tempUnits = $tempName -split "-"
        $tempUnit = $tempUnits[0]
        $tempUnit = "$tempUnit-"
        $tempCount = $nameCount/2
        if ($tempUnit -ne $excludeString) {
            if ($tempElapsed -ge $cutoffTime) {
                Remove-Item -Path "$backupPath\$id\$tempName" -Force -Recurse
                Send-Elapsed "$name backup #$tempCount deleted ($tempName)"
                if ($deleteBin) { Clear-RecycleBin -Force }
            }
            else {
                Send-Elapsed "$name backup #$tempCount checked. ($tempName)"
            }
        }
        else { Send-Elapsed "$name backup #$tempCount has been excluded. ($tempName)" }
    }
    Send-Elapsed "$name checks complete."
    }
    $cutoffHuman = $cutoffDate.ToString('MM/dd/yyyy hh:mm:ss')
    Send-Elapsed "Begining to delete files older then $cutoffHuman ($cutoffFormat)."
    $curList = Get-ItemPropertyValue -Path "$backupPath\$overworldName\*" -Name Name, LastWriteTime
    $curCount = $curList.Count
    Remove-OldBackups -name $overworldName -id $overworldName -list $curList -count $curCount
    for ($rep = 0; $rep -ne $worldCount; $rep++ ) {
        $curName = $worldNames[$rep]
        $curID = $worldIDs[$rep]
        $curList = Get-ItemPropertyValue -Path "$backupPath\$curID\*" -Name Name, LastWriteTime
        $curCount = $curList.Count
        Remove-OldBackups -name $curName -id $curID -list $curList -count $curCount
    }
    Send-Elapsed "All deletes finished."
}
else { Send-Elapsed "Not deleting old backups." }
# BEGIN CLEANUP
Send-Elapsed "Backup complete."
Send-Minecraft "end"