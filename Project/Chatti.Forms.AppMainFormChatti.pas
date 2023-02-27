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
  FMX.DialogService,
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
  System.Threading,
  Chatti.Types.Persistent.Json,
  FMX.Ani,


  Skia,
  Skia.FMX;

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
    sbMessages: TVertScrollBox;
    btnShare: TSpeedButton;
    btnClear: TSpeedButton;
    EditClipboard: TEdit;
    MainLayout: TLayout;
    btnAsk: TSearchEditButton;
    TimerInfo: TTimer;
    PanelInfo: TRectangle;
    LabelInfo: TLabel;
    saiAnimatedLogo: TSkAnimatedImage;
    fanFadeOutTransition: TFloatAnimation;
    lytContent: TLayout;
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
    procedure RDChatGpt1ModerationsLoaded(Sender: TObject; AType: TModerations);
    procedure FormShow(Sender: TObject);
    procedure TimerInfoTimer(Sender: TObject);
    procedure RDChatGpt1Error(Sender: TObject; AMessage: string);
    procedure saiAnimatedLogoAnimationFinish(Sender: TObject);
  private
    FLoading: Boolean;
    FInput: string;
    FWasMe: Boolean;
    FSettings: TSettings;
    FChattiMessages: TChattiMessages;
    FFileNameChattiMessages: String;
    procedure ShowInfo(AText: String);
    procedure HideInfo;
    function GetLabelsText: string;
    procedure AddLabel(AText: string; AMe: Boolean; AFollowing: Boolean; ADate: TDateTime = 0);
    procedure AnalyzeInput(AText: string; AType: TModerations);
    function StringRework(AText: string): string;
    procedure TextToClipBoard(ABubbleLabel: TChatBubbleLabel);
    procedure LoadChattiMessages;
    procedure SaveChattiMessages;
  private
    procedure TapClick(Sender: TObject);
    procedure ControlGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
  public
    procedure SetThemeMode(ATheme: TThemeMode);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  AppMainFormChatti: TAppMainFormChatti;

implementation

uses
  FMX.Text,
  System.Math,
  System.IOUtils;

type
  TVertScrollBoxHack = class(TVertScrollBox);

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

procedure TAppMainFormChatti.AddLabel(AText: string; AMe: Boolean; AFollowing: Boolean; ADate: TDateTime);
begin
  var
    Labl: TChatBubbleLabel;
  Labl := TChatBubbleLabel.Create(sbMessages);
  Labl.BubbleText := AText;
  Labl.OnTapClick := TapClick;
  Labl.Me := AMe;
  Labl.Following := AFollowing;
  if ADate <> 0 then
  begin
    Labl.DateTime := ADate;
  end;
  if not FLoading then
  begin
    try
      sbMessages.ScrollBy(0, -(TVertScrollBoxHack(sbMessages).VScrollBar.Value + 999999));
    except
      ;
    end;
  end;
  Labl.Resize;
  // sbMessages.repaint;
  // sbMessages.RealignContent;
  // sbMessages.RecalcSize;
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

  FLoading := False;
  SynchronizedRun(
    procedure
    begin
      case TabControl1.TabIndex of
        0:
          begin
            FInput := edQuestion.Text;
            edQuestion.Text := '';
            RDChatGpt1.Ask(FInput);
            AddLabel(FInput, True, FWasMe and True);
            FChattiMessages.Add(FInput, True, Now);
            SaveChattiMessages;
            FWasMe := True;
          end;
        1:
          begin
            FInput := edQuestion.Text;
            edQuestion.Text := '';
            RDChatGpt1.LoadModerations(FInput);
          end;
      end;
    end);
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
        TDialogService.MessageDialog('Clear chat?', TMsgDlgType.mtConfirmation, mbYesNo, TMsgDlgBtn.mbNo, 0,
          procedure(const AResult: TModalResult)
          begin
            case AResult of
              mrYes:
                begin
                  FWasMe := False;
                  TChatBubbleLabel.Clear;
                  FChattiMessages.Clear;
                  SaveChattiMessages;
                end;
            end;
          end);
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
    TextToClipBoard(TChatBubbleLabel(Sender));
    Handled := True;
  end;
end;

constructor TAppMainFormChatti.Create(AOwner: TComponent);
begin
  inherited;
  HideInfo;
  FLoading := True;
  FFileNameChattiMessages := IncludeTrailingPathDelimiter(TPath.GetHomePath) + 'ChattiMessages.Dat';
  FChattiMessages := TChattiMessages.Create;
end;

destructor TAppMainFormChatti.Destroy;
begin
  FreeAndNil(FChattiMessages);
  inherited;
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
  Fill.Color := $FF372C7C; // Purple
  saiAnimatedLogo.Visible := True;
  saiAnimatedLogo.BringToFront;
  lytContent.Visible := False;

  TabControl1.ActiveTab := TabItem1;
  FSettings := TSettings.Create(RDChatGpt1);
  FSettings.Load;
  RDChatGpt1.ApiKey := S(TExternalStuff.ApiKey);
{$IFDEF DEBUG}
  RDChatGpt1.LoadModels;
{$ENDIF}
  SetThemeMode(FSettings.ThemeMode);
end;

procedure TAppMainFormChatti.FormDestroy(Sender: TObject);
begin
  TChatBubbleLabel.Clear;
  FreeAndNil(FSettings);
end;

procedure TAppMainFormChatti.FormShow(Sender: TObject);
begin
  LoadChattiMessages;
end;

function TAppMainFormChatti.GetLabelsText: string;
begin
  Result := '';
  var
    Who: string;

  var
    Bub: TChatBubbleLabel;
  for var i: Integer := 0 to TChatBubbleLabel.List.Count - 1 do
  begin
    Bub := TChatBubbleLabel.List[i];
    if Result <> '' then
    begin
      Result := Result + #13#10 + #13#10;
    end;
    if Bub.Me then
    begin
      Who := 'me: ';
    end else begin
      Who := 'Chatti: ';
    end;
    Result := Result + Who + Bub.BubbleText;
  end;
end;

procedure TAppMainFormChatti.HideInfo;
begin
  TimerInfo.Enabled := False;
  PanelInfo.Visible := False;
end;

procedure TAppMainFormChatti.RDChatGpt1Answer(Sender: TObject; AMessage: string);
begin
  AddLabel(AMessage, False, (not FWasMe) and False);
  FChattiMessages.Add(AMessage, False, Now);
  SaveChattiMessages;
  FWasMe := False;
end;

procedure TAppMainFormChatti.RDChatGpt1Error(Sender: TObject; AMessage: string);
begin
  ShowInfo(AMessage);
end;

procedure TAppMainFormChatti.RDChatGpt1ModerationsLoaded(Sender: TObject; AType: TModerations);
begin
  // still in thread-mode!
  AnalyzeInput(FInput, AType);
end;

procedure TAppMainFormChatti.saiAnimatedLogoAnimationFinish(Sender: TObject);
begin
  lytContent.Visible := True;
  Fill.Color := $FFEBEEF1; // Light gray
  fanFadeOutTransition.Enabled := True;
end;

procedure TAppMainFormChatti.LoadChattiMessages;
begin
  TTask.Run(
    procedure
    begin
      var
        S: String := '';
      if TFile.Exists(FFileNameChattiMessages) then
      begin
        S := TFile.ReadAllText(FFileNameChattiMessages)
      end;
      if S = '' then
        Exit;
      FChattiMessages.LoadFromJson(S);

      TThread.Synchronize(nil,
        procedure
        begin
          var
            wasMe: Boolean := False;
          var
            follow: Boolean;
          for var i: Integer := 0 to FChattiMessages.Count - 1 do
          begin
            if FChattiMessages[i].Me then
            begin
              follow := wasMe;
            end else begin
              follow := not wasMe;
            end;

            AddLabel(FChattiMessages[i].Message, FChattiMessages[i].Me, follow, FChattiMessages[i].Date);
            wasMe := FChattiMessages[i].Me;
          end;

        end)
    end);
end;

procedure TAppMainFormChatti.SaveChattiMessages;
begin
  TTask.Run(
    procedure
    begin
      var
        S: String := '';
      if TFile.Exists(FFileNameChattiMessages) then
      begin
        TFile.Delete(FFileNameChattiMessages);
      end;
      S := FChattiMessages.ToJson;
      TFile.AppendAllText(FFileNameChattiMessages, S);
    end);
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
  end else begin
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

procedure TAppMainFormChatti.ShowInfo(AText: String);
begin
  if AText.Trim = '' then
    Exit;
  LabelInfo.Text := AText;
  PanelInfo.Visible := True;
  TimerInfo.Enabled := True;
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

procedure TAppMainFormChatti.TapClick(Sender: TObject);
begin
  TextToClipBoard(TChatBubbleLabel(Sender));
  ShowInfo('Copied');
end;

procedure TAppMainFormChatti.TextToClipBoard(ABubbleLabel: TChatBubbleLabel);
begin
  EditClipboard.Text := ABubbleLabel.BubbleText;
  EditClipboard.SelectAll;
  EditClipboard.CopyToClipboard;
end;

procedure TAppMainFormChatti.TimerInfoTimer(Sender: TObject);
begin
  HideInfo;
end;

end.
