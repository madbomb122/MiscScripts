#input folder (w/o \ at end)
$Path = "C:\InFiles"

#output folder (w/o \ at end)
$OutputDir = "C:\OutFiles"

#Media Info path (w/o \ at end)
$MIPath = "C:\MediaInfo"

#Mkvtoolnix path (w/o \ at end)
$MkvToolPath = "C:\mkvtoolnix"

#Time to cut from end
$STime = New-TimeSpan -Minutes 1 -Seconds 30

# Dont edit past this

$Pathlen = $Path.Length
If($Path.Substring($Pathlen -1,1) -eq '\'){ $Path = $Path.Substring(0,$Pathlen -1) }
$MIPathlen = $MIPath.Length
If($MIPath.Substring($MIPathlen -1,1) -eq '\'){ $MIPath = $MIPath.Substring(0,$MIPathlen -1) }
$OutputDirlen = $OutputDir.Length
If($OutputDir.Substring($OutputDirlen -1,1) -eq '\'){ $OutputDir = $OutputDir.Substring(0,$OutputDirlen -1) }

$List = @(Get-ChildItem -Path $Path -Recurse  -Include *.mkv | Select-Object -ExpandProperty FullName)


[Int]$Count = $List.count
[Int]$i = $Count

Foreach($FilePath in $List) {
	$File = Split-Path $FilePath -Leaf
	$Subdir = (Split-Path $FilePath).Replace($Path,'')
	$basefile = [System.IO.Path]::GetFileNameWithoutExtension($File)
	$FileM = $basefile +'.mkv'
	Write-Host "Proccessing: $Subdir\$File" -ForegroundColor 'Red' -BackgroundColor 'Black' -NoNewLine
	Write-Host " ($i left of $count)" -ForegroundColor 'Green' -BackgroundColor 'Black'
	$i--
	
	$s = Invoke-Command -ScriptBlock {&$MIPath\MediaInfo.exe $FilePath --Inform="Video;%Duration/String3%"}
	$t = $s.split(":")
	$secMult = $t[2].split(".")
	$VidDur = New-TimeSpan -Minutes $t[1] -Seconds $secMult[0]
	$SplitTime = $VidDur - $STime
	$Argument2 = @(
"-o `"$OutputDir$Subdir\$FileM`""
"--split timestamps:$SplitTime"
"`"$FilePath`""
	) -join " "
	Start-Process -NoNewWindow -FilePath "$MkvToolPath\mkvmerge.exe" -ArgumentList $Argument2 -Wait
}

Read-Host 'Done'
