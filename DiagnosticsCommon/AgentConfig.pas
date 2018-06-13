unit AgentConfig;

interface

uses
  System.Classes, System.SysUtils, System.JSON, FileLogger, CryptoAPI;

type
  TAgentConfig = class
  private
    FAuthEnabled: Boolean;
    FHost: String;
    FPort: WORD;
    FProtocol: String;
    FLogLevel: Integer;
    FUserName: String;
    FPassword: String;
    class var FConfig: TAgentConfig;
    function ToJsonString: String;
    procedure FromJsonString(AValue: String);
  public
    constructor Create(AgentConfig: TAgentConfig = nil);
    function ToJSONObject: TJSONObject;
    procedure FromJSONObject(AValue: TJSONObject);
    property AuthEnabled: Boolean read FAuthEnabled write FAuthEnabled;
    property Host: String read FHost write FHost;
    property Port: WORD read FPort write FPort;
    property Protocol: String read FProtocol write FProtocol;
    property LogLevel: Integer read FLogLevel write FLogLevel;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
    property AsJson: String read ToJsonString write FromJsonString;
    class function GetAgentConfigFromJsonString(AValue: String): TAgentConfig;
    class property Config: TAgentConfig read FConfig write FConfig;
  end;

implementation

constructor TAgentConfig.Create(AgentConfig: TAgentConfig = nil);
begin
  FAuthEnabled := FALSE;
  FHost := '127.0.0.1';
  FPort := 33334;
  FProtocol := 'https';
  FLogLevel := LOG_INFO;
  FUserName := 'logrhythm';
  FPassword := 'logrhythm!1';
  if nil <> AgentConfig then
  begin
    FAuthEnabled := AgentConfig.AuthEnabled;
    FHost := AgentConfig.Host;
    FPort := AgentConfig.Port;
    FProtocol := AgentConfig.Protocol;
    FLogLevel := AgentConfig.LogLevel;
    FUserName := AgentConfig.UserName;
    FPassword := AgentConfig.Password;
  end;
end;

function TAgentConfig.ToJsonString: String;
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

procedure TAgentConfig.FromJsonString(AValue: String);
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

function TAgentConfig.ToJSONObject: TJSONObject;
var
  LEncryptedString: String;
begin
  LEncryptedString := String.Empty;
  Result := TJSONObject.Create;
  Result.AddPair('authEnabled', TJsonBool.Create(FAuthEnabled));
  Result.AddPair('host', FHost);
  Result.AddPair('port', TJsonNumber.Create(FPort));
  Result.AddPair('protocol', FProtocol);
  Result.AddPair('loglevel', TJsonNumber.Create(FLogLevel));
  Result.AddPair('userName', FUserName);
  if not String.IsNullOrWhitespace(FPassword) then
    TCryptoAPI.aesEncryptString(FPassword, LEncryptedString);
  Result.AddPair('passwd', FPassword);
end;

procedure TAgentConfig.FromJSONObject(AValue: TJSONObject);
var
  LEncryptedString: String;
begin
  if nil <> AValue.Values['authEnabled'] then
    FAuthEnabled := ('TRUE' = AValue.Values['authEnabled'].Value.ToUpper);
  if nil <> AValue.Values['host'] then
    FHost := AValue.Values['host'].Value;
  if nil <> AValue.Values['port'] then
    FPort := StrToIntDef(AValue.Values['port'].Value, 33334);
  if nil <> AValue.Values['protocol'] then
    FProtocol := AValue.Values['protocol'].Value;
  if nil <> AValue.Values['logLevel'] then
    FLogLevel := StrToIntDef(AValue.Values['logLevel'].Value, 33334);
  if nil <> AValue.Values['userName'] then
    FUserName := AValue.Values['userName'].Value;
  if nil <> AValue.Values['passwd'] then
  begin
    LEncryptedString := AValue.Values['passwd'].Value;
    TCryptoAPI.aesDecryptString(LEncryptedString, FPassword);
  end;
end;

class function TAgentConfig.GetAgentConfigFromJsonString(AValue: String): TAgentConfig;
begin
  Result := TAgentConfig.Create;
  Result.AsJson := AValue;
end;

end.
