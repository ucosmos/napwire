unit Player;

interface

uses bass, Winapi.Windows, Vcl.Dialogs, System.Variants, System.Classes, System.SysUtils,
Messages;

const
  WM_INFO_UPDATE = WM_USER + 101;


type

  TPlayer = class
  private
    FStream: HSTREAM;
    FAppHandle: HWND;
    procedure Error(AMsg: string);
  public
    constructor Create(AHandle: HWND);
    destructor Destroy;

    procedure OpenFile(AFilename: string);
    procedure OpenURL(AnURL: string);
    procedure Pause;
    procedure Resume;

    function Length: Int64;
    function Position: Int64;
    function Progress: DWORD;
  end;

implementation

{ TPlayer }

procedure TPlayer.Error(AMsg: string);
begin
  MessageBox(FAppHandle, PChar(AMsg + #13#10 + '(error code: ' + IntToStr(BASS_ErrorGetCode) +
    ')'), nil, 0);
end;

constructor TPlayer.Create(AHandle: HWND);
begin
  // check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
	begin
		MessageBox(0,'An incorrect version of BASS.DLL was loaded',nil,MB_ICONERROR);
		Halt;
	end;

	// Initialize audio - default device, 44100hz, stereo, 16 bits
	if not BASS_Init(-1, 44100, 0, AHandle, nil) then
		MessageBox(0,'Error initializing audio!',nil,MB_ICONERROR);

  BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1); // // enable playlist processing
  BASS_SetConfig(BASS_CONFIG_NET_PREBUF, 0); // minimize automatic pre-buffering, so we can do it (and display it) instead
end;

destructor TPlayer.Destroy;
begin
  BASS_Free();
end;

procedure TPlayer.Pause;
begin
  if FStream=0 then Exit;

  BASS_ChannelStop(FStream);
end;

procedure TPlayer.OpenFile(AFilename: string);
begin
  FStream := BASS_StreamCreateFile(False, PChar(AFilename), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
end;

function TPlayer.Length: Int64;
begin
  Result := BASS_StreamGetFilePosition(FStream, BASS_FILEPOS_END);
  //Result := BASS_ChannelGetLength(FStream, BASS_POS_BYTE);
end;

procedure TPlayer.OpenURL(AnURL: string);
begin
  BASS_StreamFree(FStream); // close old stream
  //Progress := 0;
  SendMessage(FAppHandle, WM_INFO_UPDATE, 0, 0); // reset the Labels and trying connecting

  FStream := BASS_StreamCreateURL(PChar(AnURL), 0, BASS_STREAM_BLOCK or BASS_UNICODE, nil, 0);

  Resume;
end;

function TPlayer.Position: Int64;
begin
  Result := Bass_ChannelGetPosition(FStream, BASS_POS_BYTE);
end;

function TPlayer.Progress: DWORD;
begin
  Result := BASS_StreamGetFilePosition(FStream, BASS_FILEPOS_CURRENT) div Length * 100;
end;

procedure TPlayer.Resume;
begin
	if FStream = 0 then
  begin
		MessageBox(0,'Error creating stream!', nil, MB_ICONERROR);
    Exit;
  end;

  if not BASS_ChannelPlay(FStream, False) then
	  MessageBox(0,'Error playing stream!',nil,MB_ICONERROR);
end;

end.
