// ---------------------------------------------------------------------------

// This software is Copyright (c) 2021 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

// ---------------------------------------------------------------------------

{
  NOTE: For work with database you should setup deployment for IB license
  http://docwiki.embarcadero.com/RADStudio/Sydney/en/IBLite_and_IBToGo_Deployment_Licensing
}

unit Model.Data;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  FMX.Dialogs,
  FMX.Forms,
  Model.Constants,
  Model.Types,
  Model.Utils,
  rd.OpenAI.ChatGpt.ViewModel;

type
  // Data access layer.
  TModelData = class(TDataModule, IModelData)
    ChatGpt: TRDChatGpt;
  protected
    FAnswer: TAnswerRefCallback;
    procedure Ask(AQuestion: String; AAnswer: TAnswerRefCallback);
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    { IModelData }
    // function GetFDConnection: TFDConnection;
    // function GetFDQueryGrid: TFDQuery;
    // function GetFDQueryListView: TFDQuery;
  end;

implementation

{$R *.dfm}
{ TModelData }

procedure TModelData.Ask(AQuestion: String; AAnswer: TAnswerRefCallback);
begin
  FAnswer := AAnswer;
end;

constructor TModelData.Create;
var
  LDatabasePath: string;
begin
  inherited Create(nil);
{$IFDEF MSWINDOWS}
  LDatabasePath := TDirectory.GetParent(TDirectory.GetParent(TDirectory.GetParent(TPath.GetLibraryPath)));
  if Application.IsUnitTestRunning then
    LDatabasePath := TDirectory.GetParent(LDatabasePath);
  LDatabasePath := TPath.Combine(LDatabasePath, sDBStoragePathWindows);
{$ENDIF}
{$IF Defined(ANDROID) or Defined(IOS)}
  LDatabasePath := TPath.GetDocumentsPath;
{$ENDIF}
  LDatabasePath := TPath.Combine(LDatabasePath, sDBName);
  // Init(LDatabasePath);
end;

destructor TModelData.Destroy;
begin
  DestroyComponents;
  inherited;
end;

// Init database connection
// procedure TModelData.Init(DatabasePath: string);
// begin
// FDConnection.Params.Database := DatabasePath;
// try
// FDConnection.Connected := True;
// except
// on E: Exception do
// ShowMessage(Concat(sIBLiteErrorPrefix, E.Message));
// end;
// end;

// implements IModelData
// function TModelData.GetFDConnection: TFDConnection;
// begin
// Result := FDConnection;
// end;
//
/// / implements IModelData
// function TModelData.GetFDQueryGrid: TFDQuery;
// begin
// Result := FDQueryGrid;
// end;
//
/// / implements IModelData
// function TModelData.GetFDQueryListView: TFDQuery;
// begin
// Result := FDQueryListView;
// end;

initialization

// Register frame
RegisterClass(TModelData);

finalization

// Unregister frame
UnRegisterClass(TModelData);

end.
