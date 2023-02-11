// ---------------------------------------------------------------------------

// This software is Copyright (c) 2021 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

// ---------------------------------------------------------------------------

unit Model.Types;

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.UITypes,
  System.Generics.Collections,
  System.Messaging,
  FMX.Types,
  FMX.Forms,
  FMX.Objects,
  FMX.Dialogs,
  FMX.Graphics,
  FMX.Platform,
  FMX.AddressBook.Types,
  FMX.AddressBook,
  FMX.MultiView,
{$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.JNI.JavaTypes,
{$ENDIF}
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait;

type
  TUserSettings = class;

  // Implements screen orientation changes monitoiring.
  TScreenOrientationMonitor = class
  private
    FScreenOrientation: TScreenOrientation;
    FDoOnOrientationChanged: TProc;
    procedure DoOrientationChanged(const Sender: TObject; const M: TMessage);
    function GetScreenOrientation: TScreenOrientation;
  public
    constructor Init(ADoOnOrientationChanged: TProc; AScreenOrientation: TScreenOrientation);
    destructor Destroy; override;
    property ScreenOrientation: TScreenOrientation read GetScreenOrientation;
  end;

  // Implements access to common application View info.
  IViewInfo = interface
    ['{EC27FF23-3003-410B-A1A0-20279EB627BA}']
    function GetScreenOrientation: TScreenOrientation;
    function IsActivityPresent(AActivityName: string): Boolean;
    function IsOrientationChanged: Boolean;
    function GetMultiView: TMultiView;
  end;

  // Interface access to preloaded contacts.
  IPreloadAddressBook = interface
    ['{0D967C0B-01E0-4B8F-BFBA-43F325E0F455}']
    function GetPreloadAddressBookContacts: TAddressBookContacts;
  end;

  // Interface access to some userinfo.
  IUserInfo = interface
    ['{45FEB1A2-45A9-4E77-A9B8-F47B554BA258}']
    function GetUserName: string;
    procedure SetUserName(AValue: string);
    function GetUserSettings: TUserSettings;
    procedure SetUserImage(AUserImage: TBitmap);
    function GetUserImage: TBitmap;
  end;

  // Implements access to some background task(for example to get progress some process).
  IBackgroundTask = interface
    ['{285F2384-3D2C-49D2-8E2C-CB77C99DDECD}']
    function GetBackgroundTask: TThread;
    procedure SetBackgroundTask(ATask: TThread);
  end;

  // Implements access to Activity metadata.
  IActivityInfo = interface
    ['{C7E60CCC-8E8C-45C6-8D9F-C1EC2916C22A}']
    function GetActivityName: string;
    procedure SetActivityName(AActivityName: string);
    function GetPrevActivityName: string;
    procedure SetPrevActivityName(AActivityName: string);
    property ActivityName: string read GetActivityName write SetActivityName;
    property PrevActivityName: string read GetPrevActivityName write SetPrevActivityName;
  end;

  // Implements access to some main View funtionality
  IViewUtils = interface
    ['{630F9491-4C80-4390-BB53-66B05A46FB8B}']
    procedure RecreateView;
    procedure SetViewDarkMode(AValue: Boolean);
    procedure SetDefaultTheme;
    procedure PortraitRealign;
    procedure LandscapeRealign;
  end;

  // Implements accsess to Model.Data.
  TAnswerRefCallback = reference to procedure(AAnswer: string);

  IModelData = interface
    ['{9A242DDE-145A-4745-A1B1-370E6BC7AEC8}']
    procedure Ask(AQuestion: string; AAnswer: TAnswerRefCallback);
    procedure GetModels(AModels: TStrings);
    procedure SetApiKey(AKey: string);
    // Max Tokens
    // ...
    // etc
  end;

  // Implements loading contacts on non-Windows platforms.
  TAddressBookLoader = class
    FAddressBook: TAddressBook;
    FAddressBookContacts: TAddressBookContacts;
  private
    procedure DoAddressBookPermissionRequest(ASender: TObject; const AMessage: string; const AAccessGranted: Boolean);
    function GetAddressBookContacts: TAddressBookContacts;
  public
    constructor Create;
{$IFDEF ANDROID}
    function GrantAddressBookPermissions: Boolean;
{$ENDIF}
    property PreloadAddressBookContacts: TAddressBookContacts read GetAddressBookContacts;
  end;

  // Set of Theme modes.
  TThemeMode = (tmNone, tmLight, tmDark);

  // Store common user settings if we won't use SignUp logic.
  TCommonUserSettings = record
  class var
    Theme: TThemeMode;
    class var ApiKey: string;
    class var ModelName: string;
    function IsValid: Boolean;
  end;

  ICommonUserSettings = interface
    ['{214941C2-336E-4001-A81A-2107906D8141}']
    function GetCommonUserSettings: TCommonUserSettings;
  end;

  // Implements the logic of interaction with the user, registration of users, login, saving personal settings.
  TUserSettings = class
  type
    // Set of User Gender.
    TUserGender = (ugNone, ugMale, ugFemale);

    // Stores user settings and system settings for this user.
    TUserData = record
      Email: string;
      FirstName: string;
      LastName: string;
      Password: string;
      Gender: TUserGender;
      UserPicture: TBitmap;
      CommonUserSettings: TCommonUserSettings;
      function IsValid: Boolean;
    end;

  private
    FUserDataList: TList<TUserData>;
    FCurrentUser: TUserData;
    function IndexOfByEmail(AEmail: string): Integer;
    function GetTheme: TThemeMode;
    function GetApiKey: string;
    function GetModelName: string;
    procedure SetTheme(ATheme: TThemeMode);
    procedure SetApiKey(AApiKey: string);
    procedure SetModelName(AModelName: string);
  public
    constructor Create;
    procedure DeSerialize;
    procedure Serialize;
    function SignUp(AEmail, AFirstName, ALastName, APassword: string; AUserPicture: TBitmap): Integer;
    function SignIn(AEmail, APassword: string): Boolean;
    property Theme: TThemeMode read GetTheme write SetTheme;
    property ApiKey: string read GetApiKey write SetApiKey;
    property ModelName: string read GetModelName write SetModelName;
    property UserDataList: TList<TUserData> read FUserDataList;
    property CurrentUser: TUserData read FCurrentUser;
  end;

implementation

uses
  Model.Constants,
  Model.Utils;

{ TScreenOrientationMonitor }

// Create & Init Screen Orientation monitoring
constructor TScreenOrientationMonitor.Init(ADoOnOrientationChanged: TProc; AScreenOrientation: TScreenOrientation);
begin
  inherited Create;
  TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, DoOrientationChanged);
  FScreenOrientation := AScreenOrientation;
  FDoOnOrientationChanged := ADoOnOrientationChanged;
end;

destructor TScreenOrientationMonitor.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TOrientationChangedMessage, DoOrientationChanged);
  inherited;
end;

// Event handler fires when screen orientation was changed.
procedure TScreenOrientationMonitor.DoOrientationChanged(const Sender: TObject; const M: TMessage);
begin
  // Execute payload if screen orientation equal screen orientation which was settings up by Init
  if GetScreenOrientation = FScreenOrientation then
    FDoOnOrientationChanged;
end;

// Get Screen orientation.
function TScreenOrientationMonitor.GetScreenOrientation: TScreenOrientation;
begin
  Result := TScreenOrientation.Portrait;
  // TMessageManager.DefaultManager.SubscribeToMessage(TOrientationChangedMessage, DoOrientationChanged);
  var
    screenService: IFMXScreenService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, screenService) then
    Result := screenService.GetScreenOrientation;
end;

{ TAddressBookLoader }

// Constructor for TAddressBookLoader.
constructor TAddressBookLoader.Create;
begin
  inherited;
  FAddressBook := TAddressBook.Create(nil);
  FAddressBookContacts := TAddressBookContacts.Create;
  FAddressBook.OnPermissionRequest := DoAddressBookPermissionRequest;
  FAddressBook.RequestPermission;
end;

// Event handler that runs when requesting permission.
procedure TAddressBookLoader.DoAddressBookPermissionRequest(ASender: TObject; const AMessage: string;
  const AAccessGranted: Boolean);
begin
  inherited;
  if Assigned(FAddressBookContacts) then
    FAddressBookContacts.Clear;
  if AAccessGranted then
    FAddressBook.AllContacts(FAddressBook.DefaultSource, FAddressBookContacts)
  else
    ShowMessage(Concat(sAdressBookAccessError, AMessage));
end;

// Get a list of contacts if permission is received.
function TAddressBookLoader.GetAddressBookContacts: TAddressBookContacts;
begin
  Result := nil;
{$IFNDEF MSWINDOWS}
  if FAddressBook.Supported
{$IFDEF ANDROID}
    and IsPermissionGranted(EnumPermissions.READ_CONTACTS)
{$ENDIF}
  then
  begin
    Result := FAddressBookContacts;
  end
  else
    ShowMessage(sAdressBookNotSupported);
{$ENDIF}
end;

{$IFDEF ANDROID}

// Get permission to read contacts.
function TAddressBookLoader.GrantAddressBookPermissions: Boolean;
begin
  var
    isGranted: Boolean := GetPermissionsSvc.IsEveryPermissionGranted([JStringToString(EnumPermissions.READ_CONTACTS),
      JStringToString(EnumPermissions.WRITE_CONTACTS)]);
  if not isGranted then
    Result := GrantAndroidPermission(EnumPermissions.READ_CONTACTS) and
      GrantAndroidPermission(EnumPermissions.WRITE_CONTACTS)
  else
    Result := isGranted;
end;
{$ENDIF}
{ TUserSettings }

// Constructor TUserSettings.
constructor TUserSettings.Create;
begin
  FUserDataList := TList<TUserData>.Create;
end;

// Saving UserSettings into binary config.
procedure TUserSettings.DeSerialize;
begin
  if not ConfigExists then
    Exit;
  var
    Count: Integer;
  var
    ASerializedData: TMemoryStream := TMemoryStream.Create;
  try
    ASerializedData.LoadFromFile(GetConfigPath);
    ASerializedData.Read(Count, SizeOf(NativeInt));
    for var i: Integer := 0 to Count - 1 do
    begin
      var
        sz: Integer;
      var
        UserData: TUserData;

      ASerializedData.Read(sz, SizeOf(NativeInt));
      SetLength(UserData.Email, sz div SizeOf(Char));
      ASerializedData.Read(TBytes(UserData.Email), sz);

      ASerializedData.Read(sz, SizeOf(NativeInt));
      SetLength(UserData.FirstName, sz div SizeOf(Char));
      ASerializedData.Read(TBytes(UserData.FirstName), sz);

      ASerializedData.Read(sz, SizeOf(NativeInt));
      SetLength(UserData.LastName, sz div SizeOf(Char));
      ASerializedData.Read(TBytes(UserData.LastName), sz);

      ASerializedData.Read(sz, SizeOf(NativeInt));
      SetLength(UserData.Password, sz div SizeOf(Char));
      ASerializedData.Read(TBytes(UserData.Password), sz);

      ASerializedData.Read(UserData.Gender, SizeOf(NativeInt));

      ASerializedData.Read(sz, SizeOf(NativeInt));
      var
      BmpStream := TMemoryStream.Create;
      try
        BmpStream.CopyFrom(ASerializedData, sz);
        UserData.UserPicture := TBitmap.Create;
        UserData.UserPicture.LoadFromStream(BmpStream);
      finally
        BmpStream.Free;
      end;

      ASerializedData.Read(UserData.CommonUserSettings.Theme, SizeOf(NativeInt));

      ASerializedData.Read(sz, SizeOf(NativeInt));
      SetLength(UserData.CommonUserSettings.ApiKey, sz div SizeOf(Char));
      ASerializedData.Read(TBytes(UserData.CommonUserSettings.ApiKey), sz);

      ASerializedData.Read(sz, SizeOf(NativeInt));
      SetLength(UserData.CommonUserSettings.ModelName, sz div SizeOf(Char));
      ASerializedData.Read(TBytes(UserData.CommonUserSettings.ModelName), sz);

      FUserDataList.Add(UserData);
    end;
  finally
    ASerializedData.Free;
  end;
end;

// Restore UserSettings from binary config
procedure TUserSettings.Serialize;
begin
  if (FUserDataList.Count = 0) or not FCurrentUser.IsValid then
    Exit;
  var
  ASerializedData := TMemoryStream.Create;
  try
    ASerializedData.Write(FUserDataList.Count, SizeOf(NativeInt));

    for var i: Integer := 0 to FUserDataList.Count - 1 do
    begin
      var
        sz: Integer;

      var
        Email: string := FUserDataList[i].Email;
      sz := Email.Length * SizeOf(Char);
      ASerializedData.Write(sz, SizeOf(NativeInt));
      ASerializedData.Write(Email[1], sz);

      var
        FirstName: string := FUserDataList[i].FirstName;
      sz := FirstName.Length * SizeOf(Char);
      ASerializedData.Write(sz, SizeOf(NativeInt));
      ASerializedData.Write(FirstName[1], sz);

      var
        LastName: string := FUserDataList[i].LastName;
      sz := LastName.Length * SizeOf(Char);
      ASerializedData.Write(sz, SizeOf(NativeInt));
      ASerializedData.Write(LastName[1], sz);

      var
        Password: string := FUserDataList[i].Password;
      sz := Password.Length * SizeOf(Char);
      ASerializedData.Write(sz, SizeOf(NativeInt));
      ASerializedData.Write(Password[1], sz);

      var
        Gender: TUserGender := FUserDataList[i].Gender;
      ASerializedData.Write(Gender, SizeOf(NativeInt));

      var
        MS: TMemoryStream := TMemoryStream.Create;
      try
        FUserDataList[i].UserPicture.SaveToStream(MS);
        var
          BmpSz: Integer := MS.Size;
        ASerializedData.Write(BmpSz, SizeOf(NativeInt));
        ASerializedData.Write(MS.Memory^, MS.Size);
      finally
        MS.Free;
      end;

      var
        T: TThemeMode := FUserDataList[i].CommonUserSettings.Theme;
      ASerializedData.Write(T, SizeOf(NativeInt));

      var
        ApiKey: string := FUserDataList[i].CommonUserSettings.ApiKey;
      sz := ApiKey.Length * SizeOf(Char);
      ASerializedData.Write(sz, SizeOf(NativeInt));
      ASerializedData.Write(ApiKey[1], sz);

      var
        StringValu: string := FUserDataList[i].CommonUserSettings.ModelName;
      sz := StringValu.Length * SizeOf(Char);
      ASerializedData.Write(sz, SizeOf(NativeInt));
      ASerializedData.Write(StringValu[1], sz);

    end;
    ASerializedData.SaveToFile(GetConfigPath);
  finally
    ASerializedData.Free
  end;
end;

// SignUp routine for a new user.
function TUserSettings.SignUp(AEmail, AFirstName, ALastName, APassword: string; AUserPicture: TBitmap): Integer;
begin
  var
    UserData: TUserData;
  with UserData do
  begin
    Email := AEmail;
    FirstName := AFirstName;
    LastName := ALastName;
    Password := APassword;
    Gender := ugNone;
    UserPicture := AUserPicture;
    Theme := tmNone;
    ApiKey := sNotDefined;
    ModelName := 'text-davinci-003';
  end;
  Result := FUserDataList.Add(UserData);
end;

// SignIn routine for a specific user.
function TUserSettings.SignIn(AEmail, APassword: string): Boolean;
var
  LUserIdxByEmail: Integer;
begin
  Result := False;
  if not(AEmail.IsEmpty or APassword.IsEmpty) then
  begin
    LUserIdxByEmail := IndexOfByEmail(AEmail);
    if (LUserIdxByEmail <> -1) and FUserDataList[LUserIdxByEmail].Password.Equals(APassword) then
    begin
      Result := True;
      FCurrentUser := FUserDataList[LUserIdxByEmail];
    end;
  end;
end;

// Getting an item index in the list of registered users based on an email
function TUserSettings.IndexOfByEmail(AEmail: string): Integer;
begin
  Result := -1;
  if FUserDataList.Count > 0 then
    for var i: Integer := 0 to FUserDataList.Count - 1 do
      if FUserDataList[i].Email.Equals(AEmail) then
      begin
        Result := i;
        Break;
      end;
end;

function TUserSettings.GetModelName: string;
begin
  Result := FCurrentUser.CommonUserSettings.ModelName;
end;

procedure TUserSettings.SetModelName(AModelName: string);
begin
  FCurrentUser.CommonUserSettings.ModelName := AModelName;
end;

// Getting ApiKey value
function TUserSettings.GetApiKey: string;
begin
  Result := FCurrentUser.CommonUserSettings.ApiKey;
end;

// Setting ApiKey value
procedure TUserSettings.SetApiKey(AApiKey: string);
begin
  FCurrentUser.CommonUserSettings.ApiKey := AApiKey;
end;

// Getting Theme value
function TUserSettings.GetTheme: TThemeMode;
begin
  Result := FCurrentUser.CommonUserSettings.Theme;
end;

// Setting Theme value
procedure TUserSettings.SetTheme(ATheme: TThemeMode);
begin
  FCurrentUser.CommonUserSettings.Theme := ATheme;
end;

{ TUserSettings.TUserData }

// Ñhecking of the basic data of a specific user.
function TUserSettings.TUserData.IsValid: Boolean;
begin
  Result := not(Email.IsEmpty or FirstName.IsEmpty or LastName.IsEmpty or Password.IsEmpty) and Assigned(UserPicture);
end;

{ TCommonUserSettings }

function TCommonUserSettings.IsValid: Boolean;
begin
  Result := not((Theme = TThemeMode.tmNone) and ApiKey.IsEmpty and ModelName.IsEmpty);
end;

end.
