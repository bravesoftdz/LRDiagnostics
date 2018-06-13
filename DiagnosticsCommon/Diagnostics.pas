unit Diagnostics;

interface

uses
  System.SysUtils, System.IOUtils, System.Classes;

type
  TDiagnostics = class
  public
    class function GetComponnets: TStrings;
  end;

implementation

class function TDiagnostics.GetComponnets: TStrings;
begin
  Result := TStringList.Create;
  Result.Add('DataIndexer');
  Result.Add('SystemMonitor');
  Result.Add('DataProcessor');
  Result.Add('AIEngine');
  Result.Add('AIEngineCacheDrilldown');
  Result.Add('ARM');
  Result.Add('JobManager');
  Result.Add('Authentication');
  Result.Add('Common');
  Result.Add('WebConsole');
end;

end.
