unit Chatti.Forms.TemplateForm;

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
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Layouts,

  Skia,
  Skia.FMX;

type
  TTemplateForm = class abstract(TForm)
    Header: TToolBar;
    HeaderLabel: TLabel;
    btnNext: TSpeedButton;
    btnBack: TSpeedButton;
    VertScrollBox1: TVertScrollBox;
    procedure btnBackClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  private
    FBackCallBack: TProc<TObject>;
    FNextCallBack: TProc<TObject>;
  protected
    function GetObject: TObject; virtual; abstract;
  public
    constructor Create(AOwner: TComponent; ABackCallBack, ANextCallBack: TProc<TObject>); reintroduce; virtual;
  end;

var
  TemplateForm: TTemplateForm;

implementation

uses
  Chatti.Forms.AppMainFormChatti;

{$R *.fmx}
{ TForm1 }

procedure TTemplateForm.btnBackClick(Sender: TObject);
begin
  if Assigned(FBackCallBack) then
  begin
    FBackCallBack(GetObject);
  end;
  Close;
end;

procedure TTemplateForm.btnNextClick(Sender: TObject);
begin
  if Assigned(FNextCallBack) then
  begin
    FNextCallBack(GetObject);
  end;
  Close;
end;

constructor TTemplateForm.Create(AOwner: TComponent; ABackCallBack, ANextCallBack: TProc<TObject>);
begin
  inherited Create(AOwner);
  Assert(HeaderLabel.Text <> 'Title', 'Change Text for HeaderLabel in designer');
  StyleBook := AppMainFormChatti.StyleBook;
  FBackCallBack := ABackCallBack;;
  FNextCallBack := ANextCallBack;
end;

procedure TTemplateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TTemplateForm.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    Key := 0;
    btnBackClick(nil);
  end;
end;

end.
