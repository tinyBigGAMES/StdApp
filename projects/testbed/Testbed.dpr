{===============================================================================
  StdApp Components™

  Copyright © 2026-present tinyBigGAMES™ LLC
  All Rights Reserved.

  See LICENSE for license information
===============================================================================}

program Testbed;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  StdApp.VMM,
  System.SysUtils,
  UTestbed in 'UTestbed.pas',
  StdApp.Base in '..\..\src\StdApp.Base.pas',
  StdApp.Console.Menu in '..\..\src\StdApp.Console.Menu.pas',
  StdApp.Console in '..\..\src\StdApp.Console.pas',
  StdApp.DllLoader in '..\..\src\StdApp.DllLoader.pas',
  StdApp.IATHook in '..\..\src\StdApp.IATHook.pas',
  StdApp.JSON in '..\..\src\StdApp.JSON.pas',
  StdApp.LibTCC in '..\..\src\StdApp.LibTCC.pas',
  StdApp.ResCompiler in '..\..\src\StdApp.ResCompiler.pas',
  StdApp.Resources in '..\..\src\StdApp.Resources.pas',
  StdApp.TestCase in '..\..\src\StdApp.TestCase.pas',
  StdApp.TestDemo in '..\..\src\StdApp.TestDemo.pas',
  StdApp.Utils in '..\..\src\StdApp.Utils.pas',
  StdApp.VFS in '..\..\src\StdApp.VFS.pas',
  StdApp.VirtualMemory in '..\..\src\StdApp.VirtualMemory.pas',
  StdApp.ZipVFS in '..\..\src\StdApp.ZipVFS.pas',
  StdApp.CImporter in '..\..\src\StdApp.CImporter.pas',
  UTest.VFS in 'UTest.VFS.pas';

begin
  RunTestbed();
end.
