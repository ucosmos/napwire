unit magicplaylist.provider;

interface

uses SongClass, DownloaderModule, NetEncoding, System.JSON;

const
  BASE_URL = 'https://api.magicplaylist.co';

type
  MagicPlaylistProvider = class
  private
    FInitialized: Boolean;
    function Initialize: Boolean;
    function GetSongId(AKeywords: string): string;
  public
    constructor Create;
    function GetPlaylist(AKeywords: string): TSongList;
  end;

implementation

{ MagicPlaylistProvider }

constructor MagicPlaylistProvider.Create;
begin
  FInitialized := False;
end;

function MagicPlaylistProvider.Initialize: Boolean;
begin
  try
    //Downloader.GetHTML(BASE_URL);
    FInitialized := True;
  except
  end;
  Result := FInitialized
end;

function MagicPlaylistProvider.GetPlaylist(AKeywords: string): TSongList;
var
  ReferenceSongId: string;
  JSonData: string;
  JSonPlaylistArray,
  JsonArtistsArray : TJSONArray;
  JSonValue  : TJSonValue;
  JSonPlaylistValue,
  JSonArtistValue: TJSonValue;
  Song: TSong;
begin
  Result := TSongList.Create;

  if not FInitialized then
  begin
    if not Initialize then Exit;
  end;

  ReferenceSongId := GetSongId(AKeywords);
  if ReferenceSongId<>'' then
  begin
    JSonData := Downloader.GetHTML(BASE_URL+'/mp/create/'+ReferenceSongId+'?country=FR&length=1');
    JSonValue := TJSonObject.ParseJSONValue(JSonData) as TJSonObject;
    JSonPlaylistArray := JSonValue.GetValue<TJSONArray>('data.playlist');
    for JSonPlaylistValue in JSonPlaylistArray do
    begin
      Song := TSong.Create;
      Song.Id := JSonPlaylistValue.GetValue<string>('id');
      Song.Title := JSonPlaylistValue.GetValue<string>('name');
      JsonArtistsArray := JSonPlaylistValue.GetValue<TJSONArray>('artists');
      if JsonArtistsArray.Count>0 then
      begin
        JSonArtistValue := JSonArtistsArray.Items[0];
        Song.Artist.Name := JSonArtistValue.GetValue<string>('name');
      end;

      Result.Add(Song);
    end;
  end;

end;

function MagicPlaylistProvider.GetSongId(AKeywords: string): string;
var
  EncodedKeywords: string;
  JSonData: string;
  JSonDataArray,
  JsonArtistArray : TJSONArray;
  JSonValue  : TJSonValue;
  ArrayElement: TJSonValue;

begin
  Result := '';

  EncodedKeywords := TNetEncoding.URL.Encode(AKeywords);
  JSonData := Downloader.GetHTML(BASE_URL+'/mp/search?txt='+EncodedKeywords);
  JSonValue := TJSonObject.ParseJSONValue(JSonData) as TJSonObject;
  JSonDataArray := JSonValue.GetValue<TJSONArray>('data');
  if JSonDataArray.Count>0 then
  begin
    ArrayElement := JSonDataArray.Items[0];
    //ArrayElement := JsonArtistArray.Items[0];
    if Assigned(ArrayElement) then
    begin
      Result := ArrayElement.GetValue<string>('id');
    end;

//    JsonArtistArray := JSonDataArray.Items[0].GetValue<TJSONArray>('artists');
//    if JsonArtistArray.Count>0 then
//    begin
//      ArrayElement := JsonArtistArray.Items[0];
//      if Assigned(ArrayElement) then
//      begin
//        Result := ArrayElement.GetValue<string>('id');
//      end;
//    end;
  end;
end;

end.
