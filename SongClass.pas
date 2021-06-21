unit SongClass;

interface

uses System.Classes, System.SysUtils, System.DateUtils;

const
  UNKNOWN_ARTIST = 'Inconnu';
  UNKNOWN_TITLE = 'Sans titre';

type

  TID3Rec = packed record
    Tag : Array[1..3] of char;         { If tag exists this must be 'TAG' }
    Title : Array[1..30] of char;      { Title data (PChar) }
    Artist : Array[1..30] of char;     { Artist data (PChar) }
    Album : Array[1..30] of char;      { Album data (PChar) }
    Year : Array[1..4] of char;        { Date data }
    Comment : Array[1..30] of char;    { Comment data (PChar) }
    Genre : Byte;                      { Genre data }
  end;

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
    procedure ReadID3Tag(AFilename: string);
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

  if (AFilename<>'') then
  begin
    ReadID3Tag(AFilename);
  end;

end;

procedure TSong.ReadID3Tag(AFilename: string);
begin
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
    dsWaiting: Result := 'En attente';
    dsInProgress: Result := 'En cours';
    dsTerminated: Result := 'Téléchargé';
    dsError: Result := 'Erreur';
  end;
end;

end.
