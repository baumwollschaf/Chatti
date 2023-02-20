unit Chatti.BubbleLabel;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Controls.Presentation,
  FMX.StdCtrls;

type
  TChatBubbleLabel = class(TLabel)
  private const
    cPERCENT_SPACES = 15;
    cMARGIN_MIN = 4;
    cMARGIN_LABEL = cMARGIN_MIN;
    cMARGIN_LABEL_HALF = cMARGIN_LABEL div 2;
    cRADIUS = 5;
    cMARGIN = 30;
    cMARGIN_TOP_NOT_FOLLOWING = cMARGIN_MIN;
    cMARGIN_TOP_FOLLOWING = 1;
  private
    class var FList: TObjectList<TChatBubbleLabel>;
  private

    FRect: TRectangle;
    FLabel: TLabel;
    FDateLabel: TLabel;

    FFollowing: Boolean;
    FBGColorYou: TAlphaColor;
    FBGColorMe: TAlphaColor;
    FMe: Boolean;
    FBubbleText: String;
    procedure SetBGColorMe(const Value: TAlphaColor);
    procedure SetBGColorYou(const Value: TAlphaColor);
    procedure SetFollowing(const Value: Boolean);
    procedure SetMe(const Value: Boolean);
    procedure SetBubbleText(const Value: String);
  private
    FDateTime: TDateTime;
    function AddSpaces(AIn: string; APercentMore: Integer): string;
    procedure SetDateTime(const Value: TDateTime);
  protected
    property Text;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Me: Boolean read FMe write SetMe;
    property Following: Boolean read FFollowing write SetFollowing;
    property BGColorMe: TAlphaColor read FBGColorMe write SetBGColorMe;
    property BGColorYou: TAlphaColor read FBGColorYou write SetBGColorYou;
    property BubbleText: String read FBubbleText write SetBubbleText;
    property DateTime: TDateTime read FDateTime write SetDateTime;
  public
    class procedure Clear;
    class constructor Create;
    class destructor Destroy;
  end;

implementation

uses
  System.StrUtils;

{ TBubbleLabel }

constructor TChatBubbleLabel.Create(AOwner: TComponent);
begin
  inherited;
  FList.Add(Self);
  HitTest := True;
  AutoSize := True;
  Align := TAlignLayout.Top;
  StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  Font.Size := 18;

  FRect := TRectangle.Create(Self);
  FRect.Parent := Self;
  FRect.Align := TAlignLayout.Client;
  FRect.Stroke.Kind := TBrushKind.None;
  FRect.XRadius := cRADIUS;
  FRect.YRadius := cRADIUS;

  FLabel := TLabel.Create(Self);
  FLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  FLabel.Font.Size := 18;
  FLabel.Parent := FRect;
  FLabel.Align := TAlignLayout.Client;
  FLabel.Margins.Left := cMARGIN_LABEL;
  FLabel.Margins.Top := cMARGIN_LABEL;
  FLabel.Margins.Right := cMARGIN_LABEL;
  FLabel.Margins.Bottom := cMARGIN_LABEL_HALF;

  FDateLabel := TLabel.Create(Self);
  FDateLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  FDateLabel.Align := TAlignLayout.Bottom;
  FDateLabel.Font.Size := 10;
  FDateLabel.Margins.Right := cMARGIN_LABEL;
  FDateLabel.Margins.Bottom := cMARGIN_LABEL_HALF;
  FDateLabel.Parent := FRect;
  FDateLabel.TextAlign := TTextAlign.Trailing;

  DateTime := Now;

  FMe := True;
  FFollowing := False;
  FBGColorMe := TAlphaColors.Dodgerblue;
  FBGColorYou := TAlphaColors.Lightgreen;
end;

function TChatBubbleLabel.AddSpaces(AIn: string; APercentMore: Integer): string;
begin
  Result := AIn;
  var
    Len: Integer := Result.Length;
  var
    LenFactor: Double := 1 + (APercentMore / 100);
  var
    LenNew: Integer := Round(Len * LenFactor);
  var
    Offset: Integer := (LenNew - Len);
  var
    s: string := DupeString(' ', Offset);
  Result := Result + #13#10 + s;
end;

destructor TChatBubbleLabel.Destroy;
begin
  FList.Remove(Self);
  inherited;
end;

procedure TChatBubbleLabel.SetBGColorMe(const Value: TAlphaColor);
begin
  FBGColorMe := Value;
end;

procedure TChatBubbleLabel.SetBGColorYou(const Value: TAlphaColor);
begin
  FBGColorYou := Value;
end;

procedure TChatBubbleLabel.SetBubbleText(const Value: String);
begin
  FBubbleText := Value;
  Text := AddSpaces(FBubbleText, cPERCENT_SPACES);
  FLabel.Text := FBubbleText;
end;

procedure TChatBubbleLabel.SetDateTime(const Value: TDateTime);
begin
  FDateTime := Value;
  FDateLabel.Text := DateTimeToStr(FDateTime);
end;

procedure TChatBubbleLabel.SetFollowing(const Value: Boolean);
begin
  FFollowing := Value;
  if FFollowing then
  begin
    Margins.Top := cMARGIN_TOP_FOLLOWING;
    FRect.Corners := [TCorner.BottomLeft, TCorner.BottomRight]
  end else begin
    Margins.Top := cMARGIN_TOP_NOT_FOLLOWING;
    FRect.Corners := [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight]
  end;
end;

procedure TChatBubbleLabel.SetMe(const Value: Boolean);
begin
  FMe := Value;
  if FMe then
  begin
    Margins.Left := cMARGIN;
    Margins.Right := cMARGIN_MIN;
    FRect.Fill.Color := FBGColorMe;
    FLabel.FontColor := TAlphaColors.White;
    FDateLabel.FontColor := TAlphaColors.White;
  end else begin
    Margins.Left := cMARGIN_MIN;
    Margins.Right := cMARGIN;
    FRect.Fill.Color := FBGColorYou;
    FLabel.FontColor := TAlphaColors.Black;
    FDateLabel.FontColor := TAlphaColors.Black;
  end;

end;

class procedure TChatBubbleLabel.Clear;
begin
  FList.Clear;
end;

class constructor TChatBubbleLabel.Create;
begin
  FList := TObjectList<TChatBubbleLabel>.Create;
end;

class destructor TChatBubbleLabel.Destroy;
begin
  FreeAndNil(FList);
end;

end.
