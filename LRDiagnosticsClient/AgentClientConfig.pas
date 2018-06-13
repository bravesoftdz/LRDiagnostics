unit AgentClientConfig;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.IOUtils,
  FileLogger, CryptoAPI, Utilities;

type
  TAgentClientConfig = class
  protected
    FRequireAuth: Boolean;
    FUserName: String;
    FPassword: String;
    FURL: String;
    class var FConfig: TAgentClientConfig;
    function ToJsonString: String;
    procedure FromJsonString(AValue: String);
  public
    constructor Create(AAgentClientConfig: TAgentClientConfig = nil);
    function ToJSONObject: TJSONObject;
    procedure FromJSONObject(AValue: TJSONObject);
    procedure SaveToFile(AFileName: String);
    property RequireAuth: Boolean read FRequireAuth write FRequireAuth;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property URL: String read FURL write FURL;
    property AsJson: String read ToJsonString write FromJsonString;
    class function DefaultConfigPath: String;
    class procedure CreateDefaultConfigPath;
    class function DefaultConfigFile: String;
    class function GetConfigFromJsonString(AValue: String): TAgentClientConfig;
    class property Config: TAgentClientConfig read FConfig write FConfig;
  end;

implementation

constructor TAgentClientConfig.Create(AAgentClientConfig: TAgentClientConfig = nil);
begin
  FRequireAuth := FALSE;
  FUserName := String.Empty;
  FPassword := String.Empty;
  FURL := String.Empty;
  if nil <> AAgentClientConfig then
  begin
    FUserName := AAgentClientConfig.UserName;
    FPassword := AAgentClientConfig.Password;
    FURL := AAgentClientConfig.URL;
  end;
end;

function TAgentClientConfig.ToJsonString: String;
var
  LObj: TJsonObject;
begin
  LObj := ToJSONObject;
  try
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;

procedure TAgentClientConfig.FromJsonString(AValue: String);
var
  LObj: TJsonObject;
begin
  LObj := TJsonObject.ParseJSONValue(AValue) As TJsonObject;
  try
    FromJSONObject(LObj);
  finally
    LObj.Free;
  end;
end;

function TAgentClientConfig.ToJSONObject: TJSONObject;
var
  LEncryptedString: String;
begin
  Result := TJSonObject.Create;
  Result.AddPair('requireAuth', TJsonBool.Create(FRequireAuth));
  Result.AddPair('username', FUserName);
  if not String.IsNullOrWhitespace(FPassword) then
    TCryptoAPI.aesEncryptString(FPassword, LEncryptedString);
  Result.AddPair('passwd', LEncryptedString);
  Result.AddPair('url', FURL);
end;

procedure TAgentClientConfig.FromJSONObject(AValue: TJSONObject);
var
  LEncryptedString: String;
begin
  if nil <> AValue.Values['requireAuth'] then
    FRequireAuth := ('TRUE' = AValue.Values['requireAuth'].Value.ToUpper);

  if nil <> AValue.Values['username'] then
    FUserName := AValue.Values['username'].Value;
  if nil <> AValue.Values['passwd'] then
  begin
    LEncryptedString := AValue.Values['passwd'].Value;
    TCryptoAPI.aesDecryptString(LEncryptedString, FPassword);
  end;
  if nil <> AValue.Values['url'] then
    FURL := AValue.Values['url'].Value;
end;

procedure TAgentClientConfig.SaveToFile(AFileName: String);
begin
  TFile.WriteAllText(AFileName, Self.AsJson);
end;

class function TAgentClientConfig.DefaultConfigPath: String;
begin
  Result := TPath.Combine(TUtilities.CommonAppDataDir, 'HoodedClaw');
  Result := TPath.Combine(Result, 'LRDAgentClient');
end;

class procedure TAgentClientConfig.CreateDefaultConfigPath;
begin
  if not TDirectory.Exists(DefaultConfigPath) then
    TDirectory.CreateDirectory(DefaultConfigPath);
end;

class function TAgentClientConfig.DefaultConfigFile: String;
begin
  Result := TPath.Combine(DefaultConfigPath, 'config.json');
end;

class function TAgentClientConfig.GetConfigFromJsonString(AValue: String): TAgentClientConfig;
begin
  Result := TAgentClientConfig.Create;
  Result.AsJson := AValue;
end;

end.
