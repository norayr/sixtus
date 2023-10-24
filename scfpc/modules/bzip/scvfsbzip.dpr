{
  tar module for VFS in Seksi Commander
  GNU GPL 2

  Radek Cervinka, radek.cervinka@centrum.cz
}


library scvfsbzip;


uses
  uBzipLib in 'uBzipLib.pas',
  uVFSbzip in 'uVFSbzip.pas',
  BZipLib in 'BZipLib.pas',
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
