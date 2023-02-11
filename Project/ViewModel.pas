// ---------------------------------------------------------------------------

// This software is Copyright (c) 2021 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

// ---------------------------------------------------------------------------

unit ViewModel;

interface

uses
  System.SysUtils,
  System.Classes,
  Model,
  Model.Types,
  Model.Constants,
  Data.DB,
  Variants,
  Model.Utils;

type
  TViewModel = class
  private
    FModel: TModel;
  public
    procedure Ask(AQuestion: string; AAnswer: TAnswerRefCallback);
    procedure GetModels(AModels: TStrings);
    procedure SetApiKey(AKey: string);

    destructor Destroy; override;
    constructor Create;
  end;

implementation

{ TViewModel }

constructor TViewModel.Create;
begin
  FModel := TModel.Create;
end;

destructor TViewModel.Destroy;
begin
  FModel.DisposeOf;
  inherited;
end;

procedure TViewModel.Ask(AQuestion: string; AAnswer: TAnswerRefCallback);
begin
  (ModelData as IModelData).Ask(AQuestion, AAnswer);
end;

procedure TViewModel.GetModels(AModels: TStrings);
begin
  (ModelData as IModelData).GetModels(AModels);
end;

procedure TViewModel.SetApiKey(AKey: string);
begin
  (ModelData as IModelData).SetApiKey(AKey);
end;

end.
