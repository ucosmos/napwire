unit SongClass;

interface

uses System.Classes, System.SysUtils, System.DateUtils, ID3Tag;

const
  UNKNOWN_ARTIST = 'Unknwon';
  UNKNOWN_TITLE = 'No title';

type

  TDownloadStatus = (dsUndefined, dsWaiting, dsInProgress, dsTerminated, dsError);

  TArtist = class
    Id: string;
    Name: string;
  public
    constructor Create;
  end;

  TSongDuration = class
  private
    FDuration: Integer;
    function GetAsString: string;
    procedure SetFromString(const Value: string);
  public
    constructor Create;
    property AsString: string read GetAsString write SetFromString;
    property AsSeconds: Integer read FDuration write FDuration;
  end;

  TSong = class
    Checked: Boolean;
    Id: string;
    Filename: string;
    Title: string;
    Artist: TArtist;
    Duration: TSongDuration;
    Url: string;
    DownloadStatus: TDownloadStatus;
    DownloadProgress: Integer;
  public
    constructor Create(AFilename: string='');
    destructor Destroy; override;
    procedure ReadID3Tag;
    function DownloadStatusText: string;
  end;

  TSongList = class(TList)
  private
    function Get(Index: Integer): TSong;
  public
    property Items[Index: Integer]: TSong read Get; default;
  end;

implementation

{ TSongList }

function TSongList.Get(Index: Integer): TSong;
begin
  Result := TSong(inherited Get(Index));
end;

{ TSong }

constructor TSong.Create(AFilename: string);
begin
  Checked := False;
  Id := '';
  Filename := '';
  Title := UNKNOWN_TITLE;
  Artist := TArtist.Create;
  Duration := TSongDuration.Create;
  DownloadStatus := dsUndefined;
end;

procedure TSong.ReadID3Tag;
var
  ID3Tag: TID3Tag;
begin
  if FileExists(Filename) then
  begin
    ID3Tag := GetID3(Filename);
    Artist.Name := ID3Tag.Artist;
    Title := ID3Tag.Title;
  end else
  begin
    Artist.Name := UNKNOWN_ARTIST;
    Title := UNKNOWN_TITLE;
  end;
end;

{ TArtist }

constructor TArtist.Create;
begin
  Id := '';
  Name := UNKNOWN_ARTIST;
end;

{ TSongDuration }

constructor TSongDuration.Create;
begin
  FDuration := -1;
end;

function TSongDuration.GetAsString: string;
begin
  if FDuration=-1 then
    Result := ''
  else
    Result := Format('%.2d:%.2d', [FDuration div 60, FDuration mod 60]);
end;

procedure TSongDuration.SetFromString(const Value: string);
var
  Time: TTime;
  TimeArray: TArray<string>;
  H,M,S: Word;
begin
  H := 0;
  M := 0;
  S := 0;
  TimeArray := Value.Split([':']);
  case Length(TimeArray) of
    3:
    begin
      H := StrToIntDef(TimeArray[0],0);
      M := StrToIntDef(TimeArray[1],0);
      S := StrToIntDef(TimeArray[2],0);
    end;
    2:
    begin
      H := StrToIntDef(TimeArray[0],0) div 60;
      M := StrToIntDef(TimeArray[0],0) mod 60;
      S := StrToIntDef(TimeArray[1],0);
    end;
    1:
    begin
      H := StrToIntDef(TimeArray[0],0) div 3600;
      M := StrToIntDef(TimeArray[0],0) div 60;
      S := StrToIntDef(TimeArray[0],0) mod 60;
    end;
  end;
  Time := EncodeTime(H,M,S,0);
  FDuration := SecondOfTheDay(Time);
end;

destructor TSong.Destroy;
begin
  Duration.Free;
  Artist.Free;
  inherited;
end;

function TSong.DownloadStatusText: string;
begin
  case DownloadStatus of
    dsUndefined: Result := '';
    dsWaiting: Result := 'Queued';
    dsInProgress: Result := 'Downloading';
    dsTerminated: Result := 'Done';
    dsError: Result := 'Error';
  end;
end;

end.
