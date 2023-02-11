program Chatti;

uses
  System.StartUpCopy,
  System.SysUtils,
  View.Main in 'View.Main.pas' {MainFrame: TFrame},
  Model.Constants in 'Model.Constants.pas',
  Model.Types in 'Model.Types.pas',
  Model.Utils in 'Model.Utils.pas',
  View.Menu in 'View.Menu.pas' {MenuFrame: TFrame},
  View.Menu.Item in 'View.Menu.Item.pas' {MenuItemFrame: TFrame},
  Model in 'Model.pas',
  ViewModel in 'ViewModel.pas',
  View.Home in 'View.Home.pas' {HomeFrame: TFrame},
  View.Settings.Item in 'View.Settings.Item.pas' {SettingsItemFrame: TFrame},
  View.Settings in 'View.Settings.pas' {SettingsFrame: TFrame},
  Model.Data in 'Model.Data.pas' {ModelData: TDataModule},
  FMX.Forms,
  View in 'View.pas' {ViewForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewForm, ViewForm);
  Application.Run;
end.
