unit Chatti.Types;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IniFiles,
  FMX.Objects,
  FMX.Controls,
  System.Threading,
  FMX.StdCtrls,
  FMX.Types,
  System.IOUtils,
  rd.OpenAI.ChatGpt.ViewModel;

type
  TLabelHelper = class helper for TLabel
    function GetStyledColor: TAlphaColor;
    procedure ResetStyleSettings;
    procedure EnableStyledColor;
    procedure EnableStyledTextSize;
  end;

type
  TThemeMode = (tmNone, tmLight, tmDark);

  TSettings = class
  private
    FThemeMode: TThemeMode;
    FRDChat: TRDChatGpt;
    FClearAnswer: Boolean;
    FClearQuestion: Boolean;
    FQuestionInAnswer: Boolean;
    FAnalyze: Boolean;
    FSendNotification: Boolean;
    procedure LoadSave(ASave: Boolean);
  public
    procedure Load;
    procedure Save;
    constructor Create(ARDChat: TRDChatGpt);
    destructor Destroy; override;
    property ThemeMode: TThemeMode read FThemeMode write FThemeMode;
    property ClearAnswer: Boolean read FClearAnswer write FClearAnswer;
    property ClearQuestion: Boolean read FClearQuestion write FClearQuestion;
    property Analyze: Boolean read FAnalyze write FAnalyze;
    property QuestionInAnswer: Boolean read FQuestionInAnswer write FQuestionInAnswer;
    property SendNotification: Boolean read FSendNotification write FSendNotification;
  end;

procedure SynchronizedRun(Proc: TProc);

implementation

procedure SynchronizedRun(Proc: TProc);
begin
  TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          Proc
        end)
    end);
end;

constructor TSettings.Create(ARDChat: TRDChatGpt);
begin
  inherited Create;
  FRDChat := ARDChat;
end;

destructor TSettings.Destroy;
begin

  inherited;
end;

procedure TSettings.LoadSave(ASave: Boolean);
begin
  var
    FileName: String := IncludeTrailingPathDelimiter(TPath.GetDocumentsPath) + 'chatti.dat';
  with TIniFile.Create(FileName) do
  begin
    try
      if ASave then
      begin
        WriteString('RDChat', 'URL', FRDChat.URL);
        WriteString('RDChat', 'Model', FRDChat.Model);
        WriteFloat('RDChat', 'Temperature', FRDChat.Temperature);
        WriteInteger('RDChat', 'MaxTokens', FRDChat.MaxTokens);
        WriteInteger('RDChat', 'TimeOutSec', FRDChat.TimeOutSeconds);

        WriteInteger('General', 'ThemeMode', Ord(FThemeMode));
        WriteBool('General', 'ClearAnswer', FClearAnswer);
        WriteBool('General', 'ClearQuestion', FClearQuestion);
        WriteBool('General', 'QuestionInAnswer', FQuestionInAnswer);
        WriteBool('General', 'SendNotification', FSendNotification);
        WriteBool('General', 'Analyze', FAnalyze);
      end else begin
        FRDChat.URL := ReadString('RDChat', 'URL', 'https://api.openai.com/v1');
        FRDChat.Model := ReadString('RDChat', 'Model', 'text-davinci-003');
        FRDChat.Temperature := ReadFloat('RDChat', 'Temperature', 0.1);
        FRDChat.MaxTokens := ReadInteger('RDChat', 'MaxTokens', 2048);
        FRDChat.TimeOutSeconds := ReadInteger('RDChat', 'TimeOutSec', 90);

        FThemeMode := TThemeMode(ReadInteger('General', 'ThemeMode', Ord(tmDark)));
        FClearAnswer := ReadBool('General', 'ClearAnswer', False);
        FClearQuestion := ReadBool('General', 'ClearQuestion', False);
        FQuestionInAnswer := ReadBool('General', 'QuestionInAnswer', True);
        FSendNotification := ReadBool('General', 'SendNotification', True);
        FAnalyze := ReadBool('General', 'Analyze', False);
      end;
    finally
      Free;
    end;
  end;
end;

procedure TSettings.Load;
begin
  LoadSave(False);
end;

procedure TSettings.Save;
begin
  LoadSave(True);
end;

{ TLabelHelper }

procedure TLabelHelper.EnableStyledColor;
begin
  Self.StyledSettings := Self.StyledSettings + [TStyledSetting.FontColor];
end;

procedure TLabelHelper.EnableStyledTextSize;
begin
  Self.StyledSettings := Self.StyledSettings + [TStyledSetting.Size];
end;

function TLabelHelper.GetStyledColor: TAlphaColor;
begin
  Result := Self.TextSettings.FontColor;
  var
    Text: TText := TText(TControl(Self).FindStyleResource('text'));
  if Assigned(Text) then
    Result := Text.TextSettings.FontColor
end;

procedure TLabelHelper.ResetStyleSettings;
begin
  Self.StyledSettings := [];
end;

end.
