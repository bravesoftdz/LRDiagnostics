unit PerfmonCountetrs;

interface

uses
  System.Classes, System.SysUtils, System.Json, System.Generics.Collections;

type
  TPerfmonCounterItem = class
  private
    FHost: String;
    FCategory: String;
    FInstance: String;
    FName: String;
    FHelp: String;
    FValue: String;
    function ToJsonString: String;
    procedure FromJsonString(AValue: String);
  public
    constructor Create(APerfmonCounterItem: TPerfmonCounterItem= nil);
    function ToJsonObject: TJsonObject;
    procedure FromJsonObject(AValue: TJsonObject);
    class function CreateFromJsonString(AValue: String): TPerfmonCounterItem;
    property Host: String read FHost write FHost;
    property Category: String read FCategory write FCategory;
    property Instance: String read FInstance write FInstance;
    property Name: String read FName write FName;
    property Help: String read FHelp write FHelp;
    property Value: String read FValue write FValue;
    property AsJson: String read ToJsonString write FromJsonString;
  end;

  TPerfmonCounterResult = class
  private
    FStatus: String;
    FError: String;
    FList: TObjectList<TPerfmonCounterItem>;
    function GetCount: Integer;
    function GetListItem(AIndex: Integer): TPerfmonCounterItem;
    procedure SetListItem(AIndex: Integer; AValue: TPerfmonCounterItem);
    function ToJsonString: String;
    procedure FromJsonString(AValue: String);
  public
    constructor Create(APerfmonCounterResult: TPerfmonCounterResult = nil);
    destructor Destroy; override;
    function ToJsonObject: TJsonObject;
    procedure FromJsonObject(AValue: TJsonObject);
    property Status: String read FStatus write FStatus;
    property Error: String read FError write FError;
    property Count: Integer read GetCount;
    property PerfmonCounterItems[AIndex: Integer]: TPerfmonCounterItem read GetListItem write SetListItem; default;
    property AsJson: String read ToJsonString write FromJsonString;
  end;

implementation

{$REGION 'TPerfmonCounterItem'}
constructor TPerfmonCounterItem.Create(APerfmonCounterItem: TPerfmonCounterItem = nil);
begin
  FHost := String.Empty;
  FCategory := String.Empty;
  FInstance := String.Empty;
  FName := String.Empty;
  FHelp := String.Empty;
  FValue := String.Empty;
  if nil <> APerfmonCounterItem then
  begin
    FHost := APerfmonCounterItem.Host;
    FCategory := APerfmonCounterItem.Category;
    FInstance := APerfmonCounterItem.Instance;
    FName := APerfmonCounterItem.Name;
    FHelp := APerfmonCounterItem.Help;
    FValue := APerfmonCounterItem.Value;
  end;
end;

function TPerfmonCounterItem.ToJsonString: String;
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

procedure TPerfmonCounterItem.FromJsonString(AValue: String);
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

function TPerfmonCounterItem.ToJsonObject: TJsonObject;
begin
  Result := TJSonObject.Create;
  Result.AddPair('host', FHost);
  Result.AddPair('category', FCategory);
  Result.AddPair('instance', FInstance);
  Result.AddPair('name', FName);
  Result.AddPair('help', FHelp);
  Result.AddPair('value', FValue);
end;

procedure TPerfmonCounterItem.FromJsonObject(AValue: TJsonObject);
begin
  if nil <> AValue.Values['host'] then
    FHost := AValue.Values['host'].Value;
  if nil <> AValue.Values['category'] then
    FCategory := AValue.Values['category'].Value;
  if nil <> AValue.Values['instance'] then
    FInstance := AValue.Values['instance'].Value;
  if nil <> AValue.Values['name'] then
    FName := AValue.Values['name'].Value;
  if nil <> AValue.Values['help'] then
    FHelp := AValue.Values['help'].Value;
  if nil <> AValue.Values['value'] then
    FValue := AValue.Values['value'].Value;
end;

class function TPerfmonCounterItem.CreateFromJsonString(AValue: String): TPerfmonCounterItem;
begin
  Result := TPerfmonCounterItem.Create;
  Result.AsJson := AValue;
end;
{$ENDREGION}

{$REGION 'TPerfmonCounterResult'}
constructor TPerfmonCounterResult.Create(APerfmonCounterResult: TPerfmonCounterResult = nil);
var
  i: Integer;
begin
  FStatus := String.Empty;
  FError := String.Empty;
  FList := TObjectList<TPerfmonCounterItem>.Create;
  if nil <> APerfmonCounterResult then
  begin
    FStatus := APerfmonCounterResult.Status;
    FError := APerfmonCounterResult.Error;
    for i := 0 to (APerfmonCounterResult.Count - 1) do
      FList.Add( TPerfmonCounterItem.Create(APerfmonCounterResult[i]) );
  end;
end;

destructor TPerfmonCounterResult.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TPerfmonCounterResult.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPerfmonCounterResult.GetListItem(AIndex: Integer): TPerfmonCounterItem;
begin
  Result := FList[AIndex];
end;

procedure TPerfmonCounterResult.SetListItem(AIndex: Integer; AValue: TPerfmonCounterItem);
begin
  FList[AIndex] := AValue;
end;

function TPerfmonCounterResult.ToJsonString: String;
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

procedure TPerfmonCounterResult.FromJsonString(AValue: String);
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

function TPerfmonCounterResult.ToJsonObject: TJsonObject;
var
  LItems: TJsonArray;
  i: Integer;
begin
  Result := TJSonObject.Create;
  Result.AddPair('status', FStatus);
  Result.AddPair('error', FError);
  LItems := TJsonArray.Create;
  for i := 0 to (FList.Count - 1) do
    LItems.AddElement(FList[i].ToJsonObject);
  Result.AddPair('items', LItems);
end;

procedure TPerfmonCounterResult.FromJsonObject(AValue: TJsonObject);
var
  LItems: TJsonArray;
  LValue: TJsonValue;
  LEnumerator: TJSONArrayEnumerator;
begin
  if nil <> AValue.Values['status'] then
    FStatus := AValue.Values['status'].Value;
  if nil <> AValue.Values['error'] then
    FError := AValue.Values['error'].Value;
  if nil <> AValue.Values['items'] then
  begin
    FList.Clear;
    LItems := AValue.Values['items'] As TJsonArray;
    for LValue in LItems do
       FList.Add(TPerfmonCounterItem.CreateFromJsonString( LValue.ToJSON ));
  end;

end;

{$ENDREGION}

end.
