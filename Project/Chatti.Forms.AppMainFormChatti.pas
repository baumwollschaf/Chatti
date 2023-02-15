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
  FMX.TabControl;

type
  TAppMainFormChatti = class(TForm)
    Header: TToolBar;
    HeaderLabel: TLabel;
    btnSettings: TSpeedButton;
    RDChatGpt1: TRDChatGpt;
    ViewStyleBook: TStyleBook;
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout1: TGridPanelLayout;
    btnCut: TSpeedButton;
    btnCopy: TSpeedButton;
    btnPaste: TSpeedButton;
    btnSelectAll: TSpeedButton;
    btnClear: TSpeedButton;
    Layout1: TLayout;
    Label1: TLabel;
    Layout4: TLayout;
    edQuestion: TEdit;
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    SpeedButton3: TSpeedButton;
    ChBxClearQuestion: TCheckBox;
    PathSend: TPath;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    edAnswer: TMemo;
    TabItem2: TTabItem;
    chBxAnalyse: TCheckBox;
    MemoModerations: TMemo;
    Layout2: TLayout;
    Label2: TLabel;
    chBxClear: TCheckBox;
    ChBxShowQuestion: TCheckBox;
    Layout3: TLayout;
    Label3: TLabel;
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
    procedure chBxClearChange(Sender: TObject);
    procedure ChBxShowQuestionChange(Sender: TObject);
    procedure Label1ApplyStyleLookup(Sender: TObject);
    procedure ChBxClearQuestionChange(Sender: TObject);
    procedure chBxAnalyseChange(Sender: TObject);
    procedure RDChatGpt1ModerationsLoaded(Sender: TObject; AType: TModerations);
  private
    FInput: String;
    FSettings: TSettings;
    procedure AnalyzeInput(AText: String; AType: TModerations);
    function StringRework(AText: String): String;
  public
    procedure SetThemeMode(ATheme: TThemeMode);
  end;

var
  AppMainFormChatti: TAppMainFormChatti;

implementation

uses
  FMX.Text,
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

function YesOrNo(b: Boolean): String;
begin
  Result := '👎';
  if not b then
    Result := '👍';
end;

procedure TAppMainFormChatti.AnalyzeInput(AText: String; AType: TModerations);
begin
  MemoModerations.Text := '';
  var
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
    MemoModerations.Lines.Add('Hate Threatening: ' + YesOrNo(AType.Results[0].Categories.HateThreatening) + '  Score: ' +
      AType.Results[0].CategoryScores.HateThreatening.ToString);
    MemoModerations.Lines.Add('Self Harm: ' + YesOrNo(AType.Results[0].Categories.SelfHarm) + '  Score: ' +
      AType.Results[0].CategoryScores.SelfHarm.ToString);
    MemoModerations.Lines.Add('Sexual: ' + YesOrNo(AType.Results[0].Categories.Sexual) + '  Score: ' + AType.Results[0]
      .CategoryScores.Sexual.ToString);
    MemoModerations.Lines.Add('Sexual Minors: ' + YesOrNo(AType.Results[0].Categories.SexualMinors) + '  Score: ' +
      AType.Results[0].CategoryScores.SexualMinors.ToString);
    MemoModerations.Lines.Add('Violence: ' + YesOrNo(AType.Results[0].Categories.Violence) + '  Score: ' +
      AType.Results[0].CategoryScores.Violence.ToString);
    MemoModerations.Lines.Add('Violence Graphic: ' + YesOrNo(AType.Results[0].Categories.ViolenceGraphic) + '  Score: ' +
      AType.Results[0].CategoryScores.ViolenceGraphic.ToString);
  end;
end;

procedure TAppMainFormChatti.btnAskClick(Sender: TObject);
begin
  if edQuestion.Text.Trim = '' then
    Exit;
  FInput := edQuestion.Text;
  RDChatGpt1.Ask(FInput);
end;

procedure TAppMainFormChatti.btnCutClick(Sender: TObject);
begin
  var
    Btn: TSpeedButton := TSpeedButton(Sender);
  if Btn = nil then
    Exit;

  var
    Intf: ITextActions := nil;

  if Focused = nil then
    Exit;

  if Focused.GetObject = nil then
    Exit;

  if not Supports(Focused.GetObject, ITextActions, Intf) then
    Exit;

  if Intf = nil then
    Exit;

  case Btn.Tag of
    0:
      begin
        Intf.CutToClipboard;
      end;
    1:
      begin
        Intf.CopyToClipboard;
      end;
    2:
      begin
        Intf.PasteFromClipboard;
      end;
    3:
      begin
        Intf.SelectAll;
      end;
    4:
      begin
        Intf.SelectAll;
        Intf.DeleteSelection;
      end;
  end;

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

procedure TAppMainFormChatti.chBxAnalyseChange(Sender: TObject);
begin
  FSettings.Analyze := chBxAnalyse.IsChecked;
  FSettings.Save;
end;

procedure TAppMainFormChatti.chBxClearChange(Sender: TObject);
begin
  FSettings.ClearAnswer := chBxClear.IsChecked;
  FSettings.Save;
end;

procedure TAppMainFormChatti.ChBxClearQuestionChange(Sender: TObject);
begin
  FSettings.ClearQuestion := ChBxClearQuestion.IsChecked;
  FSettings.Save;
end;

procedure TAppMainFormChatti.ChBxShowQuestionChange(Sender: TObject);
begin
  FSettings.QuestionInAnswer := ChBxShowQuestion.IsChecked;
  FSettings.Save;
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
{$IFNDEF MSWINDOWS}
  btnCut.RotationAngle := -90;
{$ENDIF}
  TabControl1.ActiveTab := TabItem1;
  FSettings := TSettings.Create(RDChatGpt1);
  FSettings.Load;
  RDChatGpt1.ApiKey := S(TExternalStuff.ApiKey);
  RDChatGpt1.LoadModels;
  SetThemeMode(FSettings.ThemeMode);
  chBxClear.IsChecked := FSettings.ClearAnswer;
  ChBxClearQuestion.IsChecked := FSettings.ClearQuestion;
  ChBxShowQuestion.IsChecked := FSettings.QuestionInAnswer;
  chBxAnalyse.IsChecked := FSettings.Analyze;
end;

procedure TAppMainFormChatti.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSettings);
end;

procedure TAppMainFormChatti.Label1ApplyStyleLookup(Sender: TObject);
begin
  PathSend.Fill.Color := Label1.GetStyledColor;
  PathSend.Stroke.Color := Label1.GetStyledColor;
end;

procedure TAppMainFormChatti.RDChatGpt1Answer(Sender: TObject; AMessage: string);
begin
  if chBxClear.IsChecked then
  begin
    edAnswer.Lines.Clear;
  end;
  if ChBxShowQuestion.IsChecked then
  begin
    edAnswer.Lines.Add('me: ' + FInput);
    edAnswer.Lines.Add('-----');
  end;
  if ChBxClearQuestion.IsChecked then
  begin
    edQuestion.Text := '';
    edQuestion.SetFocus;
  end;
  edAnswer.Lines.Add(AMessage);
  edAnswer.Lines.Add('');

  if chBxAnalyse.IsChecked then
  begin
    RDChatGpt1.LoadModerations(FInput);
  end;
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
    StyleRes := TResourceStream.Create(HInstance, 'Dark', RT_RCDATA)
  else
    StyleRes := TResourceStream.Create(HInstance, 'Light', RT_RCDATA);
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
  case TabControl1.TabIndex of
    0:
      begin
        ShowShareSheetAction1.TextMessage := edAnswer.Text;
      end;
    1:
      begin
        ShowShareSheetAction1.TextMessage := MemoModerations.Text;
      end;
  end;
end;

procedure TAppMainFormChatti.ShowShareSheetAction1Update(Sender: TObject);
begin
  case TabControl1.TabIndex of
    0:
      begin
        ShowShareSheetAction1.Enabled := edAnswer.Text.Trim <> '';
      end;
    1:
      begin
        ShowShareSheetAction1.Enabled := MemoModerations.Text.Trim <> '';
      end;
  end;
end;

function TAppMainFormChatti.StringRework(AText: String): String;
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

end.
