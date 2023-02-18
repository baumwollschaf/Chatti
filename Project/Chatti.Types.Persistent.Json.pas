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

implementation

end.
