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
  Skia,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  Skia.FMX,
  FMX.Layouts,
  FMX.Objects;

type
  TBubbleLabel = class(TCalloutRectangle)
  private
    FLabel: TSkLabel;
    FMe: Boolean;
    procedure SetMe(const Value: Boolean);
  public
    property Me: Boolean read FMe write SetMe;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{ TBubbleLabel }

constructor TBubbleLabel.Create(AOwner: TComponent);
begin
  inherited;
  CalloutOffset := -50;
  Stroke.Kind := TBrushKind.None;
  FMe := True; // so me
  CalloutPosition := TCalloutPosition.Right; // so me
  FLabel := TSkLabel.Create(Self);
  FLabel.Parent := Self;
  FLabel.Align := TAlignLayout.Top;
  FLabel.Position.Y := 999999999;
  FLabel.Margins.Top := 10;
  FLabel.Margins.Left := 10;
  FLabel.Margins.Right := 10;
  FLabel.Margins.Bottom := 10;
  FLabel.TextSettings.FontColor := TAlphaColors.LegacySkyBlue;
end;

destructor TBubbleLabel.Destroy;
begin
  FreeAndNil(FLabel);
  inherited;
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
          FLabel.TextSettings.FontColor := TAlphaColors.LegacySkyBlue;
          CalloutPosition := TCalloutPosition.Right;
        end;
      False:
        begin
          // ChatGPT
          FLabel.TextSettings.FontColor := TAlphaColors.Lightseagreen;
          CalloutPosition := TCalloutPosition.Left;
        end;
    end;
  end;
end;

end.
