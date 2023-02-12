// ---------------------------------------------------------------------------

// This software is Copyright (c) 2021 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

// ---------------------------------------------------------------------------

unit View.Settings;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Edit,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.ListBox,
  View.Main,
  View.Settings.Item,
  FMX.Layouts,
  FMX.Effects,
  FMX.Ani,
  FMX.Objects,
  FMX.Controls.Presentation,
  Model.Constants,
  ViewModel,
  Model.Types,
  Model.Utils;

type
  // Application settings frame.
  TSettingsFrame = class(TMainFrame)
    VertScrollBox: TVertScrollBox;
    ThemeSettingsFrame: TSettingsItemFrame;
    ApiKeyValueSettingsFrame: TSettingsItemFrame;
    ModelItemFrame: TSettingsItemFrame;
    procedure ThemeSettingsFrameValueComboBoxChange(Sender: TObject);
    procedure StringValueSettingsFrameValueEditChange(Sender: TObject);
    procedure ModelItemFrameValueComboBoxChange(Sender: TObject);
  private
    FPrevSeltext: string;
    FPrevSelIdx: Integer;
    // FUserSettings: TUserSettings;
    FViewModel: TViewModel;
    FCommonUserSettings: ICommonUserSettings;
    procedure LoadModels;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  View;

{$R *.fmx}

constructor TSettingsFrame.Create(AOwner: TComponent);
begin
  inherited;
  FCommonUserSettings := GetMainForm as ICommonUserSettings;

  case FCommonUserSettings.GetCommonUserSettings.Theme of
    tmNone:
      ThemeSettingsFrame.ValueComboBox.ItemIndex := 0;
    tmLight:
      ThemeSettingsFrame.ValueComboBox.ItemIndex := 1;
    tmDark:
      ThemeSettingsFrame.ValueComboBox.ItemIndex := 2;
  end;

  var
    ViewInfo: IViewInfo := GetMainForm as IViewInfo;
  if IsClassPresent(sModelDataClassName) then
  begin
    if not Assigned(ViewForm.ViewModel) then
    begin
      FViewModel := TViewModel.Create;
      ViewForm.ViewModel := FViewModel;
    end
    else
      FViewModel := ViewForm.ViewModel;
  end;

  // dont set apikey and model
  ApiKeyValueSettingsFrame.Visible := False;
  ModelItemFrame.Visible := False;
  Exit;

  ApiKeyValueSettingsFrame.ValueEdit.Text := FCommonUserSettings.GetCommonUserSettings.ApiKey;
  LoadModels;
  ModelItemFrame.ValueComboBox.ItemIndex := ModelItemFrame.ValueComboBox.Items.IndexOf
    (FCommonUserSettings.GetCommonUserSettings.ModelName);
end;

procedure TSettingsFrame.LoadModels;
begin
  FViewModel.GetModels(ModelItemFrame.ValueComboBox.Items);
end;

procedure TSettingsFrame.ModelItemFrameValueComboBoxChange(Sender: TObject);
begin
  inherited;
  FCommonUserSettings.GetCommonUserSettings.ModelName := TComboBox(Sender).Selected.Text;
end;

procedure TSettingsFrame.StringValueSettingsFrameValueEditChange(Sender: TObject);
begin
  inherited;
  FCommonUserSettings.GetCommonUserSettings.ApiKey := TEdit(Sender).Text;
end;

procedure TSettingsFrame.ThemeSettingsFrameValueComboBoxChange(Sender: TObject);
begin
  inherited;
  var
    ViewUtils: IViewUtils := (GetMainForm as IViewUtils);
    if Assigned(ViewUtils) then if FCommonUserSettings.GetCommonUserSettings.Theme <>
      TThemeMode(TComboBox(Sender).Selected.Index) then case TComboBox(Sender).Selected.Index of 0
      : ViewUtils.SetDefaultTheme;
    1: ViewUtils.SetViewDarkMode(False);
    2: ViewUtils.SetViewDarkMode(True);
end;
FCommonUserSettings.GetCommonUserSettings.Theme := TThemeMode(TComboBox(Sender).Selected.Index);
end;

initialization

// Register frame
RegisterClass(TSettingsFrame);

finalization

// Unregister frame
UnRegisterClass(TSettingsFrame);

end.
