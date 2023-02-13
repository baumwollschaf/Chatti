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
  FMX.MediaLibrary.Actions;

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
    btnQuestionMark: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Layout4: TLayout;
    btnAsk: TSpeedButton;
    edQuestion: TEdit;
    Layout2: TLayout;
    Label2: TLabel;
    chBxClear: TCheckBox;
    ChBxShowQuestion: TCheckBox;
    edAnswer: TMemo;
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    SpeedButton3: TSpeedButton;
    procedure btnSettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCutClick(Sender: TObject);
    procedure btnQuestionMarkClick(Sender: TObject);
    procedure btnAskClick(Sender: TObject);
    procedure RDChatGpt1Answer(Sender: TObject; AMessage: string);
    procedure edQuestionKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure ShowShareSheetAction1BeforeExecute(Sender: TObject);
    procedure ShowShareSheetAction1Update(Sender: TObject);
    procedure chBxClearChange(Sender: TObject);
    procedure ChBxShowQuestionChange(Sender: TObject);
  private
    FCurQuestion: String;
    FSettings: TSettings;
  public
    procedure SetThemeMode(ATheme: TThemeMode);
  end;

var
  AppMainFormChatti: TAppMainFormChatti;

implementation

uses
  FMX.Text;

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

procedure TAppMainFormChatti.btnAskClick(Sender: TObject);
begin
  if edQuestion.Text.Trim = '' then
    Exit;
  FCurQuestion := edQuestion.Text;
  RDChatGpt1.Cancel;
  RDChatGpt1.Ask(FCurQuestion);
end;

procedure TAppMainFormChatti.btnCutClick(Sender: TObject);
begin
  var
    Btn: TSpeedButton := TSpeedButton(Sender);
  if Btn = nil then
    Exit;

  var
    Intf: ITextActions := nil;
  if edQuestion.IsFocused then
    Intf := edQuestion
  else if edAnswer.IsFocused then
    Intf := edAnswer;

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

procedure TAppMainFormChatti.btnQuestionMarkClick(Sender: TObject);
begin
  if edQuestion.Text.Trim = '' then
    Exit;

  var
    Btn: TSpeedButton := TSpeedButton(Sender);
  if Btn = nil then
    Exit;

  var
    Char: Char;

  case Btn.Tag of
    0:
      begin
        Char := '?';
      end;
    1:
      begin
        Char := '!';
      end;
    2:
      begin
        Char := '.';
      end;
    else
      Exit;
  end;
  edQuestion.Text := edQuestion.Text.TrimRight + Char;
  edQuestion.SelStart := edQuestion.Text.Length;
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
      if CurTheme <> TSetting(Setting).Theme then
      begin
        FSettings.ThemeMode := TSetting(Setting).Theme;
        FSettings.Save;
        SetThemeMode(FSettings.ThemeMode);
      end;
    end);
  SettingsForm.Settings.Theme := CurTheme;
  SettingsForm.Show;
end;

procedure TAppMainFormChatti.chBxClearChange(Sender: TObject);
begin
  FSettings.ClearAnswer := chBxClear.IsChecked;
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
  FSettings := TSettings.Create(RDChatGpt1);
  FSettings.Load;
  RDChatGpt1.ApiKey := S(TExternalStuff.ApiKey);
  RDChatGpt1.LoadModels;
  SetThemeMode(FSettings.ThemeMode);
  chBxClear.IsChecked := FSettings.ClearAnswer;
  ChBxShowQuestion.IsChecked := FSettings.QuestionInAnswer;
end;

procedure TAppMainFormChatti.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSettings);
end;

procedure TAppMainFormChatti.RDChatGpt1Answer(Sender: TObject; AMessage: string);
begin
  if chBxClear.IsChecked then
  begin
    edAnswer.Lines.Clear;
  end;
  if ChBxShowQuestion.IsChecked then
  begin
    edAnswer.Lines.Add('me: ' + FCurQuestion);
    edAnswer.Lines.Add('-----');
    edQuestion.Text := '';
    edQuestion.SetFocus;
  end;
  edAnswer.Lines.Add(AMessage);
  edAnswer.Lines.Add('');
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
  ShowShareSheetAction1.TextMessage := edAnswer.Text;
end;

procedure TAppMainFormChatti.ShowShareSheetAction1Update(Sender: TObject);
begin
  ShowShareSheetAction1.Enabled := edAnswer.Text.Trim <> '';
end;

end.
