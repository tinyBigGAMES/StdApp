{===============================================================================
  StdApp Components™

  Copyright © 2026-present tinyBigGAMES™ LLC
  All Rights Reserved.

  See LICENSE for license information
===============================================================================}

program ImportLibs;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  StdApp.VMM,
  System.SysUtils,
  UImportLibs in 'UImportLibs.pas';

begin
  RunImportLibs();
end.
