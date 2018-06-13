unit LRService;

interface

uses
  System.Classes, System.SysUtils, System.Json, System.Generics.Collections;

type
  TLRService = class
  protected
    FServiceName: String;
    FDisplayName: String;
    FStatus: String;
    FLogFiles: TList<String>;
    function ToJsonString: String;
    procedure FromJsonString(AValue: String);
  public
    constructor Create(ALRService: TLRService = nil);
    destructor Destroy; override;
    function ToJsonObject: TJsonObject;
    procedure FromJsonObject(AValue: TJsonObject);
    property ServiceName: String read FServiceName write FServiceName;
    property DisplayName: String read FDisplayName write FDisplayName;
    property Status: String read FStatus write FStatus;
    property LogFiles: TList<String> read FLogFiles;
    property AsJson: String read ToJsonString write FromJsonString;
    class function GetFromJsonString(AValue: String): TLRService;
  end;

  TLRServiceList = class
  protected
    FList: TObjectList<TLRService>;
    function GetCount: Integer;
    function GetListItem(AIndex: Integer): TLRService;
    procedure SetListItem(AIndex: Integer; AValue: TLRService);
  public
    constructor Create(ALRServiceList: TLRServiceList = nil);
    destructor Destroy; override;
    function ToJsonArray: TJsonArray;
    procedure FromJsonArray(AValue: TJsonArray);
    procedure Add(AValue: TLRService);
    procedure Delete(AIndex: Integer);
    property Count: Integer read GetCount;
    property Services[AIndex: Integer]:TLRService read GetListItem write SetListItem; default;
    class function GetFromJsonString(AValue: String): TLRServiceList;
  end;

implementation

{$REGION 'TLRService'}
constructor TLRService.Create(ALRService: TLRService = nil);
var
  i: Integer;
begin
  FLogFiles := TList<String>.Create;
  FServiceName := String.Empty;
  FDisplayName := String.Empty;
  FStatus := String.Empty;
  if nil <> ALRService then
  begin
    FServiceName := ALRService.ServiceName;
    FDisplayName := ALRService.DisplayName;
    FStatus := ALRService.Status;
    for i := 0 to (ALRService.LogFiles.Count - 1) do
      FLogFiles.Add(ALRService.LogFiles[i]);
  end;
end;

destructor TLRService.Destroy;
begin
  FLogFiles.Free;
  inherited Create;
end;

function TLRService.ToJsonString: String;
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

procedure TLRService.FromJsonString(AValue: String);
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

function TLRService.ToJsonObject: TJsonObject;
var
  LLogFiles: TJsonArray;
  i: Integer;
begin
  Result := TJSonObject.Create;
  Result.AddPair('serviceName', FServiceName);
  Result.AddPair('displayName', FDisplayName);
  Result.AddPair('status', FStatus);
  LLogFiles := TJsonArray.Create;
  for i := 0 to (FLogFiles.Count - 1) do
    LLogFiles.Add(FLogFiles[i]);
  Result.AddPair('logFiles', LLogFiles);
end;

procedure TLRService.FromJsonObject(AValue: TJsonObject);
var
  LLogFiles: TJsonArray;
  LEnumerator: TJSONArrayEnumerator;
begin
  if nil <> AValue.Values['serviceName'] then
    FServiceName := AValue.Values['serviceName'].Value;
  if nil <> AValue.Values['displayName'] then
    FDisplayName := AValue.Values['displayName'].Value;
  if nil <> AValue.Values['status'] then
    FStatus := AValue.Values['status'].Value;
  LLogFiles := AValue.Values['logFiles'] as TJsonArray;
  FLogFiles.Clear;
  if nil <> LLogFiles then
  begin
    LEnumerator := LLogFiles.GetEnumerator;
    try
      while LEnumerator.MoveNext do
        FLogFiles.Add( LEnumerator.Current.Value );
    finally
      LEnumerator.Free;
    end;
  end;
end;

class function TLRService.GetFromJsonString(AValue: String): TLRService;
begin
  Result := TLRService.Create;
  Result.AsJson := AValue;
end;
{$ENDREGION}

constructor TLRServiceList.Create(ALRServiceList: TLRServiceList = nil);
var
  i: Integer;
begin
  FList := TObjectList<TLRService>.Create(TRUE);
  if nil <> ALRServiceList then
  begin
    for i := 0 to (ALRServiceList.Count - 1) do
      FList.Add( TLRService.Create(ALRServiceList[i]) );
  end;
end;

destructor TLRServiceList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TLRServiceList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TLRServiceList.GetListItem(AIndex: Integer): TLRService;
begin
  Result := FList[AIndex];
end;

procedure TLRServiceList.SetListItem(AIndex: Integer; AValue: TLRService);
begin
  FList[AIndex] := AValue;
end;

function TLRServiceList.ToJsonArray: TJsonArray;
var
  i: Integer;
begin
  Result := TJSonArray.Create;
  for i := 0 to (FList.Count - 1) do
    Result.AddElement(Flist[i].ToJsonObject);
end;

procedure TLRServiceList.FromJsonArray(AValue: TJsonArray);
var
  LArrayValue: TJSONValue;
  LJsonStr: String;
begin
  FList.Clear;
  for LArrayValue in AValue do
  begin
    LJsonStr := (LArrayValue As TJSONObject).ToJSON;
    FList.Add(TLRService.GetFromJSONString(LJsonStr));
  end;
end;

procedure TLRServiceList.Add(AValue: TLRService);
begin
  FList.Add(AValue);
end;

procedure TLRServiceList.Delete(AIndex: Integer);
begin
  FList.Delete(AIndex);
end;

class function TLRServiceList.GetFromJsonString(AValue: String): TLRServiceList;
var
  LJsonArray: TJsonArray;
begin
  Result := TLRServiceList.Create;
  LJsonArray := TJsonObject.ParseJSONValue(AValue) As TJsonArray;
  try
    Result.FromJsonArray(LJsonArray);
  finally
    LJsonArray.Free;
  end;
end;

end.
