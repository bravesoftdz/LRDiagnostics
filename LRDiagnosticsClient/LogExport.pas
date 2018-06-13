unit LogExport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.UITypes,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, RzPanel, RzCmboBx, RzLabel, RzButton, Vcl.Mask, RzEdit,
  Web.HttpApp, Utilities, Diagnostics, EndPointClient, FileLogger, AgentClientConfig,
  RzLstBox, RzChkLst, ExportRequest;

type
  TfmLogExport = class(TForm)
    gbComponet: TRzGroupBox;
    RzLabel1: TRzLabel;
    pnBottom: TRzPanel;
    pnOKCancel: TRzPanel;
    btnOK: TRzBitBtn;
    btnCancel: TRzBitBtn;
    RzLabel2: TRzLabel;
    neMaxSize: TRzNumericEdit;
    RzLabel3: TRzLabel;
    neMaxAge: TRzNumericEdit;
    sdLogFile: TSaveDialog;
    clComponent: TRzCheckList;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadCombo;
    procedure SaveSettings;
    procedure LoadSettings;
    function GetLogs: Boolean;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

constructor TfmLogExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  LoadCombo;
  LoadSettings;
end;

procedure TfmLogExport.LoadCombo;
var
  LComponents: TStrings;
  i: Integer;
begin
  LComponents := TDiagnostics.GetComponnets;
  try
    for i := 0 to (LComponents.Count - 1) do
      clComponent.Items.Add(LComponents[i]);
  finally
    LComponents.Free;
  end;
end;

procedure TfmLogExport.SaveSettings;
begin
  TUtilities.SetFormKey('LogExport', 'MaxSize', IntToStr(neMaxSize.IntValue));
  TUtilities.SetFormKey('LogExport', 'MaxAge', IntToStr(neMaxAge.IntValue));
end;

procedure TfmLogExport.LoadSettings;
begin
  neMaxSize.IntValue := StrToIntDef(TUtilities.GetFormKey('LogExport', 'MaxSize'), 0);
  try
    neMaxAge.IntValue := StrToIntDef(TUtilities.GetFormKey('LogExport', 'MaxAge'), 0);
  except
    neMaxAge.IntValue := 0;
  end;
end;

function TfmLogExport.GetLogs: Boolean;
var
  LEndPoint: TEndpointClient;
  LStream, LZipFile: TStream;
  LRequest: TExportRequest;
  LComponent: TLRComponent;
  LRequestString: String;
  i: Integer;
begin
  LRequest := TExportRequest.Create;
  try
    LRequest.MaxAgeHours := neMaxSize.IntValue;
    LRequest.MaxMB := neMaxAge.IntValue;
    for i := 0 to (clComponent.Items.Count - 1) do
    begin
      if clComponent.ItemChecked[i] then
      begin
        LComponent := TLRComponent.Create;
        LComponent.ComponentName := clComponent.Items[i];
        LComponent.Logs := TRUE;
        LRequest.Components.Add(LComponent);
      end;
    end;
    LRequestString := LRequest.AsJson;
  finally
    LRequest.Free;
  end;

  Result := FALSE;
  LStream := TMemoryStream.Create;
  try
    Screen.Cursor := crHourglass;
    try
      LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
      try
        try
          LEndPoint.Post('export', LRequestString, LStream);
          LogInfo(String.Format('GET %s', [LEndPoint.Resource]));
        except
          on E:Exception do
          begin
            LogError(String.Format('Exception getting services: %s. Error code %d: %s', [E.Message, LEndPoint.StatusCode, LEndPoint.StatusText]));
            EXIT;
          end;
        end;
      finally
        LEndPoint.Free;
      end;
    finally
      Screen.Cursor := crDefault;
    end;

    LStream.Seek(0, 0);
    if sdLogFile.Execute then
    begin
      LZipFile := TFileStream.Create(sdLogFile.FileName, fmCreate);
      try
        LZipFile.CopyFrom(LStream, LStream.Size);
        Result := TRUE;
      finally
        LZipFile.Free;
      end;
    end;

  finally
    LStream.Free;
  end;
end;

procedure TfmLogExport.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfmLogExport.btnOKClick(Sender: TObject);
begin
  if GetLogs then
  begin
    SaveSettings;
    ModalResult := mrOK;
  end;
end;

end.
