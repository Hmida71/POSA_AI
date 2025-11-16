[Setup]
; Basic app information
AppId={{POSA-NextGen-AI-Browser-Automation}
AppName=POSA - Next-Gen AI Browser Automation
AppVersion=1.0.0
AppPublisher=Your Company Name
AppPublisherURL=https://yourwebsite.com
AppSupportURL=https://yourwebsite.com/support
AppUpdatesURL=https://yourwebsite.com/updates
DefaultDirName={autopf}\POSA
DefaultGroupName=POSA
AllowNoIcons=yes
LicenseFile=LICENSE.txt
OutputDir=dist
OutputBaseFilename=POSA_Setup
SetupIconFile=assets\icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; Silent installation options
SilentInstall=normal
AlwaysRestart=no
RestartIfNeededByRun=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main Flutter application
Source: "build\windows\runner\Release\posa.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Embedded Python
Source: "build\windows\runner\Release\python\*"; DestDir: "{app}\python"; Flags: ignoreversion recursesubdirs createallsubdirs

; Backend files
Source: "build\windows\runner\Release\backend\*"; DestDir: "{app}\backend"; Flags: ignoreversion recursesubdirs createallsubdirs

; Additional assets if needed
; Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\POSA"; Filename: "{app}\posa.exe"
Name: "{group}\{cm:UninstallProgram,POSA}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\POSA"; Filename: "{app}\posa.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\posa.exe"; Description: "{cm:LaunchProgram,POSA}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "taskkill"; Parameters: "/F /IM posa.exe"; Flags: runhidden
Filename: "taskkill"; Parameters: "/F /IM python.exe"; Flags: runhidden

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Kill any existing processes before installation
    Exec('taskkill', '/F /IM posa.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('taskkill', '/F /IM python.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;