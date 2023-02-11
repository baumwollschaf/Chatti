// ---------------------------------------------------------------------------

// This software is Copyright (c) 2021 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

// ---------------------------------------------------------------------------

unit Model;

interface

uses
  System.Classes,
  System.Variants,
  FMX.Forms;

type
  // Implements basic routines to DB data access
  TModel = class(TObject)
  private
    FModelData: TDataModule;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  ModelData: TDataModule;

implementation

uses
  Model.Constants,
  Model.Types,
  Model.Utils;

{ TModel }

constructor TModel.Create;
begin
  // Create Model.Data instance
  if IsClassPresent(sModelDataClassName) then
  begin
    var
      ModelDataClass: TPersistent := GetClass(sModelDataClassName).Create;
    FModelData := TDataModule(ModelDataClass).Create(Application);
    ModelData := FModelData;
  end;
end;

// Get data from DB.
destructor TModel.Destroy;
begin
  ModelData := nil;
  FModelData.Destroy;
  inherited;
end;

end.
