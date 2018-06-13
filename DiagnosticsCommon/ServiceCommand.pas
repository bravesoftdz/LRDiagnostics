unit ServiceCommand;

interface

uses
  System.Classes, System.SysUtils, System.Json;

type
  TCommandType = (ctStart = 0, ctStop = 1, ctRestart = 3, ctPause = 4, ctResume = 5);
  TServiceCommand = class
  private
    FCommand: TCommandType;
    FServiceName: String;
    function ToJsonString: String;
    procedure FromJsonString(AValue: String);
  public
    constructor Create(AServiceCommand: TServiceCommand = nil);
    function ToJsonObject: TJsonObject;
    procedure FromJsonObject(AValue: TJsonObject);
    property Command: TCommandType read FCommand write FCommand;
    property ServiceName: String read FServiceName write FServiceName;
    property AsJson: String read ToJsonString write FromJsonString;
    class function GetFromJsonString(AValue: String): TServiceCommand;
  end;

implementation

constructor TServiceCommand.Create(AServiceCommand: TServiceCommand = nil);
begin
  if nil <> AServiceCommand then
  begin
    FCommand := AServiceCommand.Command;
    FServicename := AServiceCommand.ServiceName;
  end;
end;

function TServiceCommand.ToJsonString: String;
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

procedure TServiceCommand.FromJsonString(AValue: String);
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

function TServiceCommand.ToJsonObject: TJsonObject;
begin
  Result := TJSonObject.Create;
  Result.AddPair('command', TJsonNumber.Create(Integer(FCommand)));
  Result.AddPair('serviceName', FServiceName);
end;

procedure TServiceCommand.FromJsonObject(AValue: TJsonObject);
var
  LCommand: Integer;
begin
  if nil <> AValue.Values['serviceName'] then
    FServiceName := AValue.Values['serviceName'].Value;
  if nil <> AValue.Values['command'] then
  begin
    LCommand := StrToIntDef(AValue.Values['command'].Value, 0);
    FCommand := TCommandType(LCommand);
  end;
end;

class function TServiceCommand.GetFromJsonString(AValue: String): TServiceCommand;
begin
  Result := TServiceCommand.Create;
  Result.FromJsonString(AVAlue);
end;

end.
