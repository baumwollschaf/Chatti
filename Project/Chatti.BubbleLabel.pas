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
  public const
    cDEF_MARGIN = 10;
    cDEF_MARGIN_RIGHT_LEFT = 15;
  strict private
    class var FList: TObjectList<TBubbleLabel>;
  private
    FLabel: TLabel;
    FDateLabel: TLabel;
    FMe: Boolean;
    FFollowing: Boolean;
    FDate: TDateTime;
    procedure SetMe(const Value: Boolean);
    function GetText: string;
    procedure SetText(const Value: string);
    procedure SetFollowing(const Value: Boolean);
    procedure SetDate(const Value: TDateTime);
  public
    procedure Resize; override;
    property Me: Boolean read FMe write SetMe;
    property Following: Boolean read FFollowing write SetFollowing;
    property Text: string read GetText write SetText;
    property Date: TDateTime read FDate write SetDate;
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

  // Height := 20;

  FDate := Now;

  FDateLabel := TLabel.Create(Self);
  FDateLabel.Parent := Self;
  FDateLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  FDateLabel.Anchors := [TAnchorKind.akRight, TAnchorKind.akTop];
  FDateLabel.Width := 70;
  FDateLabel.TextSettings.Font.Size := 9.0;
  FDateLabel.TextSettings.HorzAlign := TTextAlign.Trailing;
  FDateLabel.TextSettings.FontColor := TAlphaColors.White;
  FDateLabel.Align := TAlignLayout.Top;
  FDateLabel.Margins.Right := cDEF_MARGIN_RIGHT_LEFT;
  FDateLabel.Margins.Top := 1;
  FDateLabel.Text := DateTimeToStr(FDate);
  FDateLabel.AutoSize := False;
  FDateLabel.Height := 9;

  // CalloutOffset := -50;
  Stroke.Kind := TBrushKind.None;
  FMe := True; // so me
  CalloutPosition := TCalloutPosition.Right; // so me
  CalloutLength := 5;
  CalloutWidth := 10;
  XRadius := 15;
  YRadius := 15;
  Margins.Top := cDEF_MARGIN;
  Margins.Left := cDEF_MARGIN;
  Margins.Right := cDEF_MARGIN;
  Margins.Bottom := 0;

  FLabel := TLabel.Create(Self);
  FLabel.StyledSettings := FLabel.StyledSettings - [TStyledSetting.FontColor];
  FLabel.Parent := Self;
  FLabel.Align := TAlignLayout.Top;
  FLabel.Margins.Top := Abs(cDEF_MARGIN - FDateLabel.Height - FDateLabel.Margins.Top);
  FLabel.Margins.Left := cDEF_MARGIN;
  FLabel.Margins.Right := cDEF_MARGIN_RIGHT_LEFT;
  FLabel.Margins.Bottom := cDEF_MARGIN;
  FLabel.TextSettings.FontColor := TAlphaColors.White;
  FLabel.Position.Y := 9999;
  Fill.Color := TAlphaColors.Dodgerblue;
  FLabel.BringToFront;
end;

destructor TBubbleLabel.Destroy;
begin
  FList.Remove(Self);
  FreeAndNil(FDateLabel);
  FreeAndNil(FLabel);
  inherited;
end;

class destructor TBubbleLabel.Destroy;
begin
  FreeAndNil(FList);
end;

function TBubbleLabel.GetText: string;
begin
  Result := FLabel.Text;
end;

procedure TBubbleLabel.Resize;
begin
  inherited Resize;
  if FLabel <> nil then
  begin
    FLabel.AutoSize := False;
    FLabel.AutoSize := True;
  end;
end;

procedure TBubbleLabel.SetDate(const Value: TDateTime);
begin
  FDate := Value;
end;

procedure TBubbleLabel.SetFollowing(const Value: Boolean);
begin
  if FFollowing <> Value then
  begin
    FFollowing := Value;
    if Following then
    begin
      Margins.Top := 1;
      Margins.Bottom := 1;
    end
    else
    begin
      Margins.Top := cDEF_MARGIN;
      Margins.Bottom := cDEF_MARGIN;
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
          Fill.Color := TAlphaColors.Dodgerblue;
          CalloutPosition := TCalloutPosition.Right;
          FLabel.TextSettings.FontColor := TAlphaColors.White;
          FLabel.Margins.Right := cDEF_MARGIN_RIGHT_LEFT;
          FLabel.Margins.Left := cDEF_MARGIN;
        end;
      False:
        begin
          // ChatGPT
          Fill.Color := TAlphaColors.Lightgreen;
          CalloutPosition := TCalloutPosition.Left;
          FLabel.TextSettings.FontColor := TAlphaColors.Black;
          FLabel.Margins.Right := cDEF_MARGIN;
          FLabel.Margins.Left := cDEF_MARGIN_RIGHT_LEFT;
        end;
    end;
    FDateLabel.TextSettings.FontColor := FLabel.TextSettings.FontColor;
  end;
end;

procedure TBubbleLabel.SetText(const Value: string);
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
