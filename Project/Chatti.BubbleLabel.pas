unit Chatti.BubbleLabel;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  // Skia,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  // Skia.FMX,
  FMX.Layouts,
  System.Generics.Collections,
  FMX.Objects;

type
  TBubbleLabel = class(TCalloutRectangle)
  strict private
    class var FList: TObjectList<TBubbleLabel>;
  private
    FLabel: TLabel;
    FMe: Boolean;
    FFollowing: Boolean;
    procedure SetMe(const Value: Boolean);
    function GetText: String;
    procedure SetText(const Value: String);
    procedure SetFollowing(const Value: Boolean);
  public
    procedure Resize; override;
    property Me: Boolean read FMe write SetMe;
    property Following: Boolean read FFollowing write SetFollowing;
    property Text: String read GetText write SetText;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    class property List: TObjectList<TBubbleLabel> read FList;
    class procedure ClearLabels;
    class constructor Create;
    class destructor Destroy;
  end;

implementation

{ TBubbleLabel }

constructor TBubbleLabel.Create(AOwner: TComponent);
begin
  inherited;

  FList.Add(Self);

  // CalloutOffset := -50;
  Stroke.Kind := TBrushKind.None;
  FMe := True; // so me
  CalloutPosition := TCalloutPosition.Right; // so me
  CalloutLength := 5;
  CalloutWidth := 10;
  XRadius := 15;
  YRadius := 15;
  Margins.Top := 10;
  Margins.Left := 10;
  Margins.Right := 10;
  Margins.Bottom := 0;

  FLabel := TLabel.Create(Self);
  FLabel.StyledSettings := FLabel.StyledSettings - [TStyledSetting.FontColor];
  FLabel.Parent := Self;
  FLabel.Align := TAlignLayout.Top;
  FLabel.Margins.Top := 10;
  FLabel.Margins.Left := 10;
  FLabel.Margins.Right := 15;
  FLabel.Margins.Bottom := 10;
  FLabel.TextSettings.FontColor := TAlphaColors.White;
  Fill.Color := TAlphaColors.Deepskyblue;
  FLabel.BringToFront;
end;

destructor TBubbleLabel.Destroy;
begin
  FList.Remove(Self);
  FreeAndNil(FLabel);
  inherited;
end;

class destructor TBubbleLabel.Destroy;
begin
  FreeAndNil(FList);
end;

function TBubbleLabel.GetText: String;
begin
  Result := FLabel.Text;
end;

procedure TBubbleLabel.Resize;
begin
  inherited Resize;
  FLabel.AutoSize := False;
  FLabel.AutoSize := True;
end;

procedure TBubbleLabel.SetFollowing(const Value: Boolean);
begin
  if FFollowing <> Value then
  begin
    FFollowing := Value;
    if Following then
    begin
      Margins.Top := 0;
      Margins.Bottom := 0;
    end else begin
      Margins.Top := 10;
      Margins.Bottom := 10;
    end;
  end;
end;

procedure TBubbleLabel.SetMe(const Value: Boolean);
begin
  if FMe <> Value then
  begin
    FMe := Value;
    case FMe of
      True:
        begin
          // me
          Fill.Color := TAlphaColors.Deepskyblue;
          CalloutPosition := TCalloutPosition.Right;
          FLabel.TextSettings.FontColor := TAlphaColors.White;
          FLabel.Margins.Right := 15;
          FLabel.Margins.Left := 10;
        end;
      False:
        begin
          // ChatGPT
          Fill.Color := TAlphaColors.Lightgreen;
          CalloutPosition := TCalloutPosition.Left;
          FLabel.TextSettings.FontColor := TAlphaColors.Black;
          FLabel.Margins.Right := 10;
          FLabel.Margins.Left := 15;
        end;
    end;
  end;
end;

procedure TBubbleLabel.SetText(const Value: String);
begin
  FLabel.Text := Value;
  Resize;
end;

class procedure TBubbleLabel.ClearLabels;
begin
  FList.Clear;
end;

class constructor TBubbleLabel.Create;
begin
  FList := TObjectList<TBubbleLabel>.Create;
end;

end.
