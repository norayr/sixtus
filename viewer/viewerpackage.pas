{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit viewerpackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  viewercontrol, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('viewercontrol', @viewercontrol.Register);
end;

initialization
  RegisterPackage('viewerpackage', @Register);
end.
