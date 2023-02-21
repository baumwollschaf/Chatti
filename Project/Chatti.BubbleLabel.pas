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
  TLabel = class(FMX.StdCtrls.TLabel)
  private
    FRect: TRectangle;
    FDateLabel: TLabel;
  end;

  TChatBubbleLabel = class
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
    procedure ResizeLabel(Sender: TObject);
  private
    FDateTime: TDateTime;
    FOnGesture: TGestureEvent;
    FOnTapClick: TNotifyEvent;
    function AddSpaces(AIn: string; APercentMore: Integer): string;
    procedure SetDateTime(const Value: TDateTime);
    procedure ControlGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure SetOnTapClick(const Value: TNotifyEvent);

  public
    constructor Create(AOwner: TFmxObject);
    destructor Destroy; override;
    property Me: Boolean read FMe write SetMe;
    property Following: Boolean read FFollowing write SetFollowing;
    property BGColorMe: TAlphaColor read FBGColorMe write SetBGColorMe;
    property BGColorYou: TAlphaColor read FBGColorYou write SetBGColorYou;
    property BubbleText: String read FBubbleText write SetBubbleText;
    property DateTime: TDateTime read FDateTime write SetDateTime;
    property OnTapClick: TNotifyEvent read FOnTapClick write SetOnTapClick;
    procedure Resize;
  public
    class procedure Clear;
    class property List: TObjectList<TChatBubbleLabel> read FList;
    class constructor Create;
    class destructor Destroy;
  end;

implementation

uses
  System.StrUtils;

{ TBubbleLabel }

constructor TChatBubbleLabel.Create(AOwner: TFmxObject);
begin
  inherited Create;
  FList.Add(Self);

  FRect := TRectangle.Create(AOwner);
  FRect.Parent := AOwner;
  FRect.Align := TAlignLayout.Top;
  FRect.Stroke.Kind := TBrushKind.None;
  FRect.XRadius := cRADIUS;
  FRect.YRadius := cRADIUS;
  FRect.Position.Y := 9999999999999;

  FLabel := TLabel.Create(FRect);
  FLabel.Touch.InteractiveGestures := FLabel.Touch.InteractiveGestures + [TInteractiveGesture.LongTap];
  FLabel.OnGesture := ControlGesture;

  FLabel.AutoSize := True;
  FLabel.OnResize := ResizeLabel;
  FLabel.FRect := FRect;
  FLabel.HitTest := True;
  FLabel.StyledSettings := [TStyledSetting.Size, TStyledSetting.Family, TStyledSetting.Style];
  FLabel.Parent := FRect;
  FLabel.Align := TAlignLayout.Top;
  FLabel.Margins.Left := cMARGIN_LABEL;
  FLabel.Margins.Top := cMARGIN_LABEL;
  FLabel.Margins.Right := cMARGIN_LABEL;
  FLabel.Margins.Bottom := cMARGIN_LABEL_HALF;

  FDateLabel := TLabel.Create(FRect);
  FDateLabel.AutoSize := True;
  FLabel.FDateLabel := FDateLabel;
  FDateLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style];
  FDateLabel.Align := TAlignLayout.Top;
  FDateLabel.Font.Size := 11;
  FDateLabel.Margins.Right := cMARGIN_LABEL;
  FDateLabel.Margins.Bottom := cMARGIN_LABEL_HALF;
  FDateLabel.Parent := FRect;
  FDateLabel.TextAlign := TTextAlign.Trailing;

  FLabel.Position.Y := 0;

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
  FreeAndNil(FLabel);
  FreeAndNil(FDateLabel);
  FreeAndNil(FRect);
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
    FRect.Margins.Top := cMARGIN_TOP_FOLLOWING;
    FRect.Corners := [TCorner.BottomLeft, TCorner.BottomRight]
  end else begin
    FRect.Margins.Top := cMARGIN_TOP_NOT_FOLLOWING;
    FRect.Corners := [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight]
  end;
end;

procedure TChatBubbleLabel.SetMe(const Value: Boolean);
begin
  FMe := Value;
  if FMe then
  begin
    FRect.Margins.Left := cMARGIN;
    FRect.Margins.Right := cMARGIN_MIN;
    FRect.Fill.Color := FBGColorMe;
    FLabel.FontColor := TAlphaColors.White;
    FDateLabel.FontColor := TAlphaColors.White;
  end else begin
    FRect.Margins.Left := cMARGIN_MIN;
    FRect.Margins.Right := cMARGIN;
    FRect.Fill.Color := FBGColorYou;
    FLabel.FontColor := TAlphaColors.Black;
    FDateLabel.FontColor := TAlphaColors.Black;
  end;

end;

procedure TChatBubbleLabel.SetOnTapClick(const Value: TNotifyEvent);
begin
  FOnTapClick := Value;
end;

class procedure TChatBubbleLabel.Clear;
begin
  FList.Clear;
end;

procedure TChatBubbleLabel.ControlGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  if EventInfo.GestureID = System.UITypes.igiLongTap then
  begin
    if Assigned(FOnTapClick) then
    begin
      FOnTapClick(Self);
      // TextToClipBoard(TChatBubbleLabel(Sender));
      Handled := True;
    end;
  end;
end;

class constructor TChatBubbleLabel.Create;
begin
  FList := TObjectList<TChatBubbleLabel>.Create;
end;

class destructor TChatBubbleLabel.Destroy;
begin
  FreeAndNil(FList);
end;

procedure TChatBubbleLabel.Resize;
begin
  FLabel.Resize;
end;

procedure TChatBubbleLabel.ResizeLabel(Sender: TObject);
begin
  var
    L: TLabel := TLabel(Sender);
  if L.FRect = nil then
    Exit;
  L.FRect.Height := L.Height + L.Margins.Top + L.Margins.Bottom;
  if L.FDateLabel = nil then
    Exit;
  L.FRect.Height := L.FRect.Height + L.FDateLabel.Height + L.FDateLabel.Margins.Top + L.FDateLabel.Margins.Bottom;
end;

end.
