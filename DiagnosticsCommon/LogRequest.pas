unit LogRequest;

interface

uses
  System.Classes, System.SysUtils, System.Json, System.Generics.Collections;

type
  TLRComponent = class
  protected
    FComponentName: String;
    FLogs: Boolean;
    FPerfCounters: Boolean;
    FDiskStats: Boolean;
    function ToJsonString: String;
    procedure FromJsonString(AValue: String);
  public
    constructor Create(ALRComponent: TLRComponent = nil);
    function ToJsonObject: TJsonObject;
    procedure FromJsonObject(AValue: TJsonObject);
    property ComponentName: String read FComponentName write FComponentName;
    property Logs: Boolean read FLogs write FLogs;
    property PerfCounters: Boolean read FPerfCounters write FPerfCounters;
    property DiskStats: Boolean read FDiskStats write FDiskStats;
    property AsJson: String read ToJsonString write FromJsonString;
    class function GetFromJsonString(AValue: String): TLRComponent;
    class function GetFromJsonObject(AValue: TJsonObject): TLRComponent;
  end;

  TLogRequest = class
  protected
    FMaxAgeHours: Integer;
    FMaxMB: Integer;
    FComponents: TObjectList<TLRComponent>;
    function ToJsonString: String;
    procedure FromJsonString(AValue: String);
  public
    constructor Create(ALogRequest: TLogRequest = nil);
    destructor Destroy; override;
    function ToJsonObject: TJsonObject;
    procedure FromJsonObject(AValue: TJsonObject);
    property MaxAgeHours: Integer read FMaxAgeHours write FMaxAgeHours;
    property MaxMB: Integer read FMaxMB write FMaxMB;
    property Components: TObjectList<TLRComponent> read FComponents;
    property AsJson: String read ToJsonString write FromJsonString;
    class function GetFromJsonString(AValue: String): TLogRequest;
  end;

implementation

{$REGION 'TLRComponent'}
constructor TLRComponent.Create(ALRComponent: TLRComponent = nil);
begin
  FComponentName := String.Empty;
  FLogs := TRUE;
  FPerfCounters := TRUE;
  FDiskStats := TRUE;
end;

function TLRComponent.ToJsonString: String;
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

procedure TLRComponent.FromJsonString(AValue: String);
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

function TLRComponent.ToJsonObject: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.AddPair('componentName', FComponentName);
  Result.AddPair('logs', TJsonBool.Create(FLogs));
  Result.AddPair('perfCounters', TJsonBool.Create(FPerfCounters));
  Result.AddPair('diskStats', TJsonBool.Create(FDiskStats));
end;

procedure TLRComponent.FromJsonObject(AValue: TJsonObject);
begin
  if nil <> AValue.Values['componentName'] then
    FComponentName := AValue.Values['componentName'].Value;
  if nil <> AValue.Values['logs'] then
    FLogs := ('TRUE' = AValue.Values['logs'].Value.ToUpper);
  if nil <> AValue.Values['perfCounters'] then
    FPerfCounters := ('TRUE' = AValue.Values['perfCounters'].Value.ToUpper);
  if nil <> AValue.Values['diskStats'] then
    FDiskStats := ('TRUE' = AValue.Values['diskStats'].Value.ToUpper);
end;

class function TLRComponent.GetFromJsonString(AValue: String): TLRComponent;
begin
  Result := TLRComponent.Create;
  Result.AsJson := AValue;
end;

class function TLRComponent.GetFromJsonObject(AValue: TJsonObject): TLRComponent;
begin
  Result := TLRComponent.Create;
  Result.FromJsonObject(AValue);
end;
{$ENDREGION}

{$REGION 'TLogRequest'}
constructor TLogRequest.Create(ALogRequest: TLogRequest = nil);
var
  i: Integer;
begin
  FMaxAgeHours := 0;
  FMaxMB := 0;
  FComponents := TObjectList<TLRComponent>.Create(TRUE);
  if nil <> ALogRequest then
  begin
    for i := 0 to (ALogRequest.Components.Count - 1) do
      FComponents.Add(TLRComponent.Create(ALogRequest.Components[i]));
  end;
end;

destructor TLogRequest.Destroy;
begin
  FComponents.Free;
  inherited Destroy;
end;

function TLogRequest.ToJsonString: String;
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

procedure TLogRequest.FromJsonString(AValue: String);
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

function TLogRequest.ToJsonObject: TJsonObject;
var
  LComponents: TJsonArray;
  i: Integer;
begin
  Result := TJSonObject.Create;
  Result.AddPair('fileAgeHrs', TJsonNumber.Create(FMaxAgeHours));
  Result.AddPair('maxMb', TJsonNumber.Create(FMaxMB));
  LComponents := TJsonArray.Create;
  for i := 0 to (FComponents.Count - 1) do
    LComponents.Add(FComponents[i].ToJsonObject);
  Result.AddPair('components', LComponents);
end;

procedure TLogRequest.FromJsonObject(AValue: TJsonObject);
var
  LComponents: TJsonArray;
  LEnumerator: TJSONArrayEnumerator;
begin
  if nil <> AValue.Values['fileAgeHrs'] then
    FMaxAgeHours := StrToIntDef(AValue.Values['serviceName'].Value, 0);
  if nil <> AValue.Values['maxMb'] then
    FMaxMb := StrToIntDef(AValue.Values['maxMb'].Value, 0);

  LComponents := AValue.Values['logFiles'] as TJsonArray;
  FComponents.Clear;
  if nil <> LComponents then
  begin
    LEnumerator := LComponents.GetEnumerator;
    try
      while LEnumerator.MoveNext do
        FComponents.Add( TLRComponent.GetFromJsonObject(LEnumerator.Current as TJsonObject) );
    finally
      LEnumerator.Free;
    end;
  end;
end;

class function TLogRequest.GetFromJsonString(AValue: String): TLogRequest;
begin
  Result := TLogRequest.Create;
  Result.AsJson := AValue;
end;
{$ENDREGION}

end.
