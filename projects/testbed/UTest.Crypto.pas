{===============================================================================
  StdApp Components™

  Copyright © 2026-present tinyBigGAMES™ LLC
  All Rights Reserved.

  See LICENSE for license information

 -------------------------------------------------------------------------------

  StdApp.TestCrypto - Acceptance tests for StdApp.Crypto

  Verifies Blake2b-512 against RFC 7693 known-answer vectors, Ed25519
  against RFC 8032 test vectors 1-3 (with tamper rejection), and a full
  TMinisign keygen/save/load/sign/verify roundtrip with tamper detection.

  Dependencies: StdApp.Base, StdApp.TestCase, StdApp.Crypto
===============================================================================}

unit UTest.Crypto;

{$I StdApp.Defines.inc}

interface

uses
  System.SysUtils,
  System.IOUtils,
  Winapi.Windows,
  StdApp.Base,
  StdApp.TestCase,
  StdApp.Crypto;

type
  { TTestCrypto }
  TTestCrypto = class(TTestCase)
  private
    function DoHexToBytes(const AHex: string): TBytes;
    function DoBytesToHex(const ABytes: TBytes): string;
    procedure DoTestBlake2b();
    procedure DoTestEd25519();
    procedure DoTestMinisign();
  public
    constructor Create(); override;
  end;

implementation

{ TTestCrypto }

constructor TTestCrypto.Create();
begin
  inherited Create();
  Title := 'StdApp.Crypto';
  RegisterTest('Blake2b-512 vectors', DoTestBlake2b);
  RegisterTest('Ed25519 RFC 8032 vectors', DoTestEd25519);
  RegisterTest('Minisign roundtrip', DoTestMinisign);
end;

function TTestCrypto.DoHexToBytes(const AHex: string): TBytes;
var
  LIndex: Integer;
begin
  SetLength(Result, Length(AHex) div 2);
  for LIndex := 0 to High(Result) do
    Result[LIndex] := StrToInt('$' + AHex.Substring(LIndex * 2, 2));
end;

function TTestCrypto.DoBytesToHex(const ABytes: TBytes): string;
var
  LIndex: Integer;
begin
  Result := '';
  for LIndex := 0 to High(ABytes) do
    Result := Result + IntToHex(ABytes[LIndex], 2);
  Result := Result.ToLower();
end;

procedure TTestCrypto.DoTestBlake2b();
begin
  Section('Empty input');
  Check(DoBytesToHex(TBlake2b.HashBytes(nil)) =
    '786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419' +
    'd25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce',
    'Blake2b-512("")');

  Section('ASCII "abc"');
  Check(DoBytesToHex(TBlake2b.HashBytes(TEncoding.ASCII.GetBytes('abc'))) =
    'ba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d1' +
    '7d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923',
    'Blake2b-512("abc")');
end;

procedure TTestCrypto.DoTestEd25519();
var
  LSeed: TBytes;
  LPub: TBytes;
  LSec: TBytes;
  LMsg: TBytes;
  LSig: TBytes;
begin
  Section('RFC 8032 TEST 1 (empty message)');
  LSeed := DoHexToBytes('9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60');
  TEd25519.GenerateKeyPair(LSeed, LPub, LSec);
  Check(DoBytesToHex(LPub) = 'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
    'public key');
  LMsg := nil;
  LSig := TEd25519.Sign(LMsg, LSec);
  Check(DoBytesToHex(LSig) =
    'e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e06522490155' +
    '5fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b',
    'signature');
  Check(TEd25519.Verify(LMsg, LSig, LPub), 'verify');

  Section('RFC 8032 TEST 2 (one byte 0x72)');
  LSeed := DoHexToBytes('4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb');
  TEd25519.GenerateKeyPair(LSeed, LPub, LSec);
  Check(DoBytesToHex(LPub) = '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c',
    'public key');
  LMsg := DoHexToBytes('72');
  LSig := TEd25519.Sign(LMsg, LSec);
  Check(DoBytesToHex(LSig) =
    '92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da' +
    '085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00',
    'signature');
  Check(TEd25519.Verify(LMsg, LSig, LPub), 'verify');

  Section('RFC 8032 TEST 3 (two bytes 0xaf82)');
  LSeed := DoHexToBytes('c5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7');
  TEd25519.GenerateKeyPair(LSeed, LPub, LSec);
  Check(DoBytesToHex(LPub) = 'fc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025',
    'public key');
  LMsg := DoHexToBytes('af82');
  LSig := TEd25519.Sign(LMsg, LSec);
  Check(DoBytesToHex(LSig) =
    '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac' +
    '18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a',
    'signature');
  Check(TEd25519.Verify(LMsg, LSig, LPub), 'verify');

  Section('Tamper detection');
  LSig[0] := LSig[0] xor 1;
  Check(not TEd25519.Verify(LMsg, LSig, LPub), 'corrupted signature rejected');
end;

procedure TTestCrypto.DoTestMinisign();
var
  LMini: TMinisign;
  LPair: TMiniKeyPair;
  LLoaded: TMiniKeyPair;
  LPubOnly: TMiniKeyPair;
  LDir: string;
  LDataFile: string;
  LKeyFile: string;
  LPubFile: string;
begin
  LDir := TPath.Combine(TPath.GetTempPath(), 'apppacker_test_' + IntToStr(GetCurrentProcessId()));
  TDirectory.CreateDirectory(LDir);
  LMini := TMinisign.Create();
  try
    LDataFile := TPath.Combine(LDir, 'payload.bin');
    LKeyFile := TPath.Combine(LDir, 'test.key');
    LPubFile := TPath.Combine(LDir, 'test.pub');
    TFile.WriteAllText(LDataFile, 'The quick brown fox jumps over the lazy dog. 0123456789');

    Section('Key generation and persistence');
    Check(LMini.GenerateKeyPair(LPair), 'generate');
    Check(LMini.SaveSecretKey(LKeyFile, LPair), 'save secret');
    Check(LMini.SavePublicKey(LPubFile, LPair), 'save public');
    Check(LMini.LoadSecretKey(LKeyFile, LLoaded), 'load secret');
    Check(LMini.KeyIdString(LLoaded) = LMini.KeyIdString(LPair), 'key id roundtrip');
    Check(LMini.LoadPublicKey(LPubFile, LPubOnly), 'load public');
    Check(LMini.PublicKeyString(LPubOnly) = LMini.PublicKeyString(LPair), 'public key roundtrip');

    Section('Sign and verify');
    Check(LMini.SignFile(LDataFile, LLoaded, 'test trusted comment'), 'sign');
    Check(TFile.Exists(LDataFile + '.minisig'), '.minisig written');
    Check(LMini.VerifyFile(LDataFile, LPubOnly), 'verify (public key only)');

    Section('Tamper detection');
    TFile.AppendAllText(LDataFile, 'X');
    Check(not LMini.VerifyFile(LDataFile, LPubOnly), 'modified file rejected');
    LMini.GetErrors().Clear();
  finally
    LMini.Free();
    TDirectory.Delete(LDir, True);
  end;
end;

end.
