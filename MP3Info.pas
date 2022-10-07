{
  Description:
  Component MP3Info extracts/saves any ID3 Tag into/from it's
  properties from/to MP3 file.
  Keywords: MP3 ID3 TAG INFO
  Author: Rok Krulec

  Description of Variables, Properties, Methods and Events:
  Genres: TStrings;                         - List of Genres
  constructor Create(AOwner: TComponent);   - Creates an instance
  destructor Destroy; override;             - Destroys an instance
  method Save;                              - Saves ID3 Tag to file
  method RemoveID3;                         - Removes ID3 Tag form file
  property Filename: TFilename;             - Filename of MP3 file, when changed it opens a new MP3 file
  property Artist: String;                  - Artist   (30 Chars)
  property Title: String;                   - Title    (30 Chars)
  property Album: String;                   - Album    (30 Chars)
  property Year: String;                    - Year     ( 4 chars)
  property Comment: String;                 - Comment  (30 Chars)
  property Genre: String;                   - Genre               [Read Only]
  Property GenreID: Byte;                   - Genre ID
  property Valid: Boolean;                  - Is ID3 valid        [Read Only]
  property Saved: Boolean;                  - Save success        [Read Only]
  property Error: String;                   - Error Message       [Read Only]
  property onChangeFile:TNotifyEvent;       - Triggers when other file is openned
  property onChange:TNotifyEvent;           - Triggers when one of propertis is changed (Artist, Title, Album, Year, Comment, GenreID)
  property onError:TNotifyEvent;            - Triggers when errors ocure (Wrong filename, Frong fileformat)
}
unit MP3Info;

interface

uses
  SysUtils, Classes;

const
  TAGLEN = 127;

type
  TMP3Info = class(TComponent)
  private
    { Private declarations }
    vFilename: TFilename;
    vMP3Tag, vArtist, vTitle, vAlbum, vComment, vYear, vGenre, vError: string;
    vGenreID: Byte;
    vValid: Boolean;
    vSaved: Boolean;
    vChangeFileEvent, vChangeEvent, vErrorEvent: TNotifyEvent;
    procedure SetFilename(Filename: TFilename);
    procedure SetArtist(Artist: string);
    procedure SetTitle(Title: string);
    procedure SetAlbum(Album: string);
    procedure SetYear(Year: string);
    procedure SetComment(Comment: string);
    procedure SetGenreID(ID: Byte);
    procedure Open;
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    Genres: TStrings;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Save;
    procedure RemoveID3;
    property Filename: TFilename read vFilename write SetFilename;
    property Artist: string read vArtist write SetArtist;
    property Title: string read vTitle write SetTitle;
    property Album: string read vAlbum write SetAlbum;
    property Year: string read vYear write SetYear;
    property Comment: string read vComment write SetComment;
    property Genre: string read vGenre;
    property GenreID: Byte read vGenreID write SetGenreID;
    property Valid: Boolean read vValid;
    property Saved: Boolean read vSaved;
    property Error: string read vError;
    property onChangeFile: TNotifyEvent read vChangeFileEvent
      write vChangeFileEvent;
    property onChange: TNotifyEvent read vChangeEvent write vChangeEvent;
    property onError: TNotifyEvent read vErrorEvent write vErrorEvent;
  end;

procedure Register;

implementation

constructor TMP3Info.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Genres := TStringList.Create;
  vGenreID := 12;
  vValid := false;
  vSaved := false;
  { Fill the Genres String List so one can use it combo boxes e.t.c. Example: ComboBox.Items.Assign(MP3Info.Genres) }
  Genres.CommaText :=
    '"Blues","Classic Rock","Country","Dance","Disco","Funk","Grunge","Hip-Hop","Jazz","Metal","New Age","Oldies",'
    + '"Other","Pop","R&B","Rap","Reggae","Rock","Techno","Industrial","Alternative","Ska","Death Metal","Pranks",'
    + '"Soundtrack","Euro-Techno","Ambient","Trip-Hop","Vocal","Jazz+Funk","Fusion","Trance","Classical","Instrumental",'
    + '"Acid","House","Game","Sound Clip","Gospel","Noise","AlternRock","Bass","Soul","Punk","Space","Meditative",'
    + '"Instrumental Pop","Instrumental Rock","Ethnic","Gothic","Darkwave","Techno-Industrial","Electronic","Pop-Folk",'
    + '"Eurodance","Dream","Southern Rock","Comedy","Cult","Gangsta","Top 40","Christian Rap","Pop/Funk","Jungle",'
    + '"Native American","Cabaret","New Wave","Psychedelic","Rave","Showtunes","Trailer","Lo-Fi","Tribal","Acid Punk",'
    + '"Acid Jazz","Polka","Retro","Musical","Rock & Roll","Hard Rock","Folk","Folk/Rock","National Folk","Swing","Bebob",'
    + '"Latin","Revival","Celtic","Bluegrass","Avantgarde","Gothic Rock","Progressive Rock","Psychedelic Rock","Symphonic Rock",'
    + '"Slow Rock","Big Band","Chorus","Easy Listening","Acoustic","Humour","Speech","Chanson","Opera","Chamber Music","Sonata",'
    + '"Symphony","Booty Bass","Primus","Porn Groove","Satire","Slow Jam","Club","Tango","Samba","Folklore"'
end;

destructor TMP3Info.Destroy;
begin
  inherited Destroy;
end;

{ Procedure to run when Filename property is changed }
procedure TMP3Info.SetFilename(Filename: TFilename);
begin
  vFilename := Filename;
  Open;
end;

procedure TMP3Info.SetArtist(Artist: string);
begin
  vArtist := Copy(Artist, 0, 30);
  if Assigned(onChange) then
    onChange(Self);
end;

procedure TMP3Info.SetTitle(Title: string);
begin
  vTitle := Copy(Title, 0, 30);
  if Assigned(onChange) then
    onChange(Self);
end;

procedure TMP3Info.SetAlbum(Album: string);
begin
  vAlbum := Copy(Album, 0, 30);
  if Assigned(onChange) then
    onChange(Self);
end;

procedure TMP3Info.SetYear(Year: string);
begin
  vYear := Copy(Year, 0, 4);
  if Assigned(onChange) then
    onChange(Self);
end;

procedure TMP3Info.SetComment(Comment: string);
begin
  vComment := Copy(Comment, 0, 30);
  if Assigned(onChange) then
    onChange(Self);
end;

procedure TMP3Info.SetGenreID(ID: Byte);
begin
  if ((ID > 255) or (ID > Genres.Count - 1)) then
    ID := 12;
  vGenreID := ID;
  vGenre := Genres[vGenreID]; // this line is important because after changing
  // vGenreID whitout it vGenre will be the same like before !!!
  if Assigned(onChange) then
    onChange(Self);
end;

{ Opens file with Filename property, reads ID3 Tag and sets properties }
procedure TMP3Info.Open;
{ Strips empty spaces at the end of word }
  function Strip(WordToStrip: string; CharToStripAway: Char): string;
  var
    i: Integer;
  begin
    for i := length(WordToStrip) downto 1 do
    begin
      if WordToStrip[i] <> ' ' then
      begin
        Strip := Copy(WordToStrip, 0, i);
        exit;
      end;
    end;
    Strip := '';
  end;

var
  dat: file of Char;
  id3: array [0 .. TAGLEN] of Char;

begin
  vSaved := False;
  vValid := True;
  if FileExists(vFilename) then
  begin
    assignfile(dat, vFilename);
    reset(dat);
    seek(dat, FileSize(dat) - 128);
    blockread(dat, id3, 128);
    closefile(dat);
    vMP3Tag := Copy(id3, 1, 3);
    if vMP3Tag = 'TAG' then
    begin
      vTitle := Strip(Copy(id3, 4, 30), ' ');
      vArtist := Strip(Copy(id3, 34, 30), ' ');
      vAlbum := Strip(Copy(id3, 64, 30), ' ');
      vComment := Strip(Copy(id3, 98, 30), ' ');
      vYear := Strip(Copy(id3, 94, 4), ' ');
      vGenreID := ord(id3[127]);
      if vGenreID > Genres.Count then
        vGenreID := 12;
      vGenre := Genres[vGenreID];
      { Trigger OnChange Event }
      if Assigned(onChangeFile) then
        onChangeFile(Self);
    end
    else
    begin
      vValid := false;
      vTitle := '';
      vArtist := '';
      vAlbum := '';
      vComment := '';
      vYear := '';
      vGenreID := 12;
      vError := 'Wrong file format or no ID3 Tag !';
      if Assigned(onError) then
        onError(Self);
    end;
  end
  else
  begin
    vValid := false;
    vError := 'File doesn`t exist !';
    if Assigned(onError) then
      onError(Self);
  end;
end;

{ Removes the ID3-tag from currently open file }
procedure TMP3Info.RemoveID3;
var
  dat: file of Char;
begin
  // does the file exist ?
  if not FileExists(vFilename) then
  begin
    vError := 'File doesn`t exist !';
    if Assigned(onError) then
      onError(Self);
    exit;
  end;
  // is the file already untagged ?
  if (vValid = false) then
  begin
    vError := 'File is already untagged !';
    if Assigned(onError) then
      onError(Self);
    exit;
  end;
  // remove readonly-attribute
  if (FileGetAttr(vFilename) and faReadOnly > 0) then
    FileSetAttr(vFilename, FileGetAttr(vFilename) - faReadOnly);
  // if readonly attr. already exists it cannot be removed to cut ID3 Tag
  if (FileGetAttr(vFilename) and faReadOnly > 0) then
  begin
    vError := 'Cant write ID3 tag information !';
    if Assigned(onError) then
      onError(Self);
    exit;
  end;
  // open current mp3 file if ID3 tag exists
  if (vValid = True) then
  begin
    { I- }
    assignfile(dat, vFilename);
    reset(dat);
    { I+ }
    if IOResult <> 0 then
    begin
      vError := 'Could not open file !';
      if Assigned(onError) then
        onError(Self);
      exit;
    end;
    seek(dat, FileSize(dat) - 128);
    truncate(dat); // cut all 128 bytes of file
    closefile(dat);
    vValid := false; // set vValid to false because the tag has been removed
  end;
end;

{ Saves ID3 Tag to currently opened file }
procedure TMP3Info.Save;
{ Empties 128 character array }{ Don't tell me that there is a function for this in Pascal }
  procedure EmptyArray(var Destination: array of Char);
  var
    i: Integer;
  begin
    for i := 0 to TAGLEN do
    begin
      Destination[i] := ' ';
    end;
  end;
{ Insert a substring into character array at index position of array }
  procedure InsertToArray(Source: string; var Destination: array of Char;
    Index: Integer);
  var
    i: Integer;
  begin
    for i := 0 to length(Source) - 1 do
    begin
      Destination[Index + i] := Source[i + 1];
    end;
  end;

var
  dat: file of Char;
  id3: array [0 .. TAGLEN] of Char;
begin
  vSaved := True;
  // does the filename exist ?
  if FileExists(vFilename) then
  begin
    // fill 128 bytes long array with ID3 Tag information
    EmptyArray(id3);
    InsertToArray('TAG', id3, 0);
    InsertToArray(vTitle, id3, 3);
    InsertToArray(vArtist, id3, 33);
    InsertToArray(vAlbum, id3, 63);
    InsertToArray(vComment, id3, 97);
    InsertToArray(vYear, id3, 93);
    id3[127] := chr(vGenreID);
    // remove readonly-attribute
    if (FileGetAttr(vFilename) and faReadOnly > 0) then
      FileSetAttr(vFilename, FileGetAttr(vFilename) - faReadOnly);
    // if readonly attr. already exists it cannot be removed to write ID3
    if (FileGetAttr(vFilename) and faReadOnly > 0) then
    begin
      vSaved := false;
      vError := 'Cant write ID3 tag information !';
      if Assigned(onError) then
        onError(Self);
      exit;
    end;
    // if valid then overwrite existing ID3 Tag, else append to file
    if (vValid = True) then
    begin
      { I- }
      assignfile(dat, vFilename);
      reset(dat);
      seek(dat, FileSize(dat) - 128);
      blockwrite(dat, id3, 128);
      closefile(dat);
      { I+ }
      if IOResult <> 0 then
        vSaved := false;
    end
    else
    begin
      { I- }
      assignfile(dat, vFilename);
      reset(dat);
      seek(dat, FileSize(dat));
      blockwrite(dat, id3, 128);
      closefile(dat);
      { I+ }
      if IOResult <> 0 then
        vSaved := false;
    end
  end
  else
  begin
    vValid := false;
    vSaved := false;
    vError := 'File doesn`t exist or is not valid !';
    if Assigned(onError) then
      onError(Self);
  end;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TMP3Info]);
end;

end.

{
   The ID3 Information is stored in the last 128 bytes of an MP3 file.
   The ID3 has the following fields, and the offsets given here, are from 0-127
   Field       Length            offsets
   -------------------------------------
   Tag           3                0-2
   Songname     30                3-32
   Artist       30                33-62
   Album        30                63-92
   Year          4                93-96
   Comment      30                97-126
   Genre         1                127
}
