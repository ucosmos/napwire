unit Logger;

interface

uses System.Messaging;

type

  TLogger = class
  private
    FMessageManager: TMessageManager;
  public
    constructor Create;
    procedure Log(ASender: TObject; AString: string);
    property MessageManager: TMessageManager read FMessageManager;
  end;

var
  AppLogger: TLogger;

implementation

{ TLogger }

constructor TLogger.Create;
begin
  FMessageManager := TMessageManager.Create;
end;

procedure TLogger.Log(ASender: TObject; AString: string);
var
  Msg: TMessage;
begin
  Msg := TMessage<UnicodeString>.Create(AString);
  FMessageManager.SendMessage(ASender, Msg, True);
end;

initialization
  AppLogger := TLogger.Create;

end.
