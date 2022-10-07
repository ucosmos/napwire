unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, ShlObj,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, SongClass,
  StrUtils, Player, JvExControls, JvSlider, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, z1fm.provider, magicplaylist.provider,
  CommCtrl, Themes, JvComponentBase, JvDragDrop, Vcl.Menus,
  ShellApi, Vcl.Samples.Spin, Configuration, Vcl.Mask, JvExMask, JvToolEdit,
  Vcl.Buttons, System.Actions, Vcl.ActnList, Vcl.Imaging.pngimage,
  System.Messaging, SynEdit,
  System.Generics.Collections;

const
  SEARCHES_ARTIST_COLUMN_INDEX = 0;
  SEARCHES_TITLE_COLUMN_INDEX = 1;
  SEARCHES_DURATION_COLUMN_INDEX = 2;

  DOWNLOADS_ARTIST_COLUMN_INDEX = 0;
  DOWNLOADS_TITLE_COLUMN_INDEX = 1;
  DOWNLOADS_PROGRESS_COLUMN_INDEX = 2;

  OFASI_EDIT = $0001;
  OFASI_OPENDESKTOP = $0002;

type

  TColumnType = (ctText, ctCheck, ctProgress);

  TFormMain = class(TForm)
    PageControl: TPageControl;
    TabSheetSearch: TTabSheet;
    TabSheetDownloads: TTabSheet;
    ImageListPageControl: TImageList;
    ListViewSearchResults: TListView;
    ListViewDownloads: TListView;
    Panel2: TPanel;
    EditSearchKeywords: TEdit;
    ButtonSearch: TButton;
    ButtonSearchArtist: TButton;
    PopupMenuSearch: TPopupMenu;
    ImageListPlayer: TImageList;
    TabSheetSettings: TTabSheet;
    ImageListDownloads: TImageList;
    ButtonPlaylist: TButton;
    mnuSearchCheckAll: TMenuItem;
    SpinEditMaxDownloads: TSpinEdit;
    Label1: TLabel;
    EditDownloadDirectory: TJvDirectoryEdit;
    Label2: TLabel;
    ImageListButtons: TImageList;
    EditConfigPlayerLocation: TJvFilenameEdit;
    Label3: TLabel;
    mnuSearchUncheckAll: TMenuItem;
    PopupMenuDownloads: TPopupMenu;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    Retirer1: TMenuItem;
    PanelBottomBar: TPanel;
    PanelSongDetails: TPanel;
    ButtonPlay: TButton;
    ButtonAdd: TButton;
    Explorerledossier1: TMenuItem;
    PanelSearchMoreResults: TPanel;
    LabelSearchMoreResults: TLabel;
    Panel1: TPanel;
    LabelExploreDownloads: TLabel;
    MemoLog: TSynEdit;
    ButtonDownload: TButton;
    LabelSongArtist: TLabel;
    LabelSongTitle: TLabel;
    LabelSongURL: TLabel;
    PanelBottomBarContainer: TPanel;
    LabelSearchCount: TLabel;
    LabelDownloadsCount: TLabel;
    ButtonStop: TButton;
    TabSheetPlaylist: TTabSheet;
    ListView1: TListView;
    Directplay1: TMenuItem;
    Addandplay1: TMenuItem;
    Addtoplaylist1: TMenuItem;
    N1: TMenuItem;
    procedure ButtonSearchClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewSearchResultsDblClick(Sender: TObject);
    procedure ButtonSearchArtistClick(Sender: TObject);
    procedure ListViewSearchResultsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure EditSearchKeywordsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure ListViewDownloadsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonPlaylistClick(Sender: TObject);
    procedure mnuSearchCheckAllClick(Sender: TObject);
    procedure SpinEditMaxDownloadsChange(Sender: TObject);
    procedure EditDownloadDirectoryChange(Sender: TObject);
    procedure mnuSearchUncheckAllClick(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure EditConfigPlayerLocationChange(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure ButtonPlayClick(Sender: TObject);
    procedure ButtonDownloadClick(Sender: TObject);
    procedure Explorerledossier1Click(Sender: TObject);
    procedure Retirer1Click(Sender: TObject);
    procedure LabelSearchMoreResultsClick(Sender: TObject);
    procedure ListViewSearchResultsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LabelExploreDownloadsClick(Sender: TObject);
    procedure ListViewSearchResultsColumnClick(Sender: TObject;
      Column: TListColumn);
    procedure ListViewSearchResultsCompare(Sender: TObject; Item1,
      Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ListViewDownloadsDblClick(Sender: TObject);
    procedure ListViewDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure ListViewSearchResultsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListViewDownloadsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ButtonStopClick(Sender: TObject);
  private
    { Déclarations privées }
    SearchProvider: z1fmProvider;
    PlaylistProvider: MagicPlaylistProvider;
    FDownloadsRunningCount: Integer;
    FPlayer: TPlayer;
    Configuration: TConfiguration;

    FSearchSortedColumn: Integer;
    FSearchSortedDescending: Boolean;

    FSearchListColumns: TDictionary<string, TListColumn>;
    FDownloadsListColumns: TDictionary<string, TListColumn>;

    FStyleService : TCustomStyleServices;

    FThemedNormalCell: TThemedElementDetails;
    FThemedSelectedCell: TThemedElementDetails;
    FThemedCheckBoxCheckedNormal: TThemedElementDetails;
    FThemedCheckBoxCheckedHot: TThemedElementDetails;
    FThemedCheckBoxUncheckedNormal: TThemedElementDetails;
    FThemedCheckBoxUncheckedHot: TThemedElementDetails;
    FThemedProgressBar: TThemedElementDetails;
    FThemedChunk: TThemedElementDetails;
    FThemedWindowColor: TColor;
    FThemedWindowTextColor: TColor;
    FThemedHighlightTextColor: TColor;

    procedure DownloadProgressCallback(const Song: TSong);
    procedure DownloadFinishedCallback(const Song: TSong);

    // Common
    procedure Log(AString: string);
    procedure CheckAllItemsOfListView(AListView: TListView; AChecked: Boolean);
    procedure RemoveCheckedItemsOfListView(AListView: TListView);
    procedure SelectSongInListView(ASong: TSong; AListView: TListView);
    procedure UpdateBottomBar;

    procedure ShowSongDetails(ASong: TSong);
    procedure HideSongDetails;

    procedure InitThemeGlobalElements;
    procedure DisableListViewInfoTips(AListView: TListView);

    // Search panel
    procedure SearchSong(AKeywords: string);
    procedure SearchSameArtist(ASong: TSong);
    procedure AddSongToSearchResults(ASong: TSong);
    procedure AddSearchResults(ASongList: TSongList);
    procedure PlayCheckedSearches(AAutoplay: Boolean);
    procedure SearchSortColumn(AColumn: TListColumn);
    function SearchSortCompareItems(Item1, Item2: TListItem): Integer;
    procedure CreateSearchListColumns;

    // Download panel
    procedure M3UExtractInfos(ALine: string; ASong: TSong);
    procedure FillDownloadList;
    procedure SaveDownloadList;
    procedure PlayCheckedDownloads(AAutoplay: Boolean);
    procedure RemoveSelectedDownloads;
    procedure CreateDownloadsListColumns;

    procedure SetDownloadsRunningCount(const Value: Integer);
    property DownloadsRunningCount: Integer read FDownloadsRunningCount write SetDownloadsRunningCount;

    procedure DownloadSong(ASong: TSong);
    procedure AddSongToDownloads(ASong: TSong; AToDownload: Boolean = False; AChecked: Boolean = False);
    procedure ProcessDownloadQueue;

    // player
    property Player: TPlayer read FPlayer write FPlayer;
    procedure PlaySongs(ASongList: TSongList; AAutoplay: Boolean = False);

    procedure RefreshSongDownload(ASong: TSong);
    procedure InitParametersTab;
    procedure InitSearchTab;
    procedure InitDownloadsTab;
    procedure SetActiveTab(ATabSheet: TTabSheet);
  public
    { Déclarations publiques }
  end;

function ILCreateFromPath(pszPath: PChar): PItemIDList stdcall; external shell32 name 'ILCreateFromPathW';
procedure ILFree(pidl: PItemIDList) stdcall; external shell32;
function SHOpenFolderAndSelectItems(pidlFolder: PItemIDList; cidl: Cardinal; apidl: pointer; dwFlags: DWORD): HRESULT; stdcall; external shell32;

var
  FormMain: TFormMain;

implementation

uses Logger, ID3Tag;

{$R *.dfm}

function OpenFolderAndSelectFile(const FileName: string): boolean;
var
  IIDL: PItemIDList;

begin
  result := false;
  IIDL := ILCreateFromPath(PChar(FileName));
  if IIDL <> nil then
    try
      result := SHOpenFolderAndSelectItems(IIDL, 0, nil, 0) = S_OK;
    finally
      ILFree(IIDL);
    end;
end;

function ResizeRect(const ARect: TRect; const DxLeft, DxRight, DyTop, DyBottom: integer): TRect;
begin
  Result := ARect;
  Inc(Result.Left, DxLeft);
  Dec(Result.Right, DxRight);
  Inc(Result.Top, DyTop);
  Dec(Result.Bottom, DyBottom);
end;

procedure TFormMain.AddSearchResults(ASongList: TSongList);
var
  Song: TSong;

begin
  for Song in ASongList do
  begin
    AddSongToSearchResults(Song);
  end;
end;

procedure TFormMain.AddSongToDownloads(ASong: TSong; AToDownload: Boolean; AChecked: Boolean);
begin
  with ListViewDownloads.Items.Add do
  begin
    Caption := '';
    SubItems.Add(ASong.Artist.Name);
    SubItems.Add(ASong.Title);
    if ASong.Url='' then
    begin
      SearchProvider.UpdateSong(ASong);
    end;
    if AToDownload then
    begin
      ASong.DownloadStatus := dsWaiting;
    end;
    Data := ASong;
  end;
  LabelDownloadsCount.Caption := Format('%d downloads',[ListViewDownloads.Items.Count]);

  ProcessDownloadQueue;
end;

procedure TFormMain.mnuSearchCheckAllClick(Sender: TObject);
begin
  CheckAllItemsOfListView(ListViewSearchResults, True);
end;

procedure TFormMain.ButtonDownloadClick(Sender: TObject);
var
  Item: TListItem;

begin
  for Item in ListViewDownloads.Items do
  begin
    if TSong(Item.Data).Checked then
    begin
      if TSong(Item.Data).DownloadStatus in [dsUndefined, dsError] then
        TSong(Item.Data).DownloadStatus := dsWaiting;
    end;
  end;
  ProcessDownloadQueue;
end;

procedure TFormMain.ButtonPlayClick(Sender: TObject);
begin
  if PageControl.ActivePage=TabSheetSearch then
  begin
    PlayCheckedSearches(True);
  end;

  if PageControl.ActivePage=TabSheetDownloads then
  begin
    PlayCheckedDownloads(True);
  end;
end;

procedure TFormMain.ButtonPlaylistClick(Sender: TObject);
var
  SongList: TSongList;

begin
  SongList := PlaylistProvider.GetPlaylist(EditSearchKeywords.Text);
  ListViewSearchResults.Clear;
  AddSearchResults(SongList);
end;

procedure TFormMain.ButtonSearchArtistClick(Sender: TObject);
var
  Song: TSong;

begin
  if Assigned(ListViewSearchResults.Selected) then
  begin
    Song := TSong(ListViewSearchResults.Selected.Data);
    if Song.Artist.Id<>'' then
    begin
      SearchSameArtist(Song);
    end;
  end;
end;

procedure TFormMain.ButtonSearchClick(Sender: TObject);
begin
  SearchSong(EditSearchKeywords.Text);
end;

procedure TFormMain.ButtonStopClick(Sender: TObject);
begin
  Player.Pause;
end;

procedure TFormMain.CheckAllItemsOfListView(AListView: TListView; AChecked: Boolean);
var
  Item: TListItem;

begin
  AListView.Items.BeginUpdate;
  try
    for Item in AListView.Items do
    begin
      TSong(Item.Data).Checked := AChecked;
    end;
  finally
    AListView.Items.EndUpdate;
  end;
end;

procedure TFormMain.CreateDownloadsListColumns;

  procedure AddColumn(const AColumnName : String; AWidth : Integer; AColumnType : TColumnType);
  begin
   FDownloadsListColumns.Add(AColumnName, ListViewDownloads.Columns.Add());
   FDownloadsListColumns[AColumnName].Caption := AColumnName;
   FDownloadsListColumns[AColumnName].Width   := Abs(AWidth);
   FDownloadsListColumns[AColumnName].Tag     := Integer(AColumnType);
   if AWidth<0 then
     FDownloadsListColumns[AColumnName].AutoSize := True;
  end;

begin
   ListViewDownloads.Columns.Clear;
   FDownloadsListColumns  := TDictionary<string, TListColumn>.Create();

   AddColumn('', 30, ctCheck);
   AddColumn('Artist', -200, ctText);
   AddColumn('Song', -200, ctText);
   AddColumn('Progress', 200, ctProgress);
end;

procedure TFormMain.CreateSearchListColumns;

  procedure AddColumn(const AColumnName: string;
    AWidth: Integer; AColumnType: TColumnType;
    AAlignment: TAlignment);
  begin
   FSearchListColumns.Add(AColumnName, ListViewSearchResults.Columns.Add());
   FSearchListColumns[AColumnName].Caption := AColumnName;
   FSearchListColumns[AColumnName].Width   := Abs(AWidth);
   FSearchListColumns[AColumnName].Tag     := Integer(AColumnType);
   if AWidth<0 then
     FSearchListColumns[AColumnName].AutoSize := True;
   FSearchListColumns[AColumnName].Alignment := AAlignment;
  end;

begin
   ListViewSearchResults.Columns.Clear;
   FSearchListColumns  := TDictionary<string, TListColumn>.Create();

   AddColumn('', 30, ctCheck, taCenter);
   AddColumn('Artist', -200, ctText, taLeftJustify);
   AddColumn('Song', -200, ctText, taLeftJustify);
   AddColumn('Length', 100, ctText, taRightJustify);
end;

procedure TFormMain.PlaySongs(ASongList: TSongList; AAutoplay: Boolean = False);
var
  CommandLineParams: string;
  Song: TSong;
  SongStringList: TStringList;

begin
  if (Configuration.PlayerLocation='') or not FileExists(Configuration.PlayerLocation) then
  begin
    ShowMessage('Player not set');
    Exit;
  end;

  SongStringList := TStringList.Create;
  try
    for Song in ASongList do
      SongStringList.Add(Song.Url);
    SongStringList.Delimiter := ' ';
    SongStringList.QuoteChar := '"';
    CommandLineParams := '-list '+SongStringList.DelimitedText;
    if AAutoplay then
      CommandLineParams := CommandLineParams + ' -play';
    ShellExecute(Handle, 'open', PChar(Configuration.PlayerLocation), PChar(CommandLineParams), nil, SW_NORMAL);
  finally
    SongStringList.Free;
  end;
end;

procedure TFormMain.PageControlChange(Sender: TObject);
begin
  UpdateBottomBar;
end;

procedure TFormMain.PlayCheckedDownloads(AAutoplay: Boolean);
var
  Item: TListItem;
  Song: TSong;
  SongsList: TSongList;

begin
  Song := TSong(ListViewDownloads.Selected.Data);
  Player.OpenFile(Song.Filename);
  Player.Resume;
  Exit;

  SongsList := TSongList.Create;
  try
    for Item in ListViewDownloads.Items do
    begin
      Song := TSong(Item.Data);
      if Song.Checked then
      begin
        if (Song.Url='') and (Song.Filename='') then
        begin
          SearchProvider.UpdateSong(Song);
        end;
        SongsList.Add(Song);
      end;
    end;
    PlaySongs(SongsList, AAutoplay);
  finally
    SongsList.Free;
  end;
end;

procedure TFormMain.PlayCheckedSearches(AAutoplay: Boolean);
var
  Item: TListItem;
  Song, FirstSong: TSong;
  SongList: TSongList;

begin
  Song := TSong(ListViewSearchResults.Selected.Data);
  Player.OpenURL(Song.Url);
  Player.Resume;
  Exit;

  FirstSong := nil;
  SongList := TSongList.Create;
  try
    for Item in ListViewSearchResults.Items do
    begin
      Song := TSong(Item.Data);
      if Song.Checked then
      begin
        if not Assigned(FirstSong) then
          FirstSong := Song;
        AddSongToDownloads(Song, False, True);
        SongList.Add(Song);
      end;
    end;
    PlaySongs(SongList, AAutoplay);
  finally
    SongList.Free;
    RemoveCheckedItemsOfListView(ListViewSearchResults);
    if Assigned(FirstSong) then
    begin
      SetActiveTab(TabSheetDownloads);
      SelectSongInListView(FirstSong, ListViewDownloads);
      Application.ProcessMessages;
    end;
  end;
end;

procedure TFormMain.DisableListViewInfoTips(AListView: TListView);
begin
  ListView_SetExtendedListViewStyle(
    AListView.Handle,
    ListView_GetExtendedListViewStyle(AListView.Handle) and not LVS_EX_INFOTIP
  );
end;

procedure TFormMain.DownloadFinishedCallback(const Song: TSong);
begin
  RefreshSongDownload(Song);
  DownloadsRunningCount := DownloadsRunningCount-1;
  ProcessDownloadQueue;
end;

procedure TFormMain.DownloadProgressCallback(const Song: TSong);
begin
  RefreshSongDownload(Song);
end;

procedure TFormMain.DownloadSong(ASong: TSong);
begin
  DownloadsRunningCount := DownloadsRunningCount + 1;
  SearchProvider.DownloadSong(ASong, Configuration.DownloadDirectory, DownloadProgressCallback, DownloadFinishedCallback);
end;

procedure TFormMain.EditConfigPlayerLocationChange(Sender: TObject);
begin
  Configuration.PlayerLocation := EditConfigPlayerLocation.FileName;
end;

procedure TFormMain.EditDownloadDirectoryChange(Sender: TObject);
begin
  Configuration.DownloadDirectory := EditDownloadDirectory.Directory;
end;

procedure TFormMain.EditSearchKeywordsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then
  begin
    SearchSong(EditSearchKeywords.Text);
  end;
end;

procedure TFormMain.Explorerledossier1Click(Sender: TObject);
var
  Song: TSong;

begin
  if Assigned(ListViewDownloads.Selected) then
  begin
    Song := TSong(ListViewDownloads.Selected.Data);
    if Song.Filename<>'' then
    begin
      OpenFolderAndSelectFile(Song.Filename);
    end;
  end;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  SaveDownloadList;
  SearchProvider.SaveLastSearch;
  Configuration.Save;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  SubscriptionId: Integer;

begin
  //ReportMemoryLeaksOnShutdown := True;

  ListViewSearchResults.OwnerDraw := True;
  ListViewSearchResults.ViewStyle := TViewStyle.vsReport;

  ListViewDownloads.OwnerDraw := True;
  ListViewDownloads.ViewStyle := TViewStyle.vsReport;

  SubscriptionId := AppLogger.MessageManager.SubscribeToMessage(TMessage<UnicodeString>, procedure(const Sender: TObject; const M: TMessage)
  begin
    Log(Sender.ClassName + '- ' + (M as TMessage<UnicodeString>).Value);
  end);

  Configuration := TConfiguration.Create;
  SearchProvider := z1fmProvider.Create;
  PlaylistProvider := MagicPlaylistProvider.Create;
  FPlayer := TPlayer.Create(Handle);
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FPlayer.Free;
  PlaylistProvider.Free;
  SearchProvider.Free;
  Configuration.Free;

  FSearchListColumns.Free;
  FDownloadsListColumns.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  InitThemeGlobalElements;
  InitSearchTab;
  InitDownloadsTab;
  InitParametersTab;
  SetActiveTab(TabSheetSearch);
  UpdateBottomBar;
end;

procedure TFormMain.ButtonAddClick(Sender: TObject);
begin
  PlayCheckedSearches(False);
end;

procedure TFormMain.ListViewSearchResultsColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  SearchSortColumn(Column);
end;

procedure TFormMain.ListViewSearchResultsCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  Compare := SearchSortCompareItems(Item1, Item2);
end;

procedure TFormMain.ListViewSearchResultsDblClick(Sender: TObject);
var
  SongList: TSongList;

begin
  if Assigned(ListViewSearchResults.Selected) then
  begin
    SongList := TSongList.Create;
    SongList.Add(TSong(ListViewSearchResults.Selected.Data));
    PlaySongs(SongList, True);
  end;
end;

procedure TFormMain.ListViewDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
const
  ListView_Padding = 5;

var
  LRect, LRect2: TRect;
  Col : Integer;
  LText: string;
  LSize: TSize;
  LTextFormat : TTextFormatFlags;
  LColor : TColor;
  LDetails: TThemedElementDetails;
  LColummnType  : TColumnType;
  LColumnAlign: TAlignment;
  Song: TSong;

begin
  Sender.Canvas.Brush.Style := bsSolid;
  Sender.Canvas.Brush.Color := FThemedWindowColor;
  Sender.Canvas.FillRect(Rect);

  LRect := Rect;
  Song := TSong(Item.Data);

  for Col := 0 to TListView(Sender).Columns.Count - 1 do
  begin
    LColummnType := TColumnType(TListView(Sender).Columns[Col].Tag);
    LColumnAlign := TListView(Sender).Columns[Col].Alignment;
    LRect.Right  := LRect.Left + Sender.Column[Col].Width;

    LText := '';
    if Col = 0 then
      LText := Item.Caption
    else
      if (Col - 1) < Item.SubItems.Count then
        LText := Item.SubItems[Col - 1];

    case LColummnType of
      ctText:
      begin
        if ([odSelected, odHotLight] * State <> []) then
        begin
          LDetails := FThemedSelectedCell;
          LColor := FThemedHighlightTextColor;
          FStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect);
        end else
        begin
          LDetails := FThemedNormalCell;
          LColor := FThemedWindowTextColor;
        end;

        LRect2 := LRect;
        LRect2.Left := LRect2.Left + ListView_Padding;
        if LColumnAlign=taRightJustify then
          LTextFormat := TTextFormatFlags(DT_SINGLELINE or DT_RIGHT)
        else
          LTextFormat := TTextFormatFlags(DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS);

        FStyleService.DrawText(Sender.Canvas.Handle, LDetails, LText, LRect2, LTextFormat, LColor);
     end;

      ctCheck:
      begin
        if ([odSelected, odHotLight] * State <> []) then
        begin
         LDetails := FThemedSelectedCell;
         FStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect);
        end;

        LSize.cx := GetSystemMetrics(SM_CXMENUCHECK);
        LSize.cy := GetSystemMetrics(SM_CYMENUCHECK);

        LRect2.Top    := Rect.Top + (Rect.Bottom - Rect.Top - LSize.cy) div 2;
        LRect2.Bottom := LRect2.Top + LSize.cy;
        LRect2.Left   := LRect.Left + ((LRect.Width - LSize.cx) div 2);
        LRect2.Right  := LRect2.Left + LSize.cx;

        if (Song.Checked) then
        begin
         if ([odSelected, odHotLight] * State <> []) then
           LDetails := FThemedCheckBoxCheckedHot
         else
           LDetails := FThemedCheckBoxCheckedNormal;
        end
        else begin
         if ([odSelected, odHotLight] * State <> []) then
           LDetails := FThemedCheckBoxUncheckedHot
         else
           LDetails := FThemedCheckBoxUncheckedNormal;
        end;
        FStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect2);
      end;

      ctProgress:
      begin
        if Song.DownloadStatus in [dsWaiting, dsInProgress] then
        begin
          if ([odSelected, odHotLight] * State <> []) then
          begin
             FStyleService.DrawElement(Sender.Canvas.Handle, FThemedSelectedCell, LRect);
          end;

          LRect2   := ResizeRect(LRect, 2, 2, 2, 2);
          FStyleService.DrawElement(Sender.Canvas.Handle, FThemedProgressBar, LRect2);

          InflateRect(LRect2, -1, -1);
          LRect2.Right := LRect2.Left + Round(LRect2.Width * Song.DownloadProgress / 100);
          FStyleService.DrawElement(Sender.Canvas.Handle, FThemedChunk, LRect2);
        end else
        begin
          LDetails := FThemedNormalCell;
          LColor := FThemedWindowTextColor;
          if ([odSelected, odHotLight] * State <> []) then
          begin
            LDetails := FThemedSelectedCell;
            LColor := FThemedHighlightTextColor;
            FStyleService.DrawElement(Sender.Canvas.Handle, LDetails, LRect);
          end;

          LRect2 := LRect;
          LRect2.Left := LRect2.Left + ListView_Padding;

          LTextFormat := TTextFormatFlags(DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS);
          FStyleService.DrawText(Sender.Canvas.Handle, LDetails, Song.DownloadStatusText, LRect2, LTextFormat, LColor);
        end;
      end;
    end;
    Inc(LRect.Left, Sender.Column[Col].Width);
  end;
end;

procedure TFormMain.ListViewSearchResultsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key=VK_DELETE then
  begin
    ListViewSearchResults.DeleteSelected;
  end;
end;

procedure TFormMain.ListViewSearchResultsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   Item: TListItem;
   W: Integer;
   Col: Integer;
   Song: TSong;

begin
   Item := TListView(Sender).GetItemAt(0, Y);
   if Assigned(Item) then
   begin
      W := 0;
      Col := -1;
      repeat
         Inc(Col);
         Inc(W, TListView(Sender).Columns[Col].Width);
      until X < W;

      if Col = 0 then
      begin
        Song := TSong(Item.Data);
        Song.Checked := not Song.Checked;
        Item.Update;
      end;
   end;
end;

procedure TFormMain.ListViewSearchResultsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  ButtonSearchArtist.Enabled := Selected;
  if Selected then
  begin
    ShowSongDetails(TSong(Item.Data));
  end;
end;

procedure TFormMain.LabelExploreDownloadsClick(Sender: TObject);
begin
  ShellExecute(Handle,'open','explorer.exe',PChar(Configuration.DownloadDirectory),nil,SW_SHOWNORMAL);
end;

procedure TFormMain.LabelSearchMoreResultsClick(Sender: TObject);
var
  SongList: TSongList;

begin
  SongList := SearchProvider.SearchMore;
  AddSearchResults(SongList);
end;

procedure TFormMain.ListViewDownloadsDblClick(Sender: TObject);
var
  SongList: TSongList;

begin
  if Assigned(ListViewDownloads.Selected) then
  begin
    SongList := TSongList.Create;
    SongList.Add(TSong(ListViewDownloads.Selected.Data));
    PlaySongs(SongList, True);
  end;
end;

procedure TFormMain.ListViewDownloadsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key=VK_DELETE then
  begin
    RemoveSelectedDownloads;
  end;
end;

procedure TFormMain.ListViewDownloadsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    ShowSongDetails(TSong(Item.Data));
  end;
end;

procedure TFormMain.FillDownloadList;
var
  PlayList: TStringList;
  Line: string;
  Song: TSong;
  SR: TSearchRec;
  ID3Tag: TID3Tag;

begin
  ListViewDownloads.Clear;

  if FindFirst(Configuration.DownloadDirectory+'*.mp3', faAnyFile, SR)=0 then
  begin
    repeat
      Song := TSong.Create;
      Song.Filename := Configuration.DownloadDirectory + SR.Name;
      Song.DownloadStatus := dsTerminated;
      Song.Url := Song.Filename;
      Song.ReadID3Tag;

      AddSongToDownloads(Song, False);
    until FindNext(SR)<>0;
    FindClose(SR);
  end;
  Exit;


  PlayList := TStringList.Create;
  Song := nil;
  try
    PlayList.LoadFromFile('NapWire.m3u');
    for Line in PlayList do
    begin
      if Line='#EXTM3U' then Continue;
      if Trim(Line)='' then Continue;

      if Line.StartsWith('#EXTINF') then
      begin
        Song := TSong.Create;
      end else if Line.StartsWith('#EXTREM') then
      begin
        if not Assigned(Song) then Continue;
        M3UExtractInfos(Line, Song);
      end else begin
        if not Assigned(Song) then Continue;

        Song.Filename := Line;
        if not Song.Filename.StartsWith('http') then
        begin
          Song.DownloadStatus := dsTerminated;
          if not FileExists(Song.Filename) then
          begin
            Song.DownloadStatus := dsError;
          end;
        end else
          Song.Filename := '';

        AddSongToDownloads(Song, False);
        Song := nil;
      end;
    end;

  finally
    PlayList.Free;
  end
end;

procedure TFormMain.Log(AString: string);
begin
  MemoLog.Lines.Add(AString);
end;

procedure TFormMain.M3UExtractInfos(ALine: string; ASong: TSong);
var
  Data: string;
  List: TStringList;

begin
  Data := Copy(ALine, 9, Length(ALine)-8);
  if Length(Trim(Data))=0 then Exit;

  List := TStringList.Create;
  List.Delimiter := ',';
  List.DelimitedText := Data;
  ASong.Duration.AsSeconds := StrToIntDef(List[0],0);
  ASong.Artist.Name := List[1];
  ASong.Title := List[2];
  ASong.Url := List[3];
end;

procedure TFormMain.MenuItem4Click(Sender: TObject);
begin
  CheckAllItemsOfListView(ListViewDownloads, True);
end;

procedure TFormMain.MenuItem5Click(Sender: TObject);
begin
  CheckAllItemsOfListView(ListViewDownloads, False);
end;

procedure TFormMain.mnuSearchUncheckAllClick(Sender: TObject);
begin
  CheckAllItemsOfListView(ListViewSearchResults, False);
end;

procedure TFormMain.ProcessDownloadQueue;
var
  Item: TListItem;
  Song: TSong;

begin
  if DownloadsRunningCount >= Configuration.ConcurentDownloads then Exit;

  for Item in ListViewDownloads.Items do
  begin
    Song := TSong(Item.Data);
    if Song.DownloadStatus=dsWaiting then
    begin
      DownloadSong(Song);
      if DownloadsRunningCount >= Configuration.ConcurentDownloads then Exit;
    end;
  end;
end;

procedure TFormMain.RefreshSongDownload(ASong: TSong);
var
  Item: TListItem;
  Song: TSong;

begin
  for Item in ListViewDownloads.Items do
  begin
    Song := TSong(Item.Data);
    if ASong=Song then
    begin
      //Item.Caption := '';
      //Item.SubItems[0] := ASong.Artist.Name;
      //Item.SubItems[1] := ASong.Title;
      //Item.SubItems[2] := IntToStr(ASong.DownloadProgress);
      Item.Update;
      Exit;
    end;
  end;
end;

procedure TFormMain.InitParametersTab;
begin
  SpinEditMaxDownloads.Value := Configuration.ConcurentDownloads;
  EditDownloadDirectory.Directory := Configuration.DownloadDirectory;
  EditConfigPlayerLocation.FileName := Configuration.PlayerLocation;
end;

procedure TFormMain.InitSearchTab;
var
  SongList: TSongList;

begin
  DisableListViewInfoTips(ListViewSearchResults);
  CreateSearchListColumns;
  SongList := SearchProvider.LoadLastSearch;
  AddSearchResults(SongList);
end;

procedure TFormMain.InitThemeGlobalElements;
begin
  FStyleService := StyleServices;

  FThemedNormalCell := FStyleService.GetElementDetails(tgCellNormal);
  FThemedSelectedCell := FStyleService.GetElementDetails(tgCellSelected);
  FThemedCheckBoxCheckedNormal := FStyleService.GetElementDetails(tbCheckBoxCheckedNormal);
  FThemedCheckBoxCheckedHot := FStyleService.GetElementDetails(tbCheckBoxCheckedHot);
  FThemedCheckBoxUncheckedNormal := FStyleService.GetElementDetails(tbCheckBoxUncheckedNormal);
  FThemedCheckBoxUncheckedHot := FStyleService.GetElementDetails(tbCheckBoxUncheckedHot);
  FThemedProgressBar := FStyleService.GetElementDetails(tpBar);
  FThemedChunk := FStyleService.GetElementDetails(tpChunk);

  FThemedWindowColor := FStyleService.GetSystemColor(clWindow);
  FThemedWindowTextColor := FStyleService.GetSystemColor(clWindowText);
  FThemedHighlightTextColor := FStyleService.GetSystemColor(clHighlightText);

end;

procedure TFormMain.InitDownloadsTab;
begin
  DisableListViewInfoTips(ListViewDownloads);
  CreateDownloadsListColumns;
  FillDownloadList;
end;

procedure TFormMain.SetActiveTab(ATabSheet: TTabSheet);
begin
  PageControl.ActivePage := ATabSheet;
  PageControl.OnChange(PageControl);
end;

procedure TFormMain.AddSongToSearchResults(ASong: TSong);
begin
  with ListViewSearchResults.Items.Add do
  begin
    Caption := '';
    SubItems.Add(ASong.Artist.Name);
    SubItems.Add(ASong.Title);
    SubItems.Add(ASong.Duration.AsString);
    Data := ASong;
  end;
  LabelSearchCount.Caption := Format('%d results',[ListViewSearchResults.Items.Count]);
end;

procedure TFormMain.RemoveCheckedItemsOfListView(AListView: TListView);
var
  I: Integer;

begin
  I := 0;
  while I < AListView.Items.Count do
  begin
    if TSong(AListView.Items[I].Data).Checked then
    begin
      AListView.Items.Delete(I);
    end else
    begin
      Inc(I);
    end;
  end;
end;

procedure TFormMain.RemoveSelectedDownloads;
begin
  ListViewDownloads.DeleteSelected;
end;

procedure TFormMain.Retirer1Click(Sender: TObject);
begin
  RemoveSelectedDownloads;
end;

procedure TFormMain.SaveDownloadList;
var
  PlayList: TStringList;
  Item: TListItem;
  Song: TSong;

begin
  PlayList := TStringList.Create;
  try
    PlayList.Add('#EXTM3U');
    for Item in ListViewDownloads.Items do
    begin
      Song := TSong(Item.Data);
      PlayList.Add(Format('#EXTINF:%d,%s - %s',[Song.Duration.AsSeconds, Song.Artist.Name, Song.Title]));
      PlayList.Add(Format('#EXTREM:%d,"%s","%s","%s"',[Song.Duration.AsSeconds, Song.Artist.Name, Song.Title, Song.Url]));
      if Song.Filename<>'' then
        PlayList.Add(Song.Filename)
      else
        PlayList.Add(Song.Url);
    end;
    PlayList.SaveToFile('Napwire.m3u',TEncoding.UTF8);
  finally
    PlayList.Free;
  end;
end;

procedure TFormMain.SearchSameArtist(ASong: TSong);
var
  Item: TListItem;
  Song: TSong;
  SongList: TSongList;

begin
  Item := ListViewSearchResults.Selected;
  if Assigned(Item) then
  begin
    Song := TSong(Item.Data);
    if Song.Artist.Id<>'' then
    begin
      SongList := SearchProvider.SearchArtist(Song.Artist.Id);
      ListViewSearchResults.Clear;
      LabelSearchMoreResults.Visible := False;
      AddSearchResults(SongList);
      LabelSearchMoreResults.Visible := SongList.Count > 0;
    end;
  end;
end;

procedure TFormMain.SearchSong(AKeywords: string);
var
  SongList: TSongList;

begin
  if AKeywords<>'' then
  begin
    SongList := SearchProvider.SearchSongs(AKeywords);
    ListViewSearchResults.Clear;
    LabelSearchMoreResults.Visible := False;
    AddSearchResults(SongList);
    LabelSearchMoreResults.Visible := SongList.Count > 0;
  end;
end;

procedure TFormMain.SearchSortColumn(AColumn: TListColumn);
begin
  if AColumn.Index < SEARCHES_DURATION_COLUMN_INDEX then
  begin
    ListViewSearchResults.SortType := stNone;
    if AColumn.Index<>FSearchSortedColumn then
    begin
      FSearchSortedColumn := AColumn.Index;
      FSearchSortedDescending := False;
    end else
    begin
      FSearchSortedDescending := not FSearchSortedDescending;
    end;
    ListViewSearchResults.SortType := stText;
  end;
end;

function TFormMain.SearchSortCompareItems(Item1,
  Item2: TListItem): Integer;
begin
  if FSearchSortedColumn = 0 then
    Result := CompareText(Item1.Caption, Item2.Caption)
  else
    Result := CompareText(Item1.SubItems[FSearchSortedColumn-1], Item2.SubItems[FSearchSortedColumn-1]);

  if FSearchSortedDescending then
    Result := -Result;
end;

procedure TFormMain.SelectSongInListView(ASong: TSong;
  AListView: TListView);
var
  Song: TSong;
  Item: TListItem;

begin
  for Item in AListView.Items do
  begin
    Song := TSong(Item.Data);
    if Song=ASong then
    begin
      AListView.Selected := Item;
      AListView.Selected.MakeVisible(False);
      AListView.SetFocus;
      Break;
    end;
  end;
end;

procedure TFormMain.SetDownloadsRunningCount(const Value: Integer);
var
  TabCaption: string;

begin
  FDownloadsRunningCount := Value;

  if FDownloadsRunningCount>0 then
    TabCaption := Format('Transferts [%d]',[FDownloadsRunningCount])
  else
    TabCaption := 'Transferts';
  if TabSheetDownloads.Caption<>TabCaption then
  begin
    TabSheetDownloads.Caption := TabCaption;
    Application.ProcessMessages;
  end;
end;

procedure TFormMain.ShowSongDetails(ASong: TSong);
begin
  LabelSongArtist.Caption := ASong.Artist.Name;
  LabelSongTitle.Caption := ASong.Title;
  LabelSongURL.Caption := ASong.URL;
  if not PanelSongDetails.Visible then
    PanelSongDetails.Visible := True;
end;

procedure TFormMain.HideSongDetails;
begin
  PanelSongDetails.Visible := False;
end;

procedure TFormMain.SpinEditMaxDownloadsChange(Sender: TObject);
begin
  Configuration.ConcurentDownloads := SpinEditMaxDownloads.Value;
end;

procedure TFormMain.UpdateBottomBar;
var
  SelectedItem: TListItem;

begin
  case PageControl.ActivePageIndex of
    0:
    begin
      ButtonDownload.Visible := False;
      SelectedItem := ListViewSearchResults.Selected;
      if Assigned(SelectedItem) then
        ShowSongDetails(TSong(SelectedItem.Data))
      else
        HideSongDetails;
      PanelBottomBar.Visible := True;
    end;

    1:
    begin
      ButtonDownload.Visible := True;
      SelectedItem := ListViewDownloads.Selected;
      if Assigned(SelectedItem) then
        ShowSongDetails(TSong(SelectedItem.Data))
      else
        HideSongDetails;
      PanelBottomBar.Visible := True;
    end;

    2:
    begin
      PanelBottomBar.Visible := False;
    end;
  end;
end;

end.
