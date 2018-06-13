#include 'services_unicode.iss'
[Setup]
; Required by Inno=
AppName=LR Diagnostics
#define ver GetFileVersion(".\LRDiagnosticsClient.exe")
AppVersion={#ver}
DefaultDirName={pf}\Hooded Claw\LRDiagnostics

; Optional by Inno=
AppVerName=LR Diagnostics Client {#ver}
DefaultGroupName=Hooded Claw
OutputBaseFilename=LRDiagnosticsSetup
PrivilegesRequired=admin
LicenseFile=EULA.rtf
SetupLogging=yes
UninstallFilesDir={app}\uninstall
AppCopyright=Copyright © The Hooded Claw 2018
SetupIconFile=MyIcon.ico
UninstallDisplayIcon=MyIcon.ico
VersionInfoCompany=The Hooded Claw
VersionInfoCopyright=© The Hooded Claw 2018
VersionInfoVersion={#ver}
VersionInfoProductVersion={#ver}
VersionInfoProductName=LR Diagnostics
WizardImageFile=WizardImage.bmp

; "ArchitecturesAllowed=x64" specifies that Setup cannot run on
; anything but x64.
ArchitecturesAllowed=x64
; "ArchitecturesInstallIn64BitMode=x64" requests that the install be
; done in "64-bit mode" on x64, meaning it should use the native
; 64-bit Program Files directory and the 64-bit view of the registry.
ArchitecturesInstallIn64BitMode=x64

;#ifndef NOSIGN
;SignedUninstaller=yes
;SignedUninstallerDir=SignedUninstaller
;#endif


[Files]
; ***** App files *****:
; ***** App files *****:
Source: "LRDiagnosticsClient.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "LRDAgent.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "LogRhythmDiagnosticsAgent.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "LRDAgentConfigEdit.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "LRDAgentConfig.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "LRDLogger.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "log4net.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "LRDAgent.exe.config"; DestDir: "{app}"; Flags: ignoreversion
Source: "log4net.config"; DestDir: "{app}"; Flags: ignoreversion
Source: "ssleay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "libeay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "openssl.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "OpenSSL License.txt"; DestDir: "{app}"; Flags: ignoreversion


[Icons]
Name: {commonprograms}\Hooded Claw\LR Diagnostics; Filename: {app}\LRDiagnosticsClient.exe; WorkingDir: {app}

[Code]
var
  g_bCopyInstLog: Boolean;

procedure CurStepChanged(CurStep: TSetupStep);
var
  SetupType: string;
 begin
  SetupType := WizardSetupType(FALSE);
  if SetupType <> 'client' then
  begin
    if (CurStep = ssInstall) then
    begin
      if ServiceExists('LRDAgentSvc') then
        SimpleStopService('LRDAgentSvc', TRUE, TRUE);
    end;

    if (CurStep = ssPostInstall) then
    begin
      if not ServiceExists('LRDAgentSvc') then
      begin
        SimpleCreateService('LRDAgentSvc', 'LogRhythm Diagnostics Agent', ExpandConstant('{app}\') +  'LRDAgent.exe', 
          SERVICE_AUTO_START, '', '', FALSE, TRUE);
      end;
    end;
  end;
  
  if (CurStep = ssDone) then
    g_bCopyInstLog := True;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  SetupType: string;
begin
  SetupType := WizardSetupType(FALSE);
  if SetupType <> 'client' then
  begin
    if (usUninstall =  CurUninstallStep) then
    begin
      if ServiceExists('LRStatsExportService') then
      begin
        SimpleStopService('LRStatsExportService', TRUE, TRUE);
        SimpleDeleteService('LRStatsExportService');
      end;
    end;
  end;
end;

procedure DeinitializeSetup();
begin
  if (g_bCopyInstLog) then
    FileCopy(ExpandConstant('{log}'), ExpandConstant('{app}\') + ExtractFileName(ExpandConstant('{log}')), True)
end;

