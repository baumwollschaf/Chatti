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
  FMX.ListBox,
  FMX.Edit,
  FMX.EditBox,
  FMX.NumberBox;

type
  TSettingsForm = class;

  TSetting = class
  private
    FForm: TSettingsForm;
    function GetTheme: TThemeMode;
    procedure SetTheme(const AValue: TThemeMode);
    function GetTimeout: Integer;
    procedure SetTimeout(const Value: Integer);
    function GetTemperature: Double;
    procedure SetTemperature(const Value: Double);
  public
    property Theme: TThemeMode read GetTheme write SetTheme;
    property Timeout: Integer read GetTimeout write SetTimeout;
    property Temperature: Double read GetTemperature write SetTemperature;
  end;

  TSettingsForm = class(TTemplateForm)
    Layout1: TLayout;
    Label1: TLabel;
    comboTheme: TComboBox;
    Layout2: TLayout;
    Label2: TLabel;
    edTimeOut: TNumberBox;
    SpeedButton1: TSpeedButton;
    Layout3: TLayout;
    Label3: TLabel;
    edtemp: TNumberBox;
    SpeedButton2: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
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

procedure TSettingsForm.SpeedButton1Click(Sender: TObject);
begin
  inherited;
  edTimeOut.Value := 30;
end;

procedure TSettingsForm.SpeedButton2Click(Sender: TObject);
begin
  inherited;
  edtemp.Value := 0.1;
end;

{ TSettings }

function TSetting.GetTemperature: Double;
begin
  Result := FForm.edtemp.Value;
end;

function TSetting.GetTheme: TThemeMode;
begin
  Result := TThemeMode(FForm.comboTheme.Selected.Index);
end;

function TSetting.GetTimeout: Integer;
begin
  Result := Trunc(FForm.edTimeOut.Value);
end;

procedure TSetting.SetTemperature(const Value: Double);
begin
  FForm.edtemp.Value := Value;
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

procedure TSetting.SetTimeout(const Value: Integer);
begin
  FForm.edTimeOut.Value := Value;
end;

end.
