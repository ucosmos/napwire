program NapWire;

uses
  Vcl.Forms,
  Main in 'Main.pas' {FormMain},
  Parser in 'Parser.pas',
  SongClass in 'SongClass.pas',
  z1fm.provider in 'z1fm.provider.pas',
  DownloaderModule in 'DownloaderModule.pas' {Downloader: TDataModule},
  Player in 'Player.pas',
  Vcl.Themes,
  Vcl.Styles,
  magicplaylist.provider in 'magicplaylist.provider.pas',
  Configuration in 'Configuration.pas',
  Logger in 'Logger.pas',
  MP3Info in 'MP3Info.pas',
  ID3Tag in 'ID3Tag.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Glossy');
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TDownloader, Downloader);
  Application.Run;
end.
