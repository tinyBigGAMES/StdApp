{===============================================================================
  StdApp Components™

  Copyright © 2026-present tinyBigGAMES™ LLC
  All Rights Reserved.

  See LICENSE for license information
===============================================================================}

program AppPacker;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  StdApp.Packer.CLI;

begin
  RunPackerCLI();
end.
