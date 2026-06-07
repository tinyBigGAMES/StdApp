{===============================================================================
  StdApp Components™

  Copyright © 2026-present tinyBigGAMES™ LLC
  All Rights Reserved.

  See LICENSE for license information
===============================================================================}

unit UTestbed;

interface

procedure RunTestbed();

implementation

uses
  System.SysUtils,
  StdApp.Utils,
  StdApp.Console,
  StdApp.Console.Menu,
  UTest.VFS;

procedure Menu();
var
  LMenu: TConsoleMenu;

begin
  LMenu := TConsoleMenu.Create();
  try
    LMenu.Title('StdApp Testbed');
    LMenu.AddTestDemo(TTestVFS);
    LMenu.Run();
  finally
    LMenu.Free();
  end;
end;

procedure RunTestbed();
begin
  try
    Menu();
  except
    on E: Exception do
    begin
      TConsole.PrintLn('');
      TConsole.PrintLn(COLOR_RED + 'EXCEPTION: %s', [E.Message]);
    end;
  end;
end;

end.
