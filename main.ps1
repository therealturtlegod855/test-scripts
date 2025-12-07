# Set execution policy (run as Admin
Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force

# Paths
$ToolsDir = "$env:TEMP\vnc"
$NoVNCDir = "$ToolsDir\noVNC"
$UltraVNC = "$ToolsDir\ultravnc.exe"
$Websockify = "$NoVNCDir\utils\websockify\runner.exe"

# Create directory
New-Item -ItemType Directory -Force -Path $ToolsDir, $NoVNCDir

# Download UltraVNC (x64) - check latest at https://www.uvnc.com
Invoke-WebRequest -Uri "https://www.uvnc.com/downloads/ultravnc/188-ultravnc-1360.html" -OutFile $UltraVNC -UseBasicParsing

# Silent install UltraVNC
Start-Process -FilePath $UltraVNC -ArgumentList "/verysilent /loadinf=`"$ToolsDir\setup.inf`"" -Wait

# Create setup.inf for silent install (includes password)
@"
[Setup]
Lang=english
Dir=C:\Program Files\uvnc bvba\UltraVNC
Group=UltraVNC
NoIcons=0
ModifyPath=0
SaveLog=no
Password=606D6E7073737764=12345678
@" | Out-File -FilePath "$ToolsDir\setup.inf" -Encoding ASCII

# Restart service
Restart-Service -Name uvnc_service -Force

# Download noVNC + Websockify (prebuilt)
git clone https://github.com/novnc/noVNC.git $NoVNCDir
git clone https://github.com/novnc/websockify.git $NoVNCDir/utils/websockify

# Start noVNC (WebSocket proxy on port 6080)
Start-Process -FilePath $Websockify -ArgumentList "6080 localhost:5900 --web $NoVNCDir" -WindowStyle Hidden   
