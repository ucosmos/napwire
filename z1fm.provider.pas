unit z1fm.provider;

interface

uses SongClass, DownloaderModule, NetEncoding,
     System.Classes, StrUtils, System.SysUtils, System.IOUtils;

const
  BASE_URL = 'https://z1.fm';

type
  z1fmProvider = class
  private
    FInitialized: Boolean;
    FHTMLContent: string;
    FSearchPageIndex: Integer;
    FSearchURL: string;
    FMoreSplitter: Char;
    function CleanString(AString: string): string;
    function Initialize: Boolean;
    procedure ParseHTML(AValue: string; var ASongList: TSongList);
    property SearchURL: string read FSearchURL write FSearchURL;
  public
    constructor Create;
    function LoadLastSearch: TSongList;
    procedure SaveLastSearch;
    function SearchSongs(AKeywords: string): TSongList;
    function SearchMore: TSongList;
    procedure UpdateSong(var ASong: TSong);
    function SearchArtist(AUrl: string): TSongList;
    procedure DownloadSong(ASong: TSong; AOutputPath: string; AProgressCallback: TDownloadProgressCallback;
      AFinishedCallback: TDownloadFinishedCallback);
  end;

implementation

uses Logger, Parser;

{ z1fmProvider }

procedure z1fmProvider.DownloadSong(ASong: TSong; AOutputPath: string; AProgressCallback: TDownloadProgressCallback;
      AFinishedCallback: TDownloadFinishedCallback);
begin
  AppLogger.Log(Self, 'DownloadSong('+ASong.Title+')');

  if not FInitialized then
    Initialize;

  TDownloadThread.Create(ASong, AOutputPath, Downloader.IdCookieManager1, Downloader.IdSSLIOHandlerSocketOpenSSL1, AProgressCallback, AFinishedCallback);
end;

function z1fmProvider.CleanString(AString: string): string;
begin
  Result := ReplaceText(AString, '"', '');
end;

constructor z1fmProvider.Create;
begin
  FInitialized := False;
  FSearchPageIndex := -1;
end;

function z1fmProvider.Initialize: Boolean;
begin
  try
    Downloader.GetHTML(BASE_URL);
    FInitialized := True;
  except
  end;
  Result := FInitialized;
end;

function z1fmProvider.LoadLastSearch: TSongList;
begin
  AppLogger.Log(Self, 'LoadLastSearch');

  Result := TSongList.Create;
  if FileExists('z1fm.html') then
  begin
    FHTMLContent := TFile.ReadAllText('z1fm.html',TEncoding.UTF8);
    ParseHTML(FHTMLContent, Result);
  end;
end;

procedure z1fmProvider.ParseHTML(AValue: string; var ASongList: TSongList);
var
  DomTree: TDomTree;
  SongNode,
  DomTreeNode: TDomTreeNode;
  SongsNodeList,
  TempNodeList: TNodeList;

  ValueList: TStringList;
  Song: TSong;

begin
  AppLogger.Log(Self, 'ParseHTML');
  ASongList.Clear;

  SongsNodeList := TNodeList.Create;
  TempNodeList := TNodeList.Create;
  ValueList := TStringList.Create;
  DomTree := TDomTree.Create;
  DomTreeNode := DomTree.RootNode;

  if DomTreeNode.RunParse(AValue) then
  begin
    DomTreeNode.FindXPath('//div[@class="song song-xl"]', SongsNodeList, ValueList);

    for SongNode in SongsNodeList do
    begin
      Song := TSong.Create;
      Song.Filename := '';

      TempNodeList.Clear;
      SongNode.FindXPath('//ul[@class="song-menu"]/li[1]/span[1]', TempNodeList, ValueList);
      if TempNodeList.Count>0 then
      begin
        Song.Url := BASE_URL + CleanString(TempNodeList[0].Attributes['data-url']);
      end;

      TempNodeList.Clear;
      SongNode.FindXPath('//div[@class="song-artist"]/a[1]/span[1]/text()[1]', TempNodeList, ValueList);
      if TempNodeList.Count>0 then
      begin
        Song.Artist.Name := TempNodeList[0].Text;
      end;

      TempNodeList.Clear;
      SongNode.FindXPath('//div[@class="song-artist"]/a[1]', TempNodeList, ValueList);
      if TempNodeList.Count>0 then
      begin
        Song.Artist.Id := CleanString(TempNodeList[0].Attributes['href']);
      end;

      TempNodeList.Clear;
      SongNode.FindXPath('//div[@class="song-name"]/a[1]/span[1]/text()[1]', TempNodeList, ValueList);
      if TempNodeList.Count>0 then
      begin
        Song.Title := TempNodeList[0].Text;
      end;

      TempNodeList.Clear;
      SongNode.FindXPath('//span[@class="song-time"]/text()[1]', TempNodeList, ValueList);
      if TempNodeList.Count>0 then
      begin
        Song.Duration.AsString := TempNodeList[0].Text;
      end;

      ASongList.Add(Song);
    end;
  end;
end;

procedure z1fmProvider.SaveLastSearch;
begin
  AppLogger.Log(Self, 'SaveLastSearch');

  TFile.WriteAllText('z1fm.html', FHTMLContent);
end;

function z1fmProvider.SearchArtist(AUrl: string): TSongList;
var
  HTMLContent: string;

begin
  AppLogger.Log(Self, 'SearchArtist');

  Result := TSongList.Create;

  if not FInitialized then
  begin
    if not Initialize then Exit;
  end;
  FSearchURL := BASE_URL+AUrl;
  FSearchPageIndex := 1;
  FMoreSplitter := '?';
  FHTMLContent := Downloader.GetHTML(FSearchURL);

  ParseHTML(FHTMLContent, Result);
end;

function z1fmProvider.SearchMore: TSongList;
var
  HTMLContent: string;
begin
  AppLogger.Log(Self, 'SearchMore');

  Result := TSongList.Create;

  if FSearchPageIndex=-1 then Exit;

  if not FInitialized then
  begin
    if not Initialize then Exit;
  end;
  Inc(FSearchPageIndex);
  HTMLContent := Downloader.GetHTML(FSearchURL+Format('%spage=%d',[FMoreSplitter, FSearchPageIndex]));
  ParseHTML(HTMLContent, Result);
end;

function z1fmProvider.SearchSongs(AKeywords: string): TSongList;
var
  EncodedKeywords: string;

begin
  AppLogger.Log(Self, 'SearchSongs('+AKeywords+')');

  Result := TSongList.Create;

  if not FInitialized then
  begin
    if not Initialize then Exit;
  end;
  EncodedKeywords := TNetEncoding.URL.Encode(AKeywords);
  FSearchURL := BASE_URL+'/mp3/search?keywords='+EncodedKeywords;
  FSearchPageIndex := 1;
  FMoreSplitter := '&';
  FHTMLContent := Downloader.GetHTML(FSearchURL);

  ParseHTML(FHTMLContent, Result);
end;

procedure z1fmProvider.UpdateSong(var ASong: TSong);
var
  SongList: TSongList;
  EncodedKeywords: string;
  HTMLContent: string;
begin
  AppLogger.Log(Self, 'UpdateSong('+ASong.Title+')');

  if not FInitialized then
  begin
    if not Initialize then Exit;
  end;
  EncodedKeywords := TNetEncoding.URL.Encode(ASong.Artist.Name+','+ASong.Title);
  HTMLContent := Downloader.GetHTML(BASE_URL+'/mp3/search?keywords='+EncodedKeywords);
  SongList := TSongList.Create;
  ParseHTML(HTMLContent, SongList);
  if SongList.Count>0 then
  begin
    ASong.Url := SongList[0].Url;
    ASong.Duration.AsSeconds := SongList[0].Duration.AsSeconds;
  end;
end;

end.
