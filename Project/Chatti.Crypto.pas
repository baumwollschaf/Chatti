{ ******************************************************* }
{ Chatti Crypt API }
{ © Ralph Dietrich. }
{ ******************************************************* }

unit Chatti.Crypto;

interface

uses
  System.Classes,
  System.SysUtils,
  System.NetEncoding;

type
  THexString = string;

  TCryptApi = class
  public
    // SHA512 Hash (One Way... Also nicht entschlüsselbar)
    class function SHA512(const Input: string): THexString; overload;
    // SHA512 Hash mit Salt (One Way... Also nicht entschlüsselbar)
    class function SHA512(const Input: string; Salt: String): THexString; overload;
    // Vermischen: En-DeCrypt auf "einfache" Weise (Ver- und Entschlüsseln mit GLEICHER Funktion!)
    class function Scramble(s: string): string;
    // AES 256: Encrypt symmetrisch
    class function EncryptAES256(const Password: string; const input: string): string; static;
    // AES 256: Decrypt symmetrisch
    class function DecryptAES256(const Password: string; const input: string): string; static;
  end;

implementation

{ TCryptAPI }

uses
  utplb_hash,
  utplb_cryptographiclibrary,
  utplb_codec,
  utplb_constants;

const
  chainids: array [0 .. 6] of string = (ecb_progid, cbc_progid, pcbc_progid, cfb_progid, cfb8bit_progid, ctr_progid,
    ofb_progid);

function base64_encode(Value: TBytes): string;
begin
  result := TNetEncoding.Base64.EncodeBytesToString(value);
end;

function base64_decode(Value: string): tbytes;
begin
  result := TNetEncoding.Base64.DecodeStringToBytes(value);
end;

class function TCryptAPI.SHA512(const Input: string): THexString;
var
  inText: string;
  HashWord: uint32;
  Xfer: Integer;
  A: string;
  StringHash: THash;
  CryptographicLibrary: TCryptographicLibrary;
begin
  CryptographicLibrary := TCryptographicLibrary.Create(nil);
  try
    StringHash := THash.Create(nil);
    try
      StringHash.CryptoLibrary := CryptographicLibrary;
      StringHash.HashId := 'native.hash.SHA-512';
      inText := Input;
      StringHash.HashString(inText, TEncoding.UTF8);
      A := '$';
      repeat
        HashWord := 0;
        Xfer := StringHash.HashOutputValue.Read(HashWord, SizeOf(HashWord));
        if Xfer = 0 then
          break;
        if A <> '$' then
          A := A + ' ';
        A := A + Format(Format('%%.%dx', [Xfer * 2]), [HashWord])
      until Xfer < sizeof(HashWord);
      result := AnsiLowerCase(A);
    finally
      StringHash.Free;
    end;
  finally
    CryptographicLibrary.Free;
  end;
end;

class function TCryptApi.SHA512(const Input: string; Salt: String): THexString;
begin
  Result := SHA512(Input + Salt);
end;

class function TCryptAPI.EncryptAES256(const Password: string; const Input: string): string;
var
  CryptographicLibrary: TCryptographicLibrary;
  Codec: TCodec;
begin
  CryptographicLibrary := TCryptographicLibrary.Create(nil);
  try
    Codec := TCodec.Create(nil);
    try
      Codec.CryptoLibrary := CryptographicLibrary;
      Codec.StreamCipherId := BlockCipher_ProgId;
      Codec.BlockCipherId := 'native.AES-256';
      Codec.ChainModeId := ChainIds[1];
      Codec.Password := Password;
      Codec.EncryptString(Input, result, TEncoding.UTF8);
    finally
      Codec.Free;
    end;
  finally
    CryptographicLibrary.Free;
  end;
end;

class function TCryptApi.Scramble(s: string): string;
var
  r: string;
  i: Integer;
  c: char;
  b: byte;
begin
  r := '';
  for i := 1 to length(s) do begin
    b := ord(s[i]);
    b := (b and $E0) + ((b and $1F) xor 5);
    c := chr(b);
    r := r + c;
  end;
  Result := r;
end;

class function TCryptAPI.DecryptAES256(const Password: string; const Input: string): string;
var
  CryptographicLibrary: TCryptographicLibrary;
  Codec: TCodec;
begin
  CryptographicLibrary := TCryptographicLibrary.Create(nil);
  try
    Codec := TCodec.Create(nil);
    try
      Codec.CryptoLibrary := CryptographicLibrary;
      Codec.StreamCipherId := BlockCipher_ProgId;
      Codec.BlockCipherId := 'native.AES-256';
      Codec.ChainModeId := ChainIds[1];
      Codec.Password := Password;
      Codec.DecryptString(result, Input, TEncoding.UTF8);
    finally
      Codec.Free;
    end;
  finally
    CryptographicLibrary.Free;
  end;
end;

end.
