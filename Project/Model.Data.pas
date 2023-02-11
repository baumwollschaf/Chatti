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
  rd.OpenAI.ChatGpt.Model,
  rd.OpenAI.ChatGpt.ViewModel;

type
  // Data access layer.
  TModelData = class(TDataModule, IModelData)
    ChatGpt: TRDChatGpt;
    procedure DataModuleCreate(Sender: TObject);
    procedure ChatGptModelsLoaded(Sender: TObject; AType: TModels);
    procedure ChatGptAnswer(Sender: TObject; AMessage: string);
  protected
    FAnswer: TAnswerRefCallback;
    FModels: TStringList;
    FInitialized: Boolean;
    procedure Ask(AQuestion: string; AAnswer: TAnswerRefCallback);
    procedure GetModels(AModels: TStrings);
    procedure SetApiKey(AKey: string);
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

procedure TModelData.Ask(AQuestion: string; AAnswer: TAnswerRefCallback);
begin
  if not FInitialized then
    Exit;
  FAnswer := AAnswer;
  ChatGpt.Ask(AQuestion);
end;

procedure TModelData.ChatGptAnswer(Sender: TObject; AMessage: string);
begin
  if Assigned(FAnswer) then
    FAnswer(AMessage);
end;

procedure TModelData.ChatGptModelsLoaded(Sender: TObject; AType: TModels);
begin
  FModels.Clear;
  for var i: integer := 0 to AType.Data.Count - 1 do
  begin
    FModels.Add(AType.Data[i].Id);
  end;
  FInitialized := True;
end;

constructor TModelData.Create;
begin
  inherited Create(nil);
  FModels := TStringList.Create;
end;

procedure TModelData.DataModuleCreate(Sender: TObject);
begin
{$IFDEF DEBUG}
//  if TFile.Exists('ApiKey.txt') then
//  begin
//    ChatGpt.ApiKey := TFile.ReadAllText('ApiKey.txt');
//  end;
  ChatGpt.LoadModels;
{$ENDIF}
end;

destructor TModelData.Destroy;
begin
  FreeAndNil(FModels);
  DestroyComponents;
  inherited;
end;

procedure TModelData.GetModels(AModels: TStrings);
begin
  AModels.Assign(FModels);
end;

procedure TModelData.SetApiKey(AKey: string);
begin
  ChatGpt.ApiKey := AKey;
end;

initialization

// Register frame
RegisterClass(TModelData);

finalization

// Unregister frame
UnRegisterClass(TModelData);

end.
