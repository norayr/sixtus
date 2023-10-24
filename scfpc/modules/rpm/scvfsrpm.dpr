{
  rpm module for VFS in Seksi Commander
  GNU GPL 2

  Radek Cervinka, radek.cervinka@centrum.cz
}


library scvfsgzip;


uses
  uVFStypes in '../uVFStypes.pas',
  uRPMLib in 'uRPMLib.pas',
  uVFSrpm in 'uVFSrpm.pas',
  uRPMDef in 'uRPMDef.pas',
  uRpmIO in 'uRpmIO.pas';

{$LIBVERSION '1.0'}

exports
  VFSInit,
  VFSCaps,
  VFSDestroy,
  VFSGetExts,
  VFSOpen,
  VFSClose,
  VFSMkDir,
  VFSRmDir,
  VFSCopyOut,
  VFSCopyIn,
  VFSList,
  VFSRename,
  VFSRun,
  VFSDelete;

begin
end.
