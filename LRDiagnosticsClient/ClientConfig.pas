unit ClientConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BaseModalForm, RzButton, Vcl.ExtCtrls,
  RzPanel, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, RzRadChk, Vcl.StdCtrls, RzLabel, cxTextEdit, Vcl.Mask,
  RzEdit, System.UITypes, AgentClientConfig;

type
  TfmClientConfig = class(TfmBaseModalForm)
    ebURL: TcxTextEdit;
    lbURL: TRzLabel;
    ckbRequireAuth: TRzCheckBox;
    lblUserName: TRzLabel;
    lblPassword: TRzLabel;
    ebUserName: TRzEdit;
    ebPassword: TRzEdit;
    procedure ckbRequireAuthClick(Sender: TObject);
  private
    { Private declarations }
    FConfig: TAgentClientConfig;
    procedure SetAuthRequiredUI(AAuthRequired: Boolean);
    procedure ObjectToForm;
    procedure FormToObject;
  protected
    function RaiseOKError: Boolean; override;
    function RaiseCancelError: Boolean; override;
    function CanOK: Integer; override;
    function CanCancel: Boolean; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AConfig: TAgentClientConfig = nil); reintroduce;
    destructor Destroy; override;
    property Config: TAgentClientConfig read FConfig;
  end;

implementation

{$R *.dfm}
constructor TfmClientConfig.Create(AOwner: TComponent; AConfig: TAgentClientConfig = nil);
begin
  inherited Create(AOwner);
  FConfig := TAgentClientConfig.Create(AConfig);
  ObjectToForm;
end;

destructor TfmClientConfig.Destroy;
begin
  FConfig.Free;
  inherited Destroy;
end;

procedure TfmClientConfig.ObjectToForm;
begin
  ebURL.Text := FConfig.URL;
  ckbRequireAuth.Checked := FConfig.RequireAuth;
  if FConfig.RequireAuth then
  begin
    ebUserName.Text := FConfig.UserName;
    ebPassword.Text := FConfig.Password;
  end;
  SetAuthRequiredUI(ckbRequireAuth.Checked);
end;

procedure TfmClientConfig.FormToObject;
begin
  FConfig.URL := ebURL.Text;
  FConfig.RequireAuth := ckbRequireAuth.Checked;
  if FConfig.RequireAuth then
  begin
    FConfig.UserName := ebUserName.Text;
    FConfig.Password := ebPassword.Text;
  end else
  begin
    FConfig.UserName := String.Empty;
    FConfig.Password := String.Empty;
  end;
end;

procedure TfmClientConfig.SetAuthRequiredUI(AAuthRequired: Boolean);
begin
  lblUserName.Enabled := AAuthRequired;
  ebUserName.Enabled := AAuthRequired;
  lblPassword.Enabled := AAuthRequired;
  ebPassword.Enabled := AAuthRequired;
end;

function TfmClientConfig.RaiseOKError: Boolean;
begin
  Result := TRUE;
end;

function TfmClientConfig.RaiseCancelError: Boolean;
begin
  Result := FALSE;
end;

function TfmClientConfig.CanOK: Integer;
begin
  Result := -1;
  FormToObject;
  if String.IsNullOrWhitespace(FConfig.URL) then
  begin
    MessageDlg('You must enter a URL.', mtError, [mbOK], 0);
    EXIT;
  end;
  if FConfig.RequireAuth then
  begin
    if String.IsNullOrWhitespace(FConfig.UserName) then
    begin
      MessageDlg('You must enter a User Name.', mtError, [mbOK], 0);
      EXIT;
    end;
  end;
  FConfig.SaveToFile(TAgentClientConfig.DefaultConfigFile);
  Result := 1;
end;

function TfmClientConfig.CanCancel: Boolean;
begin
  Result := TRUE;
end;

procedure TfmClientConfig.ckbRequireAuthClick(Sender: TObject);
begin
  inherited;
  SetAuthRequiredUI(ckbRequireAuth.Checked);
end;

end.
