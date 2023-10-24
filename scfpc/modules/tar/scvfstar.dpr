{
  tar module for VFS in Seksi Commander
  GNU GPL 2

  Radek Cervinka, radek.cervinka@centrum.cz
}


library scvfstar;


uses
  uVFStar,
  uVFStypes in '../uVFStypes.pas',
  utarlib in 'utarlib.pas';

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
