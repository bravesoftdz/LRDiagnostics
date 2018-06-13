unit LRDiagnosticClientsMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.SyncObjs, System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Generics.Collections, Vcl.ExtCtrls, RzPanel, RzSplit, System.NetEncoding,
  System.UITypes, Vcl.StdCtrls, RzEdit, RzTabs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinBlack, dxSkinBlue,
  dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans,
  dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, Vcl.Menus,
  dxSkinXmas2008Blue, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, cxGridCustomTableView, cxGridTableView,
  cxGridCustomView, cxClasses, cxGridLevel, cxGrid, Vcl.ComCtrls, RzTreeVw,
  HttpApp, EndPointClient, LRService, ClientConfig, AgentClientConfig, IAmABigBoy,
  LogExport, ServiceCommand, FileLogger, PerfmonCounters, RzButton;

type
   TPerfGridDataSource = class(TcxCustomDataSource)
  private
    FResult: TPerfmonCounterResult;
  protected
    function GetRecordCount: Integer; override;
    function GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant; override;
  public
    constructor Create(APerfmonCounterResult: TPerfmonCounterResult);
    destructor Destroy; override;
    property PerfmonCounterResult: TPerfmonCounterResult read FResult;
  end;

  TMessageWriteProc = procedure(AValue: String) of Object;
  TTextMessageReceptionThread = class(TThread)
    private
      FList: TList<String>;
      FFinishEvent: THandle;
      FMessageEvent: Thandle;
      FCrticalSection: TCriticalSection;
      FCurrentLogMessage: String;
      FCurrentLogMessages: TStrings;
      FMessageWriteProc: TMessageWriteProc;
      procedure PushMessageToMainThread;
      procedure WriteMessages;
    protected
      procedure TerminatedSet; override;
      procedure Execute; override;
    public
      constructor Create; reintroduce; overload; virtual;
      constructor Create(CreateSuspended: Boolean); reintroduce; overload; virtual;
      destructor Destroy; override;
      procedure AddMessage(AValue: String);
      property MessageWriteProc: TMessageWriteProc read FMessageWriteProc write FMessageWriteProc;
  end;

  TfmMain = class(TForm)
    splMain: TRzSplitter;
    pcBottom: TRzPageControl;
    tsLog: TRzTabSheet;
    memLog: TRzMemo;
    gbServices: TRzGroupBox;
    tvMain: TRzTreeView;
    pcMain: TRzPageControl;
    tsServiceLog: TRzTabSheet;
    memServiceLog: TRzMemo;
    menMain: TMainMenu;
    menFile: TMenuItem;
    miExit: TMenuItem;
    menExport: TMenuItem;
    miLogs: TMenuItem;
    ppmTreeView: TPopupMenu;
    ppmiStart: TMenuItem;
    ppmiStop: TMenuItem;
    ppmiRestart: TMenuItem;
    tsCounters: TRzTabSheet;
    gbCountersSelect: TRzGroupBox;
    lvCounters: TcxGridLevel;
    gCounters: TcxGrid;
    tvCounters: TcxGridTableView;
    colPerfCounterHost: TcxGridColumn;
    colPerfCounterCategory: TcxGridColumn;
    colPerfCounterName: TcxGridColumn;
    colPerfCounterValue: TcxGridColumn;
    btnGetXM: TRzBitBtn;
    btnPMCounters: TRzBitBtn;
    btnGetLMCounters: TRzBitBtn;
    btnGetAIECounters: TRzBitBtn;
    miConfig: TMenuItem;
    procedure tvMainChange(Sender: TObject; Node: TTreeNode);
    procedure miExitClick(Sender: TObject);
    procedure miLogsClick(Sender: TObject);
    procedure ppmiStartClick(Sender: TObject);
    procedure ppmTreeViewPopup(Sender: TObject);
    procedure ppmiStopClick(Sender: TObject);
    procedure ppmiRestartClick(Sender: TObject);
    procedure btnGetXMClick(Sender: TObject);
    procedure btnPMCountersClick(Sender: TObject);
    procedure btnGetLMCountersClick(Sender: TObject);
    procedure btnGetAIECountersClick(Sender: TObject);
    procedure miConfigClick(Sender: TObject);
  private
    { Private declarations }
    FLogReceptionThread: TTextMessageReceptionThread;
    procedure WriteLog(ALogMessage: String);
    function UserOKToRun: Boolean;
    procedure GetConfig;
    procedure ClearChildren(ANode: TTreeNode);
    procedure GetServices;
    procedure LoadGrid(APerfmonCounterResult: TPerfmonCounterResult);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

{$REGION 'TPerfGridDataSource'}
constructor TPerfGridDataSource.Create(APerfmonCounterResult: TPerfmonCounterResult);
begin
  if nil = APerfmonCounterResult then
    FResult := TPerfmonCounterResult.Create
  else
    FResult := TPerfmonCounterResult.Create(APerfmonCounterResult);
end;

destructor TPerfGridDataSource.Destroy;
begin
  FResult.Free;
  inherited Destroy;
end;

function TPerfGridDataSource.GetRecordCount: Integer;
begin
  if nil = FResult then
    Result := 0
  else
    Result := FResult.Count;
end;

function TPerfGridDataSource.GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant;
var
  LRec: TPerfmonCounterItem;
  LCloumnIndex: Integer;
  LRecordIndex: Integer;
begin
  Result := NULL;
  LRecordIndex := Integer(ARecordHandle);
  LRec := FResult[LRecordIndex];
  if nil = LRec then
    EXIT;

  LCloumnIndex := Integer(AItemHandle);

  case LCloumnIndex of
    0: Result := LRec.Host;
    1: Result := LRec.Category;
    2: Result := LRec.Name;
    3: Result := LRec.Value;
  end;
end;
{$ENDREGION}

{$REGION 'TTextMessageReceptionThread'}
constructor TTextMessageReceptionThread.Create;
begin
  Create(TRUE);
end;

constructor TTextMessageReceptionThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FCrticalSection := TCriticalSection.Create;
  FFinishEvent := CreateEvent(nil, TRUE, FALSE, nil);
  FMessageEvent := CreateEvent(nil, TRUE, FALSE, nil);
  FList := TList<String>.Create;
  FCurrentLogMessages := TStringList.Create;
end;

destructor TTextMessageReceptionThread.Destroy;
begin
  FCurrentLogMessages.Clear;
  FList.Free;
  CloseHandle(FFinishEvent);
  CloseHandle(FMessageEvent);
  FCrticalSection.Release;
  FCrticalSection.Free;
  inherited Destroy;
end;

procedure TTextMessageReceptionThread.TerminatedSet;
begin
  SetEvent( FFinishEvent );
end;

procedure TTextMessageReceptionThread.Execute;
var
  LWaitObject: Cardinal;
  LEvents: array[0..1] of THandle;
begin
  LEvents[0] := FFinishEvent;
  LEvents[1] := FMessageEvent;
  while not Terminated do
  begin
    LWaitObject := WaitForMultipleObjects(2, @LEvents, FALSE, INFINITE);
    case (LWaitObject - WAIT_OBJECT_0) of
    0:begin
       BREAK;
      end;
    1:begin
       ResetEvent(FMessageEvent);
       WriteMessages;
     end;
    end;
  end;
end;

procedure TTextMessageReceptionThread.PushMessageToMainThread;
begin
  FMessageWriteProc(FCurrentLogMessage);
end;

procedure TTextMessageReceptionThread.WriteMessages;
var
  LNewList, LTempList: TList<String>;
  i: Integer;
begin
  LNewList := TList<String>.Create;
  FCrticalSection.Acquire;
  try
    LTempList := FList;
    FList := LNewList;
  finally
    FCrticalSection.Release;
  end;
  if Assigned(FMessageWriteProc) then
  begin
    for i := 0 to (LTempList.Count - 1) do
    begin
      FCurrentLogMessage := LTempList[i];
      Synchronize(PushMessageToMainThread);
    end;
  end;
  LTempList.Free;
end;

procedure TTextMessageReceptionThread.AddMessage(AValue: String);
begin
  FCrticalSection.Acquire;
  try
    FList.Add(AValue);
    SetEvent(FMessageEvent);
  finally
    FCrticalSection.Release;
  end;
end;
{$ENDREGION}

constructor TfmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLogReceptionThread := TTextMessageReceptionThread.Create(TRUE);
  FLogReceptionThread.MessageWriteProc := WriteLog;
  FLogReceptionThread.FreeOnTerminate := FALSE;
  TFileLogger.SetFileLogLevel(LOG_DEBUG, FLogReceptionThread.AddMessage);
  FLogReceptionThread.Suspended := FALSE;

  if not UserOKToRun then
    Application.Terminate;
  if not TFile.Exists(TAgentClientConfig.DefaultConfigFile) then
  begin
    GetConfig;
    if not TFile.Exists(TAgentClientConfig.DefaultConfigFile) then
      Application.Terminate;
  end else
  begin
    LogInfo(String.Format('Config File %s exists', [TAgentClientConfig.DefaultConfigFile]));
    LogInfo(String.Format('  URL: %s', [TAgentClientConfig.Config.URL]));
    if TAgentClientConfig.Config.RequireAuth then
    begin
      LogInfo('  Require Auth: True');
      LogInfo(String.Format('  User Name: %s', [TAgentClientConfig.Config.UserName]));
      LogInfo('  Password: ********');
    end
    else
      LogInfo('  Require Auth: False')
  end;
  try
    GetServices;
  except
  end;
  LoadGrid(nil);
  pcMain.ActivePageIndex := 0;
end;

destructor TfmMain.Destroy;
begin
  FLogReceptionThread.Terminate;
  FLogReceptionThread.Free;
  inherited Destroy;
end;

procedure TfmMain.WriteLog(ALogMessage: String);
begin
  memLog.Lines.Add(ALogMessage);
end;

function TfmMain.UserOKToRun: Boolean;
var
  fm: TfmBigBoy;
begin
  fm := TfmBigBoy.Create(nil);
  try
    fm.ShowModal;
    Result := fm.UserOK;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.GetConfig;
var
  fm: TfmClientConfig;
begin
  fm := TfmClientConfig.Create(nil, TAgentClientConfig.Config);
  try
    if mrOK = fm.ShowModal then
    begin
      TAgentClientConfig.Config.Free;
      TAgentClientConfig.Config := TAgentClientConfig.Create(fm.Config);
    end;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.ClearChildren(ANode: TTreeNode);
var
  LChildNode: TTreeNode;
  LSvc: TLRService;
begin
  if ANode.HasChildren then
  begin
    LChildNode := ANode.getFirstChild;
    while nil <> LChildNode do
    begin
      ClearChildren(LChildNode);
      LChildNode := ANode.getNextChild(LChildNode);
    end;
  end;
  if nil <> ANode.Data then
  begin
    LSvc := TLRService(ANode.Data);
    LSvc.Free;
  end;
end;

procedure TfmMain.GetServices;
var
  LEndPoint: TEndpointClient;
  LJson: String;
  LServiceList: TLRServiceList;
  i, j : Integer;
  LNode, LChildNode: TTreeNode;
begin
  Screen.Cursor := crHourglass;
  try
    LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
    try
      try
        LJson := LEndPoint.Get('services');
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

  for i := (tvMain.Items.Count - 1) downto 0 do
  begin
    if nil = tvMain.Items[i].Parent then
    begin
      ClearChildren(tvMain.Items[i]);
    end;
  end;

  Screen.Cursor := crHourglass;
  try
    LServiceList :=  TLRServiceList.GetFromJsonString(LJson);
    try
      LNode := tvMain.Items.Add(nil, TAgentClientConfig.Config.URL);
      for i := 0 to (LServiceList.Count - 1) do
      begin
        LChildNode := tvMain.Items.AddChild(LNode, String.Format('%s (%s)', [LServiceList[i].DisplayName, LServiceList[i].Status]) );
        LChildNode.Data := TLRService.Create( LServiceList[i] );
        for j := 0 to LServiceList[i].LogFiles.Count - 1 do
          tvMain.Items.AddChild(LChildNode, ExtractFileName(LServiceList[i].LogFiles[j]));
      end;
    finally
      LServiceList.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.LoadGrid(APerfmonCounterResult: TPerfmonCounterResult);
var
  LDS: TPerfGridDataSource;
begin
  tvCounters.BeginUpdate(lsimImmediate);
  try
    if (nil <> tvCounters.DataController.CustomDataSource) then
    begin
      LDS := TPerfGridDataSource(tvCounters.DataController.CustomDataSource);
      tvCounters.DataController.CustomDataSource := nil;
      LDS.Free;
    end;

    tvCounters.DataController.BeginFullUpdate;
    try
      LDS := TPerfGridDataSource.Create(APerfmonCounterResult);
      tvCounters.DataController.CustomDataSource := LDS;
    finally
      tvCounters.DataController.EndFullUpdate;
    end;
  finally
    tvCounters.EndUpdate;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.tvMainChange(Sender: TObject; Node: TTreeNode);
var
  LEndPoint: TEndpointClient;
  LLgText: String;
begin
  if nil = Node then
    EXIT;
  if nil = Node.Parent then
    EXIT;
  if nil <> Node.Parent.Data then
  begin
    //It must be a log file node
    Screen.Cursor := crHourglass;
    try
      LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
      try
        try
          LLgText := LEndPoint.Get(String.Format('log/%s?fileName=%s', [ TLRService(Node.Parent.Data).ServiceName, TNetEncoding.URL.ENcode(Node.Text)]));
          LogInfo(String.Format('GET %s', [LEndPoint.Resource]));
          memServiceLog.Lines.Text := LLgText;
          SendMessage(memServiceLog.Handle, EM_LINESCROLL, 0, memServiceLog.Lines.Count);
        except
          on E:Exception do
          begin
            LogError(String.Format('Error in GET %s', [LEndPoint.Resource]));
            LogError(String.Format('Exception getting services: %s. Error code %d: %s', [E.Message, LEndPoint.StatusCode, LEndPoint.StatusText]));
          end;
        end;
      finally
        LEndPoint.Free;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfmMain.miConfigClick(Sender: TObject);
begin
  GetConfig;
end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfmMain.miLogsClick(Sender: TObject);
var
  fm: TfmLogExport;
begin
  fm := TfmLogExport.Create(nil);
  try
    fm.ShowModal;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.ppmiStartClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEndPoint: TEndpointClient;
  LCmd: TServiceCommand;
begin
  if (nil = tvMain.Selected) then
  begin
    MessageDlg('You must selct a service.', mtError, [mbOK], 0);
    EXIT;
  end;

  LNode := tvMain.Selected;
  if nil = LNode.Parent then
    Abort;

  while nil = LNode.Data do
    LNode := LNode.Parent;

  Screen.Cursor := crHourglass;
  try
    LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
    try
      try
        LCmd := TServiceCommand.Create;
        try
          LCmd.ServiceName := TLRService(LNode.Data).ServiceName;
          LCmd.Command := ctStart;
          LogInfo(LCmd.AsJson);
          LEndPoint.Post('service/command', LCmd.AsJson);
        finally
          LCmd.Free;
        end;
        LogInfo(String.Format('POST %s', [LEndPoint.Resource]));
      except
        on E:Exception do
        begin
          LogError(String.Format('Error in POST %s', [LEndPoint.Resource]));
        end;
      end;
    finally
      LEndPoint.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.ppmiStopClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEndPoint: TEndpointClient;
  LCmd: TServiceCommand;
begin
  if (nil = tvMain.Selected) then
  begin
    MessageDlg('You must selct a service.', mtError, [mbOK], 0);
    EXIT;
  end;

  LNode := tvMain.Selected;
  if nil = LNode.Parent then
    Abort;

  while nil = LNode.Data do
    LNode := LNode.Parent;

  Screen.Cursor := crHourglass;
  try
    LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
    try
      try
        LCmd := TServiceCommand.Create;
        try
          LCmd.ServiceName := TLRService(LNode.Data).ServiceName;
          LCmd.Command := ctStop;
          LEndPoint.Post('service/command', LCmd.AsJson);
        finally
          LCmd.Free;
        end;
        LogInfo(String.Format('POST %s', [LEndPoint.Resource]));
      except
        on E:Exception do
        begin
          LogError(String.Format('Error in POST %s', [LEndPoint.Resource]));
        end;
      end;
    finally
      LEndPoint.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.ppmiRestartClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEndPoint: TEndpointClient;
  LCmd: TServiceCommand;
begin
  if (nil = tvMain.Selected) then
  begin
    MessageDlg('You must selct a service.', mtError, [mbOK], 0);
    EXIT;
  end;

  LNode := tvMain.Selected;
  if nil = LNode.Parent then
    Abort;

  while nil = LNode.Data do
    LNode := LNode.Parent;

  Screen.Cursor := crHourglass;
  try
    LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
    try
      try
        LCmd := TServiceCommand.Create;
        try
          LCmd.ServiceName := TLRService(LNode.Data).ServiceName;
          LCmd.Command := ctRestart;
          LEndPoint.Post('service/command', LCmd.AsJson);
        finally
          LCmd.Free;
        end;
        LogInfo(String.Format('POST %s', [LEndPoint.Resource]));
      except
        on E:Exception do
        begin
          LogError(String.Format('Error in POST %s', [LEndPoint.Resource]));
        end;
      end;
    finally
      LEndPoint.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.ppmTreeViewPopup(Sender: TObject);
var
  LNode: TTreeNode;
begin
  if (nil = tvMain.Selected) then
  begin
    ppmiStart.Visible := (0 <> tvMain.Items.Count);
    ppmiStop.Visible := (0 <> tvMain.Items.Count);
    ppmiRestart.Visible := (0 <> tvMain.Items.Count);
  end;

  LNode := tvMain.Selected;
  if nil = LNode.Parent then
    Abort;

  while nil = LNode.Data do
    LNode := LNode.Parent;

  ppmiStart.Visible := ('Stopped' = TLRService(LNode.Data).Status);
  ppmiStop.Visible := ('Stopped' <> TLRService(LNode.Data).Status);
  ppmiReStart.Visible := ('Stopped' <> TLRService(LNode.Data).Status);

end;

procedure TfmMain.btnGetXMClick(Sender: TObject);
var
  LEndPoint: TEndpointClient;
  LRes: TPerfmonCounterResult;
begin
  Screen.Cursor := crHourglass;
  try
    LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
    try
      LRes := TPerfmonCounterResult.Create;
      try
        try
          LRes.AsJson := LEndPoint.Get('PerfCounters/xm');
          LogInfo(String.Format('GET %s', [LEndPoint.Resource]));
          LoadGrid(LRes);
        except
          on E:Exception do
          begin
            LogError(String.Format('Error in GET %s', [LEndPoint.Resource]));
            LogError(String.Format('Exception getting services: %s. Error code %d: %s', [E.Message, LEndPoint.StatusCode, LEndPoint.StatusText]));
          end;
        end;
      finally
        LRes.Free;
      end;
    finally
      LEndPoint.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.btnPMCountersClick(Sender: TObject);
var
  LEndPoint: TEndpointClient;
  LRes: TPerfmonCounterResult;
begin
  Screen.Cursor := crHourglass;
  try
    LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
    try
      LRes := TPerfmonCounterResult.Create;
      try
        try
          LRes.AsJson := LEndPoint.Get('PerfCounters/pm');
          LogInfo(String.Format('GET %s', [LEndPoint.Resource]));
          LoadGrid(LRes);
        except
          on E:Exception do
          begin
            LogError(String.Format('Error in GET %s', [LEndPoint.Resource]));
            LogError(String.Format('Exception getting services: %s. Error code %d: %s', [E.Message, LEndPoint.StatusCode, LEndPoint.StatusText]));
          end;
        end;
      finally
        LRes.Free;
      end;
    finally
      LEndPoint.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.btnGetLMCountersClick(Sender: TObject);
var
  LEndPoint: TEndpointClient;
  LRes: TPerfmonCounterResult;
begin
  Screen.Cursor := crHourglass;
  try
    LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
    try
      LRes := TPerfmonCounterResult.Create;
      try
        try
          LRes.AsJson := LEndPoint.Get('PerfCounters/lm');
          LogInfo(String.Format('GET %s', [LEndPoint.Resource]));
          LoadGrid(LRes);
        except
          on E:Exception do
          begin
            LogError(String.Format('Error in GET %s', [LEndPoint.Resource]));
            LogError(String.Format('Exception getting services: %s. Error code %d: %s', [E.Message, LEndPoint.StatusCode, LEndPoint.StatusText]));
          end;
        end;
      finally
        LRes.Free;
      end;
    finally
      LEndPoint.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.btnGetAIECountersClick(Sender: TObject);
var
  LEndPoint: TEndpointClient;
  LRes: TPerfmonCounterResult;
begin
  Screen.Cursor := crHourglass;
  try
    LEndPoint := TEndpointClient.Create(TAgentClientConfig.Config.URL, TAgentClientConfig.Config.UserName, TAgentClientConfig.Config.Password);
    try
      LRes := TPerfmonCounterResult.Create;
      try
        try
          LRes.AsJson := LEndPoint.Get('PerfCounters/aie');
          LogInfo(String.Format('GET %s', [LEndPoint.Resource]));
          LoadGrid(LRes);
        except
          on E:Exception do
          begin
            LogError(String.Format('Error in GET %s', [LEndPoint.Resource]));
            LogError(String.Format('Exception getting services: %s. Error code %d: %s', [E.Message, LEndPoint.StatusCode, LEndPoint.StatusText]));
          end;
        end;
      finally
        LRes.Free;
      end;
    finally
      LEndPoint.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.
