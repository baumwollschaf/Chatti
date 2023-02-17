unit Chatti.Forms.AppMainFormChatti;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  rd.OpenAI.ChatGpt.Model,
  Chatti.Forms.SettingsForm,
  Chatti.Types,
{$IFDEF baumwollschaf}
  Extern.ApiKey,
{$ENDIF}
  rd.OpenAI.ChatGpt.ViewModel,
  FMX.Layouts,
  FMX.Edit,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  System.Actions,
  FMX.ActnList,
  FMX.StdActns,
  FMX.MediaLibrary.Actions,
  FMX.Objects,
  Chatti.BubbleLabel,
  FMX.TabControl,
  FMX.AutoSizer;

type
  TAppMainFormChatti = class(TForm)
    Header: TToolBar;
    HeaderLabel: TLabel;
    btnSettings: TSpeedButton;
    RDChatGpt1: TRDChatGpt;
    ViewStyleBook: TStyleBook;
    VertScrollBox1: TVertScrollBox;
    Layout4: TLayout;
    edQuestion: TEdit;
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    MemoModerations: TMemo;
    AutoSizer: TFmxAutoSizer;
    sbMessages: TVertScrollBox;
    btnShare: TSpeedButton;
    btnClear: TSpeedButton;
    EditClipboard: TEdit;
    MainLayout: TLayout;
    EditButton1: TEditButton;
    PathSend: TPath;
    procedure btnSettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCutClick(Sender: TObject);
    procedure btnAskClick(Sender: TObject);
    procedure RDChatGpt1Answer(Sender: TObject; AMessage: string);
    procedure edQuestionKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure ShowShareSheetAction1BeforeExecute(Sender: TObject);
    procedure ShowShareSheetAction1Update(Sender: TObject);
    procedure Label1ApplyStyleLookup(Sender: TObject);
    procedure RDChatGpt1ModerationsLoaded(Sender: TObject; AType: TModerations);
    procedure miCopyClick(Sender: TObject);
  private
    FInput: string;
    FWasMe: Boolean;
    FSettings: TSettings;
    function GetLabelsText: string;
    procedure AddLabel(AText: string; AMe: Boolean; AFollowing: Boolean);
    procedure AnalyzeInput(AText: string; AType: TModerations);
    function StringRework(AText: string): string;
    procedure TextToClipBoard(ABubbleLabel: TBubbleLabel);
  private
    procedure ControlGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
  public
    procedure SetThemeMode(ATheme: TThemeMode);
  end;

var
  AppMainFormChatti: TAppMainFormChatti;

implementation

uses
  FMX.Text,
  System.Math,
  System.IOUtils;

{$R *.fmx}
{$IFDEF MSWINDOWS}
{$R \Res\Styles\Styles_Win.res}
{$ENDIF}
{$IFDEF ANDROID}
{$R \Res\Styles\Styles_Android.res}
{$ENDIF}
{$IFDEF IOS}
{$R \Res\Styles\Styles_iOS.res}
{$ENDIF}
{ TViewForm }
{$IFDEF ANDROID}
{$ENDIF}

function YesOrNo(b: Boolean): string;
begin
  Result := '👎';
  if not b then
    Result := '👍';
end;

procedure TAppMainFormChatti.AddLabel(AText: string; AMe: Boolean; AFollowing: Boolean);
begin
  var
    Labl: TBubbleLabel;
  Labl := TBubbleLabel.Create(sbMessages);
  Labl.Touch.InteractiveGestures := Labl.Touch.InteractiveGestures + [TInteractiveGesture.LongTap];
  Labl.OnGesture := ControlGesture;
  // Labl.OnClick := OnLabelClick;
  Labl.Parent := sbMessages;
  Labl.Me := AMe;
  Labl.Text := AText;
  Labl.Align := TAlignLayout.Top;
  Labl.Position.Y := 999999999;
  Labl.Following := AFollowing;
  Labl.Resize;
  AutoSizer.Control := Labl;
  AutoSizer.AutoSize := False;
  AutoSizer.AutoSize := True;
  var
    Offset: Integer := 10;
  if Labl.Margins.Top = 1 then
    Offset := Trunc((TBubbleLabel.cDEF_MARGIN - Labl.Margins.Top) * 2);
  Labl.Height := Labl.Height + Labl.Margins.Top + Labl.Margins.Bottom + Offset;
  sbMessages.ScrollBy(0, -Labl.Height + 50);
end;

procedure TAppMainFormChatti.AnalyzeInput(AText: string; AType: TModerations);
begin
  MemoModerations.Text := '';

  MemoModerations.Lines.Add('Text to analyse: '#13#10 + FInput);
  MemoModerations.Lines.Add('-----');

  var
    CountChars: Integer;
  CountChars := AText.Length;
  MemoModerations.Lines.Add('Count characters: ' + CountChars.ToString);

  AText := AText.Trim;

  AText := StringRework(AText);

  var
    Words: TStringDynArray := AText.Split([' ']);
  MemoModerations.Lines.Add('Count words: ~' + Length(Words).ToString);
  MemoModerations.Lines.Add('-----');

  if AType = nil then
    Exit;
  if AType.Results.Count > 0 then
  begin
    MemoModerations.Lines.Add('OpenAI Moderations:');
    MemoModerations.Lines.Add('-----');

    MemoModerations.Lines.Add('Hate: ' + YesOrNo(AType.Results[0].Categories.Hate) + '  Score: ' + AType.Results[0]
      .CategoryScores.Hate.ToString);
    MemoModerations.Lines.Add('Hate Threatening: ' + YesOrNo(AType.Results[0].Categories.HateThreatening) + '  Score: '
      + AType.Results[0].CategoryScores.HateThreatening.ToString);
    MemoModerations.Lines.Add('Self Harm: ' + YesOrNo(AType.Results[0].Categories.SelfHarm) + '  Score: ' +
      AType.Results[0].CategoryScores.SelfHarm.ToString);
    MemoModerations.Lines.Add('Sexual: ' + YesOrNo(AType.Results[0].Categories.Sexual) + '  Score: ' + AType.Results[0]
      .CategoryScores.Sexual.ToString);
    MemoModerations.Lines.Add('Sexual Minors: ' + YesOrNo(AType.Results[0].Categories.SexualMinors) + '  Score: ' +
      AType.Results[0].CategoryScores.SexualMinors.ToString);
    MemoModerations.Lines.Add('Violence: ' + YesOrNo(AType.Results[0].Categories.Violence) + '  Score: ' +
      AType.Results[0].CategoryScores.Violence.ToString);
    MemoModerations.Lines.Add('Violence Graphic: ' + YesOrNo(AType.Results[0].Categories.ViolenceGraphic) + '  Score: '
      + AType.Results[0].CategoryScores.ViolenceGraphic.ToString);
  end;
end;

procedure TAppMainFormChatti.btnAskClick(Sender: TObject);
begin
  if edQuestion.Text.Trim = '' then
    Exit;

  case TabControl1.TabIndex of
    0:
      begin
        FInput := edQuestion.Text;
        edQuestion.Text := '';
        RDChatGpt1.Ask(FInput);
        AddLabel(FInput, True, FWasMe and True);
        FWasMe := True;
      end;
    1:
      begin
        FInput := edQuestion.Text;
        edQuestion.Text := '';
        RDChatGpt1.LoadModerations(FInput);
      end;
  end;
end;

procedure TAppMainFormChatti.btnCutClick(Sender: TObject);
begin
  var
    Btn: TSpeedButton := TSpeedButton(Sender);
  if Btn = nil then
    Exit;

  case TabControl1.TabIndex of
    0:
      begin
        FWasMe := False;
        TBubbleLabel.ClearLabels;
        Exit;
      end;
  end;

  MemoModerations.Text := '';

end;

procedure TAppMainFormChatti.btnSettingsClick(Sender: TObject);
begin
  var
    CurTheme: TThemeMode := FSettings.ThemeMode;
  SettingsForm := TSettingsForm.Create(Application,
    // cancel-click
    nil,
    // ok-click
    procedure(Setting: TObject)
    begin
      FSettings.ThemeMode := TSetting(Setting).Theme;
      RDChatGpt1.TimeOutSeconds := SettingsForm.Settings.Timeout;
      RDChatGpt1.Temperature := SettingsForm.Settings.Temperature;
      FSettings.Save;
      SetThemeMode(FSettings.ThemeMode);
    end);

  SettingsForm.Settings.Theme := CurTheme;
  SettingsForm.Settings.Timeout := RDChatGpt1.TimeOutSeconds;
  SettingsForm.Settings.Temperature := RDChatGpt1.Temperature;
  SettingsForm.Show;
end;

procedure TAppMainFormChatti.ControlGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  if EventInfo.GestureID = System.UITypes.igiLongTap then
  begin
    TextToClipBoard(TBubbleLabel(Sender));
    Handled := True;
  end;
end;

procedure TAppMainFormChatti.edQuestionKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Key := 0;
    btnAskClick(nil);
  end;
end;

procedure TAppMainFormChatti.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FSettings.Save;
end;

procedure TAppMainFormChatti.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItem1;
  FSettings := TSettings.Create(RDChatGpt1);
  FSettings.Load;
  RDChatGpt1.ApiKey := S(TExternalStuff.ApiKey);
  RDChatGpt1.LoadModels;
  SetThemeMode(FSettings.ThemeMode);
end;

procedure TAppMainFormChatti.FormDestroy(Sender: TObject);
begin
  TBubbleLabel.ClearLabels;
  FreeAndNil(FSettings);
end;

function TAppMainFormChatti.GetLabelsText: string;
begin
  Result := '';
  var
    Who: string;
  for var Bub: TBubbleLabel in TBubbleLabel.List do
  begin
    if Result <> '' then
    begin
      Result := Result + #13#10+ #13#10;
    end;
    if Bub.Me then
    begin
      Who := 'me: ';
    end
    else
    begin
      Who := 'Chatti: ';
    end;

    Result := Result + Who + Bub.Text;
  end;
end;

procedure TAppMainFormChatti.Label1ApplyStyleLookup(Sender: TObject);
begin
  PathSend.Fill.Color := HeaderLabel.GetStyledColor;
  PathSend.Stroke.Color := HeaderLabel.GetStyledColor;
end;

procedure TAppMainFormChatti.miCopyClick(Sender: TObject);
begin
  ShowMessage('Hallo');
end;

procedure TAppMainFormChatti.RDChatGpt1Answer(Sender: TObject; AMessage: string);
begin
  AddLabel(AMessage, False, (not FWasMe) and False);
  FWasMe := False;
end;

procedure TAppMainFormChatti.RDChatGpt1ModerationsLoaded(Sender: TObject; AType: TModerations);
begin
  // still in thread-mode!
  AnalyzeInput(FInput, AType);
end;

procedure TAppMainFormChatti.SetThemeMode(ATheme: TThemeMode);
begin
  if ATheme = TThemeMode.tmNone then
  begin
    StyleBook := nil;
    Exit;
  end;
  var
    DarkMode: Boolean := ATheme = TThemeMode.tmDark;
  var
    StyleRes: TResourceStream;
  if DarkMode then
  begin
    StyleRes := TResourceStream.Create(HInstance, 'Dark', RT_RCDATA);
  end
  else
  begin
    StyleRes := TResourceStream.Create(HInstance, 'Light', RT_RCDATA);
  end;
  SynchronizedRun(
    procedure
    begin
      try
        StyleRes.Position := 0;
        AppMainFormChatti.StyleBook := nil;
        AppMainFormChatti.ViewStyleBook.LoadFromStream(StyleRes);
        AppMainFormChatti.StyleBook := AppMainFormChatti.ViewStyleBook;
      finally
        StyleRes.Free;
      end;
    end);
end;

procedure TAppMainFormChatti.ShowShareSheetAction1BeforeExecute(Sender: TObject);
begin
  var
    S: string;
  case TabControl1.TabIndex of
    0:
      begin
        S := GetLabelsText;
        // ShowShareSheetAction1.TextMessage := edAnswer.Text;
      end;
    1:
      begin
        S := MemoModerations.Text;
      end;
  end;
  ShowShareSheetAction1.TextMessage := S;
end;

procedure TAppMainFormChatti.ShowShareSheetAction1Update(Sender: TObject);
begin
  case TabControl1.TabIndex of
    0:
      begin
        ShowShareSheetAction1.Enabled := True;
      end;
    1:
      begin
        ShowShareSheetAction1.Enabled := MemoModerations.Text.Trim <> '';
      end;
  end;
end;

function TAppMainFormChatti.StringRework(AText: string): string;
begin
  Result := AText;
  while Result.Contains('  ') do
  begin
    Result := Result.Replace('  ', ' ', [rfReplaceAll]);
  end;
  while Result.Contains('!') do
  begin
    Result := Result.Replace('!', '', [rfReplaceAll]);
  end;
  while Result.Contains('?') do
  begin
    Result := Result.Replace('?', '', [rfReplaceAll]);
  end;
  while Result.Contains('.') do
  begin
    Result := Result.Replace('.', '', [rfReplaceAll]);
  end;
  while Result.Contains(',') do
  begin
    Result := Result.Replace(',', '', [rfReplaceAll]);
  end;
  while Result.Contains(';') do
  begin
    Result := Result.Replace(';', '', [rfReplaceAll]);
  end;
  while Result.Contains('''') do
  begin
    Result := Result.Replace('''', '', [rfReplaceAll]);
  end;
  while Result.Contains('"') do
  begin
    Result := Result.Replace('"', '', [rfReplaceAll]);
  end;
  while Result.Contains(':') do
  begin
    Result := Result.Replace(':', '', [rfReplaceAll]);
  end;
end;

procedure TAppMainFormChatti.TextToClipBoard(ABubbleLabel: TBubbleLabel);
begin
  EditClipboard.Text := ABubbleLabel.Text;
  EditClipboard.SelectAll;
  EditClipboard.CopyToClipboard;
end;

end.
