unit Chatti.Types;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IniFiles,
  System.IOUtils,
  System.Threading,
  rd.OpenAI.ChatGpt.ViewModel;

type
  TThemeMode = (tmNone, tmLight, tmDark);

  TSettings = class
  private
    FThemeMode: TThemeMode;
    FRDChat: TRDChatGpt;
    FClearAnswer: Boolean;
    FQuestionInAnswer: Boolean;
    FSendNotification: Boolean;
    procedure LoadSave(ASave: Boolean);
  public
    procedure Load;
    procedure Save;
    constructor Create(ARDChat: TRDChatGpt);
    destructor Destroy; override;
    property ThemeMode: TThemeMode read FThemeMode write FThemeMode;
    property ClearAnswer: Boolean read FClearAnswer write FClearAnswer;
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

        WriteInteger('General', 'ThemeMode', Ord(FThemeMode));
        WriteBool('General', 'ClearAnswer', FClearAnswer);
        WriteBool('General', 'QuestionInAnswer', FQuestionInAnswer);
        WriteBool('General', 'SendNotification', FSendNotification);
      end else begin
        FRDChat.URL := ReadString('RDChat', 'URL', 'https://api.openai.com/v1');
        FRDChat.Model := ReadString('RDChat', 'Model', 'text-davinci-003');
        FRDChat.Temperature := ReadFloat('RDChat', 'Temperature', 0.1);
        FRDChat.MaxTokens := ReadInteger('RDChat', 'MaxTokens', 2048);

        FThemeMode := TThemeMode(ReadInteger('General', 'ThemeMode', Ord(tmDark)));
        FClearAnswer := ReadBool('General', 'ClearAnswer', False);
        FQuestionInAnswer := ReadBool('General', 'QuestionInAnswer', True);
        FSendNotification := ReadBool('General', 'SendNotification', True);
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

end.
