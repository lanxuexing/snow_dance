[Setup]
AppId={{8B6E3294-0D2C-4BA7-8F12-70678F3D7824}
AppName=SnowDance
AppVersion=1.0.2
AppPublisher=LanXueXing
AppPublisherURL=https://github.com/lanxuexing/snow_dance
DefaultDirName={autopf}\SnowDance
DefaultGroupName=SnowDance
DisableProgramGroupPage=yes
LicenseFile=
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=..\..\build\windows\installer
OutputBaseFilename=SnowDance_Setup_Windows
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\snow_dance.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\SnowDance"; Filename: "{app}\snow_dance.exe"
Name: "{autodesktop}\SnowDance"; Filename: "{app}\snow_dance.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\snow_dance.exe"; Description: "{cm:LaunchProgram,SnowDance}"; Flags: nowait postinstall skipifsilent
