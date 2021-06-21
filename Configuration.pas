unit Configuration;

interface

type
  TConfiguration = class
  private
    FConcurentDownloads: Integer;
    FDownloadDirectory: string;
    FPlayerLocation: string;
  public
    constructor Create;
    procedure Load;
    procedure Save;
    property ConcurentDownloads: Integer read FConcurentDownloads write FConcurentDownloads;
    property DownloadDirectory: string read FDownloadDirectory write FDownloadDirectory;
    property PlayerLocation: string read FPlayerLocation write FPlayerLocation;
  end;

implementation

{ TConfiguration }

uses IniFiles, Forms, SysUtils;

constructor TConfiguration.Create;
begin
  FConcurentDownloads := 2;
  Load;
end;

procedure TConfiguration.Load;
begin
  with TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini')) do
  begin
    FConcurentDownloads := ReadInteger('Download','ConcurentDownloads',2);
    FDownloadDirectory := ReadString('Download','Directory',ExtractFilePath(Application.ExeName)+'downloads\');
    FPlayerLocation := ReadString('Player','Location','');
  end;
end;

procedure TConfiguration.Save;
begin
  with TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini')) do
  begin
    WriteInteger('Download','ConcurentDownloads',FConcurentDownloads);
    WriteString('Download','Directory',FDownloadDirectory);
    WriteString('Player','Location',FPlayerLocation);
  end;
end;

end.
