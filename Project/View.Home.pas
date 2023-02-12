// ---------------------------------------------------------------------------

// This software is Copyright (c) 2021 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

// ---------------------------------------------------------------------------

unit View.Home;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Text,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  View.Main,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Ani,
  FMX.Objects,
  FMX.Controls.Presentation,
  FMX.Layouts,
  System.ImageList,
  FMX.ImgList,
  Model.Constants,
  Model.Utils,
  FMX.Effects,
  Model.Types,
  ViewModel,
  FMX.Edit,
  FMX.Memo.Types;

type
  // Home/main frame.
  THomeFrame = class(TMainFrame)
    DataPanel: TGridPanelLayout;
    GridPanelLayout2: TGridPanelLayout;
    GridPanelLayout1: TGridPanelLayout;
    btnCut: TSpeedButton;
    btnCopy: TSpeedButton;
    btnPaste: TSpeedButton;
    btnSelectAll: TSpeedButton;
    GridPanelLayout3: TGridPanelLayout;
    Layout1: TLayout;
    Label1: TLabel;
    GridPanelLayout4: TGridPanelLayout;
    Layout2: TLayout;
    Label2: TLabel;
    edAnswer: TMemo;
    btnClear: TSpeedButton;
    chBxClear: TCheckBox;
    ChBxShowQuestion: TCheckBox;
    btnQuestionMark: TSpeedButton;
    Layout3: TLayout;
    edQuestion: TEdit;
    btnAsk: TSpeedButton;
    procedure btnAskClick(Sender: TObject);
    procedure btnCutClick(Sender: TObject);
    procedure edQuestionKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure btnQuestionMarkClick(Sender: TObject);
  private
    FViewModel: TViewModel;
    function GetUserName: string;
  public
    { Public declarations }
    constructor Create(Owner: TComponent); override;
  end;

implementation

uses
  View;

{$R *.fmx}

// Calling contacts Screen & Loading contacts.
procedure THomeFrame.btnAskClick(Sender: TObject);
begin
  if edQuestion.Text.Trim = '' then
    Exit;
  FViewModel.Ask(edQuestion.Text,
    procedure(Answer: string)
    begin
      if chBxClear.IsChecked then
      begin
        edAnswer.Lines.Clear;
      end;
      if ChBxShowQuestion.IsChecked then
      begin
        edAnswer.Lines.Add('me: ' + edQuestion.Text);
        edAnswer.Lines.Add('-----');
        edQuestion.Text := '';
        edQuestion.SetFocus;
      end;
      edAnswer.Lines.Add(Answer);
      edAnswer.Lines.Add('');
    end);
end;

procedure THomeFrame.btnCutClick(Sender: TObject);
begin
  var
    Btn: TSpeedButton := TSpeedButton(Sender);
  if Btn = nil then
    Exit;

  var
    Intf: ITextActions := nil;
  if edQuestion.IsFocused then
    Intf := edQuestion
  else if edAnswer.IsFocused then
    Intf := edAnswer;

  if Intf = nil then
    Exit;

  case Btn.Tag of
    0:
      begin
        Intf.CutToClipboard;
      end;
    1:
      begin
        Intf.CopyToClipboard;
      end;
    2:
      begin
        Intf.PasteFromClipboard;
      end;
    3:
      begin
        Intf.SelectAll;
      end;
    4:
      begin
        Intf.SelectAll;
        Intf.DeleteSelection;
      end;
  end;

end;

procedure THomeFrame.btnQuestionMarkClick(Sender: TObject);
begin
  inherited;
  if edQuestion.Text.Trim = '' then
    Exit;
  edQuestion.Text := edQuestion.Text + '?';
  edQuestion.SelStart := edQuestion.Text.Length;
end;

constructor THomeFrame.Create(Owner: TComponent);
begin
  inherited;
  var
    UserInfo: IUserInfo := GetMainForm as IUserInfo;
  if UserInfo.GetUserName.IsEmpty then
    UserInfo.SetUserName(DEBUG_DB_USERNAME_1);
  // Create ViewModel object which implements high-level access to DB data.
  var
    ViewInfo: IViewInfo := GetMainForm as IViewInfo;
    // If Data enbaled.
  if IsClassPresent(sModelDataClassName) then
  begin
    if not Assigned(ViewForm.ViewModel) then
    begin
      FViewModel := TViewModel.Create;
      ViewForm.ViewModel := FViewModel;
    end
    else
      FViewModel := ViewForm.ViewModel;
  end;
  // Applying SVG icon.
  HamburgerImg.Data.Data := MATERIAL_UI_MENU;

  // Chatti
  ViewForm.SetChattiSettings;
  try
    FViewModel.LoadModels;
  except
    on E: Exception do
    begin
      ShowMessage('Set API-Key correctly in Settings'#13#10 + E.Message);
    end;
  end;
end;

procedure THomeFrame.edQuestionKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Key := 0;
    btnAskClick(nil);
  end;
end;

// Getting current logged UserName
function THomeFrame.GetUserName: string;
begin
  var
    UserInfo: IUserInfo := GetMainForm as IUserInfo;
  if Assigned(UserInfo) then
    Result := UserInfo.GetUserName;
end;

initialization

// Register frame
RegisterClass(THomeFrame);

finalization

// Unregister frame
UnRegisterClass(THomeFrame);

end.
