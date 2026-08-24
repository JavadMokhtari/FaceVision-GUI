#define MyAppName "FaceVision"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Javad Mokhtari"
#define MyAppExeName "facevision_gui.exe"

[Setup]
AppId={{YOUR-UNIQUE-GUID-HERE}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

OutputDir=installer
OutputBaseFilename=FaceVision-Setup

Compression=lzma
SolidCompression=yes

ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

WizardStyle=modern

[Files]
Source: "build\windows\x64\runner\Release\*"; \
    DestDir: "{app}"; \
    Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"

Name: "{autodesktop}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; \
    Description: "Launch {#MyAppName}"; \
    Flags: nowait postinstall skipifsilent