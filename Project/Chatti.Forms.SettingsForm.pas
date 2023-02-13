unit Chatti.Forms.SettingsForm;

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
  Chatti.Forms.TemplateForm,
  FMX.Controls.Presentation,
  FMX.Layouts,
  Chatti.Types,
  FMX.ListBox;

type
  TSettingsForm = class;

  TSetting = class
  private
    FForm: TSettingsForm;
    function GetTheme: TThemeMode;
    procedure SetTheme(const AValue: TThemeMode);
  public
    property Theme: TThemeMode read GetTheme write SetTheme;
  end;

  TSettingsForm = class(TTemplateForm)
    Layout1: TLayout;
    Label1: TLabel;
    comboTheme: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSettings: TSetting;
  protected
    function GetObject: TObject; override;
  public
    property Settings: TSetting read FSettings write FSettings;
  end;

var
  SettingsForm: TSettingsForm;

implementation

// uses
// Chatti.Forms.AppMainFormChatti;

{$R *.fmx}
{ TSettingsForm }

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  inherited;
  {$IFNDEF MSWINDOWS}
  btnNext.Text := '';
  {$ENDIF}

  FSettings := TSetting.Create;
  FSettings.FForm := Self;
end;

procedure TSettingsForm.FormDestroy(Sender: TObject);
begin
  inherited;
  FreeAndNil(FSettings);
end;

function TSettingsForm.GetObject: TObject;
begin
  Result := FSettings;
end;

{ TSettings }

function TSetting.GetTheme: TThemeMode;
begin
  Result := TThemeMode(FForm.comboTheme.Selected.Index);
end;

procedure TSetting.SetTheme(const AValue: TThemeMode);
begin
  case AValue of
    tmNone:
      FForm.comboTheme.ItemIndex := 0;
    tmLight:
      FForm.comboTheme.ItemIndex := 1;
    tmDark:
      FForm.comboTheme.ItemIndex := 2;
  end;
end;

end.
