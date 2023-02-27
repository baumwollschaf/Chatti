program Chatti;

uses
  System.StartUpCopy,
  System.SysUtils,
  FMX.Forms,
  FMX.Types,
  Skia.FMX,
  Chatti.Forms.AppMainFormChatti in 'Chatti.Forms.AppMainFormChatti.pas' {AppMainFormChatti} ,
  Chatti.Forms.TemplateForm in 'Chatti.Forms.TemplateForm.pas' {TemplateForm} ,
  Chatti.Forms.SettingsForm in 'Chatti.Forms.SettingsForm.pas' {SettingsForm} ,
{$IFDEF baumwollschaf}
  Extern.ApiKey in 'Extern.ApiKey.pas',
{$ENDIF }
  Chatti.Types in 'Chatti.Types.pas',
  Chatti.BubbleLabel in 'Chatti.BubbleLabel.pas',
  Chatti.Types.Persistent.Json in 'Chatti.Types.Persistent.Json.pas';

{$R *.res}

begin
  GlobalUseMetal := True;
  GlobalUseSkia := True;
  GlobalUseSkiaRasterWhenAvailable := False;
  Application.Initialize;
  FormatSettings.LongDateFormat := 'dd.mm.yyyy hh:nn';
  FormatSettings.ShortDateFormat := 'dd.mm.yyyy';
  FormatSettings.LongTimeFormat := 'hh:nn';
  Application.CreateForm(TAppMainFormChatti, AppMainFormChatti);
  Application.Run;

end.
