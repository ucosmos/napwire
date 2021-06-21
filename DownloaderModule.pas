unit DownloaderModule;

interface

uses
  System.SysUtils, System.Classes, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP,
  NetEncoding,
  Forms, IdCookieManager, SongClass;

type
  TDownloadProgressCallback = procedure(const Song: TSong) of object;
  TDownloadFinishedCallback = procedure(const Song: TSong) of object;

  TDownloader = class(TDataModule)
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    IdCookieManager1: TIdCookieManager;
    procedure DataModuleCreate(Sender: TObject);
    procedure IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    function GetHTML(AnUrl: string): string;
    class function CreateSongFilename(ASong: TSong): string;
  end;

  TDownloadThread = class(TThread)
  private
    FSong: TSong;
    FDownloadSize: Int64;
    FOutputDir: string;
    FCookieManager: TIdCookieManager;
    FSSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    FProgressCallback: TDownloadProgressCallback;
    FFinishedCallback: TDownloadFinishedCallback;
    procedure GetFile(AURL: string; Stream: TStream);
    procedure OnWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure OnWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
  public
    constructor Create(
      ASong: TSong;
      AOutputDir: string;
      ACookieManager: TIdCookieManager;
      ASSLIoHandler: TIdSSLIOHandlerSocketOpenSSL;
      AProgressCallback: TDownloadProgressCallback;
      AFinishedCallback: TDownloadFinishedCallback);
  protected
    procedure Execute; override;
  end;

var
  Downloader: TDownloader;

implementation

uses Logger;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function RemoveSpecialChars(const AStr : string): string;
const
  InvalidChars : TSysCharSet = ['\','/',':','*','?','"','<','>','|'];
var
  I : Cardinal;
begin
  Result:='';
  for I:=1 to Length(AStr) do
    if not CharInSet(AStr[I], InvalidChars) then
      Result := Result + AStr[I];
end;

class function TDownloader.CreateSongFilename(ASong: TSong): string;
begin
  Result := RemoveSpecialChars(Format('%s - %s.mp3', [ASong.Artist.Name, ASong.Title]));
end;

procedure TDownloader.DataModuleCreate(Sender: TObject);
begin
  IdHTTP1.AllowCookies := True;
  IdHTTP1.CookieManager := IdCookieManager1;
  IdHTTP1.HandleRedirects := True;
  IdHTTP1.Request.CharSet := 'utf-8';
  IdHTTP1.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.12) Gecko/20050915 Firefox/1.0.7';
end;

function TDownloader.GetHTML(AnUrl: string): string;
begin
  AppLogger.Log(Self, 'GetHTML('+AnUrl+')');
  Result := TNetEncoding.HTML.Decode(IdHttp1.Get(AnUrl));
end;

procedure TDownloader.IdHTTP1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin

end;

{ TDownloadThread }

constructor TDownloadThread.Create(
  ASong: TSong;
  AOutputDir: string;
  ACookieManager: TIdCookieManager;
  ASSLIoHandler: TIdSSLIOHandlerSocketOpenSSL;
  AProgressCallback: TDownloadProgressCallback;
  AFinishedCallback: TDownloadFinishedCallback);
begin
  inherited Create(True);

  AppLogger.Log(Self, 'New DownloadThread');

  FSong := ASong;
  FOutputDir := AOutputDir;
  FCookieManager := ACookieManager;
  FSSLIoHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FCookieManager.Owner);
  FProgressCallback := AProgressCallback;
  FFinishedCallback := AFinishedCallback;

  FSong.DownloadStatus := dsInProgress;

  Resume;
end;

procedure TDownloadThread.OnWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if AWorkMode <> wmRead then Exit;

  if FDownloadSize>0 then
  begin
    FSong.DownloadProgress := Trunc((AWorkCount / FDownloadSize)*100);
    FProgressCallback(FSong);
  end;
end;

procedure TDownloadThread.OnWorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  if AWorkMode <> wmRead then Exit;

  FDownloadSize := AWorkCountMax;
end;

procedure TDownloadThread.Execute;
var
  OutputFilename: string;
  FileStream: TFileStream;
begin
  FSong.Filename := TDownloader.CreateSongFilename(FSong);
  OutputFilename := FOutputDir + FSong.Filename;
  FileStream := TFileStream.Create(OutputFilename, fmCreate);
  try
    GetFile(FSong.Url, FileStream);
    FSong.DownloadStatus := dsTerminated;
    FSong.Filename := OutputFilename;
  finally
    FileStream.Free;
    FFinishedCallback(FSong);
  end;
end;

procedure TDownloadThread.GetFile(AURL: string; Stream: TStream);
var
  Http: TIdHttp;
begin
  AppLogger.Log(Self, 'GetFile('+AUrl+')');

  Http := TIdHttp.Create(nil);
  try
    Http.AllowCookies := True;
    Http.CookieManager := FCookieManager;
    Http.IOHandler := FSSLIOHandler;
    Http.HandleRedirects := True;
    Http.OnWork := OnWork;
    Http.OnWorkBegin := OnWorkBegin;
    Http.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.12) Gecko/20050915 Firefox/1.0.7';
    try
      Http.Get(AUrl, Stream);
    except
    end;
  finally
    Http.Free;
  end;
end;

end.
