unit ID3Tag;

interface

uses System.Classes, System.SysUtils;

type

  TID3Tag = packed record               // 128 bytes
    TAGID: array[0..2] of AnsiChar;     //   3 bytes: Must contain TAG
    Title: array[0..29] of AnsiChar;    //  30 bytes: Song's title
    Artist: array[0..29] of AnsiChar;   //  30 bytes: Song's artist
    Album: array[0..29] of AnsiChar;    //  30 bytes: Song's album
    Year: array[0..3] of AnsiChar;      //   4 bytes: Publishing year
    Comment: array[0..29] of AnsiChar;  //  30 bytes: Comment
    Genre: Byte;                        //   1 byte:  Genere-ID
  end;

  function GetID3(AFilename: string): TID3Tag;

implementation

function GetID3(AFilename: string): TID3Tag;
var
  ID3Tag: TID3Tag;
  Mp3File: TFileStream;

begin
  Mp3File := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyNone); // fmOpenRead
  try
    Mp3File.Position := Mp3File.Size-128; // jump to id3-tag
    Mp3File.Read(ID3Tag, SizeOf(ID3Tag));
    Result := ID3Tag;
    (*
    showmessage(' Title: '+id3tag.title+#13+
                ' Artist: '+id3tag.artist+#13+
                ' Album: '+id3tag.album+#13+
                ' Year: '+id3tag.year+#13+
                ' Comment: '+id3tag.comment+#13+
                ' Genre-ID: '+inttostr(id3tag.genre)
                );
    *)
  finally
    Mp3File.Free;
  end;
end;


end.
