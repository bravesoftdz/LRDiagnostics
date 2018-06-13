program LRDiagnosticsClient;

uses
  System.SysUtils,
  System.IOUtils,
  Vcl.Forms,
  LRDiagnosticClientsMain in 'LRDiagnosticClientsMain.pas' {fmMain},
  LRService in '..\DiagnosticsCommon\LRService.pas',
  CryptoAPI in '..\..\Common\Units\CryptoAPI.pas',
  LockableObject in '..\..\Common\Units\LockableObject.pas',
  MyBaseThread in '..\..\Common\Units\MyBaseThread.pas',
  Utilities in '..\..\Common\Units\Utilities.pas',
  Wcrypt2 in '..\..\Common\Units\Wcrypt2.pas',
  FileLogger in '..\..\Common\Units\FileLogger.pas',
  EndpointClient in '..\..\Common\Units\EndpointClient.pas',
  BaseModalForm in '..\..\Common\Forms\BaseModalForm.pas' {fmBaseModalForm},
  IAmABigBoy in '..\..\Common\Forms\IAmABigBoy.pas' {fmBigBoy},
  AgentConfig in '..\DiagnosticsCommon\AgentConfig.pas',
  CustomThread in '..\..\Common\Units\CustomThread.pas',
  AgentClientConfig in 'AgentClientConfig.pas',
  ClientConfig in 'ClientConfig.pas' {fmClientConfig},
  LogExport in 'LogExport.pas' {fmLogExport},
  Diagnostics in '..\DiagnosticsCommon\Diagnostics.pas',
  ServiceCommand in '..\DiagnosticsCommon\ServiceCommand.pas',
  PerfmonCounters in 'PerfmonCounters.pas',
  ExportRequest in '..\DiagnosticsCommon\ExportRequest.pas';

{$R *.res}

procedure LoadConfig;
var
  LCFgTxt: String;
begin
  TAgentClientConfig.CreateDefaultConfigPath;
  if TFile.Exists(TAgentClientConfig.DefaultConfigFile) then
  begin
    LCFgTxt := TFile.ReadAllText(TAgentClientConfig.DefaultConfigFile);
    TAgentClientConfig.Config := TAgentClientConfig.GetConfigFromJsonString(LCFgTxt);
  end else
    TAgentClientConfig.Config := TAgentClientConfig.Create;
end;

begin
  LoadConfig;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
