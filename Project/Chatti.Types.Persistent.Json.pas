unit Chatti.Types.Persistent.Json;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Json,
  Rest.Json,
  System.Generics.Collections,
  Rest.JsonReflect,
  Rest.Json.Types;

type
  TChattiMessage = class
  strict private
    FMessage: string;
    FMe: Boolean;
    FDate: TDateTime;
  public
    property &Message: string read FMessage write FMessage;
    property Me: Boolean read FMe write FMe;
    property Date: TDateTime read FDate write FDate;
  end;

  TChattiMessages = class
  private
    [GenericListReflect]
    FItems: TObjectList<TChattiMessage>;
    function GetItems(Index: Integer): TChattiMessage;
    procedure SetItems(Index: Integer; const Value: TChattiMessage);
  public
    constructor Create;
    procedure LoadFromJson(AJson: String);
    function Add(AMesg: String; AMe: Boolean; ADateTime: TDateTime): TChattiMessage;
    function Count: Integer;
    procedure Clear;
    property Items[Index: Integer]: TChattiMessage read GetItems write SetItems; default;
    function ToJson: String;
    destructor Destroy; override;
  end;

implementation

{ TChattiMessages }

function TChattiMessages.Add(AMesg: String; AMe: Boolean; ADateTime: TDateTime): TChattiMessage;
begin
  Result := TChattiMessage.Create;
  Result.Message := AMesg;
  Result.Me := AMe;
  Result.Date := ADateTime;
  FItems.Add(Result);
end;

procedure TChattiMessages.Clear;
begin
  FItems.Clear;
end;

function TChattiMessages.Count: Integer;
begin
  Result := FItems.Count;
end;

constructor TChattiMessages.Create;
begin
  inherited;
  FItems := TObjectList<TChattiMessage>.Create;
end;

destructor TChattiMessages.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

function TChattiMessages.GetItems(Index: Integer): TChattiMessage;
begin
  Result := FItems[Index];
end;

procedure TChattiMessages.LoadFromJson(AJson: String);
begin
  FItems := TJson.JsonToObject < TObjectList < TChattiMessage >> (AJson);
end;

procedure TChattiMessages.SetItems(Index: Integer; const Value: TChattiMessage);
begin
  FItems[Index] := Value;
end;

function TChattiMessages.ToJson: String;
begin
  Result := TJson.ObjectToJsonString(FItems);
end;

end.
