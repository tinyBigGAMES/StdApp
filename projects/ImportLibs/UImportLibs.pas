{===============================================================================
  StdApp Components™

  Copyright © 2026-present tinyBigGAMES™ LLC
  All Rights Reserved.

  See LICENSE for license information
===============================================================================}

unit UImportLibs;

interface

procedure RunImportLibs();

implementation

uses
  System.SysUtils,
  StdApp.Base,
  StdApp.Utils,
  StdApp.Console,
  StdApp.CImporter;

procedure ImportRaylib(const ABindingMode: TBindingMode);
var
  LImporter: TCImporter;
begin
  TConsole.PrintLn('=== Import raylib.h ===');
  TConsole.PrintLn('');

  LImporter := TCImporter.Create();
  try
    LImporter.SetStatusCallback(
      procedure(const AText: string; const AUserData: Pointer)
      begin
        TConsole.PrintLn(AText);
      end
    );
    LImporter.SetSavePreprocessed(False);

    LImporter.SetBindingMode(ABindingMode);

    case ABindingMode of
      bmStatic        : LImporter.SetModuleName('raylib_static');
      bmDynamic       : LImporter.SetModuleName('raylib_dynamic');
      bmDynamicDelayed: LImporter.SetModuleName('raylib_dynamic_delayed');
      bmDynamicCustom : LImporter.SetModuleName('raylib_dynamc_custom');
      bmStaticVpk     : LImporter.SetModuleName('raylib_static_vpk');
    end;

    LImporter.SetDllName('raylib');

    LImporter.SetOutputPath('..\imports');
    LImporter.SetDllPath('..\libs\raylib\bin\raylib.dll');
    LImporter.AddIncludePath('..\libs\raylib\include');
    LImporter.AddSourcePath('..\libs\raylib\include');
    LImporter.AddExcludedType('va_list');
    LImporter.SetHeader('..\libs\raylib\include\raylib.h');
    LImporter.SaveToConfig('..\libs\raylib\raylib.json');
    if LImporter.Process() then
      TConsole.PrintLn(COLOR_CYAN + 'Success')
    else
      TConsole.PrintLn(COLOR_RED + 'Failed: %s', [LImporter.GetLastError()]);
  finally
    LImporter.Free();
  end;

  TConsole.PrintLn('');
  TConsole.PrintLn('=== Done ===');
end;

procedure RunImportLibs();
begin
  try
    ImportRaylib(bmStatic);
    ImportRaylib(bmDynamic);
    ImportRaylib(bmDynamicDelayed);
    ImportRaylib(bmDynamicCustom);
    ImportRaylib(bmStaticVpk);
  except
    on E: Exception do
    begin
      TConsole.PrintLn('');
      TConsole.PrintLn(COLOR_RED + 'EXCEPTION: %s', [E.Message]);
    end;
  end;

  if TUtils.RunFromIDE() then
    TConsole.Pause();
end;

end.
