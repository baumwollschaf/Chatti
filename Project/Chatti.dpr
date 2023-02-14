program Chatti;

uses
  System.StartUpCopy,
  FMX.Forms,
  Chatti.Forms.AppMainFormChatti in 'Chatti.Forms.AppMainFormChatti.pas' {AppMainFormChatti},
  Chatti.Forms.TemplateForm in 'Chatti.Forms.TemplateForm.pas' {TemplateForm},
  Chatti.Forms.SettingsForm in 'Chatti.Forms.SettingsForm.pas' {SettingsForm},
  {$IFDEF baumwollschaf}
  Extern.ApiKey in 'Extern.ApiKey.pas',
  {$ENDIF }
  Chatti.Types in 'Chatti.Types.pas',
  Chatti.Crypto in 'Chatti.Crypto.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TAppMainFormChatti, AppMainFormChatti);
  Application.Run;

end.
