{
  tar module for VFS in Seksi Commander
  GNU GPL 2

  Radek Cervinka, radek.cervinka@centrum.cz
}


library scvfsgzip;


uses
  uGzipLib in 'uGzipLib.pas',
  uVFSgzip in 'uVFSgzip.pas',
  ZLib in 'ZLib.pas',
  uVFStypes in '../uVFStypes.pas';

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
