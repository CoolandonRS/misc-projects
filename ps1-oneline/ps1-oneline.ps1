Set-PSDebug -Trace 0
$debugbreak = $false
if ($args[0] -eq $null) {
    $t = Read-Host "Input script (Begin with a period to indicate a file path, two periods to indicate a relative one)`n"
    if ($t -notmatch "^[.].*") {
        $in = $t
    } else {
        $in = Get-Content -Raw ($t.Substring(1))
    }
} else {
    if (($args[0].ToString().Substring(($args[0].ToString().Length - 3),3)) -ne "ps1") { Write-Host "Not a valid powershell file"; Pause; Exit}
    $in = Get-Content -Raw $args[0]
}
$inSp = $in.Split("`r`n")
$rep = -1
$outT = ""
foreach ($i in $inSp) {
    $rep++
    if ($rep -ne 0) {
        if ($i -notmatch "^\s*$") {
            if ($i -match "\s*[};]\s*$") {
                $outT = $outT + $i.Trim()
            } else {
                if ($i -match "\s*[{]\s*$") {
                    $outT = $outT + $i.Trim()
                } else {
                    if (($inSp.Count -lt ($rep + 2)) -or ($inSp.Count -lt ($rep + 1))) {
                        $outT = $outT + $i.Trim()
                    } else {
                        if (($inSp[($rep + 2)] -match "^\s*[}]\s*.*") -or ($inSp[($rep + 1)] -match "^\s*[}]\s*.*")) {
                            $outT = $outT + $i.Trim()
                        } else {
                            $outT = $outT + $i.Trim() + "; "
                        }
                    }
                }
            }
        }
    } else {
        if ($i -notmatch "^\s*$") {
            $outT = $outT + $i.Trim() + "; "
        }
    }
    if ($comment) { 
        $outT = $outT + "#>"
    }
    if ($debugbreak) { exit }
}
Write-Host $outT
$prevCB = Get-Clipboard
Set-Clipboard $outT
Write-Host "`nThis version CANNOT handle comments. Any comment WILL break it." -BackgroundColor:Black -ForegroundColor:DarkRed
Read-Host "Output has been copied to clipboard. Press enter to end program and restore clipboard"
Set-Clipboard $prevCB